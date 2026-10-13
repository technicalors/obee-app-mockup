<script lang="ts" setup>
import { Page } from '@vben/common-ui';
import { createIconifyIcon } from '@vben/icons';

import { DatePicker } from 'ant-design-vue';

import { $t } from '#/locales';

import { getAttendanceCellSurfaceClasses } from './attendance-rules';
import { useAttendancePage } from './use-attendance-page';

const MapPinIcon = createIconifyIcon('lucide:map-pin');
const WifiIcon = createIconifyIcon('lucide:wifi');
const ClockIcon = createIconifyIcon('lucide:clock');
const FingerprintIcon = createIconifyIcon('lucide:fingerprint');
const CheckIcon = createIconifyIcon('lucide:check-circle');
const CloseIcon = createIconifyIcon('lucide:x-circle');
const RefreshIcon = createIconifyIcon('lucide:refresh-cw');
const BriefcaseIcon = createIconifyIcon('lucide:briefcase');
const CalendarIcon = createIconifyIcon('lucide:calendar');
const ChevronLeftIcon = createIconifyIcon('lucide:chevron-left');
const ChevronRightIcon = createIconifyIcon('lucide:chevron-right');
const AlertTriangleIcon = createIconifyIcon('lucide:alert-triangle');

const {
  activeTab,
  calendarCells,
  canShiftNextMonth,
  canPunch,
  currentMonth,
  currentTime,
  formatSelectedDateLabel,
  getTickingDateString,
  getTickingTimeString,
  gpsCoords,
  gpsLoading,
  gpsValid,
  handlePunch,
  handleRefreshGPS,
  handleRefreshIP,
  ipAddress,
  ipLoading,
  ipValid,
  isFutureMonth,
  monthlyDeficientDays,
  monthlyTotalHours,
  monthlyWorkingDays,
  openDayDetail,
  selectedDate,
  selectedDayHoursText,
  selectedDayPunches,
  selectedDayStatusText,
  selectCurrentMonth,
  selectMonth,
  shiftMonth,
  todayOnTimeStatus,
  todayPunches,
  todayWorkHoursDecimalStr,
  todayWorkHoursMobileStr,
} = useAttendancePage();
</script>

<!-- eslint-disable vue/html-closing-bracket-newline -->
<template>
  <Page auto-content-height>
    <!-- Root Container -->
    <div class="relative min-h-[500px] text-foreground">
      <!-- ========================================== -->
      <!-- TABLET/DESKTOP LAYOUT (visible on md and above) -->
      <!-- ========================================== -->
      <div class="hidden md:block">
        <!-- ROW 1: PUNCH & STATUS CARDS -->
        <div class="mb-6 grid grid-cols-2 gap-6 xl:grid-cols-3">
          <!-- Card 1: Chấm công hôm nay -->
          <div
            class="bg-background border border-border rounded-2xl p-6 shadow-sm flex flex-col justify-between col-span-2 xl:col-span-1"
          >
            <h2 class="text-base font-bold text-foreground mb-4">
              {{ $t('page.attendance.todayPunch') }}
            </h2>
            <div
              class="flex items-center justify-center gap-8 xl:justify-start xl:gap-6"
            >
              <!-- Green Fingerprint Button -->
              <div class="relative flex shrink-0 flex-col items-center">
                <button
                  :disabled="!canPunch"
                  @click="handlePunch"
                  class="group relative size-40 xl:size-32 rounded-full flex flex-col justify-center items-center select-none transition-all duration-300 border-4 border-background focus:outline-none"
                  :class="
                    canPunch
                      ? 'bg-gradient-to-br from-emerald-500 to-green-600 text-white shadow-lg hover:shadow-emerald-500/30 scale-100 hover:scale-105 active:scale-95 cursor-pointer'
                      : 'bg-muted text-muted-foreground border-border cursor-not-allowed shadow-none'
                  "
                >
                  <!-- Pulse animation ring for active state -->
                  <span
                    v-if="canPunch"
                    class="absolute inset-0 rounded-full bg-emerald-400 opacity-20 animate-ping group-hover:animate-none"
                  ></span>

                  <FingerprintIcon class="w-10 h-10 mb-1" />
                  <span class="text-sm font-bold tracking-wide">{{
                    $t('page.attendance.punchButton')
                  }}</span>
                  <span class="text-[10px] opacity-90 mt-0.5 font-mono">{{
                    getTickingTimeString(currentTime)
                  }}</span>
                </button>
              </div>

              <!-- GPS & IP Validation Stack -->
              <div
                class="flex w-full max-w-[16rem] flex-col gap-3 xl:max-w-none xl:flex-1"
              >
                <!-- GPS Card -->
                <div
                  class="rounded-xl p-3 flex items-start gap-2.5 transition-all duration-200 border"
                  :class="
                    gpsValid
                      ? 'bg-emerald-500/10 border-emerald-500/20 text-emerald-600 dark:text-emerald-400'
                      : 'bg-rose-500/10 border-rose-500/20 text-rose-600 dark:text-rose-400'
                  "
                >
                  <div class="mt-0.5">
                    <CheckIcon
                      v-if="gpsValid"
                      class="w-4 h-4 text-emerald-500"
                    />
                    <CloseIcon v-else class="w-4 h-4 text-rose-500" />
                  </div>
                  <div class="flex-1 min-w-0">
                    <div
                      class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-1"
                    >
                      <MapPinIcon class="w-3.5 h-3.5" />
                      {{ $t('page.attendance.gpsLocation') }}
                    </div>
                    <div class="text-[13px] font-bold mt-0.5 leading-none">
                      {{
                        gpsValid
                          ? $t('page.attendance.gpsValid')
                          : $t('page.attendance.gpsInvalid')
                      }}
                    </div>
                    <div class="text-[11px] opacity-80 mt-1 truncate">
                      {{ gpsCoords }}
                    </div>
                  </div>
                  <button
                    @click="handleRefreshGPS"
                    :disabled="gpsLoading"
                    class="p-1 hover:bg-muted rounded-md transition-colors text-muted-foreground hover:text-foreground disabled:opacity-50"
                  >
                    <RefreshIcon
                      class="w-3.5 h-3.5"
                      :class="{ 'animate-spin': gpsLoading }"
                    />
                  </button>
                </div>

                <!-- IP Card -->
                <div
                  class="rounded-xl p-3 flex items-start gap-2.5 transition-all duration-200 border"
                  :class="
                    ipValid
                      ? 'bg-emerald-500/10 border-emerald-500/20 text-emerald-600 dark:text-emerald-400'
                      : 'bg-rose-500/10 border-rose-500/20 text-rose-600 dark:text-rose-400'
                  "
                >
                  <div class="mt-0.5">
                    <CheckIcon
                      v-if="ipValid"
                      class="w-4 h-4 text-emerald-500"
                    />
                    <CloseIcon v-else class="w-4 h-4 text-rose-500" />
                  </div>
                  <div class="flex-1 min-w-0">
                    <div
                      class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-1"
                    >
                      <WifiIcon class="w-3.5 h-3.5" />
                      {{ $t('page.attendance.ipNetwork') }}
                    </div>
                    <div class="text-[13px] font-bold mt-0.5 leading-none">
                      {{
                        ipValid
                          ? $t('page.attendance.ipValid')
                          : $t('page.attendance.ipInvalid')
                      }}
                    </div>
                    <div class="text-[11px] opacity-80 mt-1 truncate">
                      {{ ipAddress }}
                    </div>
                  </div>
                  <button
                    @click="handleRefreshIP"
                    :disabled="ipLoading"
                    class="p-1 hover:bg-muted rounded-md transition-colors text-muted-foreground hover:text-foreground disabled:opacity-50"
                  >
                    <RefreshIcon
                      class="w-3.5 h-3.5"
                      :class="{ 'animate-spin': ipLoading }"
                    />
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Card 2: Thông tin chấm công hôm nay -->
          <div
            class="bg-background border border-border rounded-2xl p-6 shadow-sm flex flex-col"
          >
            <h2 class="text-base font-bold text-foreground mb-4">
              {{ $t('page.attendance.punchInfo') }}
            </h2>
            <div class="flex-1 flex flex-col justify-around">
              <!-- Row 1: Đúng giờ / Muộn -->
              <div
                class="flex items-center gap-4 p-3 bg-muted/35 rounded-xl border border-border/50"
              >
                <div
                  class="w-10 h-10 rounded-lg bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 flex items-center justify-center"
                >
                  <ClockIcon class="w-5 h-5" />
                </div>
                <div>
                  <div class="text-xs text-muted-foreground font-semibold">
                    {{ $t('page.attendance.onTimeStatus') }}
                  </div>
                  <div
                    class="text-sm font-bold mt-0.5"
                    :class="
                      todayPunches.length === 0
                        ? 'text-muted-foreground'
                        : todayOnTimeStatus === $t('page.attendance.onTime')
                          ? 'text-emerald-600 dark:text-emerald-400'
                          : 'text-rose-600 dark:text-rose-400'
                    "
                  >
                    {{
                      todayPunches.length > 0
                        ? todayOnTimeStatus === $t('page.attendance.onTime')
                          ? $t('page.attendance.onTime')
                          : $t('page.attendance.late')
                        : $t('page.attendance.noData')
                    }}
                  </div>
                </div>
              </div>

              <!-- Row 2: Tổng giờ làm -->
              <div
                class="flex items-center gap-4 p-3 bg-muted/35 rounded-xl border border-border/50"
              >
                <div
                  class="w-10 h-10 rounded-lg bg-blue-500/10 text-blue-600 dark:text-blue-400 flex items-center justify-center"
                >
                  <BriefcaseIcon class="w-5 h-5" />
                </div>
                <div>
                  <div class="text-xs text-muted-foreground font-semibold">
                    {{ $t('page.attendance.totalWorkHours') }}
                  </div>
                  <div class="text-sm font-bold text-foreground mt-0.5">
                    {{ todayWorkHoursDecimalStr }}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Card 3: Thống kê tháng -->
          <div
            class="bg-background border border-border rounded-2xl p-6 shadow-sm flex flex-col"
          >
            <h2 class="text-base font-bold text-foreground mb-4">
              {{
                $t('page.attendance.monthlyStats', {
                  month: `${currentMonth.substring(5, 7)}/${currentMonth.substring(0, 4)}`,
                })
              }}
            </h2>
            <div class="flex-1 flex flex-col justify-between text-[13px] gap-2">
              <div
                class="flex justify-between items-center py-1.5 border-b border-border/50"
              >
                <span class="text-muted-foreground font-semibold">{{
                  $t('page.attendance.totalWorkHours')
                }}</span>
                <span class="font-bold text-foreground">{{
                  $t('page.attendance.totalWorkHoursValue', {
                    hours: monthlyTotalHours,
                  })
                }}</span>
              </div>
              <div
                class="flex justify-between items-center py-1.5 border-b border-border/50"
              >
                <span class="text-muted-foreground font-semibold">{{
                  $t('page.attendance.workingDays')
                }}</span>
                <span class="font-bold text-foreground">{{
                  $t('page.attendance.daysValue', {
                    days: monthlyWorkingDays,
                  })
                }}</span>
              </div>
              <div class="flex justify-between items-center py-1.5">
                <span class="text-muted-foreground font-semibold">{{
                  $t('page.attendance.deficientDays')
                }}</span>
                <span class="font-bold text-amber-500">{{
                  $t('page.attendance.daysValue', {
                    days: monthlyDeficientDays,
                  })
                }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- ROW 2: HISTORY CALENDAR & DAY DETAIL -->
        <div class="grid grid-cols-1 gap-6 xl:grid-cols-3">
          <!-- Calendar Column (Span 2) -->
          <div
            class="bg-background border border-border rounded-2xl p-6 shadow-sm flex flex-col xl:col-span-2"
          >
            <div
              class="mb-6 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between"
            >
              <h2 class="text-base font-bold text-foreground">
                {{ $t('page.attendance.history') }}
              </h2>

              <!-- Month selection controls -->
              <div class="flex flex-wrap items-center gap-2">
                <button
                  @click="shiftMonth(-1)"
                  class="p-2 border border-border rounded-lg hover:bg-muted text-muted-foreground transition-colors"
                >
                  <ChevronLeftIcon class="w-4 h-4" />
                </button>
                <DatePicker
                  :allow-clear="false"
                  :aria-label="$t('page.attendance.selectMonth')"
                  class="min-w-[9rem]"
                  :disabled-date="isFutureMonth"
                  :value="currentMonth"
                  format="MM/YYYY"
                  picker="month"
                  value-format="YYYY-MM"
                  @update:value="selectMonth"
                />
                <button
                  :disabled="!canShiftNextMonth"
                  @click="shiftMonth(1)"
                  class="p-2 border border-border rounded-lg hover:bg-muted text-muted-foreground transition-colors disabled:cursor-not-allowed disabled:opacity-40"
                >
                  <ChevronRightIcon class="w-4 h-4" />
                </button>

                <button
                  @click="selectCurrentMonth"
                  class="ml-2 text-xs font-bold py-2 px-3 border border-border rounded-lg hover:bg-muted text-foreground transition-colors"
                >
                  {{ $t('page.attendance.today') }}
                </button>
              </div>
            </div>

            <!-- Calendar Grid -->
            <div
              class="flex-1 flex flex-col border border-border rounded-xl overflow-hidden mb-4"
            >
              <!-- Weekday Header -->
              <div class="grid grid-cols-7 bg-muted/30 border-b border-border">
                <div
                  v-for="d in [
                    $t('page.attendance.weekdays.mon'),
                    $t('page.attendance.weekdays.tue'),
                    $t('page.attendance.weekdays.wed'),
                    $t('page.attendance.weekdays.thu'),
                    $t('page.attendance.weekdays.fri'),
                    $t('page.attendance.weekdays.sat'),
                    $t('page.attendance.weekdays.sun'),
                  ]"
                  :key="d"
                  class="py-2.5 text-center text-xs font-bold text-muted-foreground"
                >
                  {{ d }}
                </div>
              </div>

              <!-- Days Grid -->
              <div
                class="grid grid-cols-7 grid-rows-5 divide-x divide-y divide-border border-b border-r border-border flex-1 min-h-[300px]"
              >
                <div
                  v-for="(cell, idx) in calendarCells"
                  :key="idx"
                  @click="
                    cell.inMonth && !cell.isFuture && openDayDetail(cell.date)
                  "
                  class="p-2 flex flex-col justify-between transition-all duration-200 select-none"
                  :class="
                    getAttendanceCellSurfaceClasses(
                      cell,
                      selectedDate === cell.date && cell.inMonth,
                    )
                  "
                >
                  <!-- Day Number -->
                  <div
                    class="text-xs font-bold"
                    :class="
                      cell.inMonth
                        ? 'text-foreground/80'
                        : 'text-muted-foreground/30'
                    "
                  >
                    {{ cell.dayNumber }}
                  </div>

                  <!-- Punch status contents -->
                  <div class="text-right mt-1">
                    <!-- Punched: shows time of first punch -->
                    <div
                      v-if="cell.status === 'punched'"
                      class="text-[10px] font-bold text-emerald-600 dark:text-emerald-400"
                    >
                      {{ cell.workHours }}
                    </div>

                    <!-- Deficient (Warning status) -->
                    <div
                      v-else-if="cell.status === 'deficient'"
                      class="flex flex-col items-end gap-0.5"
                    >
                      <div
                        class="text-[10px] font-bold text-amber-600 dark:text-amber-400 flex items-center gap-0.5 justify-end"
                      >
                        <AlertTriangleIcon
                          class="w-2.5 h-2.5 text-amber-500 dark:text-amber-400"
                        />
                        {{ $t('page.attendance.statusDeficient') }}
                      </div>
                      <div
                        class="text-[9px] text-amber-600 dark:text-amber-400 font-semibold font-mono"
                      >
                        {{ cell.workHours }}
                      </div>
                    </div>

                    <!-- Approved leave -->
                    <div
                      v-else-if="cell.status === 'leave'"
                      class="text-[10px] font-bold text-blue-600 dark:text-blue-400 flex items-center gap-0.5 justify-end"
                    >
                      <CalendarIcon
                        class="w-2.5 h-2.5 text-blue-500 dark:text-blue-400"
                      />
                      {{ $t('page.attendance.statusLeave') }}
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Legend Info -->
            <div
              class="flex flex-wrap items-center gap-x-6 gap-y-2 text-xs font-medium text-muted-foreground mt-2"
            >
              <div class="flex items-center gap-2">
                <span class="w-3 h-3 rounded-full bg-emerald-500"></span>
                <span>{{ $t('page.attendance.statusPunched') }}</span>
              </div>
              <div class="flex items-center gap-2">
                <span
                  class="w-3 h-3 rounded-full bg-amber-500 flex items-center justify-center text-white text-[8px] font-bold"
                  >!</span
                >
                <span>{{ $t('page.attendance.statusDeficient') }}</span>
              </div>
              <div class="flex items-center gap-2">
                <span class="w-3 h-3 rounded-full bg-blue-500"></span>
                <span>{{ $t('page.attendance.statusLeave') }}</span>
              </div>
              <div class="flex items-center gap-2">
                <span class="w-3 h-3 rounded-full bg-rose-500"></span>
                <span>{{ $t('page.attendance.statusOff') }}</span>
              </div>
            </div>
          </div>

          <!-- Day Detail Column -->
          <div
            class="bg-background border border-border rounded-2xl p-6 shadow-sm flex flex-col justify-between"
          >
            <div>
              <h2 class="text-base font-bold text-foreground mb-2">
                {{ $t('page.attendance.dayDetail') }}
              </h2>
              <div class="text-xs text-muted-foreground font-semibold mb-6">
                {{ formatSelectedDateLabel(selectedDate) }}
              </div>

              <!-- Timeline component -->
              <div
                v-if="selectedDayPunches.length > 0"
                class="relative pl-6 border-l border-border space-y-6 ml-2.5"
              >
                <div
                  v-for="(punch, index) in selectedDayPunches"
                  :key="index"
                  class="relative"
                >
                  <!-- Timeline dot -->
                  <span
                    class="absolute -left-[31px] top-1 w-4 h-4 rounded-full border-2 border-background flex items-center justify-center"
                    :class="
                      index === 0
                        ? 'bg-emerald-500 shadow-sm ring-4 ring-emerald-100 dark:ring-emerald-950'
                        : 'bg-muted-foreground'
                    "
                  >
                  </span>

                  <!-- Timeline item details -->
                  <div>
                    <div
                      class="text-[13px] font-bold text-foreground flex items-center gap-2"
                    >
                      {{ punch.time }}
                      <span
                        class="text-[10px] font-normal px-1.5 py-0.5 rounded bg-muted text-muted-foreground"
                        >{{ $t('page.attendance.punchButton') }}</span
                      >
                    </div>
                    <div
                      class="text-xs text-muted-foreground mt-1 flex flex-col gap-0.5 font-medium"
                    >
                      <span class="flex items-center gap-1"
                        ><MapPinIcon class="w-3 h-3" /> {{ punch.coords }}</span
                      >
                      <span class="flex items-center gap-1"
                        ><WifiIcon class="w-3 h-3" /> IP: {{ punch.ip }}</span
                      >
                    </div>
                  </div>
                </div>
              </div>

              <!-- Empty state -->
              <div
                v-else
                class="flex flex-col items-center justify-center py-16 text-center"
              >
                <AlertTriangleIcon
                  class="w-8 h-8 text-muted-foreground/40 mb-2"
                />
                <span class="text-sm text-muted-foreground font-semibold">{{
                  selectedDayStatusText
                }}</span>
                <span class="text-xs text-muted-foreground/60 mt-1">{{
                  $t('page.attendance.noData')
                }}</span>
              </div>
            </div>

            <!-- Summary at bottom of details -->
            <div
              class="pt-4 border-t border-border mt-6 flex flex-col gap-3 text-xs font-bold text-muted-foreground sm:flex-row sm:justify-between"
            >
              <span
                >{{ $t('page.attendance.statusLabel') }}:
                <span
                  :class="
                    selectedDayStatusText === $t('page.attendance.onTime')
                      ? 'text-emerald-600 dark:text-emerald-400'
                      : selectedDayStatusText === $t('page.attendance.late')
                        ? 'text-rose-600 dark:text-rose-400'
                        : 'text-muted-foreground'
                  "
                  >{{ selectedDayStatusText }}</span
                ></span
              >
              <span
                >{{ $t('page.attendance.workHoursLabel') }}:
                <span class="text-foreground">{{
                  selectedDayHoursText
                }}</span></span
              >
            </div>
          </div>
        </div>
      </div>

      <!-- ========================================== -->
      <!-- MOBILE LAYOUT (visible on screens < md)    -->
      <!-- ========================================== -->
      <div class="md:hidden">
        <!-- Tab buttons at the top -->
        <div class="bg-muted p-1 rounded-xl flex items-center gap-1 mb-5">
          <button
            @click="activeTab = 'punch'"
            class="flex-1 flex items-center justify-center gap-2 py-2 rounded-lg text-xs font-bold transition-all duration-200"
            :class="
              activeTab === 'punch'
                ? 'bg-background text-emerald-600 dark:text-emerald-400 shadow-sm'
                : 'text-muted-foreground'
            "
          >
            <ClockIcon class="w-4 h-4" />
            {{ $t('page.attendance.punchButton') }}
          </button>
          <button
            @click="activeTab = 'history'"
            class="flex-1 flex items-center justify-center gap-2 py-2 rounded-lg text-xs font-bold transition-all duration-200"
            :class="
              activeTab === 'history'
                ? 'bg-background text-emerald-600 dark:text-emerald-400 shadow-sm'
                : 'text-muted-foreground'
            "
          >
            <CalendarIcon class="w-4 h-4" />
            {{ $t('page.attendance.history') }}
          </button>
        </div>

        <!-- ==================== -->
        <!-- TAB 1: PUNCH PAGE    -->
        <!-- ==================== -->
        <div v-if="activeTab === 'punch'" class="flex flex-col gap-5">
          <!-- Live ticking clock & date display -->
          <div
            class="text-center py-4 bg-muted/30 border border-border rounded-2xl"
          >
            <div
              class="text-3xl font-extrabold text-foreground tracking-tight font-mono"
            >
              {{ getTickingTimeString(currentTime) }}
            </div>
            <div class="text-xs text-muted-foreground font-semibold mt-1">
              {{ getTickingDateString(currentTime) }}
            </div>
          </div>

          <!-- Big circle fingerprint button -->
          <div class="flex justify-center py-4">
            <button
              :disabled="!canPunch"
              @click="handlePunch"
              class="group relative w-36 h-36 rounded-full flex flex-col justify-center items-center select-none transition-all duration-300 border-4 border-background focus:outline-none"
              :class="
                canPunch
                  ? 'bg-gradient-to-br from-emerald-500 to-green-600 text-white shadow-xl hover:shadow-emerald-500/30 scale-100 active:scale-95 cursor-pointer'
                  : 'bg-muted text-muted-foreground border-border cursor-not-allowed shadow-none'
              "
            >
              <span
                v-if="canPunch"
                class="absolute inset-0 rounded-full bg-emerald-400 opacity-20 animate-ping group-hover:animate-none"
              ></span>

              <FingerprintIcon class="w-12 h-12 mb-1" />
              <span class="text-sm font-bold tracking-wide">{{
                $t('page.attendance.punchButton')
              }}</span>
              <span class="text-[10px] opacity-80 mt-0.5">{{
                $t('page.attendance.fingerprint')
              }}</span>
            </button>
          </div>

          <!-- GPS and IP condition cards -->
          <div class="grid grid-cols-2 gap-3">
            <!-- GPS Card -->
            <div
              class="rounded-xl p-3 border flex flex-col justify-between gap-2"
              :class="
                gpsValid
                  ? 'bg-emerald-500/10 border-emerald-500/20 text-emerald-600 dark:text-emerald-400'
                  : 'bg-rose-500/10 border-rose-500/20 text-rose-600 dark:text-rose-400'
              "
            >
              <div class="flex justify-between items-start">
                <span
                  class="w-6 h-6 rounded-lg bg-background border border-border flex items-center justify-center"
                >
                  <MapPinIcon class="w-3.5 h-3.5 text-muted-foreground" />
                </span>
                <button
                  @click="handleRefreshGPS"
                  :disabled="gpsLoading"
                  class="text-muted-foreground hover:text-foreground disabled:opacity-50"
                >
                  <RefreshIcon
                    class="w-3.5 h-3.5"
                    :class="{ 'animate-spin': gpsLoading }"
                  />
                </button>
              </div>
              <div>
                <div
                  class="text-[10px] font-bold text-muted-foreground uppercase tracking-wider"
                >
                  {{ $t('page.attendance.gpsLocation') }}
                </div>
                <div class="text-[13px] font-bold mt-0.5">
                  {{
                    gpsValid
                      ? $t('page.attendance.gpsValid')
                      : $t('page.attendance.gpsInvalid')
                  }}
                </div>
                <div class="text-[10px] opacity-80 mt-0.5 truncate">
                  {{ gpsCoords }}
                </div>
              </div>
            </div>

            <!-- IP Card -->
            <div
              class="rounded-xl p-3 border flex flex-col justify-between gap-2"
              :class="
                ipValid
                  ? 'bg-emerald-500/10 border-emerald-500/20 text-emerald-600 dark:text-emerald-400'
                  : 'bg-rose-500/10 border-rose-500/20 text-rose-600 dark:text-rose-400'
              "
            >
              <div class="flex justify-between items-start">
                <span
                  class="w-6 h-6 rounded-lg bg-background border border-border flex items-center justify-center"
                >
                  <WifiIcon class="w-3.5 h-3.5 text-muted-foreground" />
                </span>
                <button
                  @click="handleRefreshIP"
                  :disabled="ipLoading"
                  class="text-muted-foreground hover:text-foreground disabled:opacity-50"
                >
                  <RefreshIcon
                    class="w-3.5 h-3.5"
                    :class="{ 'animate-spin': ipLoading }"
                  />
                </button>
              </div>
              <div>
                <div
                  class="text-[10px] font-bold text-muted-foreground uppercase tracking-wider"
                >
                  {{ $t('page.attendance.ipNetwork') }}
                </div>
                <div class="text-[13px] font-bold mt-0.5">
                  {{
                    ipValid
                      ? $t('page.attendance.ipValid')
                      : $t('page.attendance.ipInvalid')
                  }}
                </div>
                <div class="text-[10px] opacity-80 mt-0.5 truncate">
                  {{ ipAddress }}
                </div>
              </div>
            </div>
          </div>

          <!-- Summaries: Đúng giờ / Muộn & Tổng thời gian làm -->
          <div
            class="bg-background border border-border rounded-2xl p-4 shadow-sm grid grid-cols-2 divide-x divide-border"
          >
            <div class="flex items-center gap-3 pr-2">
              <div
                class="w-8 h-8 rounded-lg bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 flex items-center justify-center flex-shrink-0"
              >
                <ClockIcon class="w-4 h-4" />
              </div>
              <div class="min-w-0">
                <div
                  class="text-[10px] text-muted-foreground font-bold uppercase tracking-wider"
                >
                  {{ $t('page.attendance.onTimeStatus') }}
                </div>
                <div
                  class="text-xs font-extrabold truncate"
                  :class="
                    todayPunches.length === 0
                      ? 'text-muted-foreground'
                      : todayOnTimeStatus === $t('page.attendance.onTime')
                        ? 'text-emerald-600 dark:text-emerald-400'
                        : 'text-rose-600 dark:text-rose-400'
                  "
                >
                  {{
                    todayPunches.length > 0
                      ? todayOnTimeStatus === $t('page.attendance.onTime')
                        ? $t('page.attendance.onTime')
                        : $t('page.attendance.late')
                      : $t('page.attendance.noData')
                  }}
                </div>
              </div>
            </div>

            <div class="flex items-center gap-3 pl-4">
              <div
                class="w-8 h-8 rounded-lg bg-blue-500/10 text-blue-600 dark:text-blue-400 flex items-center justify-center flex-shrink-0"
              >
                <BriefcaseIcon class="w-4 h-4" />
              </div>
              <div class="min-w-0">
                <div
                  class="text-[10px] text-muted-foreground font-bold uppercase tracking-wider"
                >
                  {{ $t('page.attendance.totalWorkHours') }}
                </div>
                <div class="text-xs font-extrabold text-foreground truncate">
                  {{ todayWorkHoursMobileStr }}
                </div>
              </div>
            </div>
          </div>

          <!-- Punches Today Timeline List -->
          <div
            class="bg-background border border-border rounded-2xl p-5 shadow-sm"
          >
            <h3 class="text-sm font-bold text-foreground mb-4">
              {{ $t('page.attendance.punchesToday') }}
            </h3>

            <div
              v-if="todayPunches.length > 0"
              class="relative pl-6 border-l border-border space-y-5 ml-1.5"
            >
              <div
                v-for="(punch, index) in todayPunches"
                :key="index"
                class="relative"
              >
                <span
                  class="absolute -left-[30px] top-1 w-3.5 h-3.5 rounded-full border-2 border-background flex items-center justify-center"
                  :class="
                    index === 0
                      ? 'bg-emerald-500 shadow-sm ring-4 ring-emerald-100 dark:ring-emerald-950'
                      : 'bg-muted-foreground'
                  "
                >
                </span>
                <div>
                  <div class="text-xs font-bold text-foreground">
                    {{ punch.time }}
                  </div>
                  <div
                    class="text-[10px] text-muted-foreground mt-0.5 flex flex-col gap-0.5"
                  >
                    <span class="flex items-center gap-1"
                      ><MapPinIcon class="w-2.5 h-2.5" />
                      {{ punch.coords }}</span
                    >
                    <span class="flex items-center gap-1"
                      ><WifiIcon class="w-2.5 h-2.5" /> IP: {{ punch.ip }}</span
                    >
                  </div>
                </div>
              </div>
            </div>

            <div
              v-else
              class="text-center py-8 text-muted-foreground text-xs font-semibold"
            >
              {{ $t('page.attendance.noData') }}
            </div>
          </div>
        </div>

        <!-- ==================== -->
        <!-- TAB 2: HISTORY PAGE  -->
        <!-- ==================== -->
        <div v-else class="flex flex-col gap-5">
          <!-- Month Selector -->
          <div
            class="flex justify-between items-center bg-background border border-border rounded-xl p-2.5 shadow-sm"
          >
            <button
              @click="shiftMonth(-1)"
              class="p-1.5 hover:bg-muted text-muted-foreground rounded-lg"
            >
              <ChevronLeftIcon class="w-4 h-4" />
            </button>
            <DatePicker
              :allow-clear="false"
              :aria-label="$t('page.attendance.selectMonth')"
              :disabled-date="isFutureMonth"
              :value="currentMonth"
              class="min-w-32"
              format="MM/YYYY"
              picker="month"
              size="small"
              value-format="YYYY-MM"
              @update:value="selectMonth"
            />
            <button
              :disabled="!canShiftNextMonth"
              @click="shiftMonth(1)"
              class="p-1.5 hover:bg-muted text-muted-foreground rounded-lg disabled:cursor-not-allowed disabled:opacity-40"
            >
              <ChevronRightIcon class="w-4 h-4" />
            </button>
          </div>

          <!-- Quick Metrics Chips -->
          <div class="grid grid-cols-3 gap-2">
            <div
              class="bg-emerald-500/5 border border-emerald-500/10 p-3 rounded-xl flex flex-col items-center text-center"
            >
              <ClockIcon class="w-4 h-4 text-emerald-500 mb-1" />
              <span
                class="text-[9px] text-muted-foreground font-bold uppercase"
                >{{ $t('page.attendance.workHoursLabel') }}</span
              >
              <span
                class="text-xs font-black text-emerald-600 dark:text-emerald-400 mt-0.5"
                >{{
                  $t('page.attendance.totalWorkHoursValue', {
                    hours: monthlyTotalHours,
                  })
                }}</span
              >
            </div>
            <div
              class="bg-blue-500/5 border border-blue-500/10 p-3 rounded-xl flex flex-col items-center text-center"
            >
              <BriefcaseIcon class="w-4 h-4 text-blue-500 mb-1" />
              <span
                class="text-[9px] text-muted-foreground font-bold uppercase"
                >{{ $t('page.attendance.workingDays') }}</span
              >
              <span
                class="text-xs font-black text-blue-600 dark:text-blue-400 mt-0.5"
                >{{
                  $t('page.attendance.daysValue', {
                    days: monthlyWorkingDays,
                  })
                }}</span
              >
            </div>
            <div
              class="bg-amber-500/5 border border-amber-500/10 p-3 rounded-xl flex flex-col items-center text-center"
            >
              <CalendarIcon class="w-4 h-4 text-amber-500 mb-1" />
              <span
                class="text-[9px] text-muted-foreground font-bold uppercase"
                >{{ $t('page.attendance.deficientDays') }}</span
              >
              <span
                class="text-xs font-black text-amber-600 dark:text-amber-400 mt-0.5"
                >{{
                  $t('page.attendance.daysValue', {
                    days: monthlyDeficientDays,
                  })
                }}</span
              >
            </div>
          </div>

          <!-- Calendar Grid -->
          <div
            class="bg-background border border-border p-4 rounded-2xl shadow-sm"
          >
            <div class="grid grid-cols-7 border-b border-border pb-2">
              <div
                v-for="d in [
                  $t('page.attendance.weekdaysShort.mon'),
                  $t('page.attendance.weekdaysShort.tue'),
                  $t('page.attendance.weekdaysShort.wed'),
                  $t('page.attendance.weekdaysShort.thu'),
                  $t('page.attendance.weekdaysShort.fri'),
                  $t('page.attendance.weekdaysShort.sat'),
                  $t('page.attendance.weekdaysShort.sun'),
                ]"
                :key="d"
                class="text-center text-[10px] font-bold text-muted-foreground"
              >
                {{ d }}
              </div>
            </div>

            <div
              class="grid grid-cols-7 divide-x divide-y divide-border border-b border-r border-border min-h-[220px]"
            >
              <div
                v-for="(cell, idx) in calendarCells"
                :key="idx"
                @click="
                  cell.inMonth && !cell.isFuture && openDayDetail(cell.date)
                "
                class="pt-1.5 pb-2 px-1 flex flex-col justify-between items-center transition-all duration-200 select-none min-h-[50px]"
                :class="
                  getAttendanceCellSurfaceClasses(
                    cell,
                    selectedDate === cell.date && cell.inMonth,
                  )
                "
              >
                <!-- Day Number -->
                <span
                  class="text-[11px] font-bold"
                  :class="
                    cell.inMonth
                      ? 'text-foreground'
                      : 'text-muted-foreground/30'
                  "
                  >{{ cell.dayNumber }}</span
                >

                <!-- Status indicator (dot) -->
                <span
                  v-if="cell.inMonth"
                  class="w-1.5 h-1.5 rounded-full mt-1"
                  :class="{
                    'bg-emerald-500': cell.status === 'punched',
                    'bg-amber-500': cell.status === 'deficient',
                    'bg-blue-500': cell.status === 'leave',
                    'bg-rose-500': cell.status === 'empty',
                    'bg-transparent': !cell.inMonth || cell.isFuture,
                  }"
                >
                </span>
              </div>
            </div>

            <!-- Legend Info Mobile -->
            <div
              class="grid grid-cols-2 gap-2 text-[10px] font-bold text-muted-foreground mt-4 border-t border-border pt-3"
            >
              <div class="flex items-center gap-1">
                <span class="w-2.5 h-2.5 rounded-full bg-emerald-500"></span>
                <span>{{ $t('page.attendance.statusPunched') }}</span>
              </div>
              <div class="flex items-center gap-1">
                <span class="w-2.5 h-2.5 rounded-full bg-amber-500"></span>
                <span>{{ $t('page.attendance.statusDeficient') }}</span>
              </div>
              <div class="flex items-center gap-1">
                <span class="w-2.5 h-2.5 rounded-full bg-blue-500"></span>
                <span>{{ $t('page.attendance.statusLeave') }}</span>
              </div>
              <div class="flex items-center gap-1">
                <span class="w-2.5 h-2.5 rounded-full bg-rose-500"></span>
                <span>{{ $t('page.attendance.statusOff') }}</span>
              </div>
            </div>
          </div>

          <!-- Selected Date Details Mobile -->
          <div
            class="bg-background border border-border p-5 rounded-2xl shadow-sm"
          >
            <h3
              class="text-xs font-bold text-muted-foreground uppercase tracking-wider mb-2"
            >
              {{ $t('page.attendance.dayDetail') }}
            </h3>
            <div class="text-sm font-black text-foreground mb-4">
              {{ formatSelectedDateLabel(selectedDate) }}
            </div>

            <!-- Timeline -->
            <div
              v-if="selectedDayPunches.length > 0"
              class="relative pl-6 border-l border-border space-y-5 ml-1.5"
            >
              <div
                v-for="(punch, index) in selectedDayPunches"
                :key="index"
                class="relative"
              >
                <span
                  class="absolute -left-[30px] top-1 w-3.5 h-3.5 rounded-full border-2 border-background flex items-center justify-center"
                  :class="
                    index === 0
                      ? 'bg-emerald-500 shadow-sm ring-4 ring-emerald-100 dark:ring-emerald-950'
                      : 'bg-muted-foreground'
                  "
                >
                </span>
                <div>
                  <div class="text-xs font-extrabold text-foreground">
                    {{ punch.time }}
                  </div>
                  <div
                    class="text-[10px] text-muted-foreground mt-0.5 flex flex-col gap-0.5"
                  >
                    <span class="flex items-center gap-1"
                      ><MapPinIcon class="w-2.5 h-2.5" />
                      {{ punch.coords }}</span
                    >
                    <span class="flex items-center gap-1"
                      ><WifiIcon class="w-2.5 h-2.5" /> IP: {{ punch.ip }}</span
                    >
                  </div>
                </div>
              </div>
            </div>

            <!-- Empty State Mobile -->
            <div
              v-else
              class="text-center py-8 text-muted-foreground text-xs font-semibold"
            >
              {{ $t('page.attendance.noData') }}
            </div>

            <!-- Summary metrics -->
            <div
              class="flex justify-between text-xs font-bold text-muted-foreground mt-5 pt-3 border-t border-border"
            >
              <span
                >{{ $t('page.attendance.statusLabel') }}:
                <span
                  :class="
                    selectedDayStatusText === $t('page.attendance.onTime')
                      ? 'text-emerald-600 dark:text-emerald-400'
                      : selectedDayStatusText === $t('page.attendance.late')
                        ? 'text-rose-600 dark:text-rose-400'
                        : 'text-muted-foreground'
                  "
                  >{{ selectedDayStatusText }}</span
                ></span
              >
              <span
                >{{ $t('page.attendance.totalHoursLabel') }}:
                <span class="text-foreground">{{
                  selectedDayHoursText
                }}</span></span
              >
            </div>
          </div>
        </div>
      </div>
    </div>
  </Page>
</template>

<style scoped>
@keyframes fade-in {
  from {
    opacity: 0;
    transform: translateY(8px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in {
  animation: fade-in 0.25s ease-out forwards;
}

/* Custom transitions and elevations */
button:disabled {
  opacity: 0.7;
  filter: grayscale(100%);
}

/* Pulsing outline for the fingerprint button in valid state */
@keyframes pulse-glow {
  0% {
    box-shadow: 0 0 0 0 rgb(16 185 129 / 40%);
  }

  75% {
    box-shadow: 0 0 0 12px rgb(16 185 129 / 0%);
  }

  100% {
    box-shadow: 0 0 0 0 rgb(16 185 129 / 0%);
  }
}

.bg-gradient-to-br {
  transition:
    transform 0.2s cubic-bezier(0.34, 1.56, 0.64, 1),
    box-shadow 0.2s ease;
}
</style>
