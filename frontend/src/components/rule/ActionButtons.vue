<template>
  <span class="buttons is-pulled-right">
    <router-link
      class="button is-warning is-small is-rounded"
      :to="{ name: 'Alerts', query: { q: q } }"
    >
      <span>Alerts:</span>
      <span>{{ getAlertsTask.last?.value?.total }}</span>
    </router-link>
    <a class="button is-small is-success is-rounded">
      <span>Artifacts:</span>
      <span>{{ getArtifactsTask.last?.value?.total }}</span>
    </a>
    <a class="button is-link is-light is-small" :href="href" target="_blank">
      <span>JSON</span>
      <span class="icon is-small">
        <font-awesome-icon icon="barcode"></font-awesome-icon>
      </span>
    </a>
    <button class="button is-primary is-light is-small" @click="searchRule">
      <span>Search</span>
      <span class="icon is-small">
        <font-awesome-icon
          icon="triangle-exclamation"
          v-if="searchRuleTask.isError"
        ></font-awesome-icon>
        <font-awesome-icon
          icon="spinner"
          spin
          v-else-if="searchRuleTask.isRunning"
        ></font-awesome-icon>
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

<script lang="ts">
import { computed, defineComponent, onMounted, type PropType } from "vue"

import {
  generateDeleteRuleTask,
  generateGetAlertsTask,
  generateGetArtifactsTask,
  generateSearchRuleTask
} from "@/api-helper"
import type { Rule } from "@/types"

export default defineComponent({
  name: "RuleActionButtons",
  props: {
    rule: {
      type: Object as PropType<Rule>,
      required: true
    }
  },
  emits: ["refresh", "set-error", "delete"],
  setup(props, context) {
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
          context.emit("delete")
        } catch (err) {
          context.emit("set-error")
        }
      }
    }

    const searchRule = async () => {
      try {
        await searchRuleTask.perform(props.rule.id)
        context.emit("refresh")
      } catch (err) {
        context.emit("set-error", err)
      }
    }

    onMounted(() => {
      getAlertsTask.perform({ q: q.value, page: 1, limit: 0 })
      getArtifactsTask.perform({ q: q.value, page: 1, limit: 0 })
    })

    return {
      deleteRule,
      searchRule,
      searchRuleTask,
      href,
      getAlertsTask,
      getArtifactsTask,
      q
    }
  }
})
</script>