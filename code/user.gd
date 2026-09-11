extends Camera3D
class_name fnat_user

enum action {sit, hide, peek, pc, back, loss, window, minigame}

@export var state : action
@export var to_rotate : float
@export var flash_light : SpotLight3D
@export var flash_light_charge : float = 100
@export var flashlight_broke_factor : int = 80
@export var flashlight_loss_factor : float = 2
@export var spot_light : SpotLight3D
@export var cast : RayCast3D
@export var source : Dictionary[String,AudioStreamPlayer]
@export var cam : fnat_camera
@export var fan_rotor : MeshInstance3D
@export var is_booting : bool
@export var running_out_batary : bool
@export var anims : Array[fnat_animatronic]
@export var mental_sickness : float
@export var mental_sickness_factor : float
@export var blink_screen : Node
@export var is_shaking : bool
@export var fatass : Node3D
@export var fuses : Array[Node3D]
var interaction

@export var item_right : fnat_item
@export var item_left : fnat_item
@export var item_head : fnat_item
@export var items : Dictionary[String, fnat_item]

func _process(delta):
	if Input.is_action_just_pressed("pause") : arc.pause()
	if get_tree().paused or state == action.loss : return
	input()
	if to_rotate != 0 :
		match state :
			action.sit, action.hide, action.window:
				if arc.loss : return
				rotation.y = lerp(rotation.y, rotation.y + to_rotate, delta * 1.57)
				arc.screen.get_node("sub/ui/scheme/map/you/arrow").rotation = -rotation.y
			action.pc :
				if arc.screen.cam.visible == true:
					var rot = cam.rotation_degrees.y + to_rotate
					cam.rotation_degrees.y = lerp(cam.rotation_degrees.y, rot, delta * 100)
					if cam.rotation_degrees.y > cam.min : cam.rotation_degrees.y = cam.min
					if cam.rotation_degrees.y < cam.max : cam.rotation_degrees.y = cam.max

	if state != action.pc : 
		match item_right.resource_path.get_file().get_basename() :
			"light", "light_big" : 
				if arc.user.flash_light_charge < 0 : arc.user.flash_light.visible = false
				else : 
					flash_light.visible = Input.is_action_pressed("light")
					flash_light_charge -= delta * flashlight_loss_factor
					flash_light.light_energy = flash_light_charge / 100
			_ : if flash_light.visible : flash_light.visible = false
		if Input.is_action_pressed("light") :
			if arc.user.state == arc.user.action.minigame :
				if arc.user.anims[0].current_point.flag == "office" :
					arc.user.anims[0].hunger = -1000
					arc.user.anims[0].ai_lvl = -1
					arc.time = 999
			var mouse_pos = get_viewport().get_mouse_position()
			var ray_origin = project_ray_origin(mouse_pos)
			var ray_direction = project_ray_normal(mouse_pos)
			var ray_length = 1000
			var query = PhysicsRayQueryParameters3D.create(
			ray_origin,
			ray_origin + ray_direction * ray_length)
			var result = get_world_3d().direct_space_state.intersect_ray(query)
			if arc.user.flash_light.visible : flash_light.look_at(result.position)
			#print(result.collider.name)
			match result.collider.name :
				"nchimera" : 
					if flash_light_charge > 0 :
						match item_right.resource_path.get_file().get_basename() :
							"flash" : get_node("/root/main/nchimera").hunger -= 60 * delta * (flash_light_charge / 50)
							"flash_big" : get_node("/root/main/nchimera").hunger -= 100 * delta * (flash_light_charge / 50)
						if get_node("/root/main/nchimera").hunger <= 0 :
							blink(.31)
							get_node("/root/main/nchimera").poof()
				"gnoise" :
					if get_node("/root/main/gnoise").hunger > 100 :
						get_node("/root/main/gnoise").emit_signal("in_office")
					elif flash_light_charge > 0 : flashlight_brake()
				"noise" :
					if flash_light_charge > 0 :
						match item_right.resource_path.get_file().get_basename() :
							"flash" : get_node("/root/main/noise").hunger += 25 * delta * (flash_light_charge / 50)
							"flash_big" : get_node("/root/main/noise").hunger += 75 * delta * (flash_light_charge / 50)
				_: 
					if Input.is_action_just_pressed("light") and result.collider is fnat_interact_object : result.collider.touch()

	if spot_light.visible == true and fan_rotor != null :
		fan_rotor.rotation_degrees.y += 1000 * delta
		if fan_rotor.rotation_degrees.y > 57000: fan_rotor.rotation_degrees.y = 0
		mental_sickness += .75 * delta * mental_sickness_factor
	else : 
		mental_sickness += 1.75 * delta * mental_sickness_factor

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
	
	if state == action.hide or state == action.window : return
	
	if Input.is_action_just_pressed("cancel") : cancel_call()
	if Input.is_action_just_pressed("pc") : change_state(3)
	if Input.is_action_just_pressed("spotlight") : spotlight()

	if Input.is_action_just_pressed("peek") : change_state(2)
	if Input.is_action_just_released("peek") : change_state(0)


	if Input.is_action_just_pressed("scheme") and state == action.pc : arc.screen._on_scheme_pressed()
	if Input.is_action_just_pressed("cam") and state == action.pc : arc.screen._on_cam_pressed()

