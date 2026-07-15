/**
 * Express 应用主配置
 */

const express = require('express')
const cors = require('cors')
const helmet = require('helmet')
const morgan = require('morgan')

const authRoutes = require('./routes/auth')
const entityRoutes = require('./routes/index')
const { authenticate } = require('./middleware/auth')

const app = express()

// ---- 全局中间件 ----
app.use(helmet())
app.use(cors())
app.use(morgan('dev'))
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true }))

// ---- 健康检查 ----
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

// ---- 公开路由 ----
app.use('/api/auth', authRoutes)

// ---- 受保护路由（需要认证） ----
app.use('/api', authenticate, entityRoutes)

// ---- 404 ----
app.use((req, res) => {
  res.status(404).json({ error: `路由不存在: ${req.method} ${req.path}` })
})

// ---- 全局错误处理 ----
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err)
  res.status(500).json({ error: '服务器内部错误' })
})

module.exports = app
