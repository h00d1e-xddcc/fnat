extends Node3D
class_name fnat_animatronic

enum mind {IDLE, WALKING, HUNTING}
# idle - стоять на месте без дела, аля играть на гитаре или в аркады
# walking - идти куда-то, с конкретной целью, или без
# hunting - атака на пользователя

@export var mood : mind
@export var current_point : node_path
@export var ai_lvl : int = 0
@export var color : Color
@export var animator : AnimationPlayer
@export var hunger : int = 0
@export var acc : Node3D
@export var noise : AudioStreamPlayer3D
@export var is_lock : bool

signal in_office

func jumpscare() :
	for i in arc.user.anims.size() :
		arc.user.anims[i].ai_lvl = 0
	await get_tree().create_timer(2.57).timeout
	arc.user.blink(.15)
	await get_tree().create_timer(.257).timeout
	arc.user.blink(.3)
	animator.play("default")
	arc.user.state = arc.user.action.loss
	arc.user.flash_light.visible = false
	get_node("/root/main/office/user/omni").visible = true
	set_face("shock")
	reparent(arc.user)
	position = arc.user.basis.x
	var tween = create_tween()
	tween.tween_property(self, "position", Vector3(0,-2.2,-.64), .420)
	#position = Vector3(0,-2.2,-.64)
	rotation_degrees = Vector3(0,180, 0)
	arc.play_sound("anim/" + name + "/scream")
	await get_tree().create_timer(2.57).timeout
	get_tree().quit()

func move() :
	arc.screen.interupt_cam()
	var move_to = current_point.get_random()
	if move_to.occupation != name : 
		print(name)
		print(move_to.name)
		OS.crash("You stupid ni-") 

	match move_to.flag :
		"office" :
			arc.user.flash_light_charge = 0
			visible = false
			if arc.user.flash_light.visible == true : arc.play_sound("user/error")
			arc.play_sound("anim/chimera/knock")
			await get_tree().create_timer(2.57).timeout
			arc.play_sound("anim/door_move" + str(randi_range(0,2)))
			animator.play(move_to.get_pose())
			global_position = move_to.global_position
			rotation = move_to.rotation
			visible = true
			current_point = move_to
			return
		"door" :
			arc.play_sound("anim/door_move" + str(randi_range(0,2)), 0, self)

		"vent" :
			arc.play_sound("anim/vent_quiet" + str(randi_range(0,1)), 0, self)

		"window":
			arc.user.blink(.3)

	match current_point.name :
		"office" :
			hunger = 0
			mood = mind.WALKING
			arc.user.mental_sickness += 40
			arc.user.blink(.350)
			match name :
				"chimera", "bear", "nerd" :
					arc.play_sound("anim/door_move" + str(randi_range(0,2)), 0, self, 0, 7)
				"noise" : arc.play_sound("anim/vent_quiet" + str(randi_range(0,1)), 0, self, 0, 7)
		"kitchen" :
			if name == "nerd" and move_to.name == "fire_exit" and arc.user.anims[3].is_lock == true:
				arc.user.anims[3].is_lock = false
				arc.play_sound("anim/nerd/lockpick",0, arc.user.anims[3])

	var anim_to_play : String = move_to.get_pose()
	match name :
		"noise" :
			noise.playing = false
			if anim_to_play == "default" :
				guitar(true) 
				animator.play("guitar")
			else :
				guitar(false)
				animator.play(anim_to_play)
			var roll : int = randi_range(0, 100)
			if roll > 80 : arc.play_sound("anim/noise/bass/fingering", 0, self, 0, 13)
			else : arc.play_sound("anim/noise/moved", 0, self, 7)
		_ : 
			animator.play(anim_to_play)

	global_position = move_to.global_position
	rotation = move_to.rotation
	current_point = move_to
	if name == "endo" : arc.play_sound("anim/" + arc.user.anims[randi_range(0,3)].name + "/moved", 0, self, 0, 15)
	else : arc.play_sound("anim/" + name + "/moved", 0, self, 0, 15)

