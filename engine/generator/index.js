/**
 * DDF 代码生成器
 * 
 * 将 IR → 模板 → 输出文件
 * 
 * 用法：
 *   node generator/index.js --out ../generated
 */

import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import ejs from 'ejs'
import { compile } from '../compiler/index.js'
import * as h from './helpers.js'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const TEMPLATE_DIR = path.resolve(__dirname, '../templates')

/**
 * 生成所有代码
 */
export async function generate(options = {}) {
  const {
    outDir = path.resolve(__dirname, '../../generated'),
    entities = null, // null = all entities
  } = options

  // 1. 编译 DSL → IR
  const ir = await compile()

  if (ir.errors.length > 0) {
    console.error('❌ IR 存在验证错误，中止生成:')
    ir.errors.forEach(e => console.error(`   - ${e.message}`))
    return { ir, files: [], errors: ir.errors }
  }

  // 2. 确定要生成的实体列表
  const entityList = entities
    ? entities.map(name => ir.entities[name]).filter(Boolean)
    : Object.values(ir.entities)

  if (entityList.length === 0) {
    console.error('❌ 没有找到可生成的实体')
    return { ir, files: [], errors: ['No entities to generate'] }
  }

  // 3. 清理输出目录
  if (fs.existsSync(outDir)) {
    fs.rmSync(outDir, { recursive: true })
  }

  const generatedFiles = []

  // 4. 生成实体代码
  for (const entity of entityList) {
    generatedFiles.push(
      ...await generateEntity(entity, ir, outDir)
    )
  }

  // 5. 生成 DB Migration（单个合并文件）
  const migrationContent = await renderTemplate('backend/sql-migration.ejs', {
    entities: entityList,
    ir,
    ...h,
  })
  const migrationPath = path.join(outDir, 'backend/migrations', '0001-initial.sql')
  writeFile(migrationPath, migrationContent)
  generatedFiles.push(migrationPath)

  // 6. 生成 OpenAPI 规范（单个合并文件）
  const openapiContent = await renderTemplate('backend/openapi-spec.ejs', {
    entities: entityList,
    ir,
    ...h,
  })
  const openapiPath = path.join(outDir, 'backend/docs', 'openapi.json')
  writeFile(openapiPath, openapiContent)
  generatedFiles.push(openapiPath)

  // 7. 生成汇总文件
  generatedFiles.push(...await generateSummary(entityList, ir, outDir))

  console.log(`✅ 生成完成: ${generatedFiles.length} 个文件 → ${outDir}`)
  return { ir, files: generatedFiles, errors: [] }
}

/**
 * 为单个实体生成代码
 */
async function generateEntity(entity, ir, outDir) {
  const files = []
  const renderContext = {
    entity,
    ir,
    ...h,
  }

  // --- 后端 Code ---
  // Prisma Schema
  const prismaContent = await renderTemplate('backend/prisma-schema.ejs', renderContext)
  const prismaPath = path.join(outDir, 'backend/prisma', `schema-${h.toKebab(entity.name)}.prisma`)
  writeFile(prismaPath, prismaContent)
  files.push(prismaPath)

  // Express Router
  const routeContent = await renderTemplate('backend/express-router.ejs', renderContext)
  const routePath = path.join(outDir, 'backend/routes', `${h.toKebab(entity.name)}.routes.js`)
  writeFile(routePath, routeContent)
  files.push(routePath)

  // --- 前端 Code ---
  // List page
  const listContent = await renderTemplate('frontend/list-page.ejs', renderContext)
  const listPath = path.join(outDir, 'frontend/views', `${h.toKebab(entity.name)}-list.vue`)
  writeFile(listPath, listContent)
  files.push(listPath)

  // Form page
  const formContent = await renderTemplate('frontend/form-page.ejs', renderContext)
  const formPath = path.join(outDir, 'frontend/views', `${h.toKebab(entity.name)}-form.vue`)
  writeFile(formPath, formContent)
  files.push(formPath)

  // API 服务层
  const serviceContent = await renderTemplate('frontend/api-service.ejs', renderContext)
  const servicePath = path.join(outDir, 'frontend/api', `${h.toKebab(entity.name)}.js`)
  writeFile(servicePath, serviceContent)
  files.push(servicePath)

  return files
}

/**
 * 生成汇总文件
 */
async function generateSummary(entityList, ir, outDir) {
  const files = []
  
  // 生成 index routes
  const indexContent = entityList.map(e => {
    const kebab = h.toKebab(e.name)
    return `const ${h.toCamel(e.name)}Router = require('./${kebab}.routes');`
  }).join('\n') + '\n\nmodule.exports = { ' + entityList.map(e => `${h.toCamel(e.name)}Router`).join(', ') + ' };'
  
  writeFile(path.join(outDir, 'backend/routes/index.js'), indexContent)
  files.push(path.join(outDir, 'backend/routes/index.js'))
  
  return files
}

/**
 * 渲染 EJS 模板
 */
async function renderTemplate(templatePath, context) {
  const fullPath = path.join(TEMPLATE_DIR, templatePath)
  const template = fs.readFileSync(fullPath, 'utf-8')
  return ejs.render(template, context, { filename: fullPath })
}

/**
 * 写入文件（自动创建目录）
 */
function writeFile(filePath, content) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true })
  fs.writeFileSync(filePath, content, 'utf-8')
}

// CLI 入口
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const args = process.argv.slice(2)
  const outDir = args.includes('--out') 
    ? args[args.indexOf('--out') + 1] 
    : undefined
  const entities = args.includes('--entities')
    ? args[args.indexOf('--entities') + 1]?.split(',')
    : null

  const result = await generate({ outDir, entities })
  console.log(JSON.stringify({ fileCount: result.files.length, errors: result.errors.length }, null, 2))
}
