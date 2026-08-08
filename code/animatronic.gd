extends Node3D
class_name fnat_animatronic

enum mind {IDLE, WALKING, HUNTING}
# idle - стоять на месте без дела, аля играть на гитаре или в аркады
# walking - идти куда-то, с конкретной целью, или без
# hunting - атака на пользователя
#???


@export var mood : mind
@export var current_point : node_path
@export var ai_lvl : int = 0
@export var color : Color
@export var animator : AnimationPlayer
@export var hunger : float = 0
@export var acc : Node3D
@export var noise : AudioStreamPlayer3D
@export var is_lock : bool
@export var is_static : bool
@export var talk : bool = false
@export var cursed : bool

@export var pose_default : Array[String]
@export var pose_hunting : Array[String]

@export var face_default : Array[String]
@export var face_hunting : Array[String]
@export var face_scream : String

# animation_array
# dab, damn, default, engage, guitar0-1, look, lotos, mrbeast, peta, pootis_pow, reference, absolute, sniper, imp, tpose
# mannrobic0-4, kas0-4, pc, romantic

signal in_office

func jumpscare() :
	while arc.user.state == arc.user.action.hide : 
		return
	arc.is_can_pause = false
	for i in arc.user.anims.size() :
		arc.user.anims[i].ai_lvl = 0
	await get_tree().create_timer(2.57).timeout
	arc.user.blink(.15)
	await get_tree().create_timer(.2).timeout
	arc.user.blink(.15)
	await get_tree().create_timer(.257).timeout
	arc.user.blink(.3)
	animator.play("mannrobic2")
	arc.user.state = arc.user.action.loss
	arc.user.flash_light.visible = false
	get_node("/root/main/office/user/omni").visible = true
	set_face(face_scream)
	#var direction = (marker.global_position - arc.user.global_position).normalized()
	#global_position = arc.user.global_transform.basis.z.dot(direction)
	#position = Vector3(-2.75,-1,-18.15)
	#look_at(arc.user.global_position)
	#rotation.x = 0
	#rotation.z = 0
	#reparent(arc.user)
	#position = arc.user.basis.x
	#var tween = create_tween()
	#tween.tween_property(self, "position", Vector3(0,-2.2,-.64), .420)
	#rotation_degrees = Vector3(0,180, 0)
	arc_event.play_sfx({"path" = "anim/" + name + "/scream"})
	#if arc.user.spot_light.visible == true : arc.user.spotlight()
	arc.user.mute()
	await get_tree().create_timer(3.9).timeout
	arc.user.blink(9999999)
	print("anim/" + name + "/" + arc.lang.get_lange() + "/" + str(randi_range(0,9)))
	arc.deloadout()
	if talk : 
		await  get_tree().create_timer(await arc_event.play_sfx({"path" = "anim/" + name + "/" + arc.save.lange + "/" + str(randi_range(0,9))}) + 2.57).timeout
	else : await get_tree().create_timer(2.57).timeout
	SceneManager.change_scene("res://prefabs/misc/main_menu.tscn", {"pattern" : "curtians"})

func move() :
	arc.screen.interupt_cam()
	var move_to = current_point.get_random()
	if move_to.name == "office" and arc.room_check(-1, "office") == true : return
	if move_to.occupation != name : 
		print(name)
		print(move_to.name)
		OS.crash("796F7520737475706964206E6967676572")

	match move_to.flag :
		"office" :
			arc.user.flashlight_brake()
			visible = false
			if arc.user.flash_light.visible == true : arc.play_sound("user/error")
			if current_point.name == "office_vent" : arc.play_sound("/anim/vent_quiet" + str(randi_range(0,1)))
			else : arc.play_sound("anim/chimera/knock")
			await get_tree().create_timer(2.57).timeout
			#rotate_head()
			arc.play_sound("anim/"+ name + "/move")
			animator.play(move_to.get_pose())
			arc.user.blink(.257)
			global_position = move_to.global_position
			rotation = move_to.rotation
			visible = true
			current_point = move_to
			return
		"door" :
			arc_event.play_sfx({"path" = "anim/door_move" + str(randi_range(0,2))})

		"vent" :
			arc.play_sound("anim/vent_quiet" + str(randi_range(0,1)), 0, self)

		"window":
			#rotate_head()
			arc.user.blink(.3)
			arc_event.play_sfx({"path" = "anim/tapglass", "volume" = -4})

	match current_point.name :
		"office" :
			hunger = 0
			mood = mind.WALKING
			arc.user.mental_sickness += 40
			arc.user.blink(.350)
			#rotate_head(Vector3.ONE)
			match name :
				"chimera", "bear", "nerd" :
					arc.play2D_sound("anim/door_move" + str(randi_range(0,2)), 2)
				"noise" : arc.play2D_sound("anim/vent_quiet" + str(randi_range(0,1)), 2)
		"kitchen" :
			if name == "nerd" and move_to.name == "fire_exit" and arc.user.anims[3].is_lock == true:
				arc.user.anims[3].is_lock = false
				arc_event.play_sound("anim/nerd/lockpick",0, arc.user.anims[3])
		"window":
			arc.user.blink(.257)
			arc_event.play_sfx({"path" = "anim/tapglass", "volume" = -4})

	var anim_to_play : String = move_to.get_pose()
	match name :
		"noise" :
			noise.playing = false
			if anim_to_play == "default" :
				animator.play("guitar")
			else :
				animator.play(anim_to_play)
			var roll : int = randi_range(0, 100)
			if roll > 80 : arc.play_sound("anim/noise/bass/fingering", 0, self, 0, 13)
			else : arc.play_sound("anim/noise/moved", 0, self, 7)
		_ : 
			animator.play(anim_to_play)

	global_position = move_to.global_position
	rotation = move_to.rotation
	current_point = move_to
	if name == "endo" : arc_event.play_sfx({"path" = str("anim/" + arc.user.anims[randi_range(0,3)].name + "/moved"), "type" = "3d", "node" = str(self.get_path())})
	#else : arc.play_sound("anim/" + name + "/moved", 0, self, 0, 0)
	else : arc_event.play_sfx({"path" = "anim/" + name + "/moved" , "type" = "3d", "node" = str(self.get_path())})

