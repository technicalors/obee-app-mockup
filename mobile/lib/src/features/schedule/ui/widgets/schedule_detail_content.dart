import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:obee_mobile/src/core/time/business_time.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_formatters.dart';
import 'package:url_launcher/url_launcher.dart';

enum ScheduleOccurrenceStatus {
  upcoming,
  ongoing,
  completed;

  String get label => switch (this) {
    ScheduleOccurrenceStatus.upcoming => 'Sắp diễn ra',
    ScheduleOccurrenceStatus.ongoing => 'Đang diễn ra',
    ScheduleOccurrenceStatus.completed => 'Đã diễn ra',
  };
}

ScheduleOccurrenceStatus getScheduleOccurrenceStatus({
  required DateTime start,
  required DateTime end,
  required DateTime now,
}) {
  if (now.isAfter(end)) {
    return ScheduleOccurrenceStatus.completed;
  }
  if (!now.isBefore(start) && !now.isAfter(end)) {
    return ScheduleOccurrenceStatus.ongoing;
  }
  return ScheduleOccurrenceStatus.upcoming;
}

class ScheduleDetailContent extends StatelessWidget {
  const ScheduleDetailContent({
    required this.schedule,
    this.currentTime,
    this.onUrlTap,
    super.key,
  });

  final ScheduleModel schedule;
  final DateTime? currentTime;
  final ValueChanged<String>? onUrlTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = schedule.event.type.harmonizedColor(colorScheme);
    final blockBgColor = schedule.event.type.backgroundColorFor(colorScheme);
    final blockBorderColor = typeColor.withValues(alpha: isDark ? 0.35 : 0.2);
    final now = currentTime ?? businessNow();
    final occurrenceStatus = getScheduleOccurrenceStatus(
      start: schedule.start,
      end: schedule.end,
      now: now,
    );

    final isSingleDay =
        schedule.oneDay ||
        (schedule.start.year == schedule.end.year &&
            schedule.start.month == schedule.end.month &&
            schedule.start.day == schedule.end.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Top block with light event type background
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: blockBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: blockBorderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event type tag inline right before title
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          schedule.event.type.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(
                      text: schedule.event.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              // Description directly below
              if (schedule.event.note != null &&
                  schedule.event.note!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                LinkifiedScheduleNote(
                  note: schedule.event.note!.trim(),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onTapUrl: onUrlTap,
                ),
              ],
              // Status badge row: tag lịch công ty (ngay trước phần đang/sắp diễn ra)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (schedule.event.isGeneral)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF59E0B,
                          ).withValues(alpha: isDark ? 0.25 : 0.15),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(
                              0xFFF59E0B,
                            ).withValues(alpha: isDark ? 0.45 : 0.35),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 13,
                              color: Color(0xFFD97706),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Lịch công ty',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _ScheduleStatusBadge(status: occurrenceStatus),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. Time section
        _DetailSectionRow(
          icon: Icons.calendar_today_outlined,
          title: 'Thời gian',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSingleDay) ...[
                Text(
                  formatScheduleDateWithWeekday(schedule.start),
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  schedule.start == schedule.end
                      ? formatScheduleTime(schedule.start)
                      : '${formatScheduleTime(schedule.start)} - ${formatScheduleTime(schedule.end)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatScheduleDateWithWeekday(schedule.start),
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatScheduleTime(schedule.start),
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        size: 14,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'đến',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatScheduleDateWithWeekday(schedule.end),
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatScheduleTime(schedule.end),
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // 3. Repeat section (cụm riêng)
        if (formatScheduleRepeatSummary(schedule)
            case final repeatSummary?) ...[
          const SizedBox(height: 16),
          _DetailSectionRow(
            icon: Icons.repeat,
            title: 'Lặp lại',
            content: Text(
              repeatSummary,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],

        // 4. Location section
        if (schedule.event.physicalAddress != null &&
            schedule.event.physicalAddress!.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _DetailSectionRow(
            icon: Icons.place_outlined,
            title: 'Địa điểm',
            content: Text(
              schedule.event.physicalAddress!.trim(),
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],

        // 5. Reminder section (if set)
        if (schedule.event.remindValue != null &&
            schedule.event.remindRange != null) ...[
          const SizedBox(height: 16),
          _DetailSectionRow(
            icon: Icons.notifications_none_outlined,
            title: 'Nhắc nhở',
            content: Text(
              'Nhắc trước ${schedule.event.remindValue} ${schedule.event.remindRange!.label}',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],

        // 6. Participants section ("Tham gia")
        if (schedule.event.participants.isNotEmpty) ...[
          const SizedBox(height: 16),
          _DetailSectionRow(
            icon: Icons.group_outlined,
            title: 'Tham gia (${schedule.event.participants.length})',
            content: _ParticipantList(
              users: schedule.event.participants,
              toggleKey: const ValueKey('schedule_detail_toggle_participants'),
            ),
          ),
        ],

        // 7. Observers section ("Chia sẻ")
        if (schedule.event.observers.isNotEmpty) ...[
          const SizedBox(height: 16),
          _DetailSectionRow(
            icon: Icons.share_outlined,
            title: 'Chia sẻ (${schedule.event.observers.length})',
            content: _ParticipantList(
              users: schedule.event.observers,
              toggleKey: const ValueKey('schedule_detail_toggle_observers'),
            ),
          ),
        ],
      ],
    );
  }
}

class LinkifiedScheduleNote extends StatefulWidget {
  const LinkifiedScheduleNote({
    required this.note,
    required this.style,
    this.onTapUrl,
    super.key,
  });

  final String note;
  final TextStyle style;
  final ValueChanged<String>? onTapUrl;

  @override
  State<LinkifiedScheduleNote> createState() => _LinkifiedScheduleNoteState();
}

class _LinkifiedScheduleNoteState extends State<LinkifiedScheduleNote> {
  final List<TapGestureRecognizer> _recognizers = [];
  List<InlineSpan> _spans = const [];

  static final _urlRegex = RegExp(
    r'https?:\/\/[^\s<]+|www\.[^\s<]+',
    caseSensitive: false,
  );

  static final _trailingPunctuation = RegExp(r'[.,;:!?)]+$');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildSpans();
  }

  @override
  void didUpdateWidget(LinkifiedScheduleNote oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note != widget.note ||
        oldWidget.style != widget.style ||
        oldWidget.onTapUrl != widget.onTapUrl) {
      _rebuildSpans();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  Future<void> _handleLaunch(String url) async {
    if (widget.onTapUrl != null) {
      widget.onTapUrl!(url);
      return;
    }

    final urlString =
        url.startsWith(RegExp(r'https?:\/\/', caseSensitive: false))
        ? url
        : 'https://$url';
    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Liên kết không hợp lệ: $url')));
      }
      return;
    }

    var launched = false;

    // 1. Try platformDefault first (standard browser / in-app custom tabs)
    try {
      launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('LaunchMode.platformDefault failed: $e');
    }

    // 2. If not launched, try externalApplication
    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('LaunchMode.externalApplication failed: $e');
      }
    }

    // 3. If still not launched, try inAppBrowserView
    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (e) {
        debugPrint('LaunchMode.inAppBrowserView failed: $e');
      }
    }

    // 4. Fallback: Copy to clipboard and notify user if launch did not succeed
    if (mounted && !launched) {
      await Clipboard.setData(ClipboardData(text: urlString));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể mở trình duyệt. Đã sao chép liên kết vào bộ nhớ tạm: $urlString',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _rebuildSpans() {
    final note = widget.note;
    final matches = _urlRegex.allMatches(note).toList(growable: false);
    if (matches.isEmpty) {
      _disposeRecognizers();
      _spans = const [];
      return;
    }

    _disposeRecognizers();

    final colorScheme = Theme.of(context).colorScheme;
    final linkStyle = widget.style.copyWith(
      color: colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: colorScheme.primary,
      fontWeight: FontWeight.w500,
    );

    final spans = <InlineSpan>[];
    var lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: note.substring(lastIndex, match.start),
            style: widget.style,
          ),
        );
      }

