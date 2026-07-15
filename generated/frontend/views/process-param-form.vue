<template>
  <div class="page-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <h1 class="page-title">{{ isEdit ? '编辑' : '新建' }}工艺参数</h1>
      <DdfButton variant="text" @click="router.back()">返回</DdfButton>
    </div>

    <!-- 表单 -->
    <div class="form-wrapper">
      <div class="form-grid">
        
        <div class="form-group" :class="'string'">
          <label class="form-label">
            参数编码
            <span class="required">*</span>
          </label>
          <input type="text" v-model="form.param_code" class="form-input" />
        </div>
        
        <div class="form-group" :class="'string'">
          <label class="form-label">
            参数名称
            <span class="required">*</span>
          </label>
          <input type="text" v-model="form.param_name" class="form-input" />
        </div>
        
        <div class="form-group" :class="'relation'">
          <label class="form-label">
            所属工序
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.process_step_id" class="form-input" placeholder="ProcessStep" />
        </div>
        
        <div class="form-group" :class="'enum'">
          <label class="form-label">
            数据类型
            <span class="required">*</span>
          </label>
          <select v-model="form.data_type" class="form-input">
        <option value="">请选择</option>
        <option v-for="opt in [null]" :key="opt" :value="opt">{{ opt }}</option>
      </select>
        </div>
        
        <div class="form-group" :class="'string'">
          <label class="form-label">
            单位
            <span class="required">*</span>
          </label>
          <input type="text" v-model="form.unit" class="form-input" />
        </div>
        
        <div class="form-group" :class="'float'">
          <label class="form-label">
            规格下限
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.spec_min" class="form-input" step="0.01" />
        </div>
        
        <div class="form-group" :class="'float'">
          <label class="form-label">
            规格上限
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.spec_max" class="form-input" step="0.01" />
        </div>
        
        <div class="form-group" :class="'string'">
          <label class="form-label">
            可选值
            <span class="required">*</span>
          </label>
          <input type="text" v-model="form.options" class="form-input" />
        </div>
        
        <div class="form-group" :class="'boolean'">
          <label class="form-label">
            是否必填
            <span class="required">*</span>
          </label>
          <input type="checkbox" v-model="form.required" class="form-input" />
        </div>
        
        <div class="form-group" :class="'enum'">
          <label class="form-label">
            状态
            <span class="required">*</span>
          </label>
          <select v-model="form.status" class="form-input">
        <option value="">请选择</option>
        <option v-for="opt in [null]" :key="opt" :value="opt">{{ opt }}</option>
      </select>
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
import { getProcessParam, createProcessParam, updateProcessParam } from '@/api/process-param'

const router = useRouter()
const route = useRoute()
const isEdit = computed(() => !!route.params.id)
const submitting = ref(false)

const form = ref({})

// 初始化表单
function initForm() {
  const data = {}
  
  
  data['param_code'] = ''
  
  
  
  data['param_name'] = ''
  
  
  
  data['process_step_id'] = ''
  
  
  
  data['data_type'] = ''
  
  
  
  data['unit'] = ''
  
  
  
  data['spec_min'] = null
  
  
  
  data['spec_max'] = null
  
  
  
  data['options'] = ''
  
  
  
  data['required'] = false
  
  
  
  data['status'] = ''
  
  
  return data
}

async function fetchDetail() {
  try {
    const res = await getProcessParam(route.params.id)
    form.value = res
  } catch (err) {
    console.error('Failed to fetch detail:', err)
  }
}

async function handleSubmit() {
  submitting.value = true
  try {
    if (isEdit.value) {
      await updateProcessParam(route.params.id, form.value)
    } else {
      await createProcessParam(form.value)
    }
    router.push({ name: 'process-param-list' })
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
