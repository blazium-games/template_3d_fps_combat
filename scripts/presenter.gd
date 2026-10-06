extends Node3D

const Rules = preload("res://scripts/rules.gd")
var rules = Rules.new()
var gaze := 0.2

@onready var walker: CharacterBody3D = $Walker
@onready var gaze_pivot: Node3D = $Walker/GazePivot
@onready var shot_mark: MeshInstance3D = $ShotMark

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		walker.rotate_y(-event.relative.x * gaze * 0.01)
		gaze_pivot.rotate_x(-event.relative.y * gaze * 0.01)
		gaze_pivot.rotation.x = clampf(gaze_pivot.rotation.x, deg_to_rad(-80.0), deg_to_rad(80.0))

func _physics_process(_delta: float) -> void:
	var wish := Vector2(
		Input.get_action_strength("stride_east") - Input.get_action_strength("stride_west"),
		Input.get_action_strength("stride_south") - Input.get_action_strength("stride_north")
	)
	var facing := walker.global_transform.basis
	var planar := facing * Vector3(wish.x, 0, wish.y) * 4.0
	walker.velocity.x = planar.x
	walker.velocity.z = planar.z
	if not walker.is_on_floor():
		walker.velocity.y -= 12.0 * _delta
	walker.move_and_slide()
	if Input.is_action_just_pressed("primary"):
		var eye := gaze_pivot.get_node("GazeEye") as Camera3D
		var offset := shot_mark.global_position - eye.global_position
		var distance := offset.length()
		var facing_dot := 0.0
		if distance > 0.001:
			facing_dot = (-eye.global_transform.basis.z).dot(offset / distance)
		var outcome := rules.fire(rules.aim_hits(facing_dot, distance))
		if outcome == "hit":
			var left := float(rules.mark_points) / 4.0
			shot_mark.scale = Vector3.ONE * maxf(left, 0.15)
			shot_mark.visible = rules.mark_points > 0
		if rules.may_second():
			_go("res://scenes/second_mark.tscn")
	if Input.is_action_just_pressed("leap") and rules.refill_when_empty() == "refilled":
		shot_mark.visible = true
		shot_mark.scale = Vector3.ONE

func _go(next_path: String) -> void:
	get_tree().change_scene_to_file(next_path)
