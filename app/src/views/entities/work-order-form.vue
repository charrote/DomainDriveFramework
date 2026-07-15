<template>
  <div class="page-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <h1 class="page-title">{{ isEdit ? '编辑' : '新建' }}工单</h1>
      <DdfButton variant="text" @click="router.back()">返回</DdfButton>
    </div>

    <!-- 表单 -->
    <div class="form-wrapper">
      <div class="form-grid">
        
        <div class="form-group" :class="'string'">
          <label class="form-label">
            工单编号
            <span class="required">*</span>
          </label>
          <input type="text" v-model="form.order_no" class="form-input" />
        </div>
        
        <div class="form-group" :class="'string'">
          <label class="form-label">
            产品编码
            <span class="required">*</span>
          </label>
          <input type="text" v-model="form.product_code" class="form-input" />
        </div>
        
        <div class="form-group" :class="'string'">
          <label class="form-label">
            产品名称
            <span class="required">*</span>
          </label>
          <input type="text" v-model="form.product_name" class="form-input" />
        </div>
        
        <div class="form-group" :class="'integer'">
          <label class="form-label">
            计划数量
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.quantity" class="form-input" step="1" />
        </div>
        
        <div class="form-group" :class="'integer'">
          <label class="form-label">
            已完成数量
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.completed_quantity" class="form-input" step="1" />
        </div>
        
        <div class="form-group" :class="'integer'">
          <label class="form-label">
            报废数量
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.scrap_quantity" class="form-input" step="1" />
        </div>
        
        <div class="form-group" :class="'enum'">
          <label class="form-label">
            工单状态
            <span class="required">*</span>
          </label>
          <select v-model="form.status" class="form-input">
        <option value="">请选择</option>
        <option v-for="opt in [null]" :key="opt" :value="opt">{{ opt }}</option>
      </select>
        </div>
        
        <div class="form-group" :class="'enum'">
          <label class="form-label">
            优先级
            <span class="required">*</span>
          </label>
          <select v-model="form.priority" class="form-input">
        <option value="">请选择</option>
        <option v-for="opt in [null]" :key="opt" :value="opt">{{ opt }}</option>
      </select>
        </div>
        
        <div class="form-group" :class="'date'">
          <label class="form-label">
            计划开始日期
            <span class="required">*</span>
          </label>
          <input type="date" v-model="form.plan_start_date" class="form-input" />
        </div>
        
        <div class="form-group" :class="'date'">
          <label class="form-label">
            计划完成日期
            <span class="required">*</span>
          </label>
          <input type="date" v-model="form.plan_end_date" class="form-input" />
        </div>
        
        <div class="form-group" :class="'datetime'">
          <label class="form-label">
            实际开工时间
            <span class="required">*</span>
          </label>
          <input type="datetime-local" v-model="form.actual_start_time" class="form-input" />
        </div>
        
        <div class="form-group" :class="'datetime'">
          <label class="form-label">
            实际完工时间
            <span class="required">*</span>
          </label>
          <input type="datetime-local" v-model="form.actual_end_time" class="form-input" />
        </div>
        
        <div class="form-group" :class="'relation'">
          <label class="form-label">
            工艺路线
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.route_id" class="form-input" placeholder="ProcessRoute" />
        </div>
        
        <div class="form-group" :class="'relation'">
          <label class="form-label">
            生产产线
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.production_line_id" class="form-input" placeholder="ProductionLine" />
        </div>
        
        <div class="form-group" :class="'relation'">
          <label class="form-label">
            班次
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.shift_id" class="form-input" placeholder="Shift" />
        </div>
        
        <div class="form-group" :class="'string'">
          <label class="form-label">
            备注
            <span class="required">*</span>
          </label>
          <input type="text" v-model="form.comment" class="form-input" />
        </div>
        
      </div>

      <div class="form-actions">
        <DdfButton variant="primary" @click="handleSubmit" :loading="submitting">
          {{ isEdit ? '保存' : '创建' }}
        </DdfButton>
        <DdfButton variant="outline" @click="router.back()">取消</DdfButton>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { getWorkOrder, createWorkOrder, updateWorkOrder } from '@/api/work-order'

const router = useRouter()
const route = useRoute()
const isEdit = computed(() => !!route.params.id)
const submitting = ref(false)

const form = ref({})

// 初始化表单
function initForm() {
  const data = {}
  
  
  data['order_no'] = ''
  
  
  
  data['product_code'] = ''
  
  
  
  data['product_name'] = ''
  
  
  
  data['quantity'] = null
  
  
  
  data['completed_quantity'] = null
  
  
  
  data['scrap_quantity'] = null
  
  
  
  data['status'] = ''
  
  
  
  data['priority'] = ''
  
  
  
  data['plan_start_date'] = ''
  
  
  
  data['plan_end_date'] = ''
  
  
  
  data['actual_start_time'] = ''
  
  
  
  data['actual_end_time'] = ''
  
  
  
  data['route_id'] = ''
  
  
  
  data['production_line_id'] = ''
  
  
  
  data['shift_id'] = ''
  
  
  
  data['comment'] = ''
  
  
  return data
}

async function fetchDetail() {
  try {
    const res = await getWorkOrder(route.params.id)
    form.value = res
  } catch (err) {
    console.error('Failed to fetch detail:', err)
  }
}

async function handleSubmit() {
  submitting.value = true
  try {
    if (isEdit.value) {
      await updateWorkOrder(route.params.id, form.value)
    } else {
      await createWorkOrder(form.value)
    }
    router.push({ name: 'work-order-list' })
  } catch (err) {
    console.error('Submit failed:', err)
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  form.value = initForm()
  if (isEdit.value) fetchDetail()
})
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--space-6);
}
.page-title {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
}
.form-wrapper {
  background: var(--color-bg-primary);
  border-radius: var(--radius-lg);
  border: 1px solid var(--color-border-default);
  padding: var(--space-6);
}
.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--space-5);
}
.form-group.full-width {
  grid-column: 1 / -1;
}
.form-group.text-type {
  grid-column: 1 / -1;
}
.form-label {
  display: block;
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  margin-bottom: var(--space-2);
  color: var(--color-text-primary);
}
.form-label .required {
  color: var(--color-red-500);
  margin-left: 2px;
}
.form-input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-base);
  font-size: var(--font-size-sm);
  background: var(--color-bg-primary);
  color: var(--color-text-primary);
  transition: border-color var(--transition-fast);
}
.form-input:focus {
  outline: none;
  border-color: var(--color-primary-500);
  box-shadow: 0 0 0 2px var(--color-primary-100);
}
.form-actions {
  display: flex;
  gap: var(--space-3);
  margin-top: var(--space-6);
  padding-top: var(--space-4);
  border-top: 1px solid var(--color-border-default);
}
select.form-input {
  appearance: auto;
}
input[type="checkbox"].form-input {
  width: auto;
  height: 20px;
  width: 20px;
  cursor: pointer;
}
</style>
