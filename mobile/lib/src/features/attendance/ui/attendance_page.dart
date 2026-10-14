import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/core/widgets/app_top_bar.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/attendance/logic/attendance_date.dart';
import 'package:obee_mobile/src/features/attendance/logic/attendance_formatters.dart';
import 'package:obee_mobile/src/features/attendance/logic/attendance_rules.dart';
import 'package:obee_mobile/src/features/attendance/state/attendance_controller.dart';

enum AttendanceTab { punch, calendar }

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  var _activeTab = AttendanceTab.punch;
  var _currentTime = attendanceNow();
  Timer? _clockTimer;
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (mounted) {
          unawaited(
            ref
                .read(attendanceControllerProvider.notifier)
                .refreshForCurrentDay(),
          );
        }
      },
    );
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      setState(() => _currentTime = attendanceNow());
      if (ref.read(attendanceControllerProvider).today != attendanceToday()) {
        unawaited(
          ref
              .read(attendanceControllerProvider.notifier)
              .refreshForCurrentDay(),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(ref.read(attendanceControllerProvider.notifier).bootstrap());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final attendanceState = ref.watch(attendanceControllerProvider);
    final controller = ref.read(attendanceControllerProvider.notifier);
    final bestEvaluation = controller.bestEvaluation;
    final rangeSummaryByDate = {
      for (final summary in attendanceState.rangeSummaries)
        summary.date: summary,
    };
    final displayedDayDetail =
        attendanceState.selectedDate == attendanceState.today
        ? attendanceState.todayDetail
        : attendanceState.selectedDayDetail;

    ref.listen<String?>(
      attendanceControllerProvider.select((state) => state.feedbackMessage),
      (_, next) {
        if (next == null || !context.mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_feedbackText(next))));

        // Khi chấm công xong thì chuyển luôn qua tab lịch sử
        if (next == 'attendanceRecorded') {
          setState(() => _activeTab = AttendanceTab.calendar);
        }

        controller.clearFeedbackMessage();
      },
    );

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AppTopBar(title: 'Chấm công'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _AttendanceTabBar(
                  activeTab: _activeTab,
                  onChanged: (tab) => setState(() => _activeTab = tab),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(attendanceControllerProvider.notifier).refresh(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: _activeTab == AttendanceTab.punch
                        ? _PunchTab(
                            locale: locale,
                            currentTime: _currentTime,
                            bestEvaluation: bestEvaluation,
                            loadingContext: attendanceState.loadingContext,
                            punching: attendanceState.punching,
                            canPunch: canPunchAttendance(
                              hasShiftToday:
                                  attendanceState.contextData?.hasShiftToday ==
                                  true,
                              locationOrIpEligible:
                                  bestEvaluation?.eligibility.eligible == true,
                            ),
                            positionState: attendanceState.positionState,
                            contextData: attendanceState.contextData,
                            onPunch: () async {
                              await controller.punch();
                              if (mounted &&
                                  ref
                                          .read(attendanceControllerProvider)
                                          .feedbackMessage ==
                                      'attendanceRecorded') {
                                setState(
                                  () => _activeTab = AttendanceTab.calendar,
                                );
                              }
                            },
                            onRefreshPosition:
                                attendanceState.positionState ==
                                    PositionState.deniedForever
                                ? controller.openLocationSettings
                                : controller.requestCurrentPosition,
                            onRefreshContext: controller.loadContext,
                            today: attendanceState.today,
                            todayDetail: attendanceState.todayDetail,
                            loadingTodayLogs: attendanceState.loadingTodayLogs,
                          )
                        : _CalendarTab(
                            locale: locale,
                            today: attendanceState.today,
                            calendarMonthStart:
                                attendanceState.calendarMonthStart,
                            rangeSummaryByDate: rangeSummaryByDate,
                            selectedDate: attendanceState.selectedDate,
                            displayedDayDetail: displayedDayDetail,
                            loadingSelectedDay:
                                attendanceState.loadingSelectedDay,
                            onPreviousMonth: () =>
                                controller.shiftCalendarMonth(-1),
                            onNextMonth: () => controller.shiftCalendarMonth(1),
                            onSelectDay: (date) =>
                                unawaited(controller.openDayDetail(date)),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _feedbackText(String message) {
    return switch (message) {
      'attendanceNoShift' => 'Bạn chưa được phân ca làm việc hôm nay.',
      'attendanceNoAssignedLocation' => 'Bạn chưa được gán địa điểm chấm công.',
      'attendanceNotEligible' => 'IP và vị trí đều chưa hợp lệ để chấm công.',
      'attendanceRecorded' => 'Đã ghi nhận chấm công.',
      'attendanceConnectError' => 'Không thể kết nối máy chủ.',
      _ => message,
    };
  }
}

class _AttendanceThemeColors {
  _AttendanceThemeColors(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    cardBg = isDark
        ? colorScheme.surfaceContainer
        : colorScheme.surfaceContainerLowest;

    successAccent = isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A);
    successBg = isDark
        ? const Color(0xFF065F46).withValues(alpha: 0.35)
        : const Color(0xFFF0FDF4);
    successBorder = isDark
        ? const Color(0xFF059669).withValues(alpha: 0.4)
        : const Color(0xFFDCFCE7);
    successIconBg = isDark
        ? const Color(0xFF065F46).withValues(alpha: 0.5)
        : const Color(0xFFDCFCE7);

    warningAccent = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
    warningBg = isDark
        ? const Color(0xFF78350F).withValues(alpha: 0.35)
        : const Color(0xFFFFFBEB);
    warningBorder = isDark
        ? const Color(0xFFD97706).withValues(alpha: 0.4)
        : const Color(0xFFFEF3C7);
    warningIconBg = isDark
        ? const Color(0xFF78350F).withValues(alpha: 0.5)
        : const Color(0xFFFEF3C7);

    errorAccent = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    errorBg = isDark
        ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
        : const Color(0xFFFEF2F2);
    errorBorder = isDark
        ? const Color(0xFFDC2626).withValues(alpha: 0.4)
        : const Color(0xFFFEE2E2);
    errorIconBg = isDark
        ? const Color(0xFF7F1D1D).withValues(alpha: 0.5)
        : const Color(0xFFFEE2E2);

    infoAccent = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    infoBg = isDark
        ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
        : const Color(0xFFEFF6FF);
    infoBorder = isDark
        ? const Color(0xFF2563EB).withValues(alpha: 0.4)
        : const Color(0xFFDBEAFE);
    infoIconBg = isDark
        ? const Color(0xFF1E3A8A).withValues(alpha: 0.5)
        : const Color(0xFFDBEAFE);

    primaryAccent = colorScheme.primary;
    primaryBg = colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.08);
    primaryBorder = colorScheme.primary.withValues(alpha: isDark ? 0.4 : 0.2);
    primaryIconBg = colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.12);
  }

  late final Color cardBg;

  late final Color successAccent;
  late final Color successBg;
  late final Color successBorder;
  late final Color successIconBg;

  late final Color warningAccent;
  late final Color warningBg;
  late final Color warningBorder;
  late final Color warningIconBg;

  late final Color errorAccent;
  late final Color errorBg;
  late final Color errorBorder;
  late final Color errorIconBg;

  late final Color infoAccent;
  late final Color infoBg;
  late final Color infoBorder;
  late final Color infoIconBg;

  late final Color primaryAccent;
  late final Color primaryBg;
  late final Color primaryBorder;
  late final Color primaryIconBg;
}

