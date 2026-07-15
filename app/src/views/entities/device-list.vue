<template>
  <div class="page-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <h1 class="page-title">设备</h1>
      <div class="page-actions">
        <DdfButton variant="primary" @click="handleCreate">
          新建设备
        </DdfButton>
      </div>
    </div>

    <!-- 搜索栏 -->
    <div class="search-bar">
      <el-input
        v-model="searchQuery"
        placeholder="搜索..."
        clearable
        @input="handleSearch"
        class="search-input"
      />
      <DdfButton variant="primary" @click="fetchData">搜索</DdfButton>
    </div>

    <!-- 数据表格 -->
    <div class="table-wrapper">
      <table class="ddf-table">
        <thead>
          <tr>
            
            <th>ID</th>
            
            <th>设备编码</th>
            
            <th>设备名称</th>
            
            <th>设备类型</th>
            
            <th>规格型号</th>
            
            <th>设备状态</th>
            
            <th>采购日期</th>
            
            <th>最近维保日期</th>
            
            <th class="th-actions">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in dataList" :key="row.id">
            
            <td>
              {{ row.id }}
            </td>
            
            <td>
              {{ row.device_code || '-' }}
            </td>
            
            <td>
              {{ row.device_name || '-' }}
            </td>
            
            <td>
              <DdfTag color="primary" size="sm">{{ row.device_type }}</DdfTag>
            </td>
            
            <td>
              {{ row.model || '-' }}
            </td>
            
            <td>
              <DdfTag color="primary" size="sm">{{ row.status }}</DdfTag>
            </td>
            
            <td>
              {{ row.purchase_date ? new Date(row.purchase_date).toLocaleString() : '-' }}
            </td>
            
            <td>
              {{ row.last_maintenance_date ? new Date(row.last_maintenance_date).toLocaleString() : '-' }}
            </td>
            
            <td class="td-actions">
              <DdfLink @click="handleEdit(row.id)">编辑</DdfLink>
              <DdfLink @click="handleDelete(row.id)">删除</DdfLink>
            </td>
          </tr>
          <tr v-if="!dataList.length">
            <td :colspan="9" class="td-empty">暂无数据</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- 分页 -->
    <div class="pagination-bar">
      <span class="pagination-info">共 {{ total }} 条</span>
      <div class="pagination-controls">
        <DdfButton variant="outline" size="sm" :disabled="page <= 1" @click="page--; fetchData()">上一页</DdfButton>
        <span class="pagination-current">第 {{ page }} / {{ totalPages }} 页</span>
        <DdfButton variant="outline" size="sm" :disabled="page >= totalPages" @click="page++; fetchData()">下一页</DdfButton>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getDeviceList, deleteDevice } from '@/api/device'

const router = useRouter()
const dataList = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(20)
const searchQuery = ref('')

const totalPages = computed(() => Math.ceil(total.value / pageSize.value))

async function fetchData() {
  try {
    const res = await getDeviceList({
      page: page.value,
      pageSize: pageSize.value,
      search: searchQuery.value || undefined,
    })
    dataList.value = res.data
    total.value = res.total
  } catch (err) {
    console.error('Failed to fetch Device:', err)
  }
}

function handleSearch() {
  page.value = 1
  fetchData()
}

function handleCreate() {
  router.push({ name: 'device-create' })
}

function handleEdit(id) {
  router.push({ name: 'device-edit', params: { id } })
}

async function handleDelete(id) {
  if (!confirm('确认删除？')) return
  try {
    await deleteDevice(id)
    fetchData()
  } catch (err) {
    console.error('Delete failed:', err)
  }
}

onMounted(fetchData)
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--space-4);
}
.page-title {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
}
.search-bar {
  display: flex;
  gap: var(--space-2);
  margin-bottom: var(--space-4);
}
.search-input {
  width: 280px;
}
.table-wrapper {
  background: var(--color-bg-primary);
  border-radius: var(--radius-lg);
  border: 1px solid var(--color-border-default);
  overflow: hidden;
}
.ddf-table {
  width: 100%;
  border-collapse: collapse;
}
.ddf-table th {
  text-align: left;
  padding: var(--space-3) var(--space-4);
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  border-bottom: 1px solid var(--color-border-default);
  background: var(--color-bg-subtle);
}
.ddf-table td {
  padding: var(--space-3) var(--space-4);
  font-size: var(--font-size-sm);
  border-bottom: 1px solid var(--color-border-default);
}
.ddf-table tr:last-child td {
  border-bottom: none;
}
.ddf-table tr:hover td {
  background: var(--color-bg-hover);
}
.th-actions, .td-actions {
  width: 120px;
  text-align: right;
}
.td-actions {
  display: flex;
  gap: var(--space-2);
  justify-content: flex-end;
}
.td-empty {
  text-align: center;
  padding: var(--space-8);
  color: var(--color-text-disabled);
}
.pagination-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: var(--space-4);
}
.pagination-controls {
  display: flex;
  align-items: center;
  gap: var(--space-2);
}
.pagination-current {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
}
</style>
