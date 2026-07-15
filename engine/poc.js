/**
 * Phase 4 — Code Generation Engine Proof of Concept
 * 
 * Usage: node engine/poc.js
 */

import { compile } from './compiler/index.js'

const ir = await compile()

console.log('='.repeat(60))
console.log('  DDF Code Generation Engine — POC')
console.log('='.repeat(60))
console.log()

console.log(`  📊 Stats:`)
console.log(`     Entities:    ${ir.stats.entityCount}`)
console.log(`     Fields:      ${ir.stats.fieldCount}`)
console.log(`     Relations:   ${ir.stats.relationCount}`)
console.log(`     Workflows:   ${ir.stats.workflowCount}`)
console.log(`     Roles:       ${ir.stats.roleCount}`)
console.log()

if (ir.errors.length > 0) {
  console.log(`  ⚠️  Validation Errors:`)
  for (const err of ir.errors) {
    console.log(`     ❌ ${err.message}`)
  }
  console.log()
} else {
  console.log(`  ✅ All references valid — no errors`)
  console.log()
}

console.log('  📋 Entities:')
for (const [name, entity] of Object.entries(ir.entities)) {
  const fieldTypes = [...new Set(entity.fields.map(f => f.type))]
  const relCount = entity.relations.length
  console.log(`     ${name.padEnd(20)} fields=${String(entity.fields.length).padEnd(2)} types=[${fieldTypes.join(',')}] relations=${relCount}`)
}
console.log()

console.log('  🔄 Workflows:')
for (const [name, wf] of Object.entries(ir.workflows)) {
  const stateNames = Object.keys(wf.states).join(' → ')
  console.log(`     ${name.padEnd(20)} states=[${stateNames}]`)
}
console.log()

console.log('  👤 Roles:')
for (const role of ir.roles) {
  console.log(`     ${role.name.padEnd(20)} ${role.label}`)
}
console.log()

// Generate a stats report for the project plan
console.log('='.repeat(60))
console.log('  IR 结构可用，已准备好驱动模板引擎')
console.log('='.repeat(60))
