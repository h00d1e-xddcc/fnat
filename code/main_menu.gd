extends Node3D

@export var light : SpotLight3D
@export var start_sfx : AudioStreamPlayer3D

func _ready() -> void:
	var local = OS.get_locale().substr(0, 2)
	if local == "ru" or local == "en" : arc.lang = load("res://resources/local/" + local + ".tres") 
	else : arc.lang = load("res://resources/local/en.tres")
	get_node("ui/disclaimer_back").visible = true
	get_node("ui/loadout_back").visible = false
	get_node("ui/custom_night").visible = false
	get_node("ui/thanks").visible = false
	get_node("ui/main").visible = true
	arc.load_sounds("res://resources/sounds/")
	arc.retranslate_title()

func _process(delta: float) -> void:
	light.light_energy = randf_range(.75, 1)
	
	var roll = randi_range(0,2542)
	if roll < 1 : 
		light.light_energy = 0
		var node : Node3D = get_node(str(randi_range(0,4)))
		node.visible = !node.visible 

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
	
	var diff0 = int(get_node("ui/custom_night/anims/chimera/line_edit").text)
	if diff0 == null : diff0 = 0
	arc.diff.set(0,diff0)
	
	var diff1 = int(get_node("ui/custom_night/anims/nerd/line_edit").text)
	if diff1 == null : diff1 = 0
	arc.diff.set(1,diff1)
	
	var diff2 = int(get_node("ui/custom_night/anims/noise/line_edit").text)
	if diff2 == null : diff2 = 0
	arc.diff.set(2,diff2)

	# сысл в этой секретке, если исходный код открыт?
	if diff0 == 57 and diff1 == 57 and diff2 == 57 :
		arc.play_sound("ambient/random/13",0, arc)
		await get_tree().create_timer(.57).timeout
	elif diff0 == 2 and diff1 == 5 and diff2 == 7 :
		arc.play_sound("anim/nerd/random/6", 0.257, arc, 0, -40)
		await get_tree().create_timer(2.57).timeout
		OS.crash("596F752073757373792062616B61")
	SceneManager.change_scene("res://prefabs/misc/main.tscn", {"pattern" : "curtians"} )
	arc.play_sound("user/start_shift", 0, arc, 0, -10, 10000)

func _on_custom_night_pressed() -> void:
	get_node("ui/main").visible = false
	get_node("ui/custom_night").visible = true

func _on_back_pressed() -> void:
	get_node("ui/custom_night").visible = false
	get_node("ui/main").visible = true

func _on_thanks_pressed() -> void:
	get_node("ui/main").visible = false
	get_node("ui/thanks").visible = true

func _on_thanks_back_pressed() -> void:
	get_node("ui/main").visible = true
	get_node("ui/thanks").visible = false
