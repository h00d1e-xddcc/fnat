extends Node3D

@export var user : fnat_user
@export var world : WorldEnvironment
@export var screen : fnat_screen
@export var debug : bool
@export var pause : bool
@export var night : int = 0
@export var usage : float = 1.75
@export var time : float
@export var batary : float = 57.9
@export var sounds : Dictionary[String, AudioStream]
@export var lang : fnat_lange
@export var volume : int = 15
@export var diff : Array[int] = [0,0,0,0,0]
@export var teto : bool = true

signal out_of_power
signal second_pass

func loadout() -> void:
	user = get_node("/root/main/office/user")
	world = get_node("/root/main/world")
	screen = get_node("/root/main/office/screen")

	if world == null : return
	if debug == true:
		world.environment.background_color = Color.WHITE
	else :
		world.environment.background_color = Color.BLACK

	lang.retranslate_screen()
	out_of_power.connect(run_out_power)

	second_pass.connect(pass_time)
	second_pass.connect(eat_batary)

	change_da_note(get_word("note" + str(randi_range(0,7))))
	while true :
		await get_tree().create_timer(1).timeout
		emit_signal("second_pass")

func eat_batary(value : int = 1) :
	batary -= value * usage * .075
	if batary < 0 : emit_signal("out_of_power")

func pass_time() :
	time += 1
	if time >= 480 : 
		second_pass.disconnect(pass_time)
		for i in arc.user.anims.size() :
			arc.user.anims[i].ai_lvl = 0
		arc.user.process_mode = Node.PROCESS_MODE_DISABLED
		await get_tree().create_timer(2.57).timeout
		SceneManager.change_scene("res://prefabs/misc/the_end.tscn", {"pattern" : "curtians"} )
	arc.screen.update_text()

func load_sounds(path) :
	var dir = DirAccess.open(path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file = dir.get_next()

	while file != "" :
		var full_path = path + "/" + file
		if dir.current_is_dir():
			if file != "." and file != "..":
				load_sounds(full_path) # рекурсия
		else:
			var ext = file.get_extension()
			if ext == "wav" or ext == "mp3" or ext == "ogg" :
				var id_audio : String = full_path
				id_audio = id_audio.replace("res://resources/sounds/", "")
				id_audio = id_audio.replace("." + ext, "")
				id_audio[0] = ""
				sounds[id_audio] = load(full_path)
		file = dir.get_next()
	dir.list_dir_end() 

func button_delay(button : Button, waiting : float) :
	var old_string = button.text
	var icon = button.icon
	button.icon = null
	button.disabled = true
	button.text = "."
	await get_tree().create_timer(waiting).timeout
	button.text = ".."
	await get_tree().create_timer(waiting).timeout
	button.text = "..."
	await get_tree().create_timer(waiting).timeout
	button.text = old_string
	button.icon = icon
	button.disabled = false
	if arc.user.spot_light.visible == true : arc.play_sound("user/math_correct", 0, null, 0, 6)

func play2D_sound(path : String, delay : float = 0, volume_to_decrease : float = 0) :
	var sfx : AudioStreamPlayer = AudioStreamPlayer.new()
	var audio = sounds.get(path)
	if audio == null : 
		audio = preload("res://resources/sounds/user/alarm.wav")
		push_error("sound eggor >" + path)
	arc.add_child(sfx)
	sfx.stream = audio
	sfx.name = path
	sfx.volume_db = volume_to_decrease
	sfx.finished.connect(func() : sfx.queue_free())
	await get_tree().create_timer(delay).timeout
	sfx.play()

func play_sound(path : String, second : float = 0, node : Node3D = null, delay : float = 0, volume_to_decrease : float = 0, max_dist : int = 45) :
	var sfx : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	if node != null :
		node.add_child(sfx)
		sfx.position = Vector3.ZERO
	else : 
		user.add_child(sfx)
		sfx.position = Vector3.ZERO
	var audio = sounds.get(path)
	if audio == null : 
		audio = preload("res://resources/sounds/user/alarm.wav")
		push_error("sound eggor >" + path)
		sfx.volume_db = -80
	sfx.max_distance = max_dist
	sfx.stream = audio
	sfx.name = path
	sfx.attenuation_filter_db = -10
	sfx.unit_size = 1
	sfx.attenuation_filter_cutoff_hz = 6400
	sfx.volume_db = volume_to_decrease
	sfx.finished.connect(func() : sfx.queue_free())
	await get_tree().create_timer(delay).timeout
	sfx.play(second)

func play_teto() :
	if teto == true :
		teto = false
		play2D_sound("user/teto",0, -10)
		await get_tree().create_timer(.257).timeout
		teto = true

func play_external(sfx : AudioStreamPlayer3D, path : String, volume_to_decrease : int, delay : float) :
	if sfx == null : return
	sfx.stream = sounds[path]
	sfx.attenuation_filter_db = -24
	sfx.volume_db = arc.volume - volume_to_decrease
	sfx.finished.connect(func() : sfx.queue_free())
	await get_tree().create_timer(delay).timeout
	sfx.play()

func set_dif() :
	user.anims[0].ai_lvl = diff[0] # chimera
	user.anims[1].ai_lvl = diff[1] # noise
	user.anims[2].ai_lvl = diff[2] # nerd

func run_out_power() :
	#run_out_power().disconnect(run_out_power())
	out_of_power.disconnect(run_out_power)
	user.audios["fan"].playing = false
	user.audios["spot"].playing = false
	user.spot_light.visible = false
	screen.visible = false
	play_sound("user/power_down")

func add_word(id : String, word : String) :
	lang.dictionary[id] = word 

func room_check(anim_id : int, room : String) -> bool :
	match anim_id :
		-1 :
			for i in user.anims.size() :
				if user.anims[i].current_point.name == room : return true
		_ :
			if user.anims[anim_id].current_point.name == room : return true
	return false

func get_word(id : String) -> String :
	var word = lang.dictionary.get(id)
	if word == "" or word == null : return ""
	else : return word.replace("\\n", "\n")
	# это уже не хоррор, а шапито какое-то
func change_da_note(text : String, size : int = 18) :
	var note : Label3D = get_node("/root/main/office/decor/fnat_note/label_3d")
	note.text = text
	note.text = text.replace("\\n", "\n")
	note.font_size = size

func retranslate_title() :
	# yandere
	get_node("/root/main_menu/ui/title").text = get_word("ui_title")
	get_node("/root/main_menu/ui/main/buttons/custom_night").text = get_word("ui_custom")
	get_node("/root/main_menu/ui/main/buttons/thanks").text = get_word("ui_thanks")
	get_node("/root/main_menu/ui/thanks/label").text = get_word("ui_thanks_text")
	get_node("/root/main_menu/ui/thanks/thanks_back").text = get_word("ui_back")
	get_node("/root/main_menu/ui/main/control/label").text = get_word("ui_volume")
	get_node("/root/main_menu/ui/main/control/v_box_container/v-sync").text = get_word("ui_v-sync")
	get_node("/root/main_menu/ui/main/control/v_box_container/full-screen").text = get_word("ui_fullscreen")
	get_node("/root/main_menu/ui/custom_night/cont/start").text = get_word("ui_cont")
	get_node("/root/main_menu/ui/custom_night/cont/p_s_").text = get_word("p.s.")
	get_node("/root/main_menu/ui/custom_night/cont/back").text = get_word("ui_back")
	get_node("/root/main_menu/ui/disclaimer_back/title").text = get_word("ui_dis_title")
	get_node("/root/main_menu/ui/disclaimer_back/text").text = get_word("ui_dis_text")
	get_node("/root/main_menu/ui/disclaimer_back/ps").text = get_word("ui_dis_p.s.")
	get_node("/root/main_menu/ui/disclaimer_back/cont").text = get_word("ui_dis_cont")
	
	get_node("/root/main_menu/ui/loadout_back/loadout/flashlight").text = get_word("ui_flashligh")
	get_node("/root/main_menu/ui/loadout_back/continue").text = get_word("ui_cont")
	get_node("/root/main_menu/ui/loadout_back/loadout/flashlight_charge").text = get_word("ui_flashlight_recharge")
	get_node("/root/main_menu/ui/loadout_back/loadout/pc").text = get_word("ui_pc")
	get_node("/root/main_menu/ui/loadout_back/loadout/left").text = get_word("ui_left")
	get_node("/root/main_menu/ui/loadout_back/loadout/light").text = get_word("ui_light")
	get_node("/root/main_menu/ui/loadout_back/loadout/under").text = get_word("ui_hide")
	get_node("/root/main_menu/ui/loadout_back/loadout/right").text = get_word("ui_right")
	get_node("/root/main_menu/ui/loadout_back/loadout/scheme").text = get_word("ui_scheme")
	get_node("/root/main_menu/ui/loadout_back/loadout/cam").text = get_word("ui_cam")
	get_node("/root/main_menu/ui/loadout_back/loadout/peek").text = get_word("ui_peek")
	
	get_node("/root/main_menu/thanks/da_rules/label").text = get_word("da_rules")
	get_node("/root/main_menu/thanks/board/thanks").text = get_word("ui_thanks")
	get_node("/root/main_menu/thanks/board/ad").text = get_word("thanks_ad")
	
	
