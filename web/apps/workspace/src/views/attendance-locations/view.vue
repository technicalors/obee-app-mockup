<script setup lang="ts">
import { useRoute } from 'vue-router';

import DetailForm from './detail-form.vue';

const route = useRoute();
const id = String(route.params.id);
</script>

<template>
  <DetailForm mode="view" :id="id" />
</template>
