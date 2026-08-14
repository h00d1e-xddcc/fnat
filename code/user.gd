extends Camera3D
class_name fnat_user

enum action {sit, hide, peek, pc, back, loss}

@export var state : action
@export var to_rotate : float
@export var flash_light : SpotLight3D
@export var flash_light_charge : float = 100
@export var flashlight_broke_factor : int = 80
@export var flashlight_loss_factor : int = 2
@export var spot_light : SpotLight3D
@export var cast : RayCast3D
@export var source : Dictionary[String,AudioStreamPlayer]
@export var cam : fnat_camera
@export var fan_rotor : MeshInstance3D
@export var is_booting : bool
@export var running_out_batary : bool
@export var anims : Array[fnat_animatronic]
@export var mental_sickness : float
@export var blink_screen : Node
@export var is_shaking : bool
var interaction

func _process(delta):
	if Input.is_action_just_pressed("pause") : arc.pause()
	if get_tree().paused or state == action.loss : return
	input()
	if to_rotate != 0 :
		match state :
			action.sit, action.hide:
				rotation.y = lerp(rotation.y, rotation.y + to_rotate, delta * 1.57)
			action.pc :
				if arc.screen.cam.visible == true:
					var rot = cam.rotation_degrees.y + to_rotate
					cam.rotation_degrees.y = lerp(cam.rotation_degrees.y, rot, delta * 100)
					if cam.rotation_degrees.y > cam.min : cam.rotation_degrees.y = cam.min
					if cam.rotation_degrees.y < cam.max : cam.rotation_degrees.y = cam.max

	if state != action.pc : 
		flash_light.visible = Input.is_action_pressed("light")
		if flash_light.visible :
			var mouse_pos = get_viewport().get_mouse_position()
			var ray_origin = project_ray_origin(mouse_pos)
			var ray_direction = project_ray_normal(mouse_pos)
			var ray_length = 1000
			var query = PhysicsRayQueryParameters3D.create(
			ray_origin,
			ray_origin + ray_direction * ray_length)
			var result = get_world_3d().direct_space_state.intersect_ray(query)
			#print(result.collider.name)
			match result.collider.name :
				"nchimera" : 
					if flash_light_charge > 0 :
						get_node("/root/main/nchimera").hunger -= 85 * delta * (flash_light_charge / 50)
						if get_node("/root/main/nchimera").hunger <= 0:
							arc.user.blink(.31)
							get_node("/root/main/nchimera").poof()
				"gnoise" :
					get_node("/root/main/gnoise").emit_signal("in_office")
				_: 
					if Input.is_action_just_pressed("light") and result.collider is fnat_interact_object : result.collider.touch()
			flash_light.look_at(result.position)
			flash_light_charge -= delta * flashlight_loss_factor
			flash_light.light_energy = flash_light_charge / 100

	if spot_light.visible == true :
		fan_rotor.rotation_degrees.y += 1000 * delta
		if fan_rotor.rotation_degrees.y > 57000: fan_rotor.rotation_degrees.y = 0
		mental_sickness += .75 * delta
	else : 
		mental_sickness += 1.75 * delta

	if mental_sickness >= 40 :
		arc_event.play_some_event("mental")
		mental_sickness -= 40

func input() :
	if state == action.loss : return
	if Input.is_action_just_pressed("hide") : change_state(1)
	if Input.is_action_just_pressed("left") : to_rotate = 1
	if Input.is_action_just_released("left") : to_rotate = 0
	
	if Input.is_action_just_pressed("right") : to_rotate = -1
	if Input.is_action_just_released("right") : to_rotate = 0

	if Input.is_action_just_pressed("recharge") : recharge()
	
	if state == action.hide : return
	
	if Input.is_action_just_pressed("cancel") : cancel_call()
	if Input.is_action_just_pressed("pc") : change_state(3)
	if Input.is_action_just_pressed("spotlight") : spotlight()

	if Input.is_action_just_pressed("peek") : change_state(2)
	if Input.is_action_just_released("peek") : change_state(0)


	if Input.is_action_just_pressed("scheme") and state == action.pc : arc.screen._on_scheme_pressed()
	if Input.is_action_just_pressed("cam") and state == action.pc : arc.screen._on_cam_pressed()

