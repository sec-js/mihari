<script setup lang="ts">
import axios, { AxiosError } from "axios"
import { computed, onMounted, type PropType } from "vue"

import {
  generateDeleteRuleTask,
  generateGetAlertsTask,
  generateGetArtifactsTask,
  generateSearchRuleTask
} from "@/api-helper"
import type { QueueMessageType, RuleType } from "@/schemas"

const props = defineProps({
  rule: {
    type: Object as PropType<RuleType>,
    required: true
  }
})

const emits = defineEmits<{
  (e: "delete"): void
  (e: "set-error", value: AxiosError): void
  (e: "set-message", value: QueueMessageType): void
}>()

const href = computed(() => {
  return `/api/rules/${props.rule.id}`
})

const q = computed(() => {
  return `rule.id:"${props.rule.id}"`
})

const deleteRuleTask = generateDeleteRuleTask()
const searchRuleTask = generateSearchRuleTask()
const getAlertsTask = generateGetAlertsTask()
const getArtifactsTask = generateGetArtifactsTask()

const deleteRule = async () => {
  const confirmed = window.confirm(`Are you sure you want to delete ${props.rule.id}?`)

  if (confirmed) {
    try {
      await deleteRuleTask.perform(props.rule.id)
      emits("delete")
    } catch (err) {
      if (axios.isAxiosError(err)) {
        emits("set-error", err)
      }
    }
  }
}

const searchRule = async () => {
  try {
    const message = await searchRuleTask.perform(props.rule.id)
    emits("set-message", message)
  } catch (err) {
    if (axios.isAxiosError(err)) {
      emits("set-error", err)
    }
  }
}

onMounted(() => {
  getAlertsTask.perform({ q: q.value, page: 1, limit: 0 })
  getArtifactsTask.perform({ q: q.value, page: 1, limit: 0 })
})
</script>

<template>
  <span class="buttons is-pulled-right">
    <router-link
      class="button is-warning is-small is-rounded"
      :to="{ name: 'Alerts', query: { q: q } }"
    >
      <span>Alerts:</span>
      <span>{{ getAlertsTask.last?.value?.total }}</span>
    </router-link>
    <router-link
      class="button is-success is-small is-rounded"
      :to="{ name: 'Artifacts', query: { q: q } }"
    >
      <span>Artifacts:</span>
      <span>{{ getArtifactsTask.last?.value?.total }}</span>
    </router-link>
    <a class="button is-link is-light is-small" :href="href" target="_blank">
      <span>JSON</span>
      <span class="icon is-small">
        <font-awesome-icon icon="barcode"></font-awesome-icon>
      </span>
    </a>
    <button class="button is-primary is-light is-small" @click="searchRule">
      <span>Search</span>
      <span class="icon is-small">
        <font-awesome-icon icon="spinner" spin v-if="searchRuleTask.isRunning"></font-awesome-icon>
        <font-awesome-icon icon="magnifying-glass" v-else></font-awesome-icon>
      </span>
    </button>
    <router-link
      class="button is-info is-light is-small"
      :to="{ name: 'EditRule', params: { id: rule.id } }"
    >
      <span>Edit</span>
      <span class="icon is-small">
        <font-awesome-icon icon="edit"></font-awesome-icon>
      </span>
    </router-link>
    <button class="button is-light is-small" @click="deleteRule">
      <span>Delete</span>
      <span class="icon is-small">
        <font-awesome-icon icon="times"></font-awesome-icon>
      </span>
    </button>
  </span>
</template>
