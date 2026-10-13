<script setup lang="ts">
import type {
  Department,
  DepartmentWithRelations,
  PaginationMeta,
  User,
} from '#/api';

import { computed, ref, watch } from 'vue';

import { Avatar, Empty, Pagination, Spin } from 'ant-design-vue';

import { departmentsResource, departmentUsersResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { getUserAvatarSource } from '#/views/users/avatar';

interface Props {
  department: Department;
}

const props = defineProps<Props>();
const emit = defineEmits<{
  failed: [];
  loaded: [department: DepartmentWithRelations];
}>();

const departmentDetails = ref<DepartmentWithRelations | null>(null);
const loading = ref(false);
const MEMBER_PAGE_SIZE = 5;
const memberPage = ref(1);
const memberPagination = ref<null | PaginationMeta>(null);
const members = ref<User[]>([]);
const memberTotal = computed(() =>
  memberPagination.value === null ? 0 : memberPagination.value.total,
);

async function loadDepartment(
  selectedDepartment: Department,
  page: number,
): Promise<void> {
  loading.value = true;

  try {
    const [detail, memberResult] = await Promise.all([
      departmentsResource.getById(selectedDepartment.id),
      departmentUsersResource.getAll(selectedDepartment.id, {
        page,
        per_page: MEMBER_PAGE_SIZE,
      }),
    ]);

    if (props.department.id !== selectedDepartment.id) {
      return;
    }

    departmentDetails.value = detail;
    members.value = memberResult.items;
    memberPagination.value = memberResult.pagination;
    emit('loaded', detail);
  } catch (error) {
    showRequestError(
      error,
      $t('page.departments.messages.unexpectedError'),
      'Unexpected department detail load error:',
    );
    emit('failed');
  } finally {
    loading.value = false;
  }
}

function handleMemberPageChange(page: number): void {
  memberPage.value = page;
  void loadDepartment(props.department, page);
}

watch(
  () => props.department,
  (selectedDepartment) => {
    departmentDetails.value = null;
    memberPagination.value = null;
    members.value = [];
    memberPage.value = 1;
    void loadDepartment(selectedDepartment, 1);
  },
  { immediate: true },
);
</script>

<template>
  <Spin :spinning="loading">
    <div v-if="departmentDetails !== null" class="space-y-6">
      <dl class="space-y-5 text-base">
        <div class="flex items-center gap-3">
          <dt class="text-muted-foreground">
            {{ $t('page.departments.fields.company') }}:
          </dt>
          <dd class="m-0 font-medium text-foreground">
            {{
              departmentDetails.company === null
                ? $t('page.departments.values.notProvided')
                : departmentDetails.company.name
            }}
          </dd>
        </div>
        <div class="flex items-center gap-3">
          <dt class="text-muted-foreground">
            {{ $t('page.departments.fields.parent') }}:
          </dt>
          <dd class="m-0 font-medium text-foreground">
            {{
              departmentDetails.parent === null
                ? $t('page.departments.values.noParent')
                : departmentDetails.parent.name
            }}
          </dd>
        </div>
        <div class="flex items-center gap-3">
          <dt class="text-muted-foreground">
            {{ $t('page.departments.tree.memberCount') }}:
          </dt>
          <dd class="m-0 font-semibold text-foreground">
            {{ memberTotal }}
          </dd>
        </div>
      </dl>

      <section class="space-y-3">
        <h3 class="m-0 text-base font-semibold text-foreground">
          {{ $t('page.departments.tree.members.title') }}
        </h3>
        <div v-if="members.length > 0" class="w-full rounded border">
          <div class="text-sm">
            <div
              class="grid grid-cols-[minmax(0,1.4fr)_minmax(0,1fr)_5rem_minmax(0,1fr)] border-b bg-muted/50 px-3 py-2 font-medium text-foreground"
            >
              <span>{{ $t('page.departments.tree.members.name') }}</span>
              <span>{{ $t('page.departments.tree.members.username') }}</span>
              <span>{{ $t('page.departments.tree.members.avatar') }}</span>
              <span>{{ $t('page.departments.tree.members.roles') }}</span>
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
                    ? $t('page.users.values.noRoles')
                    : member.roles.map((role) => role.name).join(', ')
                }}
              </span>
            </div>
          </div>
        </div>
        <Empty
          v-else
          :description="$t('page.departments.tree.members.empty')"
        />
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
