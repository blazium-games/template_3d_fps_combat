extends RefCounted

var rounds := 6
var mark_points := 4

func fire(in_reach: bool) -> String:
	if rounds <= 0:
		return "empty"
	rounds -= 1
	if in_reach:
		mark_points = maxi(mark_points - 1, 0)
		return "hit"
	return "miss"

func refill() -> void:
	rounds = 6

func refill_when_empty() -> String:
	if rounds > 0:
		return "rejected"
	rounds = 6
	return "refilled"

func reset_mark() -> void:
	rounds = 6
	mark_points = 4

func aim_hits(facing_dot: float, distance: float) -> bool:
	return facing_dot >= 0.65 and distance < 8.0

func may_second() -> bool:
	return mark_points <= 0
