extends Node3D
class_name main

@export var light : SpotLight3D
@export var start_sfx : AudioStreamPlayer3D
@export var anims : Array[fnat_animatronic]
@export var stars : int = 0

## region_main
func _ready() -> void:
	if FileAccess.file_exists("user://fnat.tres") : 
		arc.save = ResourceLoader.load("user://fnat.tres") as fnat_save
		arc.lang = load("res://resources/local/" + arc.save.lange + ".tres")
		if arc.lang == null : arc.lang = preload("res://resources/local/en.tres")
		if arc.save.fullscreen : get_window().mode = Window.MODE_FULLSCREEN
		else : get_window().mode = Window.MODE_WINDOWED

		if arc.save.vsync : DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else : DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		get_node("/root/main_menu/ui/main/control/lang").text = arc.save.lange
		get_node("ui/disclaimer_back/lc/panel/" + arc.save.lange).visible = true
		get_node("/root/main_menu/ui/main/control/v_box_container/v-sync").button_pressed = arc.save.vsync
		get_node("/root/main_menu/ui/main/control/v_box_container/full-screen").button_pressed = arc.save.fullscreen
	else :
		arc.save = fnat_save.new()
		var local = OS.get_locale().substr(0, 2)
		match local :
			"ru" : arc.lang = preload("res://resources/local/ru.tres") 
			"en", _ : arc.lang = preload("res://resources/local/en.tres")
		arc.save.fullscreen = false
		arc.save.vsync = false
		arc.save.stars = [false, false, false, false, false, false, false]
		arc.save.night = 1
		arc.save.night1_deads = 0
		arc.save.night2_deads = 0
		arc.save.night6_deads = 0
		arc.save_settings()
		get_node("ui/disclaimer_back/lc/panel/" + local).visible = true
	for i in anims.size() :
		get_node("sub/custom").get_child(i).get_node("light").visible = false
	get_node("sub/custom/fnat_pc").visible = false
	
	get_node("ui/disclaimer_back").visible = true
	get_node("ui/loadout_back").visible = false
	get_node("ui/custom_night").visible = false
	get_node("ui/thanks").visible = false
	get_node("ui/main").visible = true
	for i in arc.save.stars.size() :
		get_node("ui/title/stars/" + str(i)).visible = arc.save.stars[i]
	change_state("main")
	arc.retranslate_title()

func _process(delta: float) -> void:
	light.light_energy = randf_range(.75, 1)
	
	var roll = randi_range(0,2542)
	if roll < 1 : 
		light.light_energy = 0
		var node : Node3D = get_node("sub/main/" + str(randi_range(0,4)))
		node.visible = !node.visible 

	var mouse_pos = get_viewport().get_mouse_position()
	var space_state = get_viewport().get_camera_3d().get_world_3d().direct_space_state
	var ray_origin = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
	var ray_normal = get_viewport().get_camera_3d().project_ray_normal(mouse_pos)
	var ray_end = ray_origin + ray_normal * 20
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	if Input.is_action_just_pressed("light") and result.collider is fnat_interact_object : result.collider.touch()

## rigeonend

func change_state(state : String, time : float = 0) :
	get_node("sub/main").visible = false
	get_node("sub/custom").visible = false
	get_node("sub/thanks").visible = false
	get_node("sub/" + state).visible = true
	await get_tree().create_timer(time).timeout
	get_node("sub/" + state + "/cam").current = true

func _on_button_pressed() -> void:
	get_node("ui/disclaimer_back").visible = false

func _on_start_pressed() -> void:
	get_node("/root/main_menu/ui/loadout_back/story").visible = false
	get_node("ui/loadout_back").visible = true

func stars_load() :
	var stars = 0
	for i in arc.save.stars.size() :
		if arc.save.stars[i] : stars += 1
	#match stars :
		#4 :

func _on_vsync_toggled(toggled_on: bool) -> void:
	if toggled_on : DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else : DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	arc.save.vsync = toggled_on
	arc.save_settings()

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on : get_window().mode = Window.MODE_FULLSCREEN
	else : get_window().mode = Window.MODE_WINDOWED
	arc.save.fullscreen = toggled_on
	arc.save_settings()

func _on_h_slider_drag_ended(value_changed: bool) -> void:
	var volume = get_node("ui/main/control/label/h_slider").value
	arc.volume = volume
	get_node("audio").volume_db = arc.volume - 30

func swap_lang() :
	if arc.lang.dictionary["ui_lang"] == "en" :
		arc.lang = preload("res://resources/local/ru.tres")
		get_node("ui/main/control/lang").text = "ru"
	else :
		arc.lang = preload("res://resources/local/en.tres")
		get_node("ui/main/control/lang").text = "en"
	arc.save.lange = str(get_node("ui/main/control/lang").text)
	arc.save_settings()
	arc.retranslate_title()

