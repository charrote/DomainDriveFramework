/**
 * DDF Server — Entry Point
 */

require('dotenv').config()

const app = require('./app')
const prisma = require('./prisma/client')

const PORT = process.env.PORT || 3000

async function main() {
  // 测试数据库连接
  try {
    await prisma.$connect()
    console.log('[DB] 数据库连接成功')
  } catch (err) {
    console.error('[DB] 数据库连接失败:', err.message)
    process.exit(1)
  }

  app.listen(PORT, () => {
    console.log(`[Server] DDF MES API 已启动 → http://localhost:${PORT}`)
    console.log(`[Server] 健康检查 → http://localhost:${PORT}/api/health`)
  })
}

main().catch((err) => {
  console.error('启动失败:', err)
  process.exit(1)
})
