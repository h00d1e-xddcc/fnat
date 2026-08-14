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
@export var ad : Control
@export var ad_source : AudioStreamPlayer
@export var teto_input : Control
@export var teto_word : String
@export var hour : int
@export var adblock : int = 90
@export var antivuris : int = 90
@export var cool_down = 3.15
@export var vissy : Control

func _ready() -> void:
	arc.loadout()
	input_event.connect(_on_input_event)
	noise.visible = false
	vissy.visible = false

func _on_input_event(camera : Camera3D, event : InputEvent, event_position : Vector3, normal : Vector3, shape_idx: int) :
		if arc.loss : return
		var mouse3D = mesh.global_transform.affine_inverse() * event_position
		var mouse2D = Vector2(mouse3D.x,mouse3D.z)
		
		var plane_size = mesh.mesh.size
		mouse2D += plane_size / 2
		mouse2D /= plane_size
		
		event.position = mouse2D * Vector2(sub.size)
		sub.push_input(event)

func update_text() :
	status.text = arc.lang.get_word("ui_usage") + " " + str(arc.usage)
	status.text += "\n" + arc.lang.get_word("ui_power") + " " + str(int(arc.batary))
	hour = int(arc.time / 60)
	
	time.text = str(arc.night.start_night) + " " + arc.lang.get_word("ui_night")
	time.text += "\n" + str(hour) + " " + arc.lang.get_word("ui_time_am")

func _pressed(extra_arg_0: StringName) -> void:
	info.text = arc.lang.get_word("ui_cam") + " > " + arc.lang.get_word("room_" + extra_arg_0)
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
	var to_play : String
	var volume = 0
	var roll = randi_range(0, 100)
	match room :
		"jeffry" :
			if roll > 70 and arc.room_check(-1, "jeffry") : 
				to_play = "ambient/room/jeffry"
		"parts_and_service" :to_play = "ambient/room/parts_and_service"
		"backstage" :
			if roll > 80 and arc.room_check(2, "backstage") : 
				to_play = "ambient/long/guts"
				return
			if roll > 60 and arc.room_check(-1 , "backstage") : to_play = "ambient/room/backstage1"
		"enter" : 
			to_play = "ambient/room/enter"
			volume = -13
		"main_stage" :
			if roll > 95 :
				to_play = "ambient/long/circus"
				return
			if roll > 75 : to_play = "ambient/long/box"
		"ware" : to_play = "ambient/room/ware"
		"kitchen" :
			if arc.room_check(3, "kitchen") :
				to_play = "anim/bear/cooking/" + str(randi_range(0,4))
	if to_play == "" : return
	arc_event.play_sfx({"path" = to_play, "volume" = volume})

func play(path : String, vol_degr : int = 0, rand : bool = true) :
	sfx.stream = arc.sounds[path]
	sfx.volume_db = vol_degr
	if rand :  sfx.play(randi_range(0, sfx.stream.get_length()))
	else : sfx.play()

func _on_ping_pong_pressed() -> void:
	arc.button_delay(get_node("sub/ui/scheme/buttons/ping_pong"), cool_down)
	arc.batary -= 1
	for i in arc.user.anims.size() :
		arc.user.anims[i].ping()
	arc_event.play_sfx({"path" = "user/wait"})

func _on_play_sound_pressed() :
	arc.button_delay(get_node("sub/ui/scheme/buttons/play_sound"), cool_down)
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
	if arc.user.spot_light.visible == false : return
	if randi_range(0,1) == 1 : 
		advestment()
		return
	if randi_range(0,100) > antivuris : return
	var rand_word = arc.night.words.pick_random()
	var rand_pos : Vector2i = Vector2i(randi_range(0,700), randi_range(0,400))
	get_node("sub/ui/word_minigame/back/teto_word").position = rand_pos
	get_node("sub/ui/word_minigame/back/teto_word/word").text = rand_word
	get_node("sub/ui/word_minigame/back/teto_word/input").placeholder_text = rand_word
	get_node("sub/ui/word_minigame/back/teto_word/input").text = ""
	get_node("/root/main/office/screen/sub/ui/word_minigame/back/teto_word/bozo").visible = false

	teto_word = rand_word
	teto_input.visible = true
	arc_event.play_sfx({"path" = "anim/virus/teto_word" + str(randi_range(0,2))})

func advestment(value : int = -1) :
	if randi_range(0,100) > adblock : return
	var roll = randi_range(0,27)
	if arc.save.lange == "ru" and randi_range(0, 100) > 90 :
		ad.get_node("panel/sprite").texture = load("res://pics/ad/ru/" + str(randi_range(0,5)) + ".jpg")
	else :
		ad.get_node("panel/sprite").texture = load("res://pics/ad/" + str(roll) + ".jpg")
		if ad.get_node("panel/sprite").texture == null : ad.get_node("panel/sprite").texture = load("res://pics/ad/" + str(roll) + ".webp")
		if ad.get_node("panel/sprite").texture == null : ad.get_node("panel/sprite").texture = load("res://pics/ad/" + str(roll) + ".png")
	
	ad_source.stream = load("res://resources/sounds/anim/virus/" + str(randi_range(0,6)) + ".ogg")
	ad_source.volume_db = randi_range(-8, -1)
	ad_source.play(1)
	if ad.get_node("panel/sprite").texture == null :
		if arc.save.lange == "ru" :
			ad.get_node("panel/sprite").texture = preload("res://pics/ad/ru/adblock.jpg")
		else : preload("res://pics/ad/adblock.png")
		ad_source.stop()
	ad.get_node("panel/sprite/button").position = Vector2(randi_range(120, 800), randi_range(30, 500))
	ad.visible = true

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
	arc.button_delay(get_node("sub/ui/scheme/shock/" + extra_arg_0), cool_down)
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

func _ad_skip() -> void:
	ad.visible = false
	ad_source.stop()

func summon_vissy() :
	if vissy.visible == true : return
	for i in range(17) :
		get_node("sub/ui/vissy/panel/grid_container/" + str(i)).visible = false
	get_node("sub/ui/vissy").visible = true
	get_node("sub/ui/vissy/panel/desc").text = ""
	get_node("sub/ui/vissy/panel/vissy").texture = load("res://pics/v" + str(randi_range(0,2)) + ".png")
	var roll0 = randi_range(0,17)
	var roll1 = randi_range(0,17)
	if roll1 == roll0 : roll1 = roll0 - 1
	get_node("sub/ui/vissy/panel/grid_container/" + str(roll0)).visible = true
	get_node("sub/ui/vissy/panel/grid_container/" + str(roll1)).visible = true

func _vissy(extra_arg_0: int) -> void:
	match extra_arg_0 :
		0 : pass
		1 : antivuris -= 10
		2 : adblock -= 10
		3 : arc.batary += randi_range(3,8)
		4 : arc.user.anims[randi_range(0,4)].ai_lvl -= randi_range(5, 10)
		5 : 
			var roll = randi_range(0,4)
			var ai = arc.user.anims[roll].ai_lvl
			arc.user.anims[roll].ai_lvl = -1
			await get_tree().create_timer(60).timeout
			arc.user.anims[roll].ai_lvl = ai
		6 :
			arc.user.flashlight_broke_factor -= 10
			arc.user.flashlight_loss_factor -= .20
			if arc.user.flashlight_loss_factor < 0 : arc.user.flashlight_loss_factor = 0
			if arc.user.flashlight_broke_factor < 0 : arc.user.flashlight_broke_factor = 0
		7 : 
			cool_down -= .15
			if cool_down < .25 : cool_down = .25
		8 : arc.user.anims[randi_range(0,4)].ai_lvl += randi_range(5, 10)
		9 : arc.batary += randi_range(3,13)
		10 :
			arc.user.flashlight_broke_factor += 10
			arc.user.flashlight_loss_factor += .20
			if arc.user.flashlight_loss_factor > 4 : arc.user.flashlight_loss_factor = 4
			if arc.user.flashlight_broke_factor > 100 : arc.user.flashlight_broke_factor = 100
		11 : cool_down += .15
		12 : arc.batary -= randi_range(10,15)
		13 : OS.crash("еще не сделано")
		14 : _vissy(randi_range(0,17))
		15 : OS.crash("еще не сделано")
		16 : arc.batary -= randi_range(10,20)
		17 : arc.batary += randi_range(3,7)
	get_node("sub/ui/vissy").visible = false

func _vhovered(extra_arg_0: int) -> void:
	var line : String
	match extra_arg_0 : 
		0 : line = "v_nothing"
		1 : line = "v_antivirus"
		2 : line = "v_adblock"
		3 : line = "v_power"
		4 : line = "v_weak"
		5 : line = "v_disable"
		6 : line = "v_flash"
		7 : line = "v_cdd"
		8 : line = "v_force"
		9 : line = "v_power"
		10 : line = "v_flashd"
		11 : line = "v_cd"
		12 : line = "v_powerd"
		13 : line = "v_radar"
		14 : line = "v_rand"
		15 : line = "v_event"
		16 : line = "v_powerd"
		17 : line = "v_power"
	get_node("sub/ui/vissy/panel/desc").text = arc.lang.get_word(line)
