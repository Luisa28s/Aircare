// file: lib/state/history_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models.dart';

class HistoryState {
  final List<AirSample> samples;
  const HistoryState(this.samples);
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final int capacity;
  HistoryNotifier({this.capacity = 30}) : super(const HistoryState([]));

  void addSample(AirSample s) {
    final list = List<AirSample>.from(state.samples);
    list.add(s);
    if (list.length > capacity) {
      list.removeAt(0);
    }
    state = HistoryState(list);
  }

  void clear() => state = const HistoryState([]);
}
