/**
 * JWT 认证中间件
 */

const jwt = require('jsonwebtoken')
const prisma = require('../prisma/client')

const JWT_SECRET = process.env.JWT_SECRET || 'ddf-mes-secret-key'

/**
 * 验证 Token — 保护需要登录的路由
 */
function authenticate(req, res, next) {
  const header = req.headers.authorization
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ error: '未提供认证令牌' })
  }

  const token = header.split(' ')[1]

  try {
    const decoded = jwt.verify(token, JWT_SECRET)
    req.user = decoded
    next()
  } catch (err) {
    return res.status(401).json({ error: '认证令牌无效或已过期' })
  }
}

/**
 * 角色验证中间件工厂
 * @param  {...string} roles 允许的角色列表
 */
function authorize(...roles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: '未认证' })
    }
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: '权限不足' })
    }
    next()
  }
}

/**
 * 生成 JWT Token
 */
function generateToken(user) {
  return jwt.sign(
    { id: user.id, username: user.username, role: user.role },
    JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' },
  )
}

module.exports = { authenticate, authorize, generateToken }
