import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';

class ScheduleParticipantsText extends StatelessWidget {
  const ScheduleParticipantsText({required this.participants, super.key});

  final List<ScheduleUserRef> participants;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(
      TextStyle(
        fontSize: 11.5,
        fontWeight: MediaQuery.boldTextOf(context)
            ? FontWeight.w700
            : FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final locale = Localizations.maybeLocaleOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final names = participants
            .map((participant) => participant.name)
            .toList();
        var label = names.isEmpty ? '' : '+${names.length}';
        final painter = TextPainter(
          textDirection: direction,
          textScaler: scaler,
          locale: locale,
          maxLines: 1,
        );
        try {
          for (var visible = names.length; visible > 0; visible--) {
            final remaining = names.length - visible;
            final prefix = names.take(visible).join(', ');
            final candidate = remaining == 0 ? prefix : '$prefix +$remaining';
            painter.text = TextSpan(text: candidate, style: style);
            painter.layout();
            if (painter.width <= constraints.maxWidth) {
              label = candidate;
              break;
            }
          }
        } finally {
          painter.dispose();
        }

        return Text(
          label,
          style: style,
          textScaler: scaler,
          locale: locale,
          maxLines: 1,
          softWrap: false,
          textAlign: TextAlign.end,
          semanticsLabel: names.join(', '),
        );
      },
    );
  }
}
