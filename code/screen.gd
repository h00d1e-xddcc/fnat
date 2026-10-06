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
@export var garbage : Control
@export var teto_input : Control
@export var teto_word : String
@export var hour : int
@export var adblock : int = 90
@export var antivuris : int = 90
@export var cool_down = 3.15
@export var vissy : Control
@export var hacking : Control
@export var array : MultiMeshInstance2D
@export var wallpaper : Control
@export var inventory : Control
@export var inventory_slots : Array[Control]

func disable_all() :
	hacking.visible = false
	vissy.visible = false
	teto_input.visible = false
	ad.visible = false
	sfx.playing = false

func _ready() -> void:
	input_event.connect(_on_input_event)
	noise.visible = false
	vissy.visible = false
	teto_input.visible = false
	for i in arc.save.inventory.slots.size() :
		var button = preload("res://prefabs/misc/slot.tscn").instantiate()
		get_node("$sub/ui/garbage_drop/background/texture_rect/inventory/grid_container").add_child(button)
		#button.get_node("item").texture = arc.save.inventory[i].texture
		
	if randi_range(0,100) > 80 : $sub/ui/wallpaper/tme.visible = true
	if randi_range(0,100) > 80 : $sub/ui/wallpaper/ds.visible = true

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
	
	#time.text = str(arc.night.start_night) + " " + arc.lang.get_word("ui_night")
	#time.text += "\n" + str(hour) + " " + arc.lang.get_word("ui_time_am")

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
	arc.screen.garbage.visible = false
	scheme.visible = true
	wallpaper.visible = true
	get_node("sub/ui/audio").visible = false
	arc_event.play_sfx({"type" = "2d", "path" = "user/swap"})
	
func _on_cam_pressed() -> void:
	if cam.visible == true or arc.user.spot_light.visible == false : return
	garbage.visible = false
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
			volume = -18
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
	volume -= - arc.save.volume
	play(to_play, volume)

func play(path : String, vol_degr : int = 0, rand : bool = true) :
	if path == "" : return
	sfx.stream = load("res://resources/sounds/" + path + ".ogg")
	sfx.volume_db = vol_degr
	if rand :  sfx.play(randi_range(0, 5))
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

func clear_screen() :
	wallpaper.visible = true
	cam.visible = false
	scheme.visible = false
	garbage.visible = false
	$sub/scenes/custom.visible = false
	$sub/scenes/garbage.visible = false
	$sub/scenes/build.visible = false
	$sub/scenes/trailer.visible = false

func advestment(value : int = -1) :
	if randi_range(0,100) > adblock : return
	var roll = randi_range(0,123)
	if value != -1 : roll = value
	if arc.save.lange == "ru" and randi_range(0, 100) > 85 :
		ad.get_node("panel/sprite").texture = load("res://pics/ad/ru/" + str(randi_range(0,16)) + ".jpg")
	else :
		ad.get_node("panel/sprite").texture = load("res://pics/ad/" + str(roll) + ".jpg")
		if ad.get_node("panel/sprite").texture == null : ad.get_node("panel/sprite").texture = load("res://pics/ad/" + str(roll) + ".webp")
		if ad.get_node("panel/sprite").texture == null : ad.get_node("panel/sprite").texture = load("res://pics/ad/" + str(roll) + ".png")

	var roll_audio = str(randi_range(0,22))
	if arc.save.lange == "ru"  and randi_range(0,100) > 99 : roll_audio = "-1"
	ad_source.stream = load("res://resources/sounds/anim/virus/" + roll_audio + ".ogg")
	if roll_audio == "9" or roll_audio == "22" : ad_source.volume_db = randi_range(-30, -25)
	else : ad_source.volume_db = randi_range(-17, -10)
	ad_source.pitch_scale = randf_range(.9,1.15)
	ad_source.play(randf_range(1,7))
	if ad.get_node("panel/sprite").texture == null :
		if arc.save.lange == "ru" :
			ad.get_node("panel/sprite").texture = preload("res://pics/ad/ru/adblock.jpg")
			push_error("403 ad_ru -> " + str(value))
		else : 
			ad.get_node("panel/sprite").texture = preload("res://pics/ad/adblock.png")
			push_error("403 ad -> " + str(value))
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

#region vissy

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
		5 : arc_event.rand_temp_disable()
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
		13 : pass
		14 : _vissy(randi_range(0,17))
		15 : pass
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

#endregion

#region tf2_panel

func update_garbage() :
	$sub/ui/garbage_drop/v/coins.text = str(arc.save.coins)
	$sub/ui/garbage_drop/v/gems.text = str(arc.save.gems)

func promo(boolean : bool = false) :
	get_node("sub/ui/garbage_drop/promo").visible = boolean

func promo_enter(new_text: String) -> void:
	if arc.save.promo_used.has(new_text) : return
	match new_text :
		"gaben" :
			arc_event.play_sfx({"path" = "user/gaben"})
			arc.save.gems =+ 99999
			arc.save.coins =+ 99999
		"zoomer" :
			arc.save.gems =+ 5
			arc.save.coins =+ 15
		_ : return
	arc.save.promo_used.append(new_text)
	arc.save_settings()
	update_garbage()
	promo()

func _promo_pressed() -> void:
	promo(!get_node("sub/ui/garbage_drop/promo").visible)

func _on_garbage_pressed() -> void:
	clear_screen()
	match garbage.visible :
		true :
			garbage.visible = false
		false :
			garbage.visible = true
			wallpaper.visible = false

func slut_ad(time : float = 5) :
	advestment()
	var but : Button = $sub/ui/ad/panel/sprite/button
	var timer = time
	but.disabled = true
	but.text = arc.lang.get_word("ui_cont") + " (" + str(int(time)) + ")"
	for i in range(8) :
		await get_tree().create_timer(1).timeout
		time -= 1
		but.text = arc.lang.get_word("ui_cont") + " (" + str(int(time)) + ")"
	but.text = arc.lang.get_word("ui_cont")
	but.disabled = false
	arc.save.coins += 4
	arc.save_settings()
	update_garbage()
#endregion

#region settings

func _swap_screen(extra_arg_0: String) -> void:
	$sub/ui/garbage_drop/background/texture_rect/settings.visible = false
	$sub/ui/garbage_drop/background/texture_rect/inventory.visible = false
	$sub/ui/garbage_drop/background/texture_rect/shop.visible = false
	$sub/ui/garbage_drop/background/texture_rect/scrap.visible = false
	get_node("sub/ui/garbage_drop/background/texture_rect/" + extra_arg_0).visible = true

func _on_lange_item_selected(index: int) -> void:
	match index :
		0 : arc.lang = preload("res://resources/local/en.tres")
		1 : arc.lang = preload("res://resources/local/ru.tres")
	arc.save.lange = arc.lang.get_lange()
	arc.retranslate_title()
	arc.save_settings()

func _on_option_button_item_selected(index: int) -> void:
	arc.save.voiceover = index
	arc.save_settings()

func _voiceover_selected(index: int) -> void:
	print(index)
	arc.save.voiceover = index
	arc.save_settings()
	update_warning(arc.lang.get_word("ui_warn"))

func _on_vsync_toggled(toggled_on: bool) -> void:
	if toggled_on : DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else : DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	arc.save.vsync = toggled_on
	arc.save_settings()

func _set_new_volume(value_changed: bool) -> void:
	arc.save.volume = $/root/main/office/screen/sub/ui/garbage_drop/background/texture_rect/settings/control/slider/grid_container/label.value
	arc.save_settings()
############################################################################################################

func _one_toggled(toggled_on: bool) -> void:
	arc.save.one = toggled_on
	arc.save_settings()
	update_warning(arc.lang.get_word("ui_one"))

func _fullscreen_swap() -> void:
	var toggled_on : bool = $"/root/main/office/screen/sub/ui/garbage_drop/background/texture_rect/settings/control/check/grid_container/full-screen".button_pressed # ничего себе, как можно
	if toggled_on : get_window().mode = Window.MODE_FULLSCREEN
	else : get_window().mode = Window.MODE_WINDOWED
	arc.save.fullscreen = toggled_on
	arc.save_settings()

func update_warning(text : String) :
	$/root/main/office/screen/sub/ui/garbage_drop/texture_rect/settings/warning.text = text
	$/root/main/office/screen/sub/ui/garbage_drop/texture_rect/settings/warning.visible = true
#endregion
