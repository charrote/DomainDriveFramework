/**
 * 生成器工具函数
 */

/**
 * DDF 类型 → Prisma/数据库类型
 */
export function ddfTypeToPrisma(type) {
  const map = {
    integer:    'Int',
    string:     'String',
    float:      'Float',
    boolean:    'Boolean',
    date:       'DateTime',
    datetime:   'DateTime',
    enum:       'String',
    relation:   'Int',
    text:       'String',
    json:       'Json',
  }
  return map[type] || 'String'
}

/**
 * DDF 类型 → TypeScript 类型
 */
export function ddfTypeToTS(type) {
  const map = {
    integer:    'number',
    string:     'string',
    float:      'number',
    boolean:    'boolean',
    date:       'string',
    datetime:   'string',
    enum:       'string',
    relation:   'number',
    text:       'string',
    json:       'Record<string, unknown>',
  }
  return map[type] || 'string'
}

/**
 * DDF 类型 → Vue 输入组件类型
 */
export function ddfTypeToInputType(type) {
  const map = {
    integer:    'number',
    string:     'text',
    float:      'number',
    boolean:    'checkbox',
    date:       'date',
    datetime:   'datetime-local',
    enum:       'select',
    relation:   'select-remote',
  }
  return map[type] || 'text'
}

/**
 * 是否可排序的字段类型
 */
export function isSortable(type) {
  return ['integer', 'string', 'float', 'date', 'datetime'].includes(type)
}

/**
 * 是否可搜索的字段类型
 */
export function isSearchable(type) {
  return ['string', 'text', 'enum'].includes(type)
}

/**
 * PascalCase 转 kebab-case
 * 正确处理连续大写：BOMItem → bom-item, ProductBOM → product-bom
 */
export function toKebab(str) {
  return str
    .replace(/([A-Z]+)([A-Z][a-z])/g, '$1-$2')   // BOMItem → BOM-Item
    .replace(/([a-z0-9])([A-Z])/g, '$1-$2')        // WorkOrder → Work-Order
    .replace(/([a-z])([0-9])/g, '$1-$2')            // 处理数字边界
    .toLowerCase()
}

/**
 * PascalCase 转 camelCase
 */
export function toCamel(str) {
  return str.charAt(0).toLowerCase() + str.slice(1)
}

/**
 * 获取实体展示字段（第一个 string 字段或 name 字段）
 */
export function getDisplayField(fields) {
  const nameField = fields.find(f => f.name === 'name' && f.type === 'string')
  if (nameField) return nameField
  return fields.find(f => f.type === 'string' && f.name !== 'id' && f.name !== 'code')
}

/**
 * 获取列表页显示的字段（过滤掉隐藏字段）
 */
export function getListFields(entity) {
  return entity.fields.filter(f => {
    // 跳过大文本字段
    if (f.type === 'text') return false
    // 默认不显示 relation ID 字段（会显示关联名称）
    if (f.type === 'relation' && f.name.endsWith('_id')) return false
    return true
  })
}

/**
 * 获取表单可编辑字段（排除 ID 和审计字段）
 */
export function getFormFields(entity) {
  return entity.fields.filter(f => {
    if (f.name === 'id') return false
    if (['created_by', 'created_at', 'updated_at'].includes(f.name)) return false
    return true
  })
}

/**
 * 渲染表单字段（根据字段类型生成 Vue 模板代码）
 */
export function renderFormField(field) {
  const name = field.name
  
  switch (field.type) {
    case 'boolean':
      return `<input type="checkbox" v-model="form.${name}" class="form-input" />`
    case 'enum':
      return `<select v-model="form.${name}" class="form-input">
        <option value="">请选择</option>
        <option v-for="opt in ${JSON.stringify(field.enumOptions || [field.enum])}" :key="opt" :value="opt">{{ opt }}</option>
      </select>`
    case 'date':
      return `<input type="date" v-model="form.${name}" class="form-input" />`
    case 'datetime':
      return `<input type="datetime-local" v-model="form.${name}" class="form-input" />`
    case 'text':
      return `<textarea v-model="form.${name}" class="form-input" rows="3"></textarea>`
    case 'integer':
    case 'float':
      return `<input type="number" v-model.number="form.${name}" class="form-input" step="${field.type === 'float' ? '0.01' : '1'}" />`
    case 'relation':
      return `<input type="number" v-model.number="form.${name}" class="form-input" placeholder="${field.relation || ''}" />`
    default:
      return `<input type="text" v-model="form.${name}" class="form-input" />`
  }
}

/**
 * DDF 类型 → OpenAPI 类型
 */
export function openapiType(type) {
  const map = {
    integer:    'integer',
    string:     'string',
    float:      'number',
    boolean:    'boolean',
    date:       'string',
    datetime:   'string',
    enum:       'string',
    relation:   'integer',
    text:       'string',
  }
  return map[type] || 'string'
}

/**
 * DDF 类型 → SQL 列类型
 */
export function ddfTypeToSQL(type, opts = {}) {
  const map = {
    integer:    'INT',
    string:     opts.enum ? `VARCHAR(50)` : 'VARCHAR(255)',
    float:      'DECIMAL(12,4)',
    boolean:    'BOOLEAN',
    date:       'DATE',
    datetime:   'TIMESTAMP',
    enum:       'VARCHAR(50)',
    relation:   'INT',
    text:       'TEXT',
    json:       'JSON',
  }
  return map[type] || 'VARCHAR(255)'
}

/**
 * 获取 SQL 默认值表达式
 */
export function sqlDefaultValue(field) {
  if (field.required === false) return 'DEFAULT NULL'
  switch (field.type) {
    case 'boolean': return 'DEFAULT FALSE'
    case 'integer':
    case 'float': return 'DEFAULT 0'
    case 'datetime': return 'DEFAULT CURRENT_TIMESTAMP'
    default: return 'NOT NULL'
  }
  return 'NOT NULL'
}

/**
 * 获取索引类型建议
 */
export function suggestIndexes(fields) {
  const indexes = []
  for (const f of fields) {
    if (f.type === 'relation') {
      indexes.push({ column: f.name, type: 'INDEX', reason: 'foreign_key' })
    }
    if (f.type === 'enum' || f.name === 'status') {
      indexes.push({ column: f.name, type: 'INDEX', reason: 'filter' })
    }
    // 常见业务查询字段
    if (['code', 'code', 'order_no', 'product_code', 'serial_no'].includes(f.name)) {
      indexes.push({ column: f.name, type: 'UNIQUE', reason: 'business_key' })
    }
  }
  // 去重
  const seen = new Set()
  return indexes.filter(idx => {
    const key = idx.column + idx.type
    if (seen.has(key)) return false
    seen.add(key)
    return true
  })
}

/**
 * 获取实体的外键关系列表（用于 migration）
 */
export function getForeignKeys(entity, allEntities) {
  const fks = []
  for (const field of entity.fields) {
    if (field.type === 'relation' && field.relation) {
      const targetEntity = allEntities[field.relation]
      fks.push({
        column: field.name,
        references: targetEntity?.table || field.relation.toLowerCase(),
        targetEntity: field.relation,
      })
    }
  }
  return fks
}

/**
 * 渲染表格单元格（根据字段类型生成 Vue 模板代码）
 */
export function renderTableCell(field, entity) {
  const name = field.name
  
  switch (field.type) {
    case 'enum':
      return `<DdfTag color="primary" size="sm">{{ row.${name} }}</DdfTag>`
    case 'boolean':
      return `<DdfStatusIndicator :status="row.${name} ? 'active' : 'inactive'" />`
    case 'date':
    case 'datetime':
      return `{{ row.${name} ? new Date(row.${name}).toLocaleString() : '-' }}`
    case 'float':
    case 'integer':
      return `{{ row.${name} }}`
    default:
      return `{{ row.${name} || '-' }}`
  }
}
