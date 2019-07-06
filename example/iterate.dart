import 'package:libinterval/interval_set.dart';

void iterateExample() {
	final numbers = Interval<num>.rightOpen(0, 10);
	IntervalIterable<num>(numbers, (i) => i++).forEach(print);

	final dates = Interval<DateTime>.leftOpen(DateTime.now(), DateTime.now().add(Duration(days: 4)));
	IntervalIterable<DateTime>(dates, (date) => date.add(Duration(days: 1))).forEach(print);
}