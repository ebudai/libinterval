library libinterval;

import 'dart:collection';
import 'package:quiver/core.dart';
part 'package:libinterval/boundary.dart';
part 'package:libinterval/interval.dart';

class IntervalSet<T extends Comparable<T>> extends IterableMixin<Interval<T>> {
	IntervalSet(T start, T end) : this.of(Interval<T>.closed(start, end));

	IntervalSet.empty();

	IntervalSet.open(T start, T end) : this.of(Interval<T>.open(start, end));

	IntervalSet.leftOpen(T start, T end) : this.of(Interval<T>.leftOpen(start, end));

	IntervalSet.rightOpen(T start, T end) : this.of(Interval<T>.rightOpen(start, end));

	IntervalSet.of(Interval<T> range) { _intervals.add(range); }

	IntervalSet.degenerate(T point) {
		_intervals.add(Interval<T>.degenerate(point));
	}

	IntervalSet.unbounded({ T start, T end }) {
		_intervals.add(Interval<T>.unbounded(start: start, end: end));
	}

	IntervalSet.copy(IntervalSet<T> other) { _intervals.addAll(other._intervals); }

	IntervalSet._(LeftBoundary<T> start, RightBoundary<T> end) : this.of(Interval<T>._(start, end));

	@override String toString() => '{ ${StringBuffer()..writeAll(_intervals, ',')} }';

	@override Iterator<Interval<T>> get iterator => _intervals.iterator;

	@override int get length => _intervals.length;

	@override Interval<T> get first => _intervals.first;
	@override Interval<T> get last => _intervals.last;

	@override bool get isEmpty => _intervals.isEmpty;
	@override bool get isNotEmpty => _intervals.isNotEmpty;

	IntervalSet<T> operator +(Interval<T> interval) {
		final set = IntervalSet<T>.copy(this);
		var lowestStart = interval.start;
		var highestEnd = interval.end;
		final intersections = set._intersectingIntervals(interval);
		for (final intersection in intersections) {
			set._intervals.remove(intersection);
			lowestStart = lowestStart.min(intersection.start).asLeft;
			highestEnd = highestEnd.max(intersection.end).asRight;
		}
		set._intervals.add(Interval<T>._(lowestStart, highestEnd));
		return set;
	}

	IntervalSet<T> operator -(Interval<T> interval) {
		final set = IntervalSet<T>.copy(this);
		final intersections = set._intersectingIntervals(interval);
		for (final intersection in intersections) {
			if (intersection.intersects(interval)) {
				set._intervals.remove(intersection);
				final difference = intersection.difference(interval);
				set._intervals.addAll(difference._intervals);
			}
		}
		return set;
	}

	IntervalSet<T> union(IntervalSet<T> other) {
		final set = IntervalSet<T>.copy(this);
		for (final interval in other._intervals) {
			var lowestStart = interval.start;
			var highestEnd = interval.end;
			final intersections = set._intersectingIntervals(interval);
			for (final intersection in intersections) {
				set._intervals.remove(intersection);
				lowestStart = lowestStart.min(intersection.start).asLeft;
				highestEnd = highestEnd.max(intersection.end).asRight;
			}
			set._intervals.add(Interval<T>._(lowestStart, highestEnd));
		}
		return set;
	}

	IntervalSet<T> difference(IntervalSet<T> other) {
		final set = IntervalSet<T>.copy(this);
		for (final interval in other._intervals) {
			final intersectings = _intersectingIntervals(interval);
			for (final intersecting in intersectings) {
				set._intervals.remove(intersecting);
				final difference = intersecting.difference(interval);
				set._intervals.addAll(difference._intervals);
			}
		}
		return set;
	}

	IntervalSet<T> symmetricDifference(IntervalSet<T> other) => union(other).difference(intersection(other));

	IntervalSet<T> intersection(IntervalSet<T> other) {
		final set = IntervalSet<T>.empty();
		for (final interval in _intervals) {
			final intersections = other._intersectingIntervals(interval);
			for (final intersectingInterval in intersections) {
				final intersection = interval.intersection(intersectingInterval);
				set._intervals.addAll(intersection._intervals);
			}
		}
		return set;
	}

	IntervalSet<T> compliment() {
		var compliment = IntervalSet<T>.unbounded();
		for (final interval in _intervals) {
			compliment -= interval;
		}
		return compliment;
	}

	@override bool contains(Object element) {
		if (element is Interval<T>) return _intervals.contains(element);
		if (element is T) {
			for (final interval in _intervals) {
				if (interval.contains(element)) return true;
			}
		}
		return false;
	}

	List<Interval<T>> _intersectingIntervals(Interval<T> intersector) {
		if (_intervals.first.start.compareTo(intersector.end) > 0) return <Interval<T>>[];
		if (_intervals.last.end.compareTo(intersector.start) < 0) return <Interval<T>>[];

		final list = <Interval<T>>[];
		for (final interval in _intervals) {
			if (interval.intersects(intersector)) list.add(interval);
		}
		return list;
	}

	final _intervals = SplayTreeSet<Interval<T>>();
}
