/**
 * CRUD 路由注册
 * 自动从 generated/backend/routes/ 加载所有实体路由
 */

const express = require('express')
const fs = require('fs')
const path = require('path')

const router = express.Router()

// 获取所有 .routes.js 文件
const routeFiles = fs.readdirSync(__dirname)
  .filter(f => f.endsWith('.routes.js') && f !== 'auth.routes.js' && f !== 'index.js')

for (const file of routeFiles) {
  const routeModule = require(path.join(__dirname, file))
  
  // 生成路由路径: work-order.routes.js → /work-order
  const basePath = '/' + file.replace(/\.routes\.js$/, '')
  
  router.use(basePath, routeModule)
}

console.log(`[Routes] 已注册 ${routeFiles.length} 个实体 CRUD 路由`)

module.exports = router
