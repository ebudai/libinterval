part of libinterval;

class Interval<T extends Comparable<T>> implements Comparable<Interval<T>> {
  Interval(T start, T end)
      : assert(_isInOrder(start, end), 'start must be not be greater than end'),
        start = LeftClosedBoundary<T>(start),
        end = RightClosedBoundary<T>(end);

  Interval.closed(T start, T end) : this(start, end);

  Interval.open(T start, T end)
      : assert(_isInOrder(start, end), 'start must be not be greater than end'),
        start = LeftOpenBoundary<T>(start),
        end = RightOpenBoundary<T>(end);

  Interval.leftOpen(T start, T end)
      : assert(_isInOrder(start, end), 'start must be not be greater than end'),
        start = LeftOpenBoundary<T>(start),
        end = RightClosedBoundary<T>(end);

  Interval.rightOpen(T start, T end)
      : assert(_isInOrder(start, end), 'start must be not be greater than end'),
        start = LeftClosedBoundary<T>(start),
        end = RightOpenBoundary<T>(end);

  Interval.unbounded({T start, T end})
      : assert(start == null || end == null, 'unbounded intervals cannot have both sides set'),
        start = start == null ? LeftClosedBoundary<T>.unbounded() : LeftClosedBoundary<T>(start),
        end = end == null ? RightClosedBoundary<T>.unbounded() : RightClosedBoundary<T>(end);

  Interval.degenerate(T value)
      : assert(value != null, 'cannot have unbounded degenerate interval'),
        start = LeftClosedBoundary<T>(value),
        end = RightClosedBoundary<T>(value);

  Interval._(this.start, this.end)
      : assert(start != null && end != null, 'boundaries cannot be null'),
        assert(start is! LeftDegenerateBoundary<T> || end is! RightDegenerateBoundary<T>, 'both sides cannot be degenerate'),
        assert(start.compareTo(end) <= 0, 'start must be not be greater than end');

  @override
  bool operator ==(dynamic other) => other is Interval<T> && start == other.start && end == other.end;

  @override
  int get hashCode => hash2(start.hashCode, end.hashCode);

  @override
  int compareTo(Interval<T> other) => start.compareTo(other.start);

  @override
  String toString() => '$start,$end';

  bool intersects(Interval<T> other) => end.compareTo(other.start) >= 0 && start.compareTo(other.end) <= 0;

  IntervalSet<T> union(Interval<T> other) {
    if (!intersects(other) && !touches(other)) return IntervalSet<T>.of(this) + other;

    final start = this.start.min(other.start).asLeft;
    final end = this.end.max(other.end).asRight;

    return IntervalSet<T>._(start, end);
  }

  IntervalSet<T> difference(Interval<T> other) {
    if (!intersects(other)) return IntervalSet<T>.of(this);

    final startCompare = start.compareTo(other.start);
    final endCompare = end.compareTo(other.end);

    if (startCompare >= 0 && endCompare <= 0) {
      /// i am entirely encompassed by [other], nothing to return
      return IntervalSet<T>.empty();
    }

    if (startCompare < 0 && endCompare > 0) {
      /// [other] is entirely inside me, so return two intervals
      final left = Interval<T>._(start, other.start.asRight);
      final right = Interval<T>._(other.end.asLeft, end);
      return left.union(right);
    }

    if (startCompare < 0 && endCompare <= 0) {
      /// [other] is cutting off the right
      return IntervalSet<T>._(start, other.start.asRight);
    }

    /// [other] is cutting off the left; the only remaining possibility
    return IntervalSet<T>._(other.end.asLeft, end);
  }

  IntervalSet<T> intersection(Interval<T> interval) {
    if (!intersects(interval)) return IntervalSet<T>.empty();
    final start = this.start.max(interval.start).asLeft;
    final end = this.end.min(interval.end).asRight;
    return IntervalSet<T>._(start, end);
  }

  IntervalSet<T> symmetricDifference(Interval<T> interval) => union(interval).difference(intersection(interval));

  bool contains(T value) => start.contains(value) && end.contains(value);

  bool touches(Interval<T> other) {
    if (end.isUnbounded && other.start.isUnbounded) return other.start.compareTo(end) > 0;
    if (start.isUnbounded && other.end.isUnbounded) return other.end.compareTo(start) < 0;
    return end.value == other.start.value && end.isClosed != other.start.isClosed || start.value == other.end.value && start.isClosed != other.end.isClosed;
  }

  IntervalIterable<T> iterate(Incrementer<T> incrementFunction) => IntervalIterable<T>(this, incrementFunction);

  static bool _isInOrder<U extends Comparable<U>>(U start, U end) => (start?.compareTo(end ?? start) ?? 0) <= 0;

  final LeftBoundary<T> start;
  final RightBoundary<T> end;
}
