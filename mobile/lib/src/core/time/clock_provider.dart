import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clockProvider = Provider<Clock>((ref) => const Clock());