func _on_continue_pressed() -> void:
	get_node("ui/loadout_back/continue").disabled = true
	var n : fnat_night = fnat_night.new()

	for i in anims.size() :
		if anims[i].ai_lvl == -57 : anims[i].ai_lvl = randi_range(0, 25)
		n.diff.set(i, anims[i].ai_lvl)

	# сысл в этой секретке, если исходный код открыт?
	var passwd : String = str(anims[0].ai_lvl) + str(anims[1].ai_lvl) + str(anims[2].ai_lvl)
	print("passwd -> " + passwd)

	match passwd :
		"575757" :
			arc_event.play_sfx({"type" = "2d", "path" = "ambient/random/13"})
			await get_tree().create_timer(.57).timeout
		"257" :
			arc_event.play_sfx({"type" = "2d", "path" = "anim/nerd/random/6"})
			await get_tree().create_timer(2.57).timeout
			OS.crash("596F752073757373792062616B61")
	
	arc.night = n
	arc.night.start_night = 6
	arc_event.play_sfx({"path" = "user/start_shift"})
	SceneManager.change_scene("res://prefabs/misc/main.tscn", {"pattern" : "curtians"})
	SceneManager.set_title(arc.lang.get_word("night6"))

func _on_story_pressed() -> void:
	get_node("/root/main_menu/ui/loadout_back/continue").visible = false
	get_node("ui/loadout_back").visible = true

func _button_start_night() -> void:
	arc.night = load("res://resources/nights/night" + str(arc.save.night) + ".tres")
	arc_event.play_sfx({"path" = "user/start_shift"})
	SceneManager.change_scene("res://prefabs/misc/main.tscn", {"pattern" : "curtians"})
	SceneManager.set_title(arc.lang.get_word("night" + str(arc.night.start_night)))

func _on_custom_night_pressed() -> void:
	get_node("ui/main").visible = false
	get_node("ui/custom_night").visible = true
	change_state("custom")
	get_node("/root/main_menu/audio").stream = preload("res://resources/sounds/ambient/long/custom.ogg")
	get_node("/root/main_menu/audio").play(randi_range(0,7))

func _on_back_pressed() -> void:
	get_node("ui/custom_night").visible = false
	get_node("ui/main").visible = true
	change_state("main")
	get_node("/root/main_menu/audio").stream = preload("res://resources/sounds/ambient/long/star_zero.ogg")
	get_node("/root/main_menu/audio").play(randi_range(0,7))

func _on_thanks_pressed() -> void:
	get_node("ui/main").visible = false
	get_node("ui/thanks").visible = true
	change_state("thanks")

func _on_thanks_back_pressed() -> void:
	get_node("ui/main").visible = true
	get_node("ui/thanks").visible = false
	change_state("main")

func input(new_text: String, extra_arg_0: String) -> void:
	var old = anims[int(extra_arg_0)].ai_lvl
	var diff = int(new_text)
	if new_text == "" : diff = 0
	anims[int(extra_arg_0)].ai_lvl = diff
	
	if diff > 0 and old < 1 : 
		get_node("sub/custom/").get_child(int(extra_arg_0)).get_node("light").visible = true
		arc_event.play_sfx({"path" = "ambient/short/13", "volume" = 0})
	if diff < 1 and old > 0 :
		get_node("sub/custom/").get_child(int(extra_arg_0)).get_node("light").visible = false
		arc_event.play_sfx({"path" = "ambient/short/squek", "volume" = 0})
	if anims[7].ai_lvl > 0 or anims[8].ai_lvl > 0 : get_node("sub/custom/fnat_pc").visible = true
	else : get_node("sub/custom/fnat_pc").visible = false

func ovveride(extra_arg_0: int) -> void:
	for i in anims.size() :
		var old = anims[i].ai_lvl
		var diff = extra_arg_0
		anims[i].ai_lvl = diff
		match diff :
			-57 : get_node("ui/custom_night/diff/input/" + anims[i].name).text = "##"
			0 : get_node("ui/custom_night/diff/input/" + anims[i].name).text = ""
			_ : 
				get_node("ui/custom_night/diff/input/" + anims[i].name).text = str(diff)
		if diff > 0 and old < 1 : 
			get_node("sub/custom/").get_child(i).get_node("light").visible = true
			arc_event.play_sfx({"path" = "ambient/short/13", "volume" = -20})
		if diff < 1 and old > 0 :
			get_node("sub/custom/").get_child(i).get_node("light").visible = false
			arc_event.play_sfx({"path" = "ambient/short/squek", "volume" = -21})
	if anims[7].ai_lvl > 0 or anims[8].ai_lvl > 0 : get_node("sub/custom/fnat_pc").visible = true
	else : get_node("sub/custom/fnat_pc").visible = false

func add(extra_arg_0: int) -> void:
	for i in anims.size() :
		var old = anims[i].ai_lvl
		var diff = anims[i].ai_lvl + extra_arg_0
		anims[i].ai_lvl = diff
		match diff :
			-57 : get_node("ui/custom_night/diff/input/" + anims[i].name).text = "##"
			0 : get_node("ui/custom_night/diff/input/" + anims[i].name).text = ""
			_ : 
				get_node("ui/custom_night/diff/input/" + anims[i].name).text = str(diff)
		if diff > 0 and old < 1 : 
			get_node("sub/custom/").get_child(i).get_node("light").visible = true
			arc_event.play_sfx({"path" = "ambient/short/13", "volume" = -20})
		if diff < 1 and old > 0 :
			get_node("sub/custom/").get_child(i).get_node("light").visible = false
			arc_event.play_sfx({"path" = "ambient/short/squek", "volume" = -21})
	if anims[7].ai_lvl > 0 or anims[8].ai_lvl > 0 : get_node("sub/custom/fnat_pc").visible = true
	else : get_node("sub/custom/fnat_pc").visible = false
