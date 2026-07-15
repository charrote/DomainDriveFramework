/**
 * DDF 模型编译器
 * 
 * 职责：读取 domain/ 下所有 DSL YAML 文件，
 *       构建中间表示(IR)，验证引用完整性
 * 
 * 用法：
 *   const ir = await compile()
 *   console.log(JSON.stringify(ir, null, 2))
 */

import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import yaml from 'js-yaml'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const DOMAIN_DIR = path.resolve(__dirname, '../../domain')

/**
 * 加载并编译所有 DSL 文件
 */
export async function compile(options = {}) {
  const {
    coreDir = path.join(DOMAIN_DIR, 'base/core'),
    workflowDir = path.join(DOMAIN_DIR, 'base/workflows'),
    rolesFile = path.join(DOMAIN_DIR, 'base/permissions/roles.yaml'),
  } = options

  // 1. 加载所有实体文件
  const entities = await loadEntities(coreDir)
  
  // 2. 加载工作流
  const workflows = await loadWorkflows(workflowDir)
  
  // 3. 加载角色
  const roles = await loadRoles(rolesFile)

  // 4. 构建 IR
  const ir = {
    version: '1.0.0',
    entities: {},
    workflows: {},
    roles,
    stats: {
      entityCount: 0,
      fieldCount: 0,
      relationCount: 0,
      workflowCount: workflows.length,
      roleCount: roles.length,
    },
    errors: [],
  }

  // 注册实体
  for (const file of entities) {
    for (const entity of file.data.entities) {
      const domain = file.data.domain
      ir.entities[entity.name] = {
        name: entity.name,
        source: path.basename(file.path),
        domain,
        label: entity.label || entity.name,
        table: entity.table || toSnake(entity.name),
        description: entity.description || '',
        fields: entity.fields || [],
        relations: entity.relations || [],
        listView: entity.list_view || null,
        permissions: entity.permissions || null,
      }
      ir.stats.entityCount++
      ir.stats.fieldCount += (entity.fields || []).length
      ir.stats.relationCount += (entity.relations || []).length
    }
  }

  // 注册工作流
  for (const wf of workflows) {
    ir.workflows[wf.data.name] = {
      label: wf.data.label || wf.data.name,
      entity: wf.data.entity,
      field: wf.data.field,
      states: wf.data.states,
      transitions: wf.data.transitions,
    }
  }

  // 5. 交叉验证引用完整性
  validateReferences(ir)

  return ir
}

/**
 * 加载 core/ 下所有实体 YAML 文件
 */
async function loadEntities(dir) {
  const results = []
  const files = fs.readdirSync(dir).filter(f => f.endsWith('.yaml'))
  
  for (const file of files) {
    const content = fs.readFileSync(path.join(dir, file), 'utf-8')
    const data = yaml.load(content)
    
    if (data && data.domain && data.entities) {
      results.push({ path: path.join(dir, file), data })
    }
  }
  
  return results.sort((a, b) => a.data.domain.localeCompare(b.data.domain))
}

/**
 * 加载 workflows/ 下所有工作流文件
 */
async function loadWorkflows(dir) {
  if (!fs.existsSync(dir)) return []
  
  const results = []
  const files = fs.readdirSync(dir).filter(f => f.endsWith('.yaml'))
  
  for (const file of files) {
    const content = fs.readFileSync(path.join(dir, file), 'utf-8')
    const data = yaml.load(content)
    
    if (data && data.name && data.states) {
      results.push({ path: path.join(dir, file), data })
    }
  }
  
  return results
}

/**
 * 加载角色权限文件
 */
async function loadRoles(file) {
  if (!fs.existsSync(file)) return []
  
  const content = fs.readFileSync(file, 'utf-8')
  const data = yaml.load(content)
  
  return data?.roles || []
}

/**
 * 验证实体引用完整性
 */
function validateReferences(ir) {
  const entityNames = new Set(Object.keys(ir.entities))
  
  for (const [name, entity] of Object.entries(ir.entities)) {
    // 检查 relation 字段引用的目标实体是否存在
    for (const field of entity.fields) {
      if (field.type === 'relation' && field.relation) {
        if (!entityNames.has(field.relation)) {
          ir.errors.push({
            type: 'missing_reference',
            entity: name,
            field: field.name,
            message: `关系字段 "${field.name}" 引用了不存在的实体 "${field.relation}"`,
          })
        }
      }
    }
    
    // 检查 relation 定义中的目标实体
    for (const rel of entity.relations) {
      if (!entityNames.has(rel.target)) {
        ir.errors.push({
          type: 'missing_reference',
          entity: name,
          relation: rel.name,
          message: `关系 "${rel.name}" 引用了不存在的实体 "${rel.target}"`,
        })
      }
    }
  }
}

/**
 * 辅助：PascalCase → snake_case
 */
function toSnake(str) {
  return str.replace(/([A-Z])/g, '_$1').toLowerCase().replace(/^_/, '')
}

// CLI 入口
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const ir = await compile()
  console.log(JSON.stringify(ir, null, 2))
}