func toss_roll() :
	var value : int = randi_range(1,25)
	#if mood == mind.IDLE or mood == mind.WALKING :
		#var roll = randi_range(0, 40)
		#if ai_lvl > 0 : hunger += roll
		#if hunger >= 257 :
			#mood = mind.HUNTING
			##current_point = get_node("/root/main/path_" + str(persone.keys()[pers]) + "/hunting/" + current_point.name)
			##if current_point == null : current_point = get_node("/root/main/path_" + str(persone.keys()[pers]) + "/hunting").get_child(0)
			#current_point = null
			##current_point = get_node("/root/main/path_chimera/hunting/stage")
			#move()
			#return
		#if value >= 10 : 
			#move()
			#return
	if is_lock : 
		if name == "noise" and randi_range(0, 100) >= 85:
			noise.playing = false
			is_lock = false
			#move()
		return
	else : 
		match name :
			"noise" :
				var roll = randi_range(0, 100)
				if roll >= 96:
					if roll % 2 == 0 : 
						arc.play_external(noise, "anim/noise/bass/it_is_sad_day", 15, randf_range(0, 7))
					else : arc.play_external(noise, "anim/noise/bass/вещественное_доказательсво", 17, randf_range(0, 7))
					is_lock = true
	if ai_lvl >= value :
		move() 

func guitar(boolean : bool = false) :
	if name == "noise" :
		if boolean : 
			acc.position = Vector3(-.11, 1.333, -.296)
			acc.rotation_degrees = Vector3(2.4, 15.4, -43.1)
		else :
			acc.position = Vector3(-.028, 1.259, -.019)
			acc.rotation_degrees = Vector3(1, -179.8, 9.2)

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
	get_node("skelet/Skeleton3D/_eyes").visible = false
	get_node("skelet/Skeleton3D/_sharp").visible = false
	get_node("skelet/Skeleton3D/_smile").visible = false
	get_node("skelet/Skeleton3D/_shock").visible = false
	get_node("skelet/Skeleton3D/_glass").visible = false
	get_node("skelet/Skeleton3D/_homeless").visible = false
	
	get_node("skelet/Skeleton3D/_" + face).visible = true

#func walking() :
	#mood = mind.WALKING
	#while mood == mind.WALKING :
		#await get_tree().create_timer(randf_range(.75, 2.57)).timeout
		#arc.play_sound("anim/chemera/step/" + str(randi_range(0,5)), 0, self, 0, 10)

func _ready() -> void:
	in_office.connect(jumpscare)
	var roll = randi_range(0,100)
	match name :
		#persone.CHIMERA :
			#if roll > 70 : current_point = get_node("/root/main/path_chimera/hunting/stage")
			#else : current_point = get_node("/root/main/path_chimera/walking/stage")
		"noise" :
			animator.play("guitar")
			if roll >= 95 :
				if roll % 2 == 0 : 
					arc.play_external(noise, "anim/noise/bass/it_is_sad_day", 15, randf_range(0, 7))
				else : arc.play_external(noise, "anim/noise/bass/вещественное_доказательсво", 17, randf_range(0, 7))
				is_lock = true
		"chimera" :
			animator.play("engage")
		"nerd" :
			animator.play("look")
		"endo" : ai_lvl = randi_range(0,25)
	while true :
		await get_tree().create_timer(randf_range(4,25)).timeout
		toss_roll()

func _process(delta: float) -> void:
	if current_point.name == "office" :
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
# Емае, такое надо было записывать,
# Сейчас, во время тестовой ночи, все стояли с интелектом 0, и химера на 25, для теста анимаций перемещений. 
# Первую половину ночи, химера с интелектом 25, перемещалась буквально между двумя комнатами. Только между двумя комнатами. 
# Чуть позже, она менее чем за 5 секунд, каким-то образом появилась на другой части карты. 
# И там она еще около двух минут опять же таки перемещалась между двумя комнатами, уже как обычно.
# И все бы ничего, сижу мониторю химеру на анимации. 
# Смотрю, нет на камерах ее, думаю дай посмотрю все заведение, куда делась то. 
# Открываю аркады, и там зануды нет. У меня прямо животный страх в этот момент появился, и паника началась. 
# У меня еще ночь за окном, и страшный эмбиент играл, так еще и дома никого нет. Это копец как страшно было. 
# Такого никогда не было, это в первые такое, что перемещение между двумя комнатами, и перемещение с 0 интелектом.
