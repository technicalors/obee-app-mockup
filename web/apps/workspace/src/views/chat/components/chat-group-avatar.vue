<script setup lang="ts">
import type { GroupMemberAvatarInfo } from '../types';

import { computed, ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

interface Props {
  members?: GroupMemberAvatarInfo[];
  size?: number;
  totalCount?: number;
}

const props = withDefaults(defineProps<Props>(), {
  members: () => [],
  size: 42,
  totalCount: 0,
});

const failedImages = ref(new Set<string>());

function handleImageError(id: string): void {
  failedImages.value.add(id);
}

function hasValidAvatar(m?: GroupMemberAvatarInfo): boolean {
  if (!m?.avatarUrl) return false;
  return !failedImages.value.has(m.userId);
}

const AVATAR_COLORS = [
  'bg-blue-500',
  'bg-indigo-500',
  'bg-emerald-500',
  'bg-amber-500',
  'bg-rose-500',
  'bg-purple-500',
  'bg-cyan-500',
  'bg-teal-500',
];

function getMemberColor(nameOrId: string): string {
  let hash = 0;
  for (let i = 0; i < nameOrId.length; i++) {
    hash = (hash * 31 + (nameOrId.codePointAt(i) ?? 0)) % AVATAR_COLORS.length;
  }
  return AVATAR_COLORS[Math.abs(hash)] ?? 'bg-blue-500';
}

function getMemberInitial(name: string): string {
  const clean = name.replaceAll(/[^\p{L}\p{N}]/gu, '').trim();
  return clean ? (clean[0]?.toUpperCase() ?? '') : '';
}

const effectiveCount = computed(() => {
  return Math.max(props.members.length, props.totalCount);
});

const displayedMembers = computed(() => {
  return props.members.slice(0, 4);
});

const hasOverflow = computed(() => {
  return effectiveCount.value > 4;
});

const overflowText = computed(() => {
  const diff = effectiveCount.value - 3;
  if (diff > 99) return '99+';
  return `${diff}`;
});
</script>

<template>
  <div
    class="relative inline-flex shrink-0 items-center justify-center select-none"
    :style="{ width: `${size}px`, height: `${size}px` }"
  >
    <!-- 0 members fallback -->
    <div
      v-if="effectiveCount === 0"
      class="flex size-full items-center justify-center rounded-full bg-primary/20 text-primary shadow-xs"
    >
      <IconifyIcon
        icon="lucide:users"
        :class="size > 50 ? 'size-8' : 'size-5'"
      />
    </div>

    <!-- 1 member -->
    <div
      v-else-if="effectiveCount === 1 && displayedMembers[0]"
      class="size-full overflow-hidden rounded-full shadow-xs"
    >
      <img
        v-if="hasValidAvatar(displayedMembers[0])"
        :src="displayedMembers[0].avatarUrl"
        :alt="displayedMembers[0].displayName"
        class="size-full object-cover"
        @error="handleImageError(displayedMembers[0].userId)"
      />
      <div
        v-else
        class="flex size-full items-center justify-center font-bold text-white shadow-2xs"
        :class="[
          getMemberColor(
            displayedMembers[0].userId || displayedMembers[0].displayName,
          ),
          size > 50 ? 'text-xl' : 'text-sm',
        ]"
      >
        {{ getMemberInitial(displayedMembers[0].displayName) }}
      </div>
    </div>

    <!-- 2 members -->
    <div v-else-if="effectiveCount === 2" class="relative size-full">
      <!-- Member 1: Top Left -->
      <div
        v-if="displayedMembers[0]"
        class="absolute left-0 top-0 size-[62%] overflow-hidden rounded-full ring-1.5 ring-card shadow-2xs z-10"
      >
        <img
          v-if="hasValidAvatar(displayedMembers[0])"
          :src="displayedMembers[0].avatarUrl"
          :alt="displayedMembers[0].displayName"
          class="size-full object-cover"
          @error="handleImageError(displayedMembers[0].userId)"
        />
        <div
          v-else
          class="flex size-full items-center justify-center font-bold text-white"
          :class="[
            getMemberColor(
              displayedMembers[0].userId || displayedMembers[0].displayName,
            ),
            size > 50 ? 'text-xs' : 'text-[10px]',
          ]"
        >
          {{ getMemberInitial(displayedMembers[0].displayName) }}
        </div>
      </div>

      <!-- Member 2: Bottom Right -->
      <div
        v-if="displayedMembers[1]"
        class="absolute bottom-0 right-0 size-[62%] overflow-hidden rounded-full ring-1.5 ring-card shadow-2xs z-20"
      >
        <img
          v-if="hasValidAvatar(displayedMembers[1])"
          :src="displayedMembers[1].avatarUrl"
          :alt="displayedMembers[1].displayName"
          class="size-full object-cover"
          @error="handleImageError(displayedMembers[1].userId)"
        />
        <div
          v-else
          class="flex size-full items-center justify-center font-bold text-white"
          :class="[
            getMemberColor(
              displayedMembers[1].userId || displayedMembers[1].displayName,
            ),
            size > 50 ? 'text-xs' : 'text-[10px]',
          ]"
        >
          {{ getMemberInitial(displayedMembers[1].displayName) }}
        </div>
      </div>
    </div>

    <!-- 3 members -->
    <div v-else-if="effectiveCount === 3" class="relative size-full">
      <!-- Member 1: Top Center -->
      <div
        v-if="displayedMembers[0]"
        class="absolute left-1/2 top-0 size-[54%] -translate-x-1/2 overflow-hidden rounded-full ring-1.5 ring-card shadow-2xs z-10"
      >
        <img
          v-if="hasValidAvatar(displayedMembers[0])"
          :src="displayedMembers[0].avatarUrl"
          :alt="displayedMembers[0].displayName"
          class="size-full object-cover"
          @error="handleImageError(displayedMembers[0].userId)"
        />
        <div
          v-else
          class="flex size-full items-center justify-center font-bold text-white"
          :class="[
            getMemberColor(
              displayedMembers[0].userId || displayedMembers[0].displayName,
            ),
            size > 50 ? 'text-xs' : 'text-[9px]',
          ]"
        >
          {{ getMemberInitial(displayedMembers[0].displayName) }}
        </div>
      </div>

      <!-- Member 2: Bottom Left -->
      <div
        v-if="displayedMembers[1]"
        class="absolute bottom-0 left-0 size-[54%] overflow-hidden rounded-full ring-1.5 ring-card shadow-2xs z-20"
      >
        <img
          v-if="hasValidAvatar(displayedMembers[1])"
          :src="displayedMembers[1].avatarUrl"
          :alt="displayedMembers[1].displayName"
          class="size-full object-cover"
          @error="handleImageError(displayedMembers[1].userId)"
        />
        <div
          v-else
          class="flex size-full items-center justify-center font-bold text-white"
          :class="[
            getMemberColor(
              displayedMembers[1].userId || displayedMembers[1].displayName,
            ),
            size > 50 ? 'text-xs' : 'text-[9px]',
          ]"
        >
          {{ getMemberInitial(displayedMembers[1].displayName) }}
        </div>
      </div>

      <!-- Member 3: Bottom Right -->
      <div
        v-if="displayedMembers[2]"
        class="absolute bottom-0 right-0 size-[54%] overflow-hidden rounded-full ring-1.5 ring-card shadow-2xs z-20"
      >
        <img
          v-if="hasValidAvatar(displayedMembers[2])"
          :src="displayedMembers[2].avatarUrl"
          :alt="displayedMembers[2].displayName"
          class="size-full object-cover"
          @error="handleImageError(displayedMembers[2].userId)"
        />
        <div
          v-else
          class="flex size-full items-center justify-center font-bold text-white"
          :class="[
            getMemberColor(
              displayedMembers[2].userId || displayedMembers[2].displayName,
            ),
            size > 50 ? 'text-xs' : 'text-[9px]',
          ]"
        >
          {{ getMemberInitial(displayedMembers[2].displayName) }}
        </div>
      </div>
    </div>

    <!-- 4 or more members (2x2 cluster) -->
    <div v-else class="relative size-full">
      <!-- Member 1: Top Left -->
      <div
        class="absolute left-0 top-0 size-[53%] overflow-hidden rounded-full ring-1.5 ring-card shadow-2xs z-10"
      >
        <template v-if="displayedMembers[0]">
          <img
            v-if="hasValidAvatar(displayedMembers[0])"
            :src="displayedMembers[0].avatarUrl"
            :alt="displayedMembers[0].displayName"
            class="size-full object-cover"
            @error="handleImageError(displayedMembers[0].userId)"
          />
          <div
            v-else
            class="flex size-full items-center justify-center font-bold text-white"
            :class="[
              getMemberColor(
                displayedMembers[0].userId || displayedMembers[0].displayName,
              ),
              size > 50 ? 'text-xs' : 'text-[9px]',
            ]"
          >
            {{ getMemberInitial(displayedMembers[0].displayName) }}
          </div>
        </template>
        <div
          v-else
          class="flex size-full items-center justify-center bg-muted text-muted-foreground"
        >
          <IconifyIcon
            icon="lucide:user"
            :class="size > 50 ? 'size-4' : 'size-2.5'"
          />
        </div>
      </div>

      <!-- Member 2: Top Right -->
      <div
        class="absolute right-0 top-0 size-[53%] overflow-hidden rounded-full ring-1.5 ring-card shadow-2xs z-10"
      >
        <template v-if="displayedMembers[1]">
          <img
            v-if="hasValidAvatar(displayedMembers[1])"
            :src="displayedMembers[1].avatarUrl"
            :alt="displayedMembers[1].displayName"
            class="size-full object-cover"
            @error="handleImageError(displayedMembers[1].userId)"
          />
          <div
            v-else
            class="flex size-full items-center justify-center font-bold text-white"
            :class="[
              getMemberColor(
                displayedMembers[1].userId || displayedMembers[1].displayName,
              ),
              size > 50 ? 'text-xs' : 'text-[9px]',
            ]"
          >
            {{ getMemberInitial(displayedMembers[1].displayName) }}
          </div>
        </template>
        <div
          v-else
          class="flex size-full items-center justify-center bg-muted text-muted-foreground"
        >
          <IconifyIcon
            icon="lucide:user"
            :class="size > 50 ? 'size-4' : 'size-2.5'"
          />
        </div>
      </div>

      <!-- Member 3: Bottom Left -->
      <div
        class="absolute bottom-0 left-0 size-[53%] overflow-hidden rounded-full ring-1.5 ring-card shadow-2xs z-20"
      >
        <template v-if="displayedMembers[2]">
          <img
            v-if="hasValidAvatar(displayedMembers[2])"
            :src="displayedMembers[2].avatarUrl"
            :alt="displayedMembers[2].displayName"
            class="size-full object-cover"
            @error="handleImageError(displayedMembers[2].userId)"
          />
          <div
            v-else
            class="flex size-full items-center justify-center font-bold text-white"
            :class="[
              getMemberColor(
                displayedMembers[2].userId || displayedMembers[2].displayName,
              ),
              size > 50 ? 'text-xs' : 'text-[9px]',
            ]"
          >
            {{ getMemberInitial(displayedMembers[2].displayName) }}
          </div>
        </template>
        <div
          v-else
          class="flex size-full items-center justify-center bg-muted text-muted-foreground"
        >
          <IconifyIcon
            icon="lucide:user"
            :class="size > 50 ? 'size-4' : 'size-2.5'"
          />
        </div>
      </div>

      <!-- Member 4 or Overflow: Bottom Right -->
      <div
        class="absolute bottom-0 right-0 size-[53%] overflow-hidden rounded-full ring-1.5 ring-card shadow-2xs z-30"
      >
        <!-- Overflow count (e.g. 88, 99+) -->
        <div
          v-if="hasOverflow"
          class="flex size-full items-center justify-center bg-zinc-800 font-bold tracking-tight text-white dark:bg-zinc-700"
          :class="size > 50 ? 'text-[11px]' : 'text-[9px]'"
        >
          {{ overflowText }}
        </div>

        <!-- 4th Member -->
        <template v-else-if="displayedMembers[3]">
          <img
            v-if="hasValidAvatar(displayedMembers[3])"
            :src="displayedMembers[3].avatarUrl"
            :alt="displayedMembers[3].displayName"
            class="size-full object-cover"
            @error="handleImageError(displayedMembers[3].userId)"
          />
          <div
            v-else
            class="flex size-full items-center justify-center font-bold text-white"
            :class="[
              getMemberColor(
                displayedMembers[3].userId || displayedMembers[3].displayName,
              ),
              size > 50 ? 'text-xs' : 'text-[9px]',
            ]"
          >
            {{ getMemberInitial(displayedMembers[3].displayName) }}
          </div>
        </template>

        <div
          v-else
          class="flex size-full items-center justify-center bg-muted text-muted-foreground"
        >
          <IconifyIcon
            icon="lucide:user"
            :class="size > 50 ? 'size-4' : 'size-2.5'"
          />
        </div>
      </div>
    </div>
  </div>
</template>
