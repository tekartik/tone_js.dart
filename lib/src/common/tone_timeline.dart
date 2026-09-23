/// Port of Tone.js 14.7.77 `Timeline` (core/util/Timeline.ts) and its
/// comparison helpers (core/util/Math.ts).
library;

/// Threshold used by Tone.js comparison operators.
const toneEpsilon = 1e-6;

/// Tone.js `GT`.
bool toneGT(double a, double b) => a > b + toneEpsilon;

/// Tone.js `GTE`.
bool toneGTE(double a, double b) => toneGT(a, b) || toneEQ(a, b);

/// Tone.js `LT`.
bool toneLT(double a, double b) => a + toneEpsilon < b;

/// Tone.js `EQ`.
bool toneEQ(double a, double b) => (a - b).abs() < toneEpsilon;

/// An event on a [ToneTimeline].
abstract interface class ToneTimelineEvent {
  /// Time in seconds.
  double get time;
}

/// Time ordered events, same search semantics as Tone.js.
class ToneTimeline<T extends ToneTimelineEvent> {
  /// Number of events retained (oldest ones are removed), null for no limit.
  final int? memory;

  /// Events sorted by time.
  final _timeline = <T>[];

  /// Time ordered events.
  ToneTimeline({this.memory});

  /// Number of events.
  int get length => _timeline.length;

  /// Events, sorted by time.
  List<T> get events => List.unmodifiable(_timeline);

  /// Insert an event, after the existing events with the same time.
  void add(T event) {
    var index = search(event.time);
    _timeline.insert(index + 1, event);
    var memory = this.memory;
    if (memory != null && _timeline.length > memory) {
      _timeline.removeRange(0, _timeline.length - memory);
    }
  }

  /// Nearest event whose time is less than or equal to [time].
  T? get(double time) {
    var index = search(time);
    if (index != -1) {
      return _timeline[index];
    }
    return null;
  }

  /// First event scheduled after [time].
  T? getAfter(double time) {
    var index = search(time);
    if (index + 1 < _timeline.length) {
      return _timeline[index + 1];
    }
    return null;
  }

  /// Event before the event at [time].
  T? getBefore(double time) {
    var len = _timeline.length;
    if (len > 0 && _timeline[len - 1].time < time) {
      return _timeline[len - 1];
    }
    var index = search(time);
    if (index - 1 >= 0) {
      return _timeline[index - 1];
    }
    return null;
  }

  /// Cancel events at and after [after].
  void cancel(double after) {
    if (_timeline.length > 1) {
      var index = search(after);
      if (index >= 0) {
        if (toneEQ(_timeline[index].time, after)) {
          // get the first item with that time
          for (var i = index; i >= 0; i--) {
            if (toneEQ(_timeline[i].time, after)) {
              index = i;
            } else {
              break;
            }
          }
          _timeline.removeRange(index, _timeline.length);
        } else {
          _timeline.removeRange(index + 1, _timeline.length);
        }
      } else {
        _timeline.clear();
      }
    } else if (_timeline.length == 1) {
      if (toneGTE(_timeline[0].time, after)) {
        _timeline.clear();
      }
    }
  }

  /// Binary search returning the index of the last event whose time is
  /// before or equal to [time], -1 if [time] is before the first event.
  int search(double time) {
    if (_timeline.isEmpty) {
      return -1;
    }
    var beginning = 0;
    var len = _timeline.length;
    var end = len;
    if (_timeline[len - 1].time <= time) {
      return len - 1;
    }
    while (beginning < end) {
      var midPoint = beginning + (end - beginning) ~/ 2;
      var event = _timeline[midPoint];
      if (toneEQ(event.time, time)) {
        // choose the last one that has the same time
        for (var i = midPoint; i < len; i++) {
          if (toneEQ(_timeline[i].time, time)) {
            midPoint = i;
          } else {
            break;
          }
        }
        return midPoint;
      } else if (toneLT(event.time, time) &&
          midPoint + 1 < len &&
          toneGT(_timeline[midPoint + 1].time, time)) {
        return midPoint;
      } else if (toneGT(event.time, time)) {
        end = midPoint;
      } else {
        beginning = midPoint + 1;
      }
    }
    return -1;
  }
}

/// Playback state of a source.
enum ToneSourceState {
  /// Started
  started,

  /// Stopped
  stopped,
}

/// State event.
class ToneStateEvent implements ToneTimelineEvent {
  @override
  final double time;

  /// State at [time].
  final ToneSourceState state;

  /// State event.
  ToneStateEvent(this.state, this.time);
}

/// Port of Tone.js `StateTimeline`.
class ToneStateTimeline extends ToneTimeline<ToneStateEvent> {
  final ToneSourceState _initial;

  /// Stopped at 0 by default.
  ToneStateTimeline({ToneSourceState initial = ToneSourceState.stopped})
    : _initial = initial,
      super(memory: 100) {
    setStateAtTime(initial, 0);
  }

  /// State at [time].
  ToneSourceState getValueAtTime(double time) => get(time)?.state ?? _initial;

  /// Set the state at [time].
  void setStateAtTime(ToneSourceState state, double time) {
    add(ToneStateEvent(state, time));
  }

  /// Next event with [state] starting from the event at [time].
  ToneStateEvent? getNextState(ToneSourceState state, double time) {
    var index = search(time);
    if (index != -1) {
      for (var i = index; i < _timeline.length; i++) {
        var event = _timeline[i];
        if (event.state == state) {
          return event;
        }
      }
    }
    return null;
  }
}