class _AttendanceTabBar extends StatelessWidget {
  const _AttendanceTabBar({required this.activeTab, required this.onChanged});

  final AttendanceTab activeTab;
  final ValueChanged<AttendanceTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AttendanceTabButton(
              label: 'Chấm công',
              icon: Icons.access_time_filled,
              selected: activeTab == AttendanceTab.punch,
              onTap: () => onChanged(AttendanceTab.punch),
            ),
          ),
          Expanded(
            child: _AttendanceTabButton(
              label: 'Lịch sử',
              icon: Icons.calendar_month,
              selected: activeTab == AttendanceTab.calendar,
              onTap: () => onChanged(AttendanceTab.calendar),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTabButton extends StatelessWidget {
  const _AttendanceTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? colorScheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      elevation: selected ? 2 : 0,
      shadowColor: colorScheme.primary.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PunchTab extends StatelessWidget {
  const _PunchTab({
    required this.locale,
    required this.currentTime,
    required this.bestEvaluation,
    required this.loadingContext,
    required this.punching,
    required this.canPunch,
    required this.positionState,
    required this.contextData,
    required this.onPunch,
    required this.onRefreshPosition,
    required this.onRefreshContext,
    required this.today,
    required this.todayDetail,
    required this.loadingTodayLogs,
  });

  final String locale;
  final DateTime currentTime;
  final AttendanceEvaluation? bestEvaluation;
  final bool loadingContext;
  final bool punching;
  final bool canPunch;
  final PositionState positionState;
  final AttendanceContext? contextData;
  final VoidCallback onPunch;
  final Future<void> Function() onRefreshPosition;
  final Future<void> Function() onRefreshContext;
  final String today;
  final AttendanceDayDetail? todayDetail;
  final bool loadingTodayLogs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeColors = _AttendanceThemeColors(colorScheme);
    final hasShiftToday = contextData?.hasShiftToday == true;
    final isPunchedToday = todayDetail != null && todayDetail!.logs.isNotEmpty;
    final isLateToday =
        todayDetail != null &&
        (todayDetail!.isLate ||
            (todayDetail!.firstCheckInAt != null &&
                contextData?.shiftStartAt != null &&
                isAttendanceLate(
                  checkInAt: DateTime.parse(todayDetail!.firstCheckInAt!),
                  shiftStartAt: DateTime.parse(contextData!.shiftStartAt!),
                )) ||
            (todayDetail!.logs.isNotEmpty &&
                contextData?.shiftStartAt != null &&
                isAttendanceLate(
                  checkInAt: DateTime.parse(todayDetail!.logs.first.checkedAt),
                  shiftStartAt: DateTime.parse(contextData!.shiftStartAt!),
                )));
    final totalWorkSecondsToday = todayDetail == null
        ? 0
        : calculateTotalWorkSeconds(logs: todayDetail!.logs);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            // Digital Clock & Date Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: themeColors.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    formatVietnameseFullDate(currentTime),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatAttendanceClock(currentTime),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 3-Item Info Card
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 10 : 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: themeColors.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoPillItem(
                      iconWidget: Container(
                        width: isNarrow ? 32 : 36,
                        height: isNarrow ? 32 : 36,
                        decoration: BoxDecoration(
                          color: themeColors.primaryIconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.business_center_outlined,
                          size: isNarrow ? 16 : 18,
                          color: themeColors.primaryAccent,
                        ),
                      ),
                      title: 'Ca làm việc',
                      subtitle: !hasShiftToday ? 'Chưa có ca' : 'Hành chính',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                  Expanded(
                    child: _InfoPillItem(
                      iconWidget: Container(
                        width: isNarrow ? 28 : 32,
                        height: isNarrow ? 28 : 32,
                        decoration: BoxDecoration(
                          color: !hasShiftToday
                              ? themeColors.errorIconBg
                              : (isPunchedToday
                                    ? (isLateToday
                                          ? themeColors.warningIconBg
                                          : themeColors.successIconBg)
                                    : themeColors.errorIconBg),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: !hasShiftToday
                                ? themeColors.errorAccent
                                : (isPunchedToday
                                      ? (isLateToday
                                            ? themeColors.warningAccent
                                            : themeColors.successAccent)
                                      : themeColors.errorAccent),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      title: !hasShiftToday
                          ? 'Chưa phân ca'
                          : (isPunchedToday
                                ? (isLateToday ? 'Đi muộn' : 'Đã chấm công')
                                : 'Chưa chấm công'),
                      subtitle: !hasShiftToday
                          ? 'Không thể chấm'
                          : (isPunchedToday
                                ? '${todayDetail!.logs.length} lượt'
                                : (canPunch ? 'Sẵn sàng' : 'Chưa sẵn sàng')),
                    ),
                  ),
                ],
              ),
            ),
            if (!hasShiftToday) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: themeColors.warningBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: themeColors.warningBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: themeColors.warningAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chỉ khi được phân ca mới có thể chấm công. Bạn chưa được phân ca làm việc hôm nay.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: themeColors.warningAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Validation Cards Row
            Row(
              children: [
                Expanded(
                  child: _ValidationCard(
                    icon: Icons.location_on,
                    title: positionState != PositionState.ready
                        ? positionStateLabel(positionState)
                        : bestEvaluation?.eligibility.locationMatched == true
                        ? 'GPS hợp lệ'
                        : (bestEvaluation == null
                              ? 'Vị trí GPS'
                              : 'GPS ngoài vùng'),
                    matched:
                        bestEvaluation?.eligibility.locationMatched == true,
                    themeColors: themeColors,
                    onTap: () => unawaited(onRefreshPosition()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ValidationCard(
                    icon: Icons.wifi,
                    title: loadingContext
                        ? 'Đang kiểm tra IP'
                        : contextData?.ipAddress == null
                        ? 'Chưa có IP'
                        : bestEvaluation?.eligibility.ipMatched == true
                        ? 'IP hợp lệ'
                        : (bestEvaluation == null
                              ? 'Mạng IP'
                              : 'IP không hợp lệ'),
                    matched: bestEvaluation?.eligibility.ipMatched == true,
                    themeColors: themeColors,
                    onTap: () => unawaited(onRefreshContext()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Big Fingerprint Punch Button
            Center(
              child: _PunchFingerprintButton(
                onPunch: onPunch,
                punching: punching,
                loadingContext: loadingContext,
                canPunch: canPunch,
                hasShiftToday: hasShiftToday,
                isNarrow: isNarrow,
                onNoShift: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bạn chưa được phân ca làm việc hôm nay.'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Location Info Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: themeColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: themeColors.primaryIconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 20,
                      color: themeColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          bestEvaluation == null
                              ? 'Chưa có địa điểm khả dụng'
                              : bestEvaluation!.location.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color:
                                    bestEvaluation
                                            ?.eligibility
                                            .locationMatched ==
                                        true
                                    ? themeColors.successAccent
                                    : themeColors.errorAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                positionState != PositionState.ready
                                    ? positionStateLabel(positionState)
                                    : bestEvaluation
                                              ?.eligibility
                                              .locationMatched ==
                                          true
                                    ? 'Trong khu vực cho phép'
                                    : (bestEvaluation == null
                                          ? 'Đang kiểm tra vị trí'
                                          : 'Ngoài khu vực cho phép'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Re-check Outlined Button
            OutlinedButton.icon(
              onPressed: () async {
                await Future.wait([onRefreshPosition(), onRefreshContext()]);
              },
              icon: Icon(Icons.sync, size: 18, color: colorScheme.primary),
              label: const Text('Kiểm tra lại'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                  width: 1.2,
                ),
                foregroundColor: colorScheme.primary,
                backgroundColor: themeColors.cardBg,
              ),
            ),
            if (isPunchedToday) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Lịch sử hôm nay',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  _WorkHoursBadge(
                    value: formatWorkSeconds(totalWorkSecondsToday),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _AttendanceLogList(
                locale: locale,
                detail: todayDetail,
                loading: loadingTodayLogs,
                compact: true,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _InfoPillItem extends StatelessWidget {
  const _InfoPillItem({
    required this.iconWidget,
    required this.title,
    required this.subtitle,
  });

  final Widget iconWidget;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  const _ValidationCard({
    required this.icon,
    required this.title,
    required this.matched,
    required this.themeColors,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool matched;
  final _AttendanceThemeColors themeColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bg = matched ? themeColors.successBg : themeColors.errorBg;
    final border = matched
        ? themeColors.successBorder
        : themeColors.errorBorder;
    final iconBg = matched
        ? themeColors.successIconBg
        : themeColors.errorIconBg;
    final accent = matched
        ? themeColors.successAccent
        : themeColors.errorAccent;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  matched ? Icons.check : Icons.priority_high,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PunchFingerprintButton extends StatelessWidget {
  const _PunchFingerprintButton({
    required this.onPunch,
    required this.punching,
    required this.loadingContext,
    required this.canPunch,
    required this.hasShiftToday,
    required this.isNarrow,
    required this.onNoShift,
  });

  final VoidCallback onPunch;
  final bool punching;
  final bool loadingContext;
  final bool canPunch;
  final bool hasShiftToday;
  final bool isNarrow;
  final VoidCallback onNoShift;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final outerSize = isNarrow ? 164.0 : 180.0;
    final midSize = isNarrow ? 138.0 : 152.0;
    final innerSize = isNarrow ? 114.0 : 126.0;

    final VoidCallback? buttonAction = loadingContext || punching
        ? null
        : (!hasShiftToday ? onNoShift : (canPunch ? onPunch : null));

    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary.withValues(alpha: 0.08),
      ),
      alignment: Alignment.center,
      child: Container(
        width: midSize,
        height: midSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary.withValues(alpha: 0.16),
        ),
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FilledButton(
            key: const ValueKey('attendance_punch_button'),
            onPressed: buttonAction,
            style: FilledButton.styleFrom(
              minimumSize: Size.square(innerSize),
              maximumSize: Size.square(innerSize),
              padding: EdgeInsets.zero,
              backgroundColor: colorScheme.primary,
              disabledBackgroundColor: colorScheme.primary.withValues(
                alpha: 0.45,
              ),
              shape: const CircleBorder(),
              elevation: 0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: isNarrow ? 42 : 48,
                  color: colorScheme.onPrimary,
                ),
                const SizedBox(height: 4),
                Text(
                  punching ? 'Đang ghi...' : 'Chấm công',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isNarrow ? 13 : 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  const _CalendarTab({
    required this.locale,
    required this.today,
    required this.calendarMonthStart,
    required this.rangeSummaryByDate,
    required this.selectedDate,
    required this.displayedDayDetail,
    required this.loadingSelectedDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDay,
  });

  final String locale;
  final String today;
  final String calendarMonthStart;
  final Map<String, AttendanceRangeSummary> rangeSummaryByDate;
  final String selectedDate;
  final AttendanceDayDetail? displayedDayDetail;
  final bool loadingSelectedDay;
  final Future<void> Function() onPreviousMonth;
  final Future<void> Function() onNextMonth;
  final ValueChanged<String> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeColors = _AttendanceThemeColors(colorScheme);
    final monthEnd = getAttendanceMonthEndValue(calendarMonthStart);
    final cells = buildAttendanceCalendarCells(calendarMonthStart, monthEnd);
    final weekdayLabels = const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    final monthParsed = parseAttendanceDateValue(calendarMonthStart);
    final selectedDt = parseAttendanceDateValue(selectedDate);
    final selectedSummary = rangeSummaryByDate[selectedDate];
    final selectedState = calendarDayAttendanceState(selectedSummary);

    // Compute monthly metrics
    final summariesInMonth = rangeSummaryByDate.values.toList();
    final checkedCount = summariesInMonth
        .where(
          (s) =>
              calendarDayAttendanceState(s) ==
              CalendarDayAttendanceState.checked,
        )
        .length;
    final lateCount = summariesInMonth
        .where(
          (s) =>
              calendarDayAttendanceState(s) ==
                  CalendarDayAttendanceState.late ||
              calendarDayAttendanceState(s) ==
                  CalendarDayAttendanceState.incomplete,
        )
        .length;
    final absentCount = summariesInMonth
        .where(
          (s) =>
              s.date.compareTo(today) <= 0 &&
              calendarDayAttendanceState(s) ==
                  CalendarDayAttendanceState.absent,
        )
        .length;
    final totalSeconds = summariesInMonth.fold<int>(
      0,
      (sum, s) => sum + s.totalWorkSeconds,
    );
    final totalHours = totalSeconds / 3600;

    final (
      statusLabel,
      statusColor,
      statusBg,
      statusBorder,
      statusIcon,
    ) = switch (selectedState) {
      CalendarDayAttendanceState.checked => (
        'Đã chấm công',
        themeColors.successAccent,
        themeColors.successBg,
        themeColors.successBorder,
        Icons.check_circle_outline,
      ),
      CalendarDayAttendanceState.late => (
        'Muộn',
        themeColors.warningAccent,
        themeColors.warningBg,
        themeColors.warningBorder,
        Icons.info_outline,
      ),
      CalendarDayAttendanceState.incomplete => (
        'Thiếu công',
        themeColors.warningAccent,
        themeColors.warningBg,
        themeColors.warningBorder,
        Icons.info_outline,
      ),
      CalendarDayAttendanceState.leave => (
        'Nghỉ phép',
        themeColors.infoAccent,
        themeColors.infoBg,
        themeColors.infoBorder,
        Icons.beach_access,
      ),
      CalendarDayAttendanceState.absent => (
        'Vắng mặt',
        themeColors.errorAccent,
        themeColors.errorBg,
        themeColors.errorBorder,
        Icons.cancel,
      ),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            // Calendar Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColors.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Month navigation row
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => unawaited(onPreviousMonth()),
                        icon: Icon(
                          Icons.chevron_left,
                          color: colorScheme.onSurface,
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          formatVietnameseMonthYear(monthParsed),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => unawaited(onNextMonth()),
                        icon: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface,
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Weekday header row
                  Row(
                    children: weekdayLabels
                        .map(
                          (label) => Expanded(
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  // Calendar cells grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          childAspectRatio: 0.95,
                        ),
                    itemCount: cells.length,
                    itemBuilder: (context, index) {
                      final cell = cells[index];
                      final summary = rangeSummaryByDate[cell.date];
                      final isFutureDay = cell.date.compareTo(today) > 0;
                      final isSelectable = cell.inRange && !isFutureDay;
                      final isSelected = cell.date == selectedDate;
                      final isToday = cell.date == today;

                      return _CalendarDayCell(
                        cell: cell,
                        summary: summary,
                        isSelectable: isSelectable,
                        isSelected: isSelected,
                        isToday: isToday,
                        today: today,
                        themeColors: themeColors,
                        onTap: () => onSelectDay(cell.date),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Section "Tổng quan tháng MM/yyyy"
            Text(
              'Tổng quan ${formatVietnameseMonthYearShort(monthParsed).toLowerCase()}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            // 4 Metric cards
            Row(
              children: [
                _OverviewMetricCard(
                  icon: Icons.calendar_today_outlined,
                  iconColor: themeColors.successAccent,
                  iconBg: themeColors.successIconBg,
                  value: '$checkedCount',
                  label: 'Ngày công',
                  themeColors: themeColors,
                ),
                const SizedBox(width: 8),
                _OverviewMetricCard(
                  icon: Icons.access_time,
                  iconColor: themeColors.warningAccent,
                  iconBg: themeColors.warningIconBg,
                  value: '$lateCount',
                  label: 'Muộn',
                  themeColors: themeColors,
                ),
                const SizedBox(width: 8),
                _OverviewMetricCard(
                  icon: Icons.close,
                  iconColor: themeColors.errorAccent,
                  iconBg: themeColors.errorIconBg,
                  value: '$absentCount',
                  label: 'Vắng mặt',
                  themeColors: themeColors,
                ),
                const SizedBox(width: 8),
                _OverviewMetricCard(
                  icon: Icons.schedule,
                  iconColor: themeColors.primaryAccent,
                  iconBg: themeColors.primaryIconBg,
                  value: '${totalHours.toStringAsFixed(1)}h',
                  label: 'Tổng giờ',
                  themeColors: themeColors,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Section "Chi tiết ngày D tháng M, YYYY"
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatVietnameseDayDetail(selectedDt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (loadingSelectedDay)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Đang tải lượt chấm công...',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else if (displayedDayDetail == null ||
                displayedDayDetail!.logs.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.event_busy_outlined,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chưa chấm công',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Chưa có dữ liệu trong ngày này.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              _AttendanceLogList(
                locale: locale,
                detail: displayedDayDetail,
                loading: false,
                compact: true,
              ),
          ],
        );
      },
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.cell,
    required this.summary,
    required this.isSelectable,
    required this.isSelected,
    required this.isToday,
    required this.today,
    required this.themeColors,
    required this.onTap,
  });

  final AttendanceCalendarCell cell;
  final AttendanceRangeSummary? summary;
  final bool isSelectable;
  final bool isSelected;
  final bool isToday;
  final String today;
  final _AttendanceThemeColors themeColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!cell.inRange) {
      return Center(
        child: Text(
          '${cell.dayOfMonth}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
          ),
        ),
      );
    }

    if (isSelected) {
      return Material(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${cell.dayOfMonth}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isPast = cell.date.compareTo(today) < 0;
    final isCurrentDay = cell.date == today;
    final state = calendarDayAttendanceState(summary);

    Color bg;
    Color? dotColor;

    if (state == CalendarDayAttendanceState.checked) {
      bg = themeColors.successBg;
      dotColor = themeColors.successAccent;
    } else if (state == CalendarDayAttendanceState.incomplete) {
      bg = themeColors.warningBg;
      dotColor = themeColors.warningAccent;
    } else if (state == CalendarDayAttendanceState.leave) {
      bg = themeColors.infoBg;
      dotColor = themeColors.infoAccent;
    } else if (isPast) {
      bg = themeColors.errorBg;
      dotColor = themeColors.errorAccent;
    } else if (isCurrentDay) {
      bg = colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
      dotColor = colorScheme.primary;
    } else {
      bg = Colors.transparent;
      dotColor = null;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: isSelectable ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${cell.dayOfMonth}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 3),
            if (dotColor != null)
              Container(
                width: 4.5,
                height: 4.5,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 4.5),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetricCard extends StatelessWidget {
  const _OverviewMetricCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    required this.themeColors,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;
  final _AttendanceThemeColors themeColors;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: themeColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceLogList extends StatelessWidget {
  const _AttendanceLogList({
    required this.locale,
    required this.detail,
    required this.loading,
    this.compact = false,
  });

  final String locale;
  final AttendanceDayDetail? detail;
  final bool loading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeColors = _AttendanceThemeColors(colorScheme);

    if (loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(
            'Đang tải lượt chấm công...',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    if (detail == null || detail!.logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(
            'Ngày này chưa có lượt chấm công.',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: themeColors.cardBg,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < detail!.logs.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            _AttendanceLogRow(
              locale: locale,
              log: detail!.logs[index],
              compact: compact,
            ),
          ],
        ],
      ),
    );
  }
}

class _AttendanceLogRow extends StatelessWidget {
  const _AttendanceLogRow({
    required this.locale,
    required this.log,
    required this.compact,
  });

  final String locale;
  final AttendanceLog log;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              formatAttendanceLogTime(log.checkedAt),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? colorScheme.onSurface : colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              log.location?.name ?? 'Không có địa điểm',
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkHoursBadge extends StatelessWidget {
  const _WorkHoursBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