func toss_roll() :
	if ai_lvl == -1 : return
	if randi_range(0,25) < ai_lvl : return
	#if ai_lvl == -1 or randi_range(1,25) < ai_lvl : return
	if is_lock : 
		if name == "noise" and randi_range(0, 100) >= 85:
			noise.playing = false
			is_lock = false
			#move()
		return
	else : 
		match name :
			#"noise" :
				#var roll = randi_range(0, 100)
				#if roll >= 96:
					#if roll % 2 == 0 : 
						##arc.play_external(noise, "anim/noise/bass/it_is_sad_day", 15, randf_range(0, 7))
					#else : arc.play_external(noise, "anim/noise/bass/вещественное_доказательсво", 17, randf_range(0, 7))
					#is_lock = true
			"nchimera" :
				if hunger > 100 : return
				var nc = get_node("/root/main/path/nchimera")
				hunger = 100
				current_point = nc.get_child(randi_range(0, 8))
				global_position = current_point.global_position
				rotation = current_point.rotation
				arc_event.play_sfx({"path" = "anim/nchimera/" + str(randi_range(0,3)), "volume" = -12})
			"virus" : arc.screen.teto_word_of_the_day()
			#_ : move()

func ping() :
	var marker : MeshInstance3D = preload("res://prefabs/ping.tscn").instantiate()
	add_child(marker)
	marker.position = Vector3.ZERO + (Vector3.UP * 3)
	marker.global_rotation_degrees = Vector3i.ZERO
	marker.set_instance_shader_parameter("albedo", color)
	for i in range(5) :
		await get_tree().create_timer(2.35).timeout
		marker.scale += (Vector3.ONE / 2 )
		if i == 3 : 
			marker.queue_free()
			break

func go_back() :
	current_point = get_node("/root/main/path_" + name).get_child(0)
	animator.play(current_point.get_pose())
	global_position = current_point.global_position
	rotation = current_point.rotation

func set_face(face : String) :
	if face == "" : return
	get_node("skelet/Skeleton3D/face").mesh = load ("res://prefabs/mesh/fnat__" + face + ".res")

#func walking() :
	#mood = mind.WALKING
	#while mood == mind.WALKING :
		#await get_tree().create_timer(randf_range(.75, 2.57)).timeout
		#arc.play_sound("anim/chemera/step/" + str(randi_range(0,5)), 0, self, 0, 10)

func friendly_marker(boolean : bool = false) :
	get_node("fr").visible = boolean

func poof() :
	current_point = get_node("/root/main/path/" + name + "/diff")
	global_position = current_point.global_position
	rotation = current_point.rotation

func _ready() -> void:
	in_office.connect(jumpscare)
	var roll = randi_range(0,100)
	match name :
		#persone.CHIMERA :
			#if roll > 70 : current_point = get_node("/root/main/path_chimera/hunting/stage")
			#else : current_point = get_node("/root/main/path_chimera/walking/stage")
		"noise" :
			if roll >= 95 and is_static == false :
				if roll % 2 == 0 : 
					arc.play_external(noise, "anim/noise/bass/it_is_sad_day", 15, randf_range(0, 7))
				else : arc.play_external(noise, "anim/noise/bass/вещественное_доказательсво", 17, randf_range(0, 7))
				is_lock = true
	if is_static == false :
		while true :
			await get_tree().create_timer(randf_range(4,25)).timeout
			toss_roll()

#func rotate_head(point : Vector3 = Vector3.ZERO) : 
	#var bone = get_node("skelet/Skeleton3D").find_bone("head")
	#var pose = get_node("skelet/Skeleton3D").get_bone_pose_rotation(bone)
	#match point :
		#Vector3.ZERO :
			#get_node("skelet/Skeleton3D").set_bone_pose_rotation(bone,Quaternion.from_euler(arc.user.global_position))
		#Vector3.ONE : bone.rotation = Vector3.ZERO
		#_ : bone.look_at(point)

func _process(delta: float) -> void:
	if is_lock == true : return
	if current_point.flag == "office" :
		match name :
			"chimera" :
				var last_state = arc.user.state
				if arc.user.state != last_state or arc.user.to_rotate != 0.0 or arc.user.flash_light.visible :
					emit_signal("in_office")
					in_office.disconnect(jumpscare)

			"nerd" :
				emit_signal("in_office")
				in_office.disconnect(jumpscare)

			"noise" : 
				if arc.user.spot_light.visible == false:
					emit_signal("in_office")
					in_office.disconnect(jumpscare)

			"bear" :
				if arc.user.state != arc.user.action.hide and arc.user.spot_light.visible == false :
					emit_signal("in_office")
					in_office.disconnect(jumpscare)

			"nchimera" :
				if hunger >= 175: 
					emit_signal("in_office")
					in_office.disconnect(jumpscare)
				else : hunger += 5 * delta
