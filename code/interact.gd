extends Node3D
class_name  fnat_interact_object

enum interact_type {TOUCH, SWICH, BUTTON, PATH, ARM}

@export var type : interact_type
@export var absolute_cd : float
@export var current_cd : float
@export var flag : String
@export var to_play : String
@export var shake_scale : float
@export var jump : float
@export var volume : int
@export var cout : int

func _ready() -> void:
	current_cd = absolute_cd

func _process(delta: float) -> void:
	if current_cd > 0 : current_cd -= delta

func touch() :
	match type :
		interact_type.TOUCH :
			if current_cd < .1 :
				current_cd = absolute_cd
				arc_event.play_sfx({"path" = to_play, "volume" = volume})
				if shake_scale > 0 :
					var old_rot = global_rotation_degrees
					global_rotation_degrees =+ Vector3(randi_range(-10,10), 31, randi_range(-10,10)) * shake_scale
					global_position.y += .05
					await get_tree().create_timer(.257).timeout
					global_position.y -= .05
					global_rotation_degrees = old_rot
				cout += 1
				if cout == 257 and to_play == "user/teto" :
					arc.save.stars[4] = true
					arc.save_settings()
		interact_type.ARM :
			arc_event.play_sfx({"path" = to_play, "volume" = volume})
			global_position.y = - 40
