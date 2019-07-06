part of libinterval;

typedef Incrementer<T> = T Function(T);

class _IntervalIterator<T extends Comparable<T>> implements Iterator<T> {
  _IntervalIterator(this.interval, this.increment)
      : _current = interval.start.isClosed
            ? interval.start.value
            : increment(interval.start.value);

  @override
  T get current => _current;

  @override
  bool moveNext() {
    if (interval.end.isClosed && _current == interval.end.value) {
      return false;
    }
    if (interval.end.isOpen && increment(_current) == interval.end.value) {
      return false;
    }
    _current = increment(_current);
    return true;
  }

  final Interval<T> interval;
  final Incrementer<T> increment;

  T _current;
}

class IntervalIterable<T extends Comparable<T>> extends IterableMixin<T> {
  IntervalIterable(Interval<T> interval, Incrementer<T> incrementer)
      : _iterator = _IntervalIterator<T>(interval, incrementer);

  @override
  Iterator<T> get iterator => _iterator;

  _IntervalIterator<T> _iterator;
}
