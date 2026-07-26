extends Node3D

@export var light : SpotLight3D
@export var start_sfx : AudioStreamPlayer3D
@export var anims : Array[fnat_animatronic]

func _ready() -> void:
	var local = OS.get_locale().substr(0, 2)
	if local == "ru" or local == "en" : arc.lang = load("res://resources/local/" + local + ".tres") 
	else : arc.lang = load("res://resources/local/en.tres")
	get_node("ui/disclaimer_back").visible = true
	get_node("ui/loadout_back").visible = false
	get_node("ui/custom_night").visible = false
	get_node("ui/thanks").visible = false
	get_node("ui/main").visible = true
	change_state("main")
	arc.load_sounds("res://resources/sounds/")
	arc.retranslate_title()

func _process(delta: float) -> void:
	light.light_energy = randf_range(.75, 1)
	
	var roll = randi_range(0,2542)
	if roll < 1 : 
		light.light_energy = 0
		var node : Node3D = get_node("main/" + str(randi_range(0,4)))
		node.visible = !node.visible 

func add_diff(value : int = 0, id : int = -1) :
	match id :
		-1 :
			for i in anims.size() :
				anims[i].ai_lvl += value
			display_diff()
		_ :
			anims[id].ai_lvl += value
			display_diff(id)

func set_diff(value : int = 0, id : int = -1) :
	match id :
		-1 :
			for i in anims.size() :
				anims[i].ai_lvl = value
			display_diff()
		_ :
			anims[id].ai_lvl = value
			display_diff(id)

func display_diff(value : int = -1) :
	match value :
		-1 :
			for i in anims.size() :
				var diff = anims[i].ai_lvl
				if diff == -57 : get_node("ui/custom_night/diff/input/" + str(i)).text = "##"
				else : get_node("ui/custom_night/diff/input/" + str(i)).text = str(diff)
		_ : get_node("ui/custom_night/diff/input/" + str(value)).text = str(anims[value].ai_lvl)

func change_state(state : String, time : float = 0) :
	get_node("main").visible = false
	get_node("custom").visible = false
	get_node("thanks").visible = false
	get_node(state).visible = true
	await get_tree().create_timer(time).timeout
	get_node(state + "/cam").current = true


func convert_line(new_text: String, extra_arg_0: int) -> void:
	var diff = int(new_text)
	anims[extra_arg_0].ai_lvl = diff

func _on_button_pressed() -> void:
	get_node("ui/disclaimer_back").visible = false

func _on_start_pressed() -> void:
	get_node("ui/loadout_back").visible = true

func _on_vsync_toggled(toggled_on: bool) -> void:
	if toggled_on : DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else : DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on : get_window().mode = Window.MODE_FULLSCREEN
	else : get_window().mode = Window.MODE_WINDOWED

func _on_h_slider_drag_ended(value_changed: bool) -> void:
	var volume = get_node("ui/main/control/label/h_slider").value
	arc.volume = volume
	get_node("audio").volume_db = arc.volume - 30

func swap_lang() :
	if arc.lang.dictionary["ui_lang"] == "en" :
		arc.lang = preload("res://resources/local/ru.tres")
		get_node("ui/main/control/lang").text = "py"
	else :
		arc.lang = preload("res://resources/local/en.tres")
		get_node("ui/main/control/lang").text = "en"
	arc.retranslate_title()

func _on_continue_pressed() -> void:
	var butt : Button = get_node("ui/loadout_back/continue")
	butt.disabled = true
	
	for i in anims.size() :
		if anims[i].ai_lvl == -57 : anims[i].ai_lvl = randi_range(0, 25)
		arc.diff.set(i, anims[i].ai_lvl)
	
	# сысл в этой секретке, если исходный код открыт?
	var passwd : String = str(anims[0].ai_lvl) + str(anims[1].ai_lvl) + str(anims[2].ai_lvl)
	print(passwd)

	match passwd :
		"575757" :
			arc.play2D_sound("ambient/random/13")
			await get_tree().create_timer(.57).timeout
		"257" :
			arc.play2D_sound("anim/nerd/random/6")
			await get_tree().create_timer(2.57).timeout
			OS.crash("596F752073757373792062616B61")
			
	SceneManager.change_scene("res://prefabs/misc/main.tscn", {"pattern" : "curtians"} )
	arc.play2D_sound("user/start_shift")

func _on_custom_night_pressed() -> void:
	get_node("ui/main").visible = false
	get_node("ui/custom_night").visible = true
	change_state("custom")

func _on_back_pressed() -> void:
	get_node("ui/custom_night").visible = false
	get_node("ui/main").visible = true
	change_state("main")

func _on_thanks_pressed() -> void:
	get_node("ui/main").visible = false
	get_node("ui/thanks").visible = true
	change_state("thanks")

func _on_thanks_back_pressed() -> void:
	get_node("ui/main").visible = true
	get_node("ui/thanks").visible = false
	change_state("main")