func spotlight() :
	if is_booting or arc.batary < 0 : 
		arc_event.play_sfx({"path" = "user/error"})
		return
	if spot_light.visible == true :
		source["fan"].stream_paused = true
		source["spot"].stream_paused = true
		source["amb"].stream_paused = true
		arc.screen.ad_source.stream_paused = true
		source["whitout"].stream_paused = false
		arc.screen.mute_channel()
		spot_light.visible = false
		arc.screen.visible = false
		arc.usage -= 1.75
	else :
		is_booting = true
		source["fan"].stream_paused = false
		source["spot"].stream_paused = false
		source["amb"].stream_paused = false
		arc.screen.ad_source.stream_paused = false
		source["whitout"].stream_paused = true
		arc_event.play_sfx({"path" = "user/pc_turn_on"})
		spot_light.visible = true
		arc.usage += 1.75
		arc.screen.booting.visible = true
		arc.screen.visible = true
		await get_tree().create_timer(3.47).timeout
		arc.screen.booting.visible = false
		is_booting = false

func recharge() :
	#anims[0].jumpscare() ля вот такими костылями мне преходилось пользоватся
	if randi_range(0,100) > flashlight_broke_factor :
		flashlight_brake()
		return
	if arc.user.flash_light_charge >= 90: 
		arc.user.flash_light_charge = 100
		arc_event.play_sfx({"path" = "user/flashlight_full", "sec" = .28})
		return
	arc.user.flash_light_charge += randf_range(7, 20)
	arc_event.play_sfx({"path" = "user/flashlight_charge", "volume" = -3})

func flashlight_brake() :
	arc.user.flash_light_charge = 0
	arc_event.play_sfx({"path" = "user/flashlight_die", "volume" = -3})

func cancel_call() :
	var node = get_node("/root/arc/user_call_" + arc.lang.get_lange())
	if node != null : 
		node.queue_free()
		arc_event.play_sfx({"path" = "user/math_correct"})

func shake_pos(inten : float = .02, dur : float = .25) :
	if is_shaking : return
	is_shaking = true

	var time_left = dur
	var start_pos = position

	while time_left > 0 :
		var offcet = Vector3(randf_range(-inten, inten),randf_range(-inten, inten), 0)
		position = start_pos + offcet
		time_left -= get_process_delta_time()
		await  get_tree().process_frame
	position = start_pos
	is_shaking = false

func change_state(numba : int = 0) :
	if state == action.loss : return
	match numba :
		4 : # loss
			state = action.loss
			arc.fatass.position = Vector3(-2.23, .865, -17.834)
			arc.fatass.rotation_degrees = Vector3(0, 31, 0)
			position = Vector3(-2.7, 1.3, -18.9)
			rotation_degrees.y = -175
			rotation_degrees.x = 0
			rotation_degrees.z = 0
			to_rotate = 0
		3 : #pc
			if state != action.pc :
				state = action.pc
				flash_light.visible = false
				position = Vector3(-3.2, 1.2, -18.4)
				look_at(get_node("/root/main/office/screen").position)
				if randi_range(0, 100) > 70 : get_node("/root/main/office/decor/baguette").rotation_degrees.y -= 7
			else : change_state()
		2 : # peek
			state = action.peek
			position = Vector3(-2.3, 1.3, -18.9)
			rotation_degrees.y = 160
		1 : # hide
				if state != action.hide :
					state = action.hide
					arc.fatass.position = Vector3(-2.782, .503, -18.876)
					arc.fatass.rotation_degrees = Vector3(0, 176, 0)
					flash_light.visible = false
					position = Vector3(-2.9, .5, -17.9)
					rotation = Vector3.ZERO
					if randi_range(0,100) > 90 :
						var strg = arc.lang.get_word("note" + str(randi_range(0,7)))
						arc.change_da_note(strg, 18)
				else :change_state()
		0, _ : # default
			state = action.sit
			arc.fatass.position = Vector3(-2.23, .865, -17.834)
			arc.fatass.rotation_degrees = Vector3(0, 31, 0)
			position = Vector3(-2.7, 1.3, -18.9)
			rotation_degrees.y = -175
			rotation_degrees.x = 0
			rotation_degrees.z = 0
			to_rotate = 0

func open_door(angle : float = 90) :
	get_node("/root/main/estab/door/door").rotation_degrees.y = angle
	arc.play_sound("anim/door_move1", 0 ,self)

func _on_left_trigger_mouse_entered() -> void:
	to_rotate = 1

func _on_left_trigger_mouse_exited() -> void:
	to_rotate = 0

func _on_right_trigger_mouse_exited() -> void:
	to_rotate = 0

func _on_right_trigger_mouse_entered() -> void:
	to_rotate = -1

func _input(event) :
	#if event.is_action_pressed("ui_cancel") : get_tree().quit()
	if state != action.pc : return

	if Input.is_action_just_pressed("light") and interaction :
		interaction = null
		set_physics_process(true)

	elif event.is_action_pressed("light") and cast.is_colliding() :
		var collider = cast.get_collider()
		interaction = collider
		set_physics_process(false)

	if arc.screen.teto_input.visible == true and event is InputEventKey and event.pressed:
		if event.unicode != 0 :
			var line = get_node("/root/main/office/screen/sub/ui/word_minigame/back/teto_word/input")
			var text = char(event.unicode)
			if text == " " : return
			line.text += str(text)
			if line.text == "gimmestar" :
				arc.save.stars[5] = true
				arc.save_settings()
			if line.text == arc.screen.teto_word :
				arc.screen.teto_input.visible = false

			if line.text.length() == 10 :
				line.text = ""
				line.visible = true
				arc.batary -= 1
				get_node("/root/main/office/screen/sub/ui/word_minigame/back/teto_word/bozo").visible = true
				arc_event.play_sfx({"path" = "user/fish_miss"})

func blink(time : float = 0) :
	blink_screen.visible = true
	arc.is_can_pause = false
	await  get_tree().create_timer(time).timeout
	blink_screen.visible = false
	arc.is_can_pause = true
	var roll = randi_range(0,100)
	if roll > 90 : blink(0.13)

func mute() :
	source["fan"].stream_paused = true
	source["spot"].stream_paused = true
	source["amb"].stream_paused = true
	source["whitout"].stream_paused = true
	arc.screen.ad_source.stream_paused = true

func _ready() -> void:
	change_state()
	await get_tree().create_timer(.257).timeout
	get_node("/root/main/office/triggers/vhs").visible = false
	arc_event.set_up_ambient()
	arc.start_night(arc.night)
	arc_event.play_random()
	await get_tree().create_timer(3.1).timeout
	arc.is_can_pause = true
	await get_tree().create_timer(await arc_event.play_sfx({"path" = "ambient/calls/" + str(randi_range(0,2)), "volume" = 0 }) + 2.57).timeout

	var joke_dead : String = ""
	var to_play : String = ""
	match arc.night.start_night :
		0 : to_play = "ambient/calls/" + arc.save.lange + "/night0"
		1 : 
			match arc.save.night1_deads :
				1 : joke_dead = "ambient/calls/" + arc.save.lange + "/first"
				2 : joke_dead = "ambient/calls/" + arc.save.lange + "/play_parody"
				3 : joke_dead = "ambient/calls/" + arc.save.lange + "/comment"
			to_play = "ambient/calls/" + arc.save.lange + "/night1"
		2 : 
			match arc.save.night2_deads :
				1 : joke_dead = "ambient/calls/" + arc.save.lange + "/gnoise"
				2 : joke_dead = "ambient/calls/" + arc.save.lange + "/bear"
				5 : joke_dead = "ambient/calls/" + arc.save.lange + "/determination"
			to_play = "ambient/calls/" + arc.save.lange + "/night2"
		6, _ : 
			match randi_range(0,7) :
				1 : joke_dead = "ambient/calls/" + arc.save.lange + "/bober"
				2 : joke_dead = "ambient/calls/" + arc.save.lange + "/cake"
				3 : joke_dead = "ambient/calls/" + arc.save.lange + "/curse"
				4 : joke_dead = "ambient/calls/" + arc.save.lange + "/damn"
				5 : joke_dead = "ambient/calls/" + arc.save.lange + "/console"
				6 : joke_dead = "ambient/calls/" + arc.save.lange + "/dr"
				6 : joke_dead = "ambient/calls/" + arc.save.lange + "/void"
				7 : joke_dead = "ambient/calls/" + arc.save.lange + "/wait"
			source["call"].stream = load("res://resources/sounds/" + joke_dead + ".ogg")
			source["call"].play()
			return
	if joke_dead != "" and to_play != "" :
		source["call"].stream = load("res://resources/sounds/" + joke_dead + ".ogg")
		source["call"].play()
		await get_tree().create_timer(source["call"].stream.get_length() + .257).timeout
	source["call"].stream = load("res://resources/sounds/" + to_play + ".ogg")
	source["call"].play()

	#arc_event.play_sfx({"type" = "2d", "path" = "ambient/calls/" + arc.save.lange + arc.night.resource_name})
	#if randi_range(0,100 > 90) : arc_event.play_some_event("long")
