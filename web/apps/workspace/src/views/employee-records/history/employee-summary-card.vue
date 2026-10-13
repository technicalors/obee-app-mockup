<script setup lang="ts">
import type { User } from '#/api';

import { computed, ref } from 'vue';

import { useAccess } from '@vben/access';
import { IconifyIcon } from '@vben/icons';

import { Avatar, Button, Card, notification, Tag } from 'ant-design-vue';

import { usersResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { getUserAvatarSource } from '#/views/users/avatar';

const props = defineProps<{ user: User }>();

const emit = defineEmits<{
  avatarUpdated: [user: User];
}>();

const avatarInput = ref<HTMLInputElement | null>(null);
const isUploadingAvatar = ref(false);
const { hasAccessByCodes } = useAccess();
const canUpdateAvatar = computed(() => hasAccessByCodes(['users.update']));

function openAvatarPicker(): void {
  avatarInput.value?.click();
}

async function handleAvatarChange(event: Event): Promise<void> {
  const input = event.currentTarget;

  if (!(input instanceof HTMLInputElement)) {
    return;
  }

  const file = input.files?.item(0);
  if (file === null || file === undefined) {
    return;
  }

  isUploadingAvatar.value = true;

  try {
    const user = await usersResource.updateAvatar(props.user.id, file);
    emit('avatarUpdated', user);
    notification.success({
      message: $t('page.employeeHistory.messages.avatarUpdated'),
    });
  } catch (error) {
    showRequestError(
      error,
      $t('page.employeeHistory.messages.unexpectedError'),
      'Unexpected employee avatar upload error:',
    );
  } finally {
    isUploadingAvatar.value = false;
    input.value = '';
  }
}
</script>

<template>
  <Card
    class="employee-summary-card"
    :bordered="true"
    data-testid="employee-summary-card"
  >
    <div class="employee-summary-identity">
      <div class="employee-summary-avatar">
        <Avatar
          :size="88"
          :src="getUserAvatarSource(user)"
          class="ring-2 ring-border/60"
        >
          {{ user.name.charAt(0).toUpperCase() }}
        </Avatar>
        <Button
          v-if="canUpdateAvatar"
          size="small"
          :loading="isUploadingAvatar"
          data-testid="change-avatar-button"
          @click="openAvatarPicker"
        >
          <template #icon>
            <IconifyIcon icon="lucide:camera" />
          </template>
          {{ $t('page.employeeHistory.actions.changeAvatar') }}
        </Button>
        <input
          ref="avatarInput"
          type="file"
          accept="image/jpeg,image/png,image/webp"
          class="sr-only"
          data-testid="avatar-input"
          @change="handleAvatarChange"
        />
      </div>

      <div class="employee-summary-heading">
        <h2 class="employee-summary-name">{{ user.name }}</h2>
        <p class="employee-summary-code">
          {{ user.profile?.code ?? $t('common.notProvided') }}
        </p>
        <Tag :bordered="false" :color="user.is_active ? 'success' : 'default'">
          {{
            user.is_active
              ? $t('page.employeeHistory.status.active')
              : $t('page.employeeHistory.status.inactive')
          }}
        </Tag>
      </div>
    </div>

    <dl class="employee-summary-fields">
      <div class="employee-summary-field">
        <dt class="flex items-center gap-1.5">
          <IconifyIcon
            icon="lucide:briefcase"
            class="size-3.5 text-muted-foreground/80"
          />
          <span>{{ $t('page.employeeHistory.fields.currentPosition') }}</span>
        </dt>
        <dd>{{ user.profile?.position?.name ?? $t('common.notProvided') }}</dd>
      </div>

      <div class="employee-summary-field">
        <dt class="flex items-center gap-1.5">
          <IconifyIcon
            icon="lucide:building-2"
            class="size-3.5 text-muted-foreground/80"
          />
          <span>{{ $t('page.employeeHistory.fields.workUnit') }}</span>
        </dt>
        <dd>
          {{
            user.departments.length === 0
              ? $t('common.notProvided')
              : user.departments
                  .map((department) => department.name)
                  .join(' > ')
          }}
        </dd>
      </div>

      <div class="employee-summary-field">
        <dt class="flex items-center gap-1.5">
          <IconifyIcon
            icon="lucide:mail"
            class="size-3.5 text-muted-foreground/80"
          />
          <span>{{ $t('page.employeeHistory.fields.email') }}</span>
        </dt>
        <dd class="break-all">{{ user.email ?? $t('common.notProvided') }}</dd>
      </div>

      <div class="employee-summary-field">
        <dt class="flex items-center gap-1.5">
          <IconifyIcon
            icon="lucide:phone"
            class="size-3.5 text-muted-foreground/80"
          />
          <span>{{ $t('page.employeeHistory.fields.phone') }}</span>
        </dt>
        <dd>{{ user.profile?.phone_number ?? $t('common.notProvided') }}</dd>
      </div>
    </dl>
  </Card>
</template>

<style scoped>
.employee-summary-card {
  position: sticky;
  top: 16px;
  min-width: 0;
  overflow: hidden;
  background: hsl(var(--card));
  border-radius: 8px;
}

.employee-summary-identity {
  display: flex;
  gap: 16px;
  align-items: center;
  padding-bottom: 20px;
  border-bottom: 1px solid hsl(var(--border));
}

.employee-summary-avatar {
  display: flex;
  flex: 0 0 auto;
  flex-direction: column;
  gap: 8px;
  align-items: center;
}

.employee-summary-heading {
  min-width: 0;
}

.employee-summary-name {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  line-height: 26px;
  color: hsl(var(--foreground));
  overflow-wrap: anywhere;
}

.employee-summary-code {
  margin: 4px 0 10px;
  font-size: 13px;
  line-height: 20px;
  color: hsl(var(--muted-foreground));
  overflow-wrap: anywhere;
}

.employee-summary-fields {
  display: grid;
  gap: 16px;
  margin: 20px 0 0;
}

.employee-summary-field {
  min-width: 0;
}

.employee-summary-field dt {
  margin-bottom: 4px;
  font-size: 12px;
  line-height: 18px;
  color: hsl(var(--muted-foreground));
}

.employee-summary-field dd {
  margin: 0;
  font-size: 14px;
  line-height: 21px;
  color: hsl(var(--foreground));
  overflow-wrap: anywhere;
}

@media (max-width: 1023px) {
  .employee-summary-card {
    position: static;
  }
}

@media (max-width: 767px) {
  .employee-summary-identity {
    align-items: flex-start;
  }
}
</style>
