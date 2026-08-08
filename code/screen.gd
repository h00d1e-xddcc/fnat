extends StaticBody3D
class_name fnat_screen

@export var status : Label
@export var time : Label
@export var info : Label
@export var sub : SubViewport
@export var mesh : MeshInstance3D
@export var cam : Control
@export var scheme : Node2D
@export var booting : Control
@export var sfx : AudioStreamPlayer3D
@export var noise : Control
@export var noise_sfx : AudioStreamPlayer3D
@export var teto_input : Control
@export var teto_word : String

func _ready() -> void:
	arc.loadout()
	input_event.connect(_on_input_event)
	noise.visible = false
	#arc.play_sound("ambient/they_coming", 0, null, 0, 15)

func _on_input_event(camera : Camera3D, event : InputEvent, event_position : Vector3, normal : Vector3, shape_idx: int) :
		if arc.user.state != arc.user.action.pc : return
		var mouse3D = mesh.global_transform.affine_inverse() * event_position
		var mouse2D = Vector2(mouse3D.x,mouse3D.z)
		
		var plane_size = mesh.mesh.size
		mouse2D += plane_size / 2
		mouse2D /= plane_size
		
		event.position = mouse2D * Vector2(sub.size)
		sub.push_input(event)

func update_text() :
	#status.text = arc.get_word("ui_usage") + " " + str(arc.usage)
	#status.text += "\n" + arc.get_word("ui_power") + " " + str(int(arc.batary))
	#
	#time.text = str(arc.night.start_night) + " " + arc.get_word("ui_night")
	#var hour : int = int(arc.time / 60) 
	var hour : int
	#if hour == 0 : time.text += "\n12 " + arc.get_word("ui_time_pm")
	#else : time.text += "\n" + str(hour) + " " + arc.get_word("ui_time_am")

func _pressed(extra_arg_0: StringName) -> void:
	info.text = arc.get_word("ui_cam") + " > " + arc.get_word("room_" + extra_arg_0)
	var new_cam = get_node("/root/main/cams/" + extra_arg_0)
	if new_cam == arc.user.cam : return
	arc.user.cam.visible = false
	arc.user.cam.current = false
	sfx.playing = false
	arc.user.cam = new_cam
	play_uniq_room_sfx()
	arc.user.cam.visible = true
	arc.user.cam.current = true
	arc_event.play_sfx({"type" = "2d", "path" = "user/swap"})

func _on_scheme_pressed() -> void:
	if scheme.visible == true or arc.user.spot_light.visible == false : return
	cam.visible = false
	scheme.visible = true
	get_node("sub/ui/audio").visible = false
	arc_event.play_sfx({"type" = "2d", "path" = "user/swap"})
	
func _on_cam_pressed() -> void:
	if cam.visible == true or arc.user.spot_light.visible == false : return
	scheme.visible = false
	if arc.user.cam.is_audio_only :
		cam.visible = false
		get_node("sub/ui/audio").visible = true
	else :
		cam.visible = true
		get_node("sub/ui/audio").visible = false
	arc_event.play_sfx({"type" = "2d", "path" = "user/swap"})

func play_uniq_room_sfx() :
	var room : String = arc.user.cam.name
	var roll = randi_range(0, 100)
	match room :
		"jeffry" :
			if roll > 70 and arc.room_check(-1, "jeffry") : 
				play("ambient/jeffry", randf_range(0, arc.sounds["ambient/jeffry"].get_length()))
		"parts_and_service" :
			play("ambient/parts_and_service", randf_range(0, arc.sounds["ambient/parts_and_service"].get_length()), -10)
		"backstage" :
			if roll > 80 and arc.room_check(2, "backstage") : 
				play("ambient/guts", randf_range(0, arc.sounds["ambient/guts"].get_length()))
				return
			if roll > 60 and arc.room_check(-1 , "backstage") : 
				play("ambient/backstage1", randf_range(0, arc.sounds["ambient/backstage"].get_length()))
		"enter" :
			play("ambient/enter", randf_range(0, arc.sounds["ambient/enter"].get_length()), 10)
		"main_stage" :
			if roll > 95 :
				play("ambient/circus", randf_range(0, arc.sounds["ambient/circus"].get_length()))
				return
			if roll > 75 : play("ambient/box", randf_range(0, arc.sounds["ambient/box"].get_length()))
		"ware" : play("ambient/ware", randf_range(0, arc.sounds["ambient/ware"].get_length()))
		"kitchen" :
			if arc.room_check(3, "kitchen") :
				play("anim/bear/cooking/" + str(randi_range(0,4)), randf_range(0, 3))

func play(path : String, second : float, vol_degr : int = 0) :
	sfx.stream = arc.sounds[path]
	sfx.volume_db = arc.volume - vol_degr
	sfx.play(second)

func _on_ping_pong_pressed() -> void:
	arc.button_delay(get_node("sub/ui/scheme/buttons/ping_pong"), PI)
	arc.batary -= 1
	for i in arc.user.anims.size() :
		arc.user.anims[i].ping()
	arc_event.play_sfx({"path" = "user/wait"})

func _on_play_sound_pressed() :
	arc.button_delay(get_node("sub/ui/scheme/buttons/play_sound"), PI)
	arc_event.play_sfx({"path" = str("user/echo" + str(randi_range(0,2)))})
	arc.batary -= 1

func interupt_cam() :
	noise.visible = true
	noise_sfx.stream = load("res://resources/sounds/user/camera_interruption" + str(randi_range(0,2)) + ".vaw")
	if cam.visible and arc.user.spot_light.visible == true : noise_sfx.play()
	await get_tree().create_timer(2.57).timeout
	noise.visible = false

func mute_channel(boolean : bool = false) :
	noise_sfx.playing = boolean
	sfx.playing = boolean

func teto_word_of_the_day():
	var rand_word = arc.save.words.pick_random()
	var rand_pos : Vector2i = Vector2i(randi_range(0,700), randi_range(0,400))
	get_node("sub/ui/word_minigame/back/teto_word").position = rand_pos
	get_node("sub/ui/word_minigame/back/teto_word/word").text = rand_word
	get_node("sub/ui/word_minigame/back/teto_word/input").placeholder_text = rand_word
	get_node("sub/ui/word_minigame/back/teto_word/input").text = ""
	teto_word = rand_word
	teto_input.visible = true
	arc_event.play_sfx({"path" = "anim/virus/teto_word" + str(randi_range(0,2))})

func _on_input_text_changed(new_text: String) -> void:
	print(1)
	if new_text == teto_word :
		teto_input.visible = false

#func game_math() :
	#var power_to_add = 0.0
	#
	#var add0 = randi_range(13, 57)
	#var add1 = randi_range(1, 42)
	#var add2 = randi_range(8, 32)
	#var user_add_input : int
	#if user_add_input == add0 + add1 + add2 : power_to_add += randf_range(.75, 2.4)
	#
	#var sub0 = randi_range(13, 57)
	#var sub1 = randi_range(1, 42)
	#var sub2 = randi_range(8, 32)
	#var user_sub_input : int
	#if user_sub_input == sub0 - sub1 - sub2 : power_to_add += randf_range(.75, 2.4)
	#
	#var mult0 = randi_range(1, 10)
	#var mult1 = randi_range(8, 14)
	#var mult2 = randi_range(0, 4)
	#var user_mul_input : int
	#if user_mul_input == mult0 * mult1 * mult2 : power_to_add += randf_range(.75, 2.4)
#
	#var div0 = randi_range(1, 10)
	#var div1 = randi_range(8, 14)
	#var div2 = randi_range(0, 4)
	#var user_div_input : int
	#if user_div_input == div0 * div1 * div2 : power_to_add += randf_range(.75, 2.4)
	#
	#arc.batary += power_to_add


func shock(extra_arg_0: StringName) -> void:
	arc.button_delay(get_node("sub/ui/scheme/shock/" + extra_arg_0), PI)
	match  extra_arg_0 :
		"noise" : 
			arc.user.anims[1].move()
		"nerd" :
			arc.user.anims[2].go_back()
		"chimera" :
			if randi_range(0,100) < 65 :
				arc.user.anims[0].move()
			else : arc.user.anims[0].go_back()
		"endo" :
			arc.user.anims[4].ai_lvl += randi_range(-7,7)
			if arc.user.anims[4].ai_lvl <= 0 : arc.user.anims[4].ai_lvl = 0
	arc_event.play_sfx({path = "user/shock", type = "3d"})


func _on_input(new_text: String) -> void:
	print(1)
	if new_text == teto_word :
		teto_input.visible = false
