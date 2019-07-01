part of intervals;

abstract class Boundary<T extends Comparable<T>> implements Comparable<Boundary<T>> {

	const Boundary(this.value);
	const Boundary.unbounded() : this(null);

	@override bool operator ==(dynamic other) => other is Boundary<T> && value == other.value;
	@override int get hashCode => value == null
								  ? runtimeType.hashCode
								  : hash2(runtimeType.hashCode, value.hashCode);

	bool get isUnbounded => value == null;

	bool get isOpen;
	bool get isClosed => !isOpen;

	bool get isLeft;
	bool get isRight => !isLeft;

	Boundary<T> min(Boundary<T> other) => compareTo(other) >= 0 ? other : this;
	Boundary<T> max(Boundary<T> other) => compareTo(other) <= 0 ? other : this;

	bool contains(T value);

	LeftBoundary<T> get asLeft;
	RightBoundary<T> get asRight;

	final T value;
}

abstract class LeftBoundary<T extends Comparable<T>> extends Boundary<T> {

	const LeftBoundary(T value) : super(value);
	const LeftBoundary.unbounded() : super.unbounded();

	@override bool get isLeft => true;
	@override LeftBoundary<T> get asLeft => this;
}

abstract class RightBoundary<T extends Comparable<T>> extends Boundary<T> {

	const RightBoundary(T value) : super(value);
	const RightBoundary.unbounded() : super.unbounded();

	@override bool get isLeft => false;
	@override RightBoundary<T> get asRight => this;
}

class LeftClosedBoundary<T extends Comparable<T>> extends LeftBoundary<T> {

	const LeftClosedBoundary(T value) : super(value);
	const LeftClosedBoundary.unbounded() : super.unbounded();

	@override bool operator ==(dynamic other) => super == other && other is LeftClosedBoundary<T>;
	@override int get hashCode => hash2(super.hashCode, runtimeType.hashCode);

	@override int compareTo(Boundary<T> other) {
		if (isUnbounded) {
			if (other.isUnbounded) {
				return other.isOpen || other.isRight ? -1 : 0;
			}
			return -1;
		}
		if (other.isUnbounded) return other.isRight ? -1 : 1;
		final compare = value.compareTo(other.value);
		if (other.isOpen && compare == 0) return other.isLeft ? -1 : 1;
		return compare;
	}

	@override String toString() => '[$value';

	@override bool get isOpen => false;

	@override bool contains(T value) => isUnbounded || (value?.compareTo(this.value) ?? 0) >= 0;

	@override RightBoundary<T> get asRight => RightOpenBoundary<T>(value);
}

class LeftOpenBoundary<T extends Comparable<T>> extends LeftBoundary<T> {

	const LeftOpenBoundary(T value) : super(value);
	const LeftOpenBoundary.unbounded() : super.unbounded();

	@override bool operator ==(dynamic other) => super == other && other is LeftOpenBoundary<T>;
	@override int get hashCode => hash2(super.hashCode, runtimeType.hashCode);

	@override int compareTo(Boundary<T> other) {
		if (isUnbounded) {
			if (other.isUnbounded) {
				if (other.isRight) return -1;
				return other.isOpen ? 0 : 1;
			}
			return -1;
		}
		if (other.isUnbounded) return other.isLeft ? 1 : -1;
		final compare = value.compareTo(other.value);
		if (compare == 0) {
			if (other.isRight || other.isClosed) return 1;
		}
		return compare;
	}

	@override String toString() => '($value';

	@override bool get isOpen => true;

	@override bool contains(T value) => value != null && value.compareTo(this.value) > 0;

	@override RightBoundary<T> get asRight => isUnbounded ? RightDegenerateBoundary<T>() : RightClosedBoundary<T>(value);
}

class LeftDegenerateBoundary<T extends Comparable<T>> extends LeftOpenBoundary<T> {
	const LeftDegenerateBoundary() : super.unbounded();

	@override bool operator ==(dynamic other) => super == other && other is LeftDegenerateBoundary<T>;
	@override int get hashCode => hash2(super.hashCode, runtimeType.hashCode);

	@override bool get isLeft => false;

	@override int compareTo(Boundary<T> other) {
		if (other.isUnbounded) return other.isRight ? 0 : 1;
		return 1;
	}

	@override String toString() => '[';

	@override bool contains(T value) => value == null;
}

class RightClosedBoundary<T extends Comparable<T>> extends RightBoundary<T> {

	const RightClosedBoundary(T value) : super(value);
	const RightClosedBoundary.unbounded() : super.unbounded();

	@override bool operator ==(dynamic other) => super == other && other is RightClosedBoundary<T>;
	@override int get hashCode => hash2(super.hashCode, runtimeType.hashCode);

	@override int compareTo(Boundary<T> other) {
		if (isUnbounded) {
			if (other.isUnbounded) {
				return other.isOpen || other.isLeft ? 1 : 0;
			}
			return 1;
		}
		if (other.isUnbounded) return other.isLeft ? 1 : -1;
		final compare = value.compareTo(other.value);
		if (other.isOpen && compare == 0) return other.isRight ? 1 : -1;
		return compare;
	}

	@override String toString() => '$value]';

	@override bool get isOpen => false;

	@override bool contains(T value) => isUnbounded || (value?.compareTo(this.value) ?? 0) <= 0;

	@override LeftBoundary<T> get asLeft => LeftOpenBoundary<T>(value);
}

class RightOpenBoundary<T extends Comparable<T>> extends RightBoundary<T> {

	const RightOpenBoundary(T value) : super(value);
	const RightOpenBoundary.unbounded() : super.unbounded();

	@override bool operator ==(dynamic other) => super == other && other is RightOpenBoundary<T>;
	@override int get hashCode => hash2(super.hashCode, runtimeType.hashCode);

	@override int compareTo(Boundary<T> other) {
		if (isUnbounded) {
			if (other.isUnbounded) {
				if (other.isLeft) return 1;
				return other.isOpen ? 0 : -1;
			}
			return 1;
		}
		if (other.isUnbounded) return other.isRight ? -1 : 1;
		final compare = value.compareTo(other.value);
		if (compare == 0) {
			if (other.isLeft || other.isClosed) return -1;
		}
		return compare;
	}

	@override String toString() => '$value)';

	@override bool get isOpen => true;

	@override bool contains(T value) => value != null && value.compareTo(this.value) < 0;

	@override LeftBoundary<T> get asLeft => isUnbounded ? LeftDegenerateBoundary<T>() : LeftClosedBoundary<T>(value);
}

class RightDegenerateBoundary<T extends Comparable<T>> extends RightOpenBoundary<T> {
	const RightDegenerateBoundary() : super.unbounded();

	@override bool operator ==(dynamic other) => super == other && other is RightDegenerateBoundary<T>;
	@override int get hashCode => hash2(super.hashCode, runtimeType.hashCode);

	@override bool get isLeft => true;

	@override int compareTo(Boundary<T> other) {
		if (other.isUnbounded) return other.isLeft ? 0 : -1;
		return -1;
	}

	@override String toString() => ']';

	@override bool contains(T value) => value == null;
}