extends Camera3D
class_name fnat_user

enum action {sit, hide, peek, pc, back, loss}

@export var state : action
@export var to_rotate : float
@export var flash_light : SpotLight3D
@export var flash_light_charge : float = 100
@export var spot_light : SpotLight3D
@export var cast : RayCast3D
@export var audios : Dictionary[String,AudioStreamPlayer3D]
@export var cam : fnat_camera
@export var fan_rotor : MeshInstance3D
@export var is_booting : bool
@export var running_out_batary : bool
@export var anims : Array[fnat_animatronic]
@export var mental_sickness : float
@export var blink_screen : Node
var interaction

func _process(delta):
	if state == action.loss : return
	input()
	if to_rotate != 0 :
		if state == action.sit :
			rotation.y = lerp(rotation.y, rotation.y + to_rotate, delta * 1.25)
		if state == action.pc and arc.screen.cam.visible == true :
			var rot = cam.rotation_degrees.y + to_rotate
			cam.rotation_degrees.y = lerp(cam.rotation_degrees.y, rot, delta * 100)
			if cam.rotation_degrees.y > cam.min : cam.rotation_degrees.y = cam.min
			if cam.rotation_degrees.y < cam.max : cam.rotation_degrees.y = cam.max

	if state == action.sit or state == action.peek : 
		flash_light.visible = Input.is_action_pressed("light")
	if flash_light.visible :
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = project_ray_origin(mouse_pos)
		var ray_direction = project_ray_normal(mouse_pos)
		var ray_length = 100
		var query = PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_origin + ray_direction * ray_length)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		if result.collider.name == "teto" : arc.play_teto()
		flash_light.look_at(result.position)
		flash_light_charge -= delta * 2
		flash_light.light_energy = flash_light_charge / 100

	if spot_light.visible == true :
		fan_rotor.rotation_degrees.y += 1000 * delta
		if fan_rotor.rotation_degrees.y > 57000: fan_rotor.rotation_degrees.y = 0
		mental_sickness += .75 * delta
	else : 
		mental_sickness += 1.75 * delta

	if randi_range(0,1000) == 256 : play_some_event("start")
	if mental_sickness >= 40 :
		play_some_event("mental")
		mental_sickness -= 40

func input() :
	if Input.is_action_just_pressed("hide") : change_state(1)
	if state == action.hide : return
	
	if Input.is_action_just_pressed("pc") : change_state(3)
	if Input.is_action_just_pressed("spotlight") : spotlight()

	if Input.is_action_just_pressed("peek") : change_state(2)
	if Input.is_action_just_released("peek") : change_state(0)

	if Input.is_action_just_pressed("left") : to_rotate = 1
	if Input.is_action_just_released("left") : to_rotate = 0
	
	if Input.is_action_just_pressed("right") : to_rotate = -1
	if Input.is_action_just_released("right") : to_rotate = 0

	if Input.is_action_just_pressed("recharge") : recharge()
	if Input.is_action_just_pressed("cancel") : cancel_call()

	if Input.is_action_just_pressed("scheme") and state == action.pc : arc.screen._on_scheme_pressed()
	if Input.is_action_just_pressed("cam") and state == action.pc : arc.screen._on_cam_pressed()

	if Input.is_action_just_pressed("konami") : debug()

func spotlight() :
	if is_booting or arc.batary < 0 : 
		arc.play_sound("user/error")
		return
	if spot_light.visible == true :
		audios["fan"].playing = false
		audios["spot"].playing = false
		arc.screen.mute_channel()
		spot_light.visible = false
		arc.screen.visible = false
		arc.usage -= 1.75
	else :
		is_booting = true
		audios["fan"].playing = true
		audios["spot"].playing = true
		arc.play_sound("user/pc_turn_on")
		spot_light.visible = true
		arc.usage += 1.75
		arc.screen.booting.visible = true
		arc.screen.visible = true
		await get_tree().create_timer(3.47).timeout
		arc.screen.booting.visible = false
		is_booting = false

func play_some_event(event : String) :
	match event :
		"start" :
			var roll = randi_range(0,15)
			match roll :
				0 : arc.play2D_sound("ambient/random/dog", 0, 3) 
				1 : arc.play2D_sound("ambient/random/crows", 0, -12)
				2 : arc.play2D_sound("ambient/random/horn", 0, -3)
				3 :arc.play2D_sound("ambient/rainstorm", 1, 4) 
				4 :arc.play2D_sound("ambient/random/punch", 0, 14)
				5 :arc.play2D_sound("ambient/random/roof_walk", 0, 13)
				6 :arc.play2D_sound("ambient/random/siren", 0, 0)
				7 :arc.play2D_sound("ambient/random/fall_pot", 0, -15)
				8 :arc.play2D_sound("ambient/random/fall_armature", 3, -17)
				#9 :arc.play_sound("ambient/random/pipes", 0, null, 3, 0, 10)
				10 :arc.play2D_sound("ambient/fire_alarm", 0, -16)
				_: blink(randf_range(0.15, 2.56))
				
		"mental":
			var roll = randi_range(0,5)
			match roll :
				0 : arc.play2D_sound("ambient/random/sanity" + str(randi_range(0,2)), 0, -0)
				1 : arc.play2D_sound("ambient/random/deerclops" + str(randi_range(0,2)), 0, -10)
				2 : arc.play2D_sound("ambient/random/laugh", 0, 10)
				3 : arc.play2D_sound("anim/spotted", 0, -3)
				4 : arc.play2D_sound("anim/" + arc.user.anims[randi_range(0,3)].name + "/moved", 0, -8)
				5 : arc.play2D_sound("anim/it/breath" + str(randi_range(0,1)), 0, -9)

func recharge() :
	#anims[0].jumpscare()
	if state != action.sit or arc.user.flash_light_charge >= 90: return
	arc.user.flash_light_charge += randf_range(7, 20)
	if arc.user.flash_light_charge > 100 : arc.user.flash_light_charge = 100
	arc.play_sound("user/flashlight_charge")

func cancel_call() :
	var node = get_node("/root/arc/user_call_" + arc.lang.get_lange())
	if node != null : 
		node.queue_free()
		arc.play2D_sound("user/math_correct")

func change_state(numba : int = 0) :
	match numba :
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
					flash_light.visible = false
					position = Vector3(-2.9, .5, -17.9)
					rotation = Vector3.ZERO
					if randi_range(0,100) > 90 :
						var strg = arc.get_word("note" + str(randi_range(0,7)))
						arc.change_da_note(strg, 18)
				else :change_state()
		0, _ : # default
			state = action.sit
			position = Vector3(-2.7, 1.3, -18.9)
			rotation_degrees.y = -175
			rotation_degrees.x = 0
			rotation_degrees.z = 0
			to_rotate = 0
			print("reset")

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
	
	if Input.is_action_just_pressed("light") and interaction :
		interaction = null
		set_physics_process(true)

	elif event.is_action_pressed("light") and cast.is_colliding() :
		var collider = cast.get_collider()
		interaction = collider
		if collider.name == "teto" : arc.play_teto()
		if collider is fnat_screen :
			set_physics_process(false)

func blink(time : float = 0) :
	blink_screen.visible = true
	await  get_tree().create_timer(time).timeout
	blink_screen.visible = false
	var roll = randi_range(0,100)
	if roll > 90 : blink(0.13)

func debug() :
	arc.time = -9999
	arc.batary = 999999

func _ready() -> void:
	change_state()
	arc.set_dif()
	arc.play2D_sound("ambient/warning", 0, -23)
	await get_tree().create_timer(.257).timeout
	play_some_event("start")
	print(arc.lang.get_lange())
	arc.play2D_sound("user/call")
	await get_tree().create_timer(7).timeout
	arc.play2D_sound("user/call_" + arc.lang.get_lange())
