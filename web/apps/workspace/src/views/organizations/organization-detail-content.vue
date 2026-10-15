<script setup lang="ts">
import type { Organization, User } from '#/api';

import { computed, ref, watch } from 'vue';

import {
  Avatar,
  Descriptions,
  DescriptionsItem,
  Empty,
  Pagination,
  Spin,
} from 'ant-design-vue';

import { organizationsResource, organizationUsersResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { getUserAvatarSource } from '#/views/users/avatar';

interface Props {
  organization: Organization;
  organizations: Organization[];
}

const props = defineProps<Props>();
const emit = defineEmits<{
  failed: [];
  loaded: [organization: Organization];
}>();

const MEMBER_PAGE_SIZE = 5;
const organizationDetails = ref<null | Organization>(null);
const members = ref<User[]>([]);
const memberPage = ref(1);
const memberTotal = ref(0);
const loading = ref(false);
let loadingRequest = 0;
const organizationsById = computed(
  () =>
    new Map(
      props.organizations.map((organization) => [
        organization.id,
        organization,
      ]),
    ),
);
const parentOrganization = computed(() => {
  if (props.organization.parent_id === null) return null;
  const parent = organizationsById.value.get(props.organization.parent_id);
  if (parent === undefined) {
    throw new Error(
      `Organization ${props.organization.id} has an unavailable parent.`,
    );
  }
  return parent;
});
const rootOrganization = computed(() => {
  let current = props.organization;
  const visited = new Set<string>();
  while (current.parent_id !== null) {
    if (visited.has(current.id)) {
      throw new Error('The organization hierarchy contains a cycle.');
    }
    visited.add(current.id);
    const parent = organizationsById.value.get(current.parent_id);
    if (parent === undefined) {
      throw new Error(`Organization ${current.id} has an unavailable parent.`);
    }
    current = parent;
  }
  return current;
});

async function loadOrganization(page: number): Promise<void> {
  const organization = props.organization;
  const parentId = organization.parent_id;
  const request = ++loadingRequest;
  loading.value = true;

  try {
    const [details, memberResult] = await Promise.all([
      organizationsResource.getById(organization.id),
      organizationUsersResource.getAll(organization.id, {
        page,
        per_page: MEMBER_PAGE_SIZE,
      }),
    ]);

    if (
      request !== loadingRequest ||
      props.organization.id !== organization.id ||
      props.organization.parent_id !== parentId
    ) {
      return;
    }

    if (details.id !== organization.id || details.parent_id !== parentId) {
      throw new Error(
        `Organization ${organization.id} details do not match its loaded hierarchy.`,
      );
    }

    organizationDetails.value = details;
    members.value = memberResult.items;
    memberPage.value = memberResult.pagination.page;
    memberTotal.value = memberResult.pagination.total;
    emit('loaded', details);
  } catch (error) {
    if (
      request !== loadingRequest ||
      props.organization.id !== organization.id ||
      props.organization.parent_id !== parentId
    ) {
      return;
    }

    showRequestError(
      error,
      $t('organizations.messages.unexpectedError'),
      'Unexpected organization detail load error:',
    );
    emit('failed');
  } finally {
    if (request === loadingRequest) loading.value = false;
  }
}

function handleMemberPageChange(page: number): void {
  memberPage.value = page;
  void loadOrganization(page);
}

watch(
  () => [props.organization.id, props.organization.parent_id],
  () => {
    loadingRequest += 1;
    organizationDetails.value = null;
    members.value = [];
    memberPage.value = 1;
    memberTotal.value = 0;
    void loadOrganization(1);
  },
  { immediate: true },
);
</script>

<template>
  <Spin :spinning="loading">
    <div v-if="organizationDetails !== null" class="space-y-6">
      <Descriptions :column="3">
        <template #title>
          <span class="text-base font-semibold text-foreground">
            Thông tin phòng ban
          </span>
        </template>
        <DescriptionsItem :label="$t('organizations.types.company')">
          <span class="font-medium text-foreground">
            {{ rootOrganization.name }}
          </span>
        </DescriptionsItem>
        <DescriptionsItem :label="$t('organizations.tree.parent')">
          <span class="font-medium text-foreground">
            {{
              parentOrganization === null
                ? $t('organizations.values.root')
                : parentOrganization.name
            }}
          </span>
        </DescriptionsItem>
        <DescriptionsItem :label="$t('organizations.tree.memberCount')">
          <span class="font-semibold text-foreground">
            {{ memberTotal }}
          </span>
        </DescriptionsItem>
      </Descriptions>

      <section class="space-y-3">
        <h3 class="m-0 text-base font-semibold text-foreground">
          {{ $t('organizations.users.title') }}
        </h3>
        <div v-if="members.length > 0" class="w-full rounded border">
          <div class="text-sm">
            <div
              class="grid grid-cols-[minmax(0,1.4fr)_minmax(0,1fr)_5rem_minmax(0,1fr)] border-b bg-muted/50 px-3 py-2 font-medium text-foreground"
            >
              <span>{{ $t('organizations.tree.members.name') }}</span>
              <span>{{ $t('organizations.tree.members.username') }}</span>
              <span>{{ $t('organizations.tree.members.avatar') }}</span>
              <span>{{ $t('organizations.tree.members.roles') }}</span>
            </div>
            <div
              v-for="member in members"
              :key="member.id"
              class="grid grid-cols-[minmax(0,1.4fr)_minmax(0,1fr)_5rem_minmax(0,1fr)] items-center border-b px-3 py-2 last:border-b-0"
            >
              <span class="break-words font-medium text-foreground">{{
                member.name
              }}</span>
              <span class="break-words text-muted-foreground">{{
                member.username
              }}</span>
              <Avatar :size="36" :src="getUserAvatarSource(member)" />
              <span class="break-words text-muted-foreground">
                {{
                  member.roles.length === 0
                    ? $t('users.values.noRoles')
                    : member.roles.map((role) => role.name).join(', ')
                }}
              </span>
            </div>
          </div>
        </div>
        <Empty v-else :description="$t('organizations.tree.members.empty')" />
        <div v-if="memberTotal > MEMBER_PAGE_SIZE" class="flex justify-end">
          <Pagination
            :current="memberPage"
            :page-size="MEMBER_PAGE_SIZE"
            :total="memberTotal"
            size="small"
            @change="handleMemberPageChange"
          />
        </div>
      </section>
    </div>
  </Spin>
</template>
