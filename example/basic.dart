import 'package:libinterval/interval_set.dart';

void basic() {
	final first = Interval<num>(2, 10); //closed interval
	final second = Interval<num>.closed(5, 15.5); //also a closed interval
	final third = Interval<num>.leftOpen(-1.1, 18); //closed on the right
	final fourth = Interval<num>.rightOpen(12, 202.565); //closed on the left
	final fifth = Interval<num>.unbounded(start: 5); //closed on left, unbounded on right
	final sixth = Interval<num>.open(-1, -0.7); //open on both sides
	final seventh = Interval<num>.degenerate(5); //degenerate must be closed
	final eighth = Interval<num>.leftOpen(0, null); //unbounded on right

	final ninth = first.union(second);
	final tenth = third.difference(fourth);
	final eleventh = fifth.intersection(sixth);
	final twelfth = seventh.symmetricDifference(eighth);

	final thirteenth = ninth + first; //union of interval set with single interval
	final fourteenth = tenth - second; //difference of interval set with single interval
	final fifteenth = eleventh.union(twelfth);
	final sixteenth = twelfth.difference(thirteenth);
	final seventeenth = fourteenth.intersection(fifteenth);
	final _ = sixteenth.symmetricDifference(seventeenth);

	if (first.contains(6)) {
		print('contains respects open v closed boundaries');
	}

	if (second.intersects(third)) {
		print('test for intersection');
	}

	if (fourth.compareTo(fifth) > 0) {
		print('compares start boundaries');
	}

	if (sixth.touches(seventh)) {
		print('indicates the two intervals can union to one without intersecting');
	}

	final interval = ninth.first; //interval sets are always sorted, so .first and .last are a thing

	if (interval.start.value > 10) {
		print('retrieving interval values');
	}

	if (ninth.last.end.isOpen) {
		print('testing boundary properties');
	}

	if (tenth.first.end.isUnbounded) {
		print('more boundary properties');
	}

	if (eleventh.last.start.isRight) {
		print('yes more boundary properties');
	}
}