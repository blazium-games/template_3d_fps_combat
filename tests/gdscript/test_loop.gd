extends AutoworkTest

const Rules = preload("res://scripts/rules.gd")

func test_hit_and_empty() -> void:
	var rules = Rules.new()
	assert_eq(rules.fire(true), "hit", "first shot")
	assert_eq(rules.mark_points, 3, "damage")
	rules.rounds = 0
	assert_eq(rules.fire(true), "empty", "zero rounds")

func test_refill() -> void:
	var rules = Rules.new()
	rules.rounds = 0
	rules.refill()
	assert_eq(rules.rounds, 6, "refilled")

func test_aim_and_second() -> void:
	var rules = Rules.new()
	assert_false(rules.aim_hits(0.1, 2.0), "off axis")
	assert_true(rules.aim_hits(0.9, 2.0), "on axis")
	assert_false(rules.may_second(), "mark remains")
	rules.mark_points = 0
	assert_true(rules.may_second(), "mark cleared")
	assert_true(load("res://scenes/second_mark.tscn") != null, "second mark loads")

func test_reload_only_empty() -> void:
	var rules = Rules.new()
	assert_eq(rules.refill_when_empty(), "rejected", "rounds remain")
	rules.rounds = 0
	assert_eq(rules.refill_when_empty(), "refilled", "empty reload")
	assert_eq(rules.rounds, 6, "magazine full")
