<template>
  <div class="page-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <h1 class="page-title">{{ isEdit ? '编辑' : '新建' }}质检记录</h1>
      <DdfButton variant="text" @click="router.back()">返回</DdfButton>
    </div>

    <!-- 表单 -->
    <div class="form-wrapper">
      <div class="form-grid">
        
        <div class="form-group" :class="'string'">
          <label class="form-label">
            检验编号
            <span class="required">*</span>
          </label>
          <input type="text" v-model="form.check_no" class="form-input" />
        </div>
        
        <div class="form-group" :class="'relation'">
          <label class="form-label">
            关联工单
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.work_order_no" class="form-input" placeholder="WorkOrder" />
        </div>
        
        <div class="form-group" :class="'relation'">
          <label class="form-label">
            关联生产记录
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.production_record_id" class="form-input" placeholder="ProductionRecord" />
        </div>
        
        <div class="form-group" :class="'enum'">
          <label class="form-label">
            检验类型
            <span class="required">*</span>
          </label>
          <select v-model="form.check_type" class="form-input">
        <option value="">请选择</option>
        <option v-for="opt in [null]" :key="opt" :value="opt">{{ opt }}</option>
      </select>
        </div>
        
        <div class="form-group" :class="'string'">
          <label class="form-label">
            检验项目
            <span class="required">*</span>
          </label>
          <input type="text" v-model="form.check_name" class="form-input" />
        </div>
        
        <div class="form-group" :class="'relation'">
          <label class="form-label">
            检验标准
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.inspection_item_id" class="form-input" placeholder="InspectionItem" />
        </div>
        
        <div class="form-group" :class="'integer'">
          <label class="form-label">
            抽样数量
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.sample_size" class="form-input" step="1" />
        </div>
        
        <div class="form-group" :class="'float'">
          <label class="form-label">
            测量值
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.measured_value" class="form-input" step="0.01" />
        </div>
        
        <div class="form-group" :class="'float'">
          <label class="form-label">
            规格下限
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.tolerance_min" class="form-input" step="0.01" />
        </div>
        
        <div class="form-group" :class="'float'">
          <label class="form-label">
            规格上限
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.tolerance_max" class="form-input" step="0.01" />
        </div>
        
        <div class="form-group" :class="'enum'">
          <label class="form-label">
            判定结果
            <span class="required">*</span>
          </label>
          <select v-model="form.result" class="form-input">
        <option value="">请选择</option>
        <option v-for="opt in [null]" :key="opt" :value="opt">{{ opt }}</option>
      </select>
        </div>
        
        <div class="form-group" :class="'relation'">
          <label class="form-label">
            缺陷类型
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.defect_id" class="form-input" placeholder="Defect" />
        </div>
        
        <div class="form-group" :class="'relation'">
          <label class="form-label">
            检验员
            <span class="required">*</span>
          </label>
          <input type="number" v-model.number="form.inspector_id" class="form-input" placeholder="User" />
        </div>
        
        <div class="form-group" :class="'datetime'">
          <label class="form-label">
            检验时间
            <span class="required">*</span>
          </label>
          <input type="datetime-local" v-model="form.check_time" class="form-input" />
        </div>
        
        <div class="form-group" :class="'string'">
          <label class="form-label">
            备注
            <span class="required">*</span>
          </label>
          <input type="text" v-model="form.remark" class="form-input" />
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
import { getQualityCheck, createQualityCheck, updateQualityCheck } from '@/api/quality-check'

const router = useRouter()
const route = useRoute()
const isEdit = computed(() => !!route.params.id)
const submitting = ref(false)

const form = ref({})

// 初始化表单
function initForm() {
  const data = {}
  
  
  data['check_no'] = ''
  
  
  
  data['work_order_no'] = ''
  
  
  
  data['production_record_id'] = ''
  
  
  
  data['check_type'] = ''
  
  
  
  data['check_name'] = ''
  
  
  
  data['inspection_item_id'] = ''
  
  
  
  data['sample_size'] = null
  
  
  
  data['measured_value'] = null
  
  
  
  data['tolerance_min'] = null
  
  
  
  data['tolerance_max'] = null
  
  
  
  data['result'] = ''
  
  
  
  data['defect_id'] = ''
  
  
  
  data['inspector_id'] = ''
  
  
  
  data['check_time'] = ''
  
  
  
  data['remark'] = ''
  
  
  return data
}

async function fetchDetail() {
  try {
    const res = await getQualityCheck(route.params.id)
    form.value = res
  } catch (err) {
    console.error('Failed to fetch detail:', err)
  }
}

async function handleSubmit() {
  submitting.value = true
  try {
    if (isEdit.value) {
      await updateQualityCheck(route.params.id, form.value)
    } else {
      await createQualityCheck(form.value)
    }
    router.push({ name: 'quality-check-list' })
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
