extends Node3D
class_name  fnat_interact_object

enum interact_type {TOUCH, SWICH, BUTTON, PATH, ARM, DOOR, ITEM}

@export var type : interact_type
@export var absolute_cd : float
@export var current_cd : float
@export var flag : String
@export var to_play : String
@export var shake_scale : float
@export var angle_jump : int = -10
@export var jump : float = .05
@export var second : float = 0
@export var volume : int
@export var cout : int
@export var funny_bool : bool
@export var return_to_old_pos : bool = true
@export var sound : bool = true
@export var item : fnat_item

func _ready() -> void:
	current_cd = absolute_cd
	if funny_bool :
		while true :
			await get_tree().create_timer(absolute_cd).timeout
			touch()

func _process(delta: float) -> void:
	if current_cd > 0 : current_cd -= delta

func touch() :
	match type :
		interact_type.TOUCH :
			if current_cd < .1 :
				current_cd = absolute_cd
				if sound : arc_event.play_sfx({"path" = to_play, "volume" = volume, "sec" = second})
				if shake_scale > 0 :
					var old_rot = global_rotation_degrees
					global_rotation_degrees =+ Vector3(randi_range(-angle_jump,angle_jump), 31, randi_range(-angle_jump,angle_jump)) * shake_scale
					global_position.y += jump
					await get_tree().create_timer(.257).timeout
					global_position.y -= jump
					if return_to_old_pos :
						global_rotation_degrees = old_rot
				cout += 1
				if cout == 257 and to_play == "user/teto" :
					arc.save.stars[4] = true
					arc.save_settings()
					arc_event.popup(preload("res://pics/fatass.png"), arc.lang.get_word("p_star"), arc.lang.get_word("p_fat"))
		interact_type.DOOR :
			arc.user.door_to()
		interact_type.ITEM : arc.user.item_swap(item)
		interact_type.SWICH :
			if arc.is_can_add_power == false : 
				arc_event.play_sfx({"path" = "user/power_error", "volume" = 0})
				return
			arc.is_can_add_power = false
			if randf() < arc.batary / 100 : arc.batary = 0
			else :
				arc.batary += randi_range(4, 15)
				arc.out_of_power.connect(arc.run_out_power)
				arc_event.play_sfx({"path" = "user/power_add", "volume" = 18})

			await get_tree().create_timer(7, false, false, false).timeout
			arc.is_can_add_power = true

		interact_type.ARM :
			arc_event.play_sfx({"path" = to_play, "volume" = volume})
			global_position.y = - 20
