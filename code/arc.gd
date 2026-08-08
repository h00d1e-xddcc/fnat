extends Node3D

@export var user : fnat_user
@export var world : WorldEnvironment
@export var screen : fnat_screen
@export var debug : bool
@export var usage : float = 1.75
@export var time : float
@export var batary : float = 57.9
@export var lang : fnat_lange
@export var volume : int = 15
@export var diff : Array[int] = [0,0,0,0,0]
@export var fatass : Node3D
@export var is_can_pause : bool = true
@export var night : fnat_night
@export var save : fnat_save

signal out_of_power
signal second_pass

func loadout() -> void:
	user = get_node("/root/main/office/user")
	world = get_node("/root/main/world")
	screen = get_node("/root/main/office/screen")
	arc.screen.teto_input.visible = false

	if world == null : return
	if debug == true:
		world.environment.background_color = Color.WHITE
	else :
		world.environment.background_color = Color.BLACK

	lang.retranslate_screen()
	out_of_power.connect(run_out_power)

	second_pass.connect(pass_time)
	second_pass.connect(eat_batary)

	fatass = get_node("/root/main/office/decor/fatass")

	change_da_note(get_word("note" + str(randi_range(0,9))))
	while true :
		await get_tree().create_timer(1).timeout
		emit_signal("second_pass")

	await get_tree().create_timer(3.1).timeout
	is_can_pause = true

func deloadout() :
	user = null
	world = null
	screen = null
	
	out_of_power.disconnect(run_out_power)

	second_pass.disconnect(pass_time)
	second_pass.disconnect(eat_batary)

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
	if arc.user.spot_light.visible == true : arc_event.play_sfx({"path" = "user/math_correct", "volume" = 3})

func start_night(night_to_paste : fnat_night) :
	night = night_to_paste
	arc.user.anims[0].ai_lvl = night.chimera
	arc.user.anims[1].ai_lvl = night.nerd
	arc.user.anims[2].ai_lvl = night.noised
	arc.user.anims[3].ai_lvl = night.bear
	
	arc.batary = night.start_power
	arc.usage = night.start_usagedd

func pause() :
	match get_tree().paused :
		false :
			if is_can_pause == true :
				is_can_pause = false
				Engine.time_scale = 0
				get_tree().paused = true
				arc_event.play_sfx({"type" = "2d", "path" = "user/pause"})
				arc.user.audios["pause"].playing = true
				get_node("/root/main/office/triggers/vhs").visible = true
			else : arc_event.play_sfx({"type" = "2d", "path" = "user/pause_error"})
		true :
			Engine.time_scale = 1
			get_tree().paused = false
			arc.user.audios["pause"].playing = false
			arc_event.play_sfx({"path" = "user/pause_un"})
			get_node("/root/main/office/triggers/vhs").visible = false
			await get_tree().create_timer(3.1).timeout
			is_can_pause = true
		_ :
			print("ляяя, надо сделать, чтобы bool имел третье свойство, maybe, вот смеха будет XD")

func set_dif() :
	user.anims[0].ai_lvl = diff[0] # chimera
	user.anims[1].ai_lvl = diff[1] # noise
	user.anims[2].ai_lvl = diff[2] # nerd

func run_out_power() :
	out_of_power.disconnect(run_out_power)
	user.audios["fan"].playing = false
	user.audios["spot"].playing = false
	user.spot_light.visible = false
	screen.visible = false
	arc_event.play_sfx({"type" = "2d", "path" = "user/pause_error"})

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

func save_settings() :
	ResourceSaver.save(save, "user://fnat.tres")

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
	
	get_node("/root/main_menu/sub/thanks/da_rules/label").text = get_word("da_rules")
	get_node("/root/main_menu/sub/thanks/board/thanks").text = get_word("ui_thanks")
	get_node("/root/main_menu/sub/thanks/board/ad").text = get_word("thanks_ad")
	
	