func spotlight() :
	if state == action.minigame : return
	if is_booting or arc.batary <= 0 : 
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
		arc.screen.disable_all()
		arc_event.play_sfx({"path" = "user/pc_turn_on"})
		spot_light.visible = true
		arc.usage += 1.75
		arc.screen.booting.visible = true
		arc.screen.visible = true
		await get_tree().create_timer(3.47).timeout
		arc.screen.booting.visible = false
		is_booting = false

func recharge() :
	if state == action.minigame : return
	if arc.user.item_right.resource_path.get_file().get_basename() == "light" or arc.user.item_right.resource_path.get_file().get_basename() == "light_big" : 
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
	if arc.user.state == arc.user.action.minigame : return
	arc.user.flash_light.visible = false
	arc.user.flash_light_charge = 0
	arc_event.play_sfx({"path" = "user/flashlight_die", "volume" = -3})

func cancel_call() :
	if state == action.minigame :
		return
	arc_event.turn_off_one_to_ten(0)
	source["call"].stop()

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
	if state == action.loss or state == action.minigame: return
	match numba :
		5 : 
			state = action.window
			position = Vector3(-3.75, 1.765, -14.362)
			rotation_degrees.y = -175
			rotation_degrees.x = 0
			rotation_degrees.z = 0
			to_rotate = 0
		4 : # loss
			state = action.loss
			fatass.position = Vector3(-2.23, .865, -17.834)
			fatass.rotation_degrees = Vector3(0, 31, 0)
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
					fatass.position = Vector3(-2.782, .503, -18.876)
					fatass.rotation_degrees = Vector3(0, 176, 0)
					flash_light.visible = false
					position = Vector3(-2.9, .5, -17.9)
					rotation = Vector3.ZERO
					if randi_range(0,100) > 90 :
						var strg = arc.lang.get_word("note" + str(randi_range(0,7)))
						arc.change_da_note(strg, 18)
				else :change_state()
		0, _ : # default
			state = action.sit
			fatass.position = Vector3(-2.23, .865, -17.834)
			fatass.rotation_degrees = Vector3(0, 31, 0)
			position = Vector3(-2.7, 1.3, -18.9)
			rotation_degrees.y = -175
			rotation_degrees.x = 0
			rotation_degrees.z = 0
			to_rotate = 0

func fuse(action : String) -> int :
	match action :
		"c" :
			var f = 0
			for i in fuses.size() :
				if fuses[i].visible :
					f += 1
					i += 1
			return f
		"r" :
			if fuses[0].visible == false : return -1
			var disabled = -1
			var iddqd = 3
			for i in range(4) : # reverce cycle
				if fuses[iddqd].visible :
					disabled = iddqd
					break
				else : iddqd -= 1
			if disabled == -1 : return -2
			fuses[disabled].visible = false
			arc_event.play_sfx({"path" = "user/fuse_remove"})
			if disabled == 0 :
				arc.batary = 0
			return disabled
		"a" :
			if fuses[3].visible : return -1
			var disabled = -1
			for i in range(4) :
				if fuses[i].visible == false :
					disabled = i
					break
				else : i -= 1
			if disabled == -1 : return -2
			fuses[disabled].visible = true
			arc_event.play_sfx({"path" = "user/fuse_place"})
			return disabled

	return -1

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
	if state != action.pc or spot_light.visible == false: return

	if Input.is_action_just_pressed("light") and interaction :
		interaction = null
		set_physics_process(true)

	elif event.is_action_pressed("light") and cast.is_colliding() :
		var collider = cast.get_collider()
		interaction = collider
		set_physics_process(false)

	if arc.screen.teto_input.visible == true and event is InputEventKey and event.pressed:
		var line = get_node("/root/main/office/screen/sub/ui/word_minigame/back/teto_word/input")
		var text = char(event.unicode)
		if event.unicode != 0 :
			if text == " " : return
			line.text += str(text)
			if line.text == "gimmestar" :
				arc.save.stars[5] = true
				arc.save_settings()
				arc_event.popup(preload("res://pics/vi0.svg"), arc.lang.get_word("p_star"), arc.lang.get_word("p_cho"), true)
			if line.text == arc.screen.teto_word :
				arc.screen.teto_input.visible = false

		if event.keycode == KEY_BACKSPACE or line.text.length() == 18 :
			line.text = ""
			line.visible = true
			arc.batary -= 1
			arc.screen.teto_input.get_node("back/teto_word/teto_right").texture = load("res://pics/vi" + str(randi_range(0,8)) + ".svg")
			arc.screen.teto_input.get_node("back/teto_word/teto_left").texture = load("res://pics/vi" + str(randi_range(0,8)) + ".svg")
			get_node("/root/main/office/screen/sub/ui/word_minigame/back/teto_word/bozo").visible = true
			arc_event.play_sfx({"path" = "user/fish_miss"})

