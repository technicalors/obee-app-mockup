import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SessionEventType { expired, authorizationDenied }

final class SessionEvent {
  const SessionEvent.expired(this.token) : type = SessionEventType.expired;

  const SessionEvent.authorizationDenied(this.token)
    : type = SessionEventType.authorizationDenied;

  final String token;
  final SessionEventType type;
}

final sessionEventsProvider = Provider<StreamController<SessionEvent>>((ref) {
  final events = StreamController<SessionEvent>.broadcast();
  ref.onDispose(events.close);
  return events;
});
