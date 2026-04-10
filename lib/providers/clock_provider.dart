import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits the current [DateTime] every second, driven by wall-clock time.
final clockProvider = StreamProvider<DateTime>((ref) {
  return _wallClockStream();
});

Stream<DateTime> _wallClockStream() async* {
  // Align the first tick to the next whole second so progress values
  // don't drift from wall-clock time.
  final now = DateTime.now();
  final msUntilNextSecond = 1000 - now.millisecond;
  await Future.delayed(Duration(milliseconds: msUntilNextSecond));

  yield DateTime.now();

  yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
}