func blink(time : float = 0) :
	if arc.user.state == arc.user.action.minigame : return
	blink_screen.visible = true
	arc.is_can_pause = false
	await  get_tree().create_timer(time).timeout
	blink_screen.visible = false
	arc.is_can_pause = true
	var roll = randi_range(0,100)
	if roll > 90 : blink(0.13)

func door_to() :
	if state == action.window : return
	#blink(2.57)
	#change_state(5)

func mute() :
	source["fan"].stream_paused = true
	source["spot"].stream_paused = true
	source["amb"].stream_paused = true
	source["whitout"].stream_paused = true
	arc.screen.ad_source.stream_paused = true

func item_swap(to_swap : fnat_item, node3d :Node3D) :
	var item = to_swap.resource_path.get_file().get_basename()
	print(item)
	match to_swap.item_type : # TYPE_OF_SWAPED_ITEM

		to_swap.TYPE_OF_ITEM.RIGHT :
			if item_right == to_swap : return
			match item_right.resource_path.get_file().get_basename() :
				"light", "light_big" : 
					node3d.visible = true
					arc.user.flash_light.visible = false

			match item : # EQUIP
				"light" :
					arc.user.flash_light_charge = 0
					arc.user.flashlight_loss_factor = 1.5
					arc.user.flash_light.spot_range = 15
					arc.user.flash_light.spot_attenuation = .2
					arc.user.flash_light.spot_angle = 10
					arc.user.flash_light.spot_angle_attenuation = .7
					node3d.visible = false
				"light_big" :
					arc.user.flash_light_charge = 0
					arc.user.flashlight_loss_factor = 2.7
					arc.user.flash_light.spot_range = 30
					arc.user.flash_light.spot_attenuation = .5
					arc.user.flash_light.spot_angle = 20
					arc.user.flash_light.spot_angle_attenuation = .6
					node3d.visible = false
			item_right = to_swap


		to_swap.TYPE_OF_ITEM.HEAD : # take_off
			if item_head == to_swap : return
			match item_head.resource_path.get_file().get_basename() :
				"goggles" :
					arc.world.environment.background_color = Color("000000")
					node3d.visible = true
					mental_sickness_factor = 1
					arc_event.play_sfx({"path" = "user/goggles_off"})
				"foil_hat" :
					arc.usage += .57
					node3d.visible = true
					mental_sickness_factor = 1
					arc_event.play_sfx({"path" = "ambient/short/item/paper"})

			match item : #equip
				"goggles" :
					arc.world.environment.background_color = Color("00c400")
					node3d.visible = false
					mental_sickness_factor = .75
					arc_event.play_sfx({"path" = "user/goggles"})
				"foil_hat" :
					arc.usage -= .57
					node3d.visible = false
					mental_sickness_factor = .5
					arc_event.play_sfx({"path" = "ambient/short/item/hemlet"})
			item_head = to_swap

func _ready() -> void:
	arc.loadout()
	if state == action.minigame :
		source["amb"].volume_db = arc.save.volume + 14
		return
	change_state()
	await get_tree().create_timer(.257).timeout
	#get_node("/root/main/office/triggers/vhs").visible = false
	arc_event.set_up_ambient()
	arc.start_night(arc.night)
	arc_event.play_random()
	await get_tree().create_timer(3.1).timeout
	arc.is_can_pause = true
	await get_tree().create_timer(await arc_event.play_sfx({"path" = "ambient/calls/" + str(randi_range(0,2)) }) + 2.57).timeout

	var joke_dead : String = ""
	var to_play : String = ""
	match arc.night.start_night :
		0 : to_play = "ambient/short/noise"
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
			#source["call"].stream = load("res://resources/sounds/" + joke_dead + ".ogg")
			source["call"].volume_db = arc.save.volume
			source["call"].play()
			return
	if joke_dead != "" and to_play != "" :
		#source["call"].stream = load("res://resources/sounds/" + joke_dead + ".ogg")
		source["call"].volume_db = arc.save.volume
		source["call"].play()
		await get_tree().create_timer(source["call"].stream.get_length() + .257).timeout
	#source["call"].stream = load("res://resources/sounds/" + to_play + ".ogg")
	source["call"].volume_db = arc.save.volume
	source["call"].play()

	if randi_range(0,100) > 99 : 
			var fatass : fnat_interact_object = get_node("/root/main/office/decor/fatass")
			fatass.to_play = "user/racist"
			fatass.absolute_cd = 12
			fatass.volume = 6
			fatass.second = .83
			fatass.get_node("fnat_fatass").mesh = preload("res://prefabs/mesh/fnat_fatass_black.res")
	if randi_range(0,100) > 99 : 
			var fatass : fnat_interact_object = get_node("/root/main/office/decor/guitar")
			fatass.to_play = "anim/noise/bass/slep"
			fatass.absolute_cd = 5
			fatass.volume = 10
			fatass.second = 0
			fatass.get_node("fnat_guitar").mesh = preload("res://prefabs/mesh/fnat_gguitar.res")
	#arc_event.play_sfx({"type" = "2d", "path" = "ambient/calls/" + arc.save.lange + arc.night.resource_name})
	#if randi_range(0,100 > 90) : arc_event.play_some_event("long")
