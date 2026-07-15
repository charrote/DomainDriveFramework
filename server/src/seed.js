/**
 * 数据库初始数据 Seeder
 * 创建管理员用户 + 基础组织架构
 */

const bcrypt = require('bcryptjs')
const prisma = require('./prisma/client')

async function main() {
  console.log('[Seed] 开始初始化数据...')

  // ---- 管理员用户 ----
  const adminHash = await bcrypt.hash('admin123', 10)
  const admin = await prisma.user.upsert({
    where: { username: 'admin' },
    update: {},
    create: {
      username: 'admin',
      password_hash: adminHash,
      real_name: '系统管理员',
      role: 'admin',
      status: 'active',
    },
  })
  console.log(`[Seed] 管理员用户: ${admin.username} (密码: admin123)`)

  // ---- 班组长 ----
  const supervisorHash = await bcrypt.hash('123456', 10)
  await prisma.user.upsert({
    where: { username: 'supervisor' },
    update: {},
    create: {
      username: 'supervisor',
      password_hash: supervisorHash,
      real_name: '张班组',
      status: 'active',
      role: 'supervisor',
    },
  })

  // ---- 操作员 ----
  const operatorHash = await bcrypt.hash('123456', 10)
  await prisma.user.upsert({
    where: { username: 'operator' },
    update: {},
    create: {
      username: 'operator',
      password_hash: operatorHash,
      real_name: '李操作',
      role: 'operator',
      status: 'active',
    },
  })

  // ---- 质检员 ----
  const inspectorHash = await bcrypt.hash('123456', 10)
  await prisma.user.upsert({
    where: { username: 'inspector' },
    update: {},
    create: {
      username: 'inspector',
      password_hash: inspectorHash,
      real_name: '王质检',
      role: 'quality_inspector',
      status: 'active',
    },
  })

  console.log('[Seed] 用户初始化完成')

  // ---- 工厂/车间/产线 ----
  await prisma.factory.upsert({
    where: { id: 1 },
    update: {},
    create: { factory_code: 'DG-001', factory_name: '东莞精密五金厂', status: 'active' },
  })

  await prisma.workshop.upsert({
    where: { id: 1 },
    update: {},
    create: { workshop_code: 'WS-CNC', workshop_name: 'CNC 加工车间', factory_id: 1, status: 'active' },
  })

  await prisma.productionLine.upsert({
    where: { id: 1 },
    update: {},
    create: { line_code: 'LINE-A', line_name: 'A 线', workshop_id: 1, status: 'active' },
  })

  console.log('[Seed] 组织架构初始化完成')
  console.log('[Seed] ✅ 数据初始化完成')
}

main()
  .catch((e) => {
    console.error('[Seed] 失败:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