      var matchedText = match.group(0)!;
      var trailing = '';
      final punctMatch = _trailingPunctuation.firstMatch(matchedText);
      if (punctMatch != null) {
        trailing = punctMatch.group(0)!;
        matchedText = matchedText.substring(
          0,
          matchedText.length - trailing.length,
        );
      }

      final url = matchedText;
      final recognizer = TapGestureRecognizer()
        ..onTap = () => _handleLaunch(url);
      _recognizers.add(recognizer);

      spans.add(
        TextSpan(
          text: url,
          style: linkStyle,
          mouseCursor: SystemMouseCursors.click,
          recognizer: recognizer,
        ),
      );

      if (trailing.isNotEmpty) {
        spans.add(TextSpan(text: trailing, style: widget.style));
      }

      lastIndex = match.end;
    }

    if (lastIndex < note.length) {
      spans.add(TextSpan(text: note.substring(lastIndex), style: widget.style));
    }

    _spans = spans;
  }

  @override
  Widget build(BuildContext context) {
    if (_spans.isEmpty) {
      return Text(widget.note, style: widget.style);
    }

    return Text.rich(TextSpan(children: _spans), style: widget.style);
  }
}

class _ScheduleStatusBadge extends StatelessWidget {
  const _ScheduleStatusBadge({required this.status});

  final ScheduleOccurrenceStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (bgColor, borderColor, textColor, dotColor) = switch (status) {
      ScheduleOccurrenceStatus.ongoing => (
        const Color(0xFF10B981).withValues(alpha: isDark ? 0.25 : 0.15),
        const Color(0xFF10B981).withValues(alpha: isDark ? 0.45 : 0.35),
        isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
        const Color(0xFF10B981),
      ),
      ScheduleOccurrenceStatus.completed => (
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        colorScheme.outlineVariant,
        colorScheme.onSurfaceVariant,
        colorScheme.onSurfaceVariant,
      ),
      ScheduleOccurrenceStatus.upcoming => (
        colorScheme.primaryContainer.withValues(alpha: 0.4),
        colorScheme.primary.withValues(alpha: 0.3),
        colorScheme.primary,
        colorScheme.primary,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSectionRow extends StatelessWidget {
  const _DetailSectionRow({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              content,
            ],
          ),
        ),
      ],
    );
  }
}

class _ParticipantList extends StatefulWidget {
  const _ParticipantList({required this.users, this.toggleKey});

  final List<ScheduleUserRef> users;
  final Key? toggleKey;

  @override
  State<_ParticipantList> createState() => _ParticipantListState();
}

class _ParticipantListState extends State<_ParticipantList> {
  var _expanded = false;
  static const _visibleLimit = 4;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasMore = widget.users.length > _visibleLimit;
    final visibleUsers = (_expanded || !hasMore)
        ? widget.users
        : widget.users.take(_visibleLimit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final user in visibleUsers)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.15,
                      ),
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name.characters.first.toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (hasMore) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: widget.toggleKey,
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              icon: Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 18,
              ),
              label: Text(
                _expanded
                    ? 'Thu gọn'
                    : 'Mở rộng (+${widget.users.length - _visibleLimit})',
                style: const TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
