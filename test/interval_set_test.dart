import 'package:kernel/text/serializer_combinators.dart';
import 'package:test/test.dart';
import 'package:interval_set/interval_set.dart';

void main() {

	group('boundary', () {
		group('hash collisions', () {
			test('closed v closed', () {
				const first = LeftClosedBoundary<num>(0);
				const second = LeftClosedBoundary<num>(0);
				const third = LeftClosedBoundary<num>(3);
				const fourth = LeftClosedBoundary<num>.unbounded();

				expect(first.hashCode, equals(second.hashCode));
				expect(first.hashCode, isNot(equals(third.hashCode)));
				expect(first.hashCode, isNot(equals(fourth.hashCode)));
			});

			test('closed v open', () {
				const first = LeftOpenBoundary<num>(0);
				const second = LeftClosedBoundary<num>(0);
				const third = LeftClosedBoundary<num>(3);
				const fourth = LeftClosedBoundary<num>.unbounded();

				expect(first.hashCode, isNot(equals(second.hashCode)));
				expect(first.hashCode, isNot(equals(third.hashCode)));
				expect(first.hashCode, isNot(equals(fourth.hashCode)));
			});

			test('open v open', () {
				const first = LeftOpenBoundary<num>(0);
				const second = LeftOpenBoundary<num>(0);
				const third = LeftOpenBoundary<num>(3);
				const fourth = LeftOpenBoundary<num>.unbounded();

				expect(first.hashCode, equals(second.hashCode));
				expect(first.hashCode, isNot(equals(third.hashCode)));
				expect(first.hashCode, isNot(equals(fourth.hashCode)));
			});

			test('closed left v right', () {
				const first = RightClosedBoundary<num>(0);
				const second = LeftClosedBoundary<num>(0);
				const third = LeftClosedBoundary<num>(3);
				const fourth = LeftClosedBoundary<num>.unbounded();

				expect(first.hashCode, isNot(equals(second.hashCode)));
				expect(first.hashCode, isNot(equals(third.hashCode)));
				expect(first.hashCode, isNot(equals(fourth.hashCode)));
			});

			test('open left v right', () {
				const first = RightOpenBoundary<num>(0);
				const second = LeftOpenBoundary<num>(0);
				const third = LeftOpenBoundary<num>(3);
				const fourth = LeftOpenBoundary<num>.unbounded();

				expect(first.hashCode, isNot(equals(second.hashCode)));
				expect(first.hashCode, isNot(equals(third.hashCode)));
				expect(first.hashCode, isNot(equals(fourth.hashCode)));
			});

			test('degenerate v non', () {
				const first = LeftDegenerateBoundary<num>();
				const second = LeftClosedBoundary<num>(0);
				const third = LeftClosedBoundary<num>(3);
				const fourth = LeftClosedBoundary<num>.unbounded();

				expect(first.hashCode, isNot(equals(second.hashCode)));
				expect(first.hashCode, isNot(equals(third.hashCode)));
				expect(first.hashCode, isNot(equals(fourth.hashCode)));
			});
		});
	});

	group('interval', () {
		group('symmetric difference', () {
			final twoArgConstructors = {
				'closed': (num a, num b) => Interval<num>.closed(a, b),
				'open': (num a, num b) => Interval<num>.open(a, b),
				'leftOpen': (num a, num b) => Interval<num>.leftOpen(a, b),
				'rightOpen': (num a, num b) => Interval<num>.rightOpen(a, b),
			};

			final oneArgConstructors = {
				'closed unbounded left': (num a) => Interval<num>.closed(null, a),
				'closed unbounded right': (num a) => Interval<num>.closed(a, null),
				'fully open unbounded left': (num a) => Interval<num>.open(null, a),
				'fully open unbounded right': (num a) => Interval<num>.open(a, null),
				'open on left unbounded left': (num a) => Interval<num>.leftOpen(null, a),
				'open on left unbounded right': (num a) => Interval<num>.leftOpen(a, null),
				'open on right unbounded left': (num a) => Interval<num>.rightOpen(null, a),
				'open on right unbounded right': (num a) => Interval<num>.rightOpen(a, null),
				'degenerate': (num a) => Interval<num>.degenerate(a),
			};

			final noArgConstructors = {
				'unbounded': () => Interval<num>.unbounded(),
			};

			const points = [
				-8097469837468
				-100.23,
				-34,
				-10,
				-1,
				0,
				1,
				2,
				5.44,
				10,
				56.8,
				100,
				230948200938
			];

			const boundaries = [
				Tuple2<num, num>(-10, -1),
				Tuple2<num, num>(-5, 1),
				Tuple2<num, num>(-4, 4),
				Tuple2<num, num>(0, 10),
				Tuple2<num, num>(1, 5),

				Tuple2<num, num>(1, 10),
				Tuple2<num, num>(3, 6),
				Tuple2<num, num>(-2, 20),

				Tuple2<num, num>(12, 22),
				Tuple2<num, num>(10, 29),
				Tuple2<num, num>(5, 13),
				Tuple2<num, num>(1, 18),
				Tuple2<num, num>(8, 10),
			];

			const base = Tuple2<num, num>(1, 10);

			group('element count', () {
				for (final constructor in twoArgConstructors.entries) {
					final first = constructor.value(base.first, base.second);
					for (final otherConstructor in twoArgConstructors.entries) {
						for (final compare in boundaries) {
							final second = otherConstructor.value(compare.first, compare.second);
							final name = '$first v $second';
							test(name, () {
								final difference = first.symmetricDifference(second);
								int length;
								if (first == second) length = 0;
								else if (first.start == second.start) length = 1;
								else if (first.end == second.end) length = 1;
								else if (first.touches(second)) length = 1;
								else length = 2;
								expect(difference.length, equals(length));

								final converse = second.symmetricDifference(first);
								expect(difference.length, equals(converse.length));
								for (var i = 0; i < converse.length; i++) {
									expect(difference.elementAt(i), equals(converse.elementAt(i)));
								}
							});
						}
					}

					for (final otherConstructor in oneArgConstructors.entries) {
						for (final point in points) {
							final second = otherConstructor.value(point);
							final name = '$first v $second';
							test(name, () {
								final difference = first.symmetricDifference(second);
								int length;
								if (first.start == second.start) length = 1;
								else if (first.end == second.end) length = 1;
								else if (first.touches(second)) length = 1;
								else length = 2;
								expect(difference.length, equals(length));

								final converse = second.symmetricDifference(first);
								expect(difference.length, equals(converse.length));
								for (var i = 0; i < converse.length; i++) {
									expect(difference.elementAt(i), equals(converse.elementAt(i)));
								}
							});
						}
					}

					for (final otherConstructor in noArgConstructors.entries) {
						final second = otherConstructor.value();
						final name = '$first v $second';
						test(name, () {
							final difference = first.symmetricDifference(second);
							int length;
							if (first.start == second.start) length = 1;
							else if (first.end == second.end) length = 1;
							else if (first.touches(second)) length = 1;
							else length = 2;
							expect(difference.length, equals(length));

							final converse = second.symmetricDifference(first);
							expect(difference.length, equals(converse.length));
							for (var i = 0; i < converse.length; i++) {
								expect(difference.elementAt(i), equals(converse.elementAt(i)));
							}
						});
					}
				}

				for (final constructor in oneArgConstructors.entries) {
					final first = constructor.value(0);
					for (final otherConstructor in twoArgConstructors.entries) {
						for (final compare in boundaries) {
							final second = otherConstructor.value(compare.first, compare.second);
							final name = '$first v $second';
							test(name, () {
								final difference = first.symmetricDifference(second);
								int length;
								if (second == first) length = 0;
								else if (second.start == first.start) length = 1;
								else if (second.end == first.end) length = 1;
								else if (second.touches(first)) length = 1;
								else length = 2;
								expect(difference.length, equals(length));

								final converse = second.symmetricDifference(first);
								expect(difference.length, equals(converse.length));
								for (var i = 0; i < converse.length; i++) {
									expect(difference.elementAt(i), equals(converse.elementAt(i)));
								}
							});
						}
					}

					for (final otherConstructor in oneArgConstructors.entries) {
						for (final point in points) {
							final second = otherConstructor.value(point);
							final name = '$first v $second';
							test(name, () {
								final difference = first.symmetricDifference(second);
								int length;
								if (first == second) length = 0;
								else if (first.start == second.start) length = 1;
								else if (first.end == second.end) length = 1;
								else if (first.touches(second)) length = 1;
								else length = 2;

								expect(difference.length, equals(length));

								final converse = second.symmetricDifference(first);
								expect(difference.length, equals(converse.length));
								for (var i = 0; i < converse.length; i++) {
									expect(difference.elementAt(i), equals(converse.elementAt(i)));
								}
							});
						}
					}

					for (final otherConstructor in noArgConstructors.entries) {
						final second = otherConstructor.value();
						final name = '$first v $second';
						test(name, () {
							final difference = first.symmetricDifference(second);
							int length;
							if (first.start == second.start) length = 1;
							else if (first.end == second.end) length = 1;
							else if (first.touches(second)) length = 1;
							else length = 2;
							expect(difference.length, equals(length));

							final converse = second.symmetricDifference(first);
							expect(difference.length, equals(converse.length));
							for (var i = 0; i < converse.length; i++) {
								expect(difference.elementAt(i), equals(converse.elementAt(i)));
							}
						});
					}
				}

				for (final constructor in noArgConstructors.entries) {
					final first = constructor.value();
					for (final otherConstructor in twoArgConstructors.entries) {
						for (final compare in boundaries) {
							final second = otherConstructor.value(compare.first, compare.second);
							final name = '$first v $second';
							test(name, () {
								final difference = first.symmetricDifference(second);
								int length;
								if (second == first) length = 0;
								else if (second.start == first.start) length = 1;
								else if (second.end == first.end) length = 1;
								else if (second.touches(first)) length = 1;
								else length = 2;
								expect(difference.length, equals(length));

								final converse = second.symmetricDifference(first);
								expect(difference.length, equals(converse.length));
								for (var i = 0; i < converse.length; i++) {
									expect(difference.elementAt(i), equals(converse.elementAt(i)));
								}
							});
						}
					}

					for (final otherConstructor in oneArgConstructors.entries) {
						for (final point in points) {
							final second = otherConstructor.value(point);
							final name = '$first v $second';
							test(name, () {
								final difference = first.symmetricDifference(second);
								int length;
								if (first == second) length = 0;
								else if (first.start == second.start) length = 1;
								else if (first.end == second.end) length = 1;
								else if (first.touches(second)) length = 1;
								else length = 2;
								expect(difference.length, equals(length));

								final converse = second.symmetricDifference(first);
								expect(difference.length, equals(converse.length));
								for (var i = 0; i < converse.length; i++) {
									expect(difference.elementAt(i), equals(converse.elementAt(i)));
								}
							});
						}
					}

					for (final otherConstructor in noArgConstructors.entries) {
						final second = otherConstructor.value();
						final name = '$first v $second';
						test(name, () {
							final difference = first.symmetricDifference(second);
							int length;
							if (first == second) length = 0;
							else if (first.start == second.start) length = 1;
							else if (first.end == second.end) length = 1;
							else if (first.touches(second)) length = 1;
							else length = 2;
							expect(difference.length, equals(length));

							final converse = second.symmetricDifference(first);
							expect(difference.length, equals(converse.length));
							for (var i = 0; i < converse.length; i++) {
								expect(difference.elementAt(i), equals(converse.elementAt(i)));
							}
						});
					}
				}
			});

			group('boundaries', () {
				for (final constructor in twoArgConstructors.entries) {
					final first = constructor.value(base.first, base.second);
					for (final otherConstructor in twoArgConstructors.entries) {
						for (final compare in boundaries) {
							final second = otherConstructor.value(compare.first, compare.second);
							final name = '$first v $second';
							test(name, () {
								final difference = first.symmetricDifference(second);
								if (difference.length == 1) {
									final interval = difference.first;
									if (first.start == second.start) {
										final lower = first.end.min(second.end);
										final higher = first.end.max(second.end);
										expect(interval.start, equals(lower.asLeft));
										expect(interval.end, equals(higher));
									} else if (first.end == second.end) {
										final lower = first.start.min(second.start);
										final higher = first.start.max(second.start);
										expect(interval.start, equals(lower));
										expect(interval.end, equals(higher.asRight));
									} else if (first.touches(second)) {
										if (first.start.value == second.end.value && (first.start.isOpen || second.end.isOpen)) {
											if (first.start.value == null) {
												expect(interval.start, equals(first.start));
												expect(interval.end, equals(second.end));
											} else {
												expect(interval.start, equals(second.start));
												expect(interval.end, equals(first.end));
											}
										} else if (first.end.value == second.start.value && (first.end.isOpen || second.start.isOpen)) {
											if (first.end.value == null) {
												expect(interval.start, equals(second.start));
												expect(interval.end, equals(first.end));
											} else {
												expect(interval.start, equals(first.start));
												expect(interval.end, equals(second.end));
											}
										} else {
											fail('failure somewhere in Interval<T>.touches');
										}
									} else {
										fail('one interval without intersecting/touching');
									}
								} else if (difference.length == 2) {
									final first = difference.first;
									final second = difference.last;
									final lowerStart = first.start.min(second.start);
									final higherEnd = first.end.max(second.end);
									final higherStart = first.start.max(second.start);
									final lowerEnd = first.end.min(second.end);
									expect(first.start, equals(lowerStart));
									expect(second.end, equals(higherEnd));
									expect(first.end, equals(lowerEnd));
									expect(second.start, equals(higherStart));
								} else if (difference.isNotEmpty) {
									fail('must have between 0 and 2 intervals, test results in ${difference.length}');
								}
							});
						}
					}

					for (final otherConstructor in oneArgConstructors.entries) {
						for (final point in points) {
							final second = otherConstructor.value(point);
							final name = '$first v $second';
							test(name, () {
								final difference = first.symmetricDifference(second);
								if (difference.length == 1) {
									final interval = difference.first;
									if (first.start == second.start) {
										final lower = first.end.min(second.end);
										final higher = first.end.max(second.end);
										expect(interval.start, equals(lower.asLeft));
										expect(interval.end, equals(higher));
									} else if (first.end == second.end) {
										final lower = first.start.min(second.start);
										final higher = first.start.max(second.start);
										expect(interval.start, equals(lower));
										expect(interval.end, equals(higher.asRight));
									} else if (first.touches(second)) {
										if (first.start.value == second.end.value && (first.start.isOpen || second.end.isOpen)) {
											if (first.start.value == null) {
												expect(interval.start, equals(first.start));
												expect(interval.end, equals(second.end));
											} else {
												expect(interval.start, equals(second.start));
												expect(interval.end, equals(first.end));
											}
										} else if (first.end.value == second.start.value && (first.end.isOpen || second.start.isOpen)) {
											if (first.end.value == null) {
												expect(interval.start, equals(second.start));
												expect(interval.end, equals(first.end));
											} else {
												expect(interval.start, equals(first.start));
												expect(interval.end, equals(second.end));
											}
										} else {
											fail('failure somewhere in Interval<T>.touches');
										}
									} else {
										fail('one interval without intersecting/touching');
									}
								} else if (difference.length == 2) {
									final first = difference.first;
									final second = difference.last;
									final lowerStart = first.start.min(second.start);
									final higherEnd = first.end.max(second.end);
									final higherStart = first.start.max(second.start);
									final lowerEnd = first.end.min(second.end);
									expect(first.start, equals(lowerStart));
									expect(second.end, equals(higherEnd));
									expect(first.end, equals(lowerEnd));
									expect(second.start, equals(higherStart));
								} else if (difference.isNotEmpty) {
									fail('must have between 0 and 2 intervals, test results in ${difference.length}');
								}
							});
						}
					}

					for (final otherConstructor in noArgConstructors.entries) {
						final second = otherConstructor.value();
						final name = '$first v $second';
						test(name, () {
							final difference = first.symmetricDifference(second);
							if (difference.length == 1) {
								final interval = difference.first;
								if (first.start == second.start) {
									final lower = first.end.min(second.end);
									final higher = first.end.max(second.end);
									expect(interval.start, equals(lower.asLeft));
									expect(interval.end, equals(higher));
								} else if (first.end == second.end) {
									final lower = first.start.min(second.start);
									final higher = first.start.max(second.start);
									expect(interval.start, equals(lower));
									expect(interval.end, equals(higher.asRight));
								} else if (first.touches(second)) {
									if (first.start.value == second.end.value && (first.start.isOpen || second.end.isOpen)) {
										if (first.start.value == null) {
											expect(interval.start, equals(first.start));
											expect(interval.end, equals(second.end));
										} else {
											expect(interval.start, equals(second.start));
											expect(interval.end, equals(first.end));
										}
									} else if (first.end.value == second.start.value && (first.end.isOpen || second.start.isOpen)) {
										if (first.end.value == null) {
											expect(interval.start, equals(second.start));
											expect(interval.end, equals(first.end));
										} else {
											expect(interval.start, equals(first.start));
											expect(interval.end, equals(second.end));
										}
									} else {
										fail('failure somewhere in Interval<T>.touches');
									}
								} else {
									fail('one interval without intersecting/touching');
								}
							} else if (difference.length == 2) {
								final first = difference.first;
								final second = difference.last;
								final lowerStart = first.start.min(second.start);
								final higherEnd = first.end.max(second.end);
								final higherStart = first.start.max(second.start);
								final lowerEnd = first.end.min(second.end);
								expect(first.start, equals(lowerStart));
								expect(second.end, equals(higherEnd));
								expect(first.end, equals(lowerEnd));
								expect(second.start, equals(higherStart));
							} else if (difference.isNotEmpty) {
								fail('must have between 0 and 2 intervals, test results in ${difference.length}');
							}
						});
					}
				}

				for (final constructor in oneArgConstructors.entries) {
					final first = constructor.value(0);
					for (final otherConstructor in twoArgConstructors.entries) {
						for (final compare in boundaries) {
							final second = otherConstructor.value(compare.first, compare.second);
							final name = '$first v $second';
							test(name, () {
								final difference = first.symmetricDifference(second);
								if (difference.length == 1) {
									final interval = difference.first;
									if (first.start == second.start) {
										final lower = first.end.min(second.end);
										final higher = first.end.max(second.end);
										expect(interval.start, equals(lower.asLeft));
										expect(interval.end, equals(higher));
									} else if (first.end == second.end) {
										final lower = first.start.min(second.start);
										final higher = first.start.max(second.start);
										expect(interval.start, equals(lower));
										expect(interval.end, equals(higher.asRight));
									} else if (first.touches(second)) {
										if (first.start.value == second.end.value && (first.start.isOpen || second.end.isOpen)) {
											if (first.start.value == null) {
												expect(interval.start, equals(first.start));
												expect(interval.end, equals(second.end));
											} else {
												expect(interval.start, equals(second.start));
												expect(interval.end, equals(first.end));
											}
										} else if (first.end.value == second.start.value && (first.end.isOpen || second.start.isOpen)) {
											if (first.end.value == null) {
												expect(interval.start, equals(second.start));
												expect(interval.end, equals(first.end));
											} else {
												expect(interval.start, equals(first.start));
												expect(interval.end, equals(second.end));
											}
										} else {
											fail('failure somewhere in Interval<T>.touches');
										}
									} else {
										fail('one interval without intersecting/touching');
									}
								} else if (difference.length == 2) {
									final first = difference.first;
									final second = difference.last;
									final lowerStart = first.start.min(second.start);
									final higherEnd = first.end.max(second.end);
									final higherStart = first.start.max(second.start);
									final lowerEnd = first.end.min(second.end);
									expect(first.start, equals(lowerStart));
									expect(second.end, equals(higherEnd));
									expect(first.end, equals(lowerEnd));
									expect(second.start, equals(higherStart));
								} else if (difference.isNotEmpty) {
									fail('must have between 0 and 2 intervals, test results in ${difference.length}');
								}
							});
						}
					}

					for (final otherConstructor in oneArgConstructors.entries) {
						for (final point in points) {
							final second = otherConstructor.value(point);
							final name = '$first v $second';
							test(name, () {
								final difference = first.symmetricDifference(second);
								if (difference.length == 1) {
									final interval = difference.first;
									if (first.start == second.start) {
										final lower = first.end.min(second.end);
										final higher = first.end.max(second.end);
										expect(interval.start, equals(lower.asLeft));
										expect(interval.end, equals(higher));
									} else if (first.end == second.end) {
										final lower = first.start.min(second.start);
										final higher = first.start.max(second.start);
										expect(interval.start, equals(lower));
										expect(interval.end, equals(higher.asRight));
									} else if (first.touches(second)) {
										if (first.start.value == second.end.value && (first.start.isOpen || second.end.isOpen)) {
											if (first.start.value == null) {
												expect(interval.start, equals(first.start));
												expect(interval.end, equals(second.end));
											} else {
												expect(interval.start, equals(second.start));
												expect(interval.end, equals(first.end));
											}
										} else if (first.end.value == second.start.value && (first.end.isOpen || second.start.isOpen)) {
											if (first.end.value == null) {
												expect(interval.start, equals(second.start));
												expect(interval.end, equals(first.end));
											} else {
												expect(interval.start, equals(first.start));
												expect(interval.end, equals(second.end));
											}
										} else {
											fail('failure somewhere in Interval<T>.touches');
										}
									} else {
										fail('one interval without intersecting/touching');
									}
								} else if (difference.length == 2) {
									final first = difference.first;
									final second = difference.last;
									final lowerStart = first.start.min(second.start);
									final higherEnd = first.end.max(second.end);
									final higherStart = first.start.max(second.start);
									final lowerEnd = first.end.min(second.end);
									expect(first.start, equals(lowerStart));
									expect(second.end, equals(higherEnd));
									expect(first.end, equals(lowerEnd));
									expect(second.start, equals(higherStart));
								} else if (difference.isNotEmpty) {
									fail('must have between 0 and 2 intervals, test results in ${difference.length}');
								}
							});
						}
					}

					for (final otherConstructor in noArgConstructors.entries) {
						final second = otherConstructor.value();
						final name = '$first v $second';
						test(name, () {
							final difference = first.symmetricDifference(second);
							if (difference.length == 1) {
								final interval = difference.first;
								if (first.start == second.start) {
									final lower = first.end.min(second.end);
									final higher = first.end.max(second.end);
									expect(interval.start, equals(lower.asLeft));
									expect(interval.end, equals(higher));
								} else if (first.end == second.end) {
									final lower = first.start.min(second.start);
									final higher = first.start.max(second.start);
									expect(interval.start, equals(lower));
									expect(interval.end, equals(higher.asRight));
								} else if (first.touches(second)) {
									if (first.start.value == second.end.value && (first.start.isOpen || second.end.isOpen)) {
										if (first.start.value == null) {
											expect(interval.start, equals(first.start));
											expect(interval.end, equals(second.end));
										} else {
											expect(interval.start, equals(second.start));
											expect(interval.end, equals(first.end));
										}
									} else if (first.end.value == second.start.value && (first.end.isOpen || second.start.isOpen)) {
										if (first.end.value == null) {
											expect(interval.start, equals(second.start));
											expect(interval.end, equals(first.end));
										} else {
											expect(interval.start, equals(first.start));
											expect(interval.end, equals(second.end));
										}
									} else {
										fail('failure somewhere in Interval<T>.touches');
									}
								} else {
									fail('one interval without intersecting/touching');
								}
							} else if (difference.length == 2) {
								final first = difference.first;
								final second = difference.last;
								final lowerStart = first.start.min(second.start);
								final higherEnd = first.end.max(second.end);
								final higherStart = first.start.max(second.start);
								final lowerEnd = first.end.min(second.end);
								expect(first.start, equals(lowerStart));
								expect(second.end, equals(higherEnd));
								expect(first.end, equals(lowerEnd));
								expect(second.start, equals(higherStart));
							} else if (difference.isNotEmpty) {
								fail('must have between 0 and 2 intervals, test results in ${difference.length}');
							}
						});
					}
				}

				for (final constructor in noArgConstructors.entries) {
					final first = constructor.value();
					for (final otherConstructor in twoArgConstructors.entries) {
						for (final compare in boundaries) {
							final second = otherConstructor.value(compare.first, compare.second);
							final name = '$first v $second';
							test(name, () {
								final difference = first.symmetricDifference(second);
								if (difference.length == 1) {
									final interval = difference.first;
									if (first.start == second.start) {
										final lower = first.end.min(second.end);
										final higher = first.end.max(second.end);
										expect(interval.start, equals(lower.asLeft));
										expect(interval.end, equals(higher));
									} else if (first.end == second.end) {
										final lower = first.start.min(second.start);
										final higher = first.start.max(second.start);
										expect(interval.start, equals(lower));
										expect(interval.end, equals(higher.asRight));
									} else if (first.touches(second)) {
										if (first.start.value == second.end.value && (first.start.isOpen || second.end.isOpen)) {
											if (first.start.value == null) {
												expect(interval.start, equals(first.start));
												expect(interval.end, equals(second.end));
											} else {
												expect(interval.start, equals(second.start));
												expect(interval.end, equals(first.end));
											}
										} else if (first.end.value == second.start.value && (first.end.isOpen || second.start.isOpen)) {
											if (first.end.value == null) {
												expect(interval.start, equals(second.start));
												expect(interval.end, equals(first.end));
											} else {
												expect(interval.start, equals(first.start));
												expect(interval.end, equals(second.end));
											}
										} else {
											fail('failure somewhere in Interval<T>.touches');
										}
									} else {
										fail('one interval without intersecting/touching');
									}
								} else if (difference.length == 2) {
									final first = difference.first;
									final second = difference.last;
									final lowerStart = first.start.min(second.start);
									final higherEnd = first.end.max(second.end);
									final higherStart = first.start.max(second.start);
									final lowerEnd = first.end.min(second.end);
									expect(first.start, equals(lowerStart));
									expect(second.end, equals(higherEnd));
									expect(first.end, equals(lowerEnd));
									expect(second.start, equals(higherStart));
								} else if (difference.isNotEmpty) {
									fail('must have between 0 and 2 intervals, test results in ${difference.length}');
								}
							});
						}
					}

					for (final otherConstructor in oneArgConstructors.entries) {
						for (final point in points) {
							final second = otherConstructor.value(point);
							final name = '$first v $second';
							test(name, () {
								final difference = first.symmetricDifference(second);
								if (difference.length == 1) {
									final interval = difference.first;
									if (first.start == second.start) {
										final lower = first.end.min(second.end);
										final higher = first.end.max(second.end);
										expect(interval.start, equals(lower.asLeft));
										expect(interval.end, equals(higher));
									} else if (first.end == second.end) {
										final lower = first.start.min(second.start);
										final higher = first.start.max(second.start);
										expect(interval.start, equals(lower));
										expect(interval.end, equals(higher.asRight));
									} else if (first.touches(second)) {
										if (first.start.value == second.end.value && (first.start.isOpen || second.end.isOpen)) {
											if (first.start.value == null) {
												expect(interval.start, equals(first.start));
												expect(interval.end, equals(second.end));
											} else {
												expect(interval.start, equals(second.start));
												expect(interval.end, equals(first.end));
											}
										} else if (first.end.value == second.start.value && (first.end.isOpen || second.start.isOpen)) {
											if (first.end.value == null) {
												expect(interval.start, equals(second.start));
												expect(interval.end, equals(first.end));
											} else {
												expect(interval.start, equals(first.start));
												expect(interval.end, equals(second.end));
											}
										} else {
											fail('failure somewhere in Interval<T>.touches');
										}
									} else {
										fail('one interval without intersecting/touching');
									}
								} else if (difference.length == 2) {
									final first = difference.first;
									final second = difference.last;
									final lowerStart = first.start.min(second.start);
									final higherEnd = first.end.max(second.end);
									final higherStart = first.start.max(second.start);
									final lowerEnd = first.end.min(second.end);
									expect(first.start, equals(lowerStart));
									expect(second.end, equals(higherEnd));
									expect(first.end, equals(lowerEnd));
									expect(second.start, equals(higherStart));
								} else if (difference.isNotEmpty) {
									fail('must have between 0 and 2 intervals, test results in ${difference.length}');
								}
							});
						}
					}

					for (final otherConstructor in noArgConstructors.entries) {
						final second = otherConstructor.value();
						final name = '$first v $second';
						test(name, () {
							final difference = first.symmetricDifference(second);
							if (difference.length == 1) {
								final interval = difference.first;
								if (first.start == second.start) {
									final lower = first.end.min(second.end);
									final higher = first.end.max(second.end);
									expect(interval.start, equals(lower.asLeft));
									expect(interval.end, equals(higher));
								} else if (first.end == second.end) {
									final lower = first.start.min(second.start);
									final higher = first.start.max(second.start);
									expect(interval.start, equals(lower));
									expect(interval.end, equals(higher.asRight));
								} else if (first.touches(second)) {
									if (first.start.value == second.end.value && (first.start.isOpen || second.end.isOpen)) {
										if (first.start.value == null) {
											expect(interval.start, equals(first.start));
											expect(interval.end, equals(second.end));
										} else {
											expect(interval.start, equals(second.start));
											expect(interval.end, equals(first.end));
										}
									} else if (first.end.value == second.start.value && (first.end.isOpen || second.start.isOpen)) {
										if (first.end.value == null) {
											expect(interval.start, equals(second.start));
											expect(interval.end, equals(first.end));
										} else {
											expect(interval.start, equals(first.start));
											expect(interval.end, equals(second.end));
										}
									} else {
										fail('failure somewhere in Interval<T>.touches');
									}
								} else {
									fail('one interval without intersecting/touching');
								}
							} else if (difference.length == 2) {
								final first = difference.first;
								final second = difference.last;
								final lowerStart = first.start.min(second.start);
								final higherEnd = first.end.max(second.end);
								final higherStart = first.start.max(second.start);
								final lowerEnd = first.end.min(second.end);
								expect(first.start, equals(lowerStart));
								expect(second.end, equals(higherEnd));
								expect(first.end, equals(lowerEnd));
								expect(second.start, equals(higherStart));
							} else if (difference.isNotEmpty) {
								fail('must have between 0 and 2 intervals, test results in ${difference.length}');
							}
						});
					}
				}
			});
		});
	});

	group('interval set', () {
		group('addition', () {
			test('overlapping', () {
				final set = IntervalSet<num>(0, 10) + Interval<num>(20, 30) + Interval<num>(40, 50);
				final interval = Interval<num>(5, 45);
				final union = set + interval;
				expect(union.length, equals(1));
				expect(union.first.start.value, equals(0));
				expect(union.first.start.isClosed, isTrue);
				expect(union.first.end.value, equals(50));
				expect(union.first.end.isClosed, isTrue);
			});
		});

		group('symmetric difference', () {
			test('basic', () {
				final first = IntervalSet<num>(1, 10) + Interval<num>(15, 20) + Interval<num>(25, 100);
				final second = IntervalSet<num>(5, 14) + Interval<num>(18, 22) + Interval<num>(70, 200);
				final difference = first.symmetricDifference(second);
				expect(difference.first.start.value, equals(1));
				expect(difference.first.start.isClosed, isTrue);
				expect(difference.first.end.value, equals(5));
				expect(difference.first.end.isOpen, isTrue);
				expect(difference.contains(5), isFalse);

				var interval = difference.elementAt(1);
				expect(interval.start.value, equals(10));
				expect(interval.start.isOpen, isTrue);
				expect(interval.end.value, equals(14));
				expect(interval.end.isClosed, isTrue);

				interval = difference.elementAt(2);
				expect(interval.start.value, equals(15));
				expect(interval.start.isClosed, isTrue);
				expect(interval.end.value, equals(18));
				expect(interval.end.isOpen, isTrue);

				interval = difference.elementAt(3);
				expect(interval.start.value, equals(20));
				expect(interval.start.isOpen, isTrue);
				expect(interval.end.value, equals(22));
				expect(interval.end.isClosed, isTrue);

				interval = difference.elementAt(4);
				expect(interval.start.value, equals(25));
				expect(interval.start.isClosed, isTrue);
				expect(interval.end.value, equals(70));
				expect(interval.end.isOpen, isTrue);

				expect(difference.last.start.value, equals(100));
				expect(difference.last.start.isOpen, isTrue);
				expect(difference.last.end.value, equals(200));
				expect(difference.last.end.isClosed, isTrue);
			});

			test('unbounded left', () {
				final first = IntervalSet<num>.unbounded(end: 7) + Interval<num>(15, 20) + Interval<num>(25, 100);
				final second = IntervalSet<num>(5, 14) + Interval<num>(18, 22) + Interval<num>(70, 200);
				final difference = first.symmetricDifference(second);
				expect(difference.first.start.isUnbounded, isTrue);
				expect(difference.first.start.isClosed, isTrue);
				expect(difference.first.end.value, equals(5));
				expect(difference.first.end.isOpen, isTrue);
				expect(difference.contains(5), isFalse);

				var interval = difference.elementAt(1);
				expect(interval.start.value, equals(7));
				expect(interval.start.isOpen, isTrue);
				expect(interval.end.value, equals(14));
				expect(interval.end.isClosed, isTrue);

				interval = difference.elementAt(2);
				expect(interval.start.value, equals(15));
				expect(interval.start.isClosed, isTrue);
				expect(interval.end.value, equals(18));
				expect(interval.end.isOpen, isTrue);

				interval = difference.elementAt(3);
				expect(interval.start.value, equals(20));
				expect(interval.start.isOpen, isTrue);
				expect(interval.end.value, equals(22));
				expect(interval.end.isClosed, isTrue);

				interval = difference.elementAt(4);
				expect(interval.start.value, equals(25));
				expect(interval.start.isClosed, isTrue);
				expect(interval.end.value, equals(70));
				expect(interval.end.isOpen, isTrue);

				expect(difference.last.start.value, equals(100));
				expect(difference.last.start.isOpen, isTrue);
				expect(difference.last.end.value, equals(200));
				expect(difference.last.end.isClosed, isTrue);
			});

			test('unbounded right', () {
				final first = IntervalSet<num>(1, 10) + Interval<num>(15, 20) + Interval<num>(25, 100);
				final second = IntervalSet<num>(5, 14) + Interval<num>(18, 22) + Interval<num>.unbounded(start: 70);
				final difference = first.symmetricDifference(second);
				expect(difference.first.start.value, equals(1));
				expect(difference.first.start.isClosed, isTrue);
				expect(difference.first.end.value, equals(5));
				expect(difference.first.end.isOpen, isTrue);
				expect(difference.contains(5), isFalse);

				var interval = difference.elementAt(1);
				expect(interval.start.value, equals(10));
				expect(interval.start.isOpen, isTrue);
				expect(interval.end.value, equals(14));
				expect(interval.end.isClosed, isTrue);

				interval = difference.elementAt(2);
				expect(interval.start.value, equals(15));
				expect(interval.start.isClosed, isTrue);
				expect(interval.end.value, equals(18));
				expect(interval.end.isOpen, isTrue);

				interval = difference.elementAt(3);
				expect(interval.start.value, equals(20));
				expect(interval.start.isOpen, isTrue);
				expect(interval.end.value, equals(22));
				expect(interval.end.isClosed, isTrue);

				interval = difference.elementAt(4);
				expect(interval.start.value, equals(25));
				expect(interval.start.isClosed, isTrue);
				expect(interval.end.value, equals(70));
				expect(interval.end.isOpen, isTrue);

				expect(difference.last.start.value, equals(100));
				expect(difference.last.start.isOpen, isTrue);
				expect(difference.last.end.isUnbounded, isTrue);
			});

			test('left open', () {
				final first = IntervalSet<num>(1, 10) + Interval<num>(15, 20) + Interval<num>(25, 100);
				final second = IntervalSet<num>(5, 14) + Interval<num>(18, 22) + Interval<num>.leftOpen(70, 90);

				final difference = first.symmetricDifference(second);
				expect(difference.first.start.value, equals(1));
				expect(difference.first.start.isClosed, isTrue);
				expect(difference.first.end.value, equals(5));
				expect(difference.first.end.isOpen, isTrue);
				expect(difference.contains(5), isFalse);

				var interval = difference.elementAt(1);
				expect(interval.start.value, equals(10));
				expect(interval.start.isOpen, isTrue);
				expect(interval.end.value, equals(14));
				expect(interval.end.isClosed, isTrue);

				interval = difference.elementAt(2);
				expect(interval.start.value, equals(15));
				expect(interval.start.isClosed, isTrue);
				expect(interval.end.value, equals(18));
				expect(interval.end.isOpen, isTrue);

				interval = difference.elementAt(3);
				expect(interval.start.value, equals(20));
				expect(interval.start.isOpen, isTrue);
				expect(interval.end.value, equals(22));
				expect(interval.end.isClosed, isTrue);

				interval = difference.elementAt(4);
				expect(interval.start.value, equals(25));
				expect(interval.start.isClosed, isTrue);
				expect(interval.end.value, equals(70));
				expect(interval.end.isClosed, isTrue);

				expect(difference.last.start.value, equals(90));
				expect(difference.last.start.isOpen, isTrue);
				expect(difference.last.end.value, equals(100));
				expect(difference.last.end.isClosed, isTrue);
			});
		});

		group('compliment', () {
			test('single', () {
				final set = IntervalSet<num>(5, 10);
				final compliment = set.compliment();
				expect(compliment.first.start.isUnbounded, isTrue);
				expect(compliment.first.end.value, equals(5));
				expect(compliment.first.end.isOpen, isTrue);
				expect(compliment.last.start.value, equals(10));
				expect(compliment.last.start.isOpen, isTrue);
				expect(compliment.last.end.isUnbounded, isTrue);
			});

			test('multiple', () {
				final set = IntervalSet<num>(5, 10) + Interval<num>(20, 30);
				final compliment = set.compliment();
				expect(compliment.first.start.isUnbounded, isTrue);
				expect(compliment.first.end.value, equals(5));
				expect(compliment.first.end.isOpen, isTrue);
				final interval = compliment.elementAt(1);
				expect(interval.start.value, equals(10));
				expect(interval.start.isOpen, isTrue);
				expect(interval.end.value, equals(20));
				expect(interval.end.isOpen, isTrue);
				expect(compliment.last.start.value, equals(30));
				expect(compliment.last.start.isOpen, isTrue);
				expect(compliment.last.end.isUnbounded, isTrue);
			});

			test('unbounded left', () {
				final set = IntervalSet<num>.unbounded(end: 10) + Interval<num>(20, 30);
				final compliment = set.compliment();
				expect(compliment.first.start.value, equals(10));
				expect(compliment.first.start.isOpen, isTrue);
				expect(compliment.first.end.value, equals(20));
				expect(compliment.first.end.isOpen, isTrue);
				expect(compliment.last.start.value, equals(30));
				expect(compliment.last.start.isOpen, isTrue);
				expect(compliment.last.end.isUnbounded, isTrue);
			});

			test('unbounded right', () {
				final set = IntervalSet<num>.unbounded(start: 10) + Interval<num>(5, 8);
				final compliment = set.compliment();
				expect(compliment.first.start.isUnbounded, isTrue);
				expect(compliment.first.end.value, equals(5));
				expect(compliment.first.end.isOpen, isTrue);
				expect(compliment.last.start.value, equals(8));
				expect(compliment.last.start.isOpen, isTrue);
				expect(compliment.last.end.value, equals(10));
				expect(compliment.last.end.isOpen, isTrue);
			});
		});

		group('subtraction', () {
			test('closed', () {

			});

			test('closed v open', () {

			});

			test('open', () {
				final left = IntervalSet<num>.open(5, 10) + Interval<num>.open(20, 40);
				final right = Interval<num>.open(9, 35);
				final difference = left - right;
				expect(difference.length, equals(2));
				expect(difference.first.start.value, equals(5));
				expect(difference.contains(5), isFalse);
				expect(difference.contains(6), isTrue);
				expect(difference.first.start.isOpen, isTrue);
				expect(difference.first.end.value, equals(9));
				expect(difference.first.end.isClosed, isTrue);
				expect(difference.last.start.value, equals(35));
				expect(difference.last.start.isClosed, isTrue);
				expect(difference.last.end.value, equals(40));
				expect(difference.last.end.isOpen, isTrue);
			});

			test('unbounded left', () {
				final left = IntervalSet<num>(5, 10) + Interval<num>(20, 40);
				final right = Interval<num>.unbounded(end: 8);
				final difference = left - right;
				expect(difference.length, equals(2));
				expect(difference.first.start.value, equals(8));
				expect(difference.first.start.isOpen, isTrue);
				expect(difference.first.end.value, equals(10));
				expect(difference.first.end.isClosed, isTrue);
				expect(difference.contains(10), isTrue);
				expect(difference.last.start.value, equals(20));
				expect(difference.last.start.isClosed, isTrue);
				expect(difference.last.end.value, equals(40));
				expect(difference.last.end.isClosed, isTrue);
			});

			test('unbounded right', () {
				final left = IntervalSet<num>(-10, -5) + Interval<num>(0, 40);
				final right = Interval<num>.unbounded(start: 8);
				final difference = left - right;
				expect(difference.length, equals(2));
				expect(difference.first.start.value, equals(-10));
				expect(difference.first.start.isClosed, isTrue);
				expect(difference.first.end.value, equals(-5));
				expect(difference.first.end.isClosed, isTrue);
				expect(difference.contains(-10), isTrue);
				expect(difference.last.start.value, equals(0));
				expect(difference.last.start.isClosed, isTrue);
				expect(difference.last.end.value, equals(8));
				expect(difference.last.end.isOpen, isTrue);
			});
		});

		test('assertion safety', () {
			expect(() => IntervalSet<num>.degenerate(0), returnsNormally);
			expect(() => IntervalSet<num>.degenerate(null), throwsA(const TypeMatcher<AssertionError>()));
			expect(() => IntervalSet<num>.unbounded(start: 7, end: 9), throwsA(const TypeMatcher<AssertionError>()));
		});
	});
}
