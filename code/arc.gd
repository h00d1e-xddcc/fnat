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
@export var diff : Array[int] = [0,0,0,0,0,0,0,0,0]
@export var rand_event : bool
@export var rand_pg : bool
@export var rand_ult : bool
@export var diff_static : bool
@export var fatass : Node3D
@export var is_can_pause : bool = true
@export var night : fnat_night
@export var save : fnat_save
@export var deads : int
@export var loss : bool = false

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
	arc_event.connect_all()
	out_of_power.connect(run_out_power)
	second_pass.connect(pass_time)

	fatass = get_node("/root/main/office/decor/fatass")

	change_da_note(arc.lang.get_word("note" + str(randi_range(0,9))))
	arc.time = 0
	arc.screen.hour = 0
	loss = false

	while true :
		await get_tree().create_timer(1).timeout
		emit_signal("second_pass")


func deloadout() :
	arc_event.connect_all()
	user = null
	world = null
	screen = null
	
	out_of_power.disconnect(run_out_power)
	second_pass.disconnect(pass_time)

func pass_time() :
	time += 1
	if time >= 480 : 
		second_pass.disconnect(pass_time)
		for i in arc.user.anims.size() :
			arc.user.anims[i].ai_lvl = 0
		arc.user.process_mode = Node.PROCESS_MODE_DISABLED
		await get_tree().create_timer(.257).timeout
		SceneManager.set_title("")
		SceneManager.change_scene("res://prefabs/misc/the_end.tscn", {"pattern" : "curtians"}, true )
	arc.screen.update_text()
	batary -= 1 * usage * .075
	if batary < 0 : emit_signal("out_of_power")

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
	arc.night = night_to_paste

	rand_event = night.is_can_random_event
	rand_pg = night.is_can_be_more_difficult
	rand_ult = night.is_can_be_ultimate_difficult
	diff_static = night.is_static_diffucult

	arc.batary = night.start_power
	arc.usage = night.start_usage
	arc.time = night.start_time

	for i in arc.diff.size() :
		arc.user.anims[i].ai_lvl = night.diff[i]

func start_custom_night() :
	for i in arc.diff.size() :
		arc.user.anims[i].ai_lvl = arc.diff[i]

func pause() :
	match get_tree().paused :
		false :
			if is_can_pause == true :
				is_can_pause = false
				Engine.time_scale = 0
				get_tree().paused = true
				arc_event.play_sfx({"type" = "2d", "path" = "user/pause"})
				#arc.user.audios["pause"].playing = true
				get_node("/root/main/office/triggers/vhs").visible = true
			else : arc_event.play_sfx({"type" = "2d", "path" = "user/pause_error"})
		true :
			Engine.time_scale = 1
			get_tree().paused = false
			#arc.user.audios["pause"].playing = false
			arc_event.play_sfx({"path" = "user/pause_un"})
			get_node("/root/main/office/triggers/vhs").visible = false
			await get_tree().create_timer(3.1).timeout
			is_can_pause = true
		_ :
			print("ляяя, надо сделать, чтобы bool имел третье свойство, maybe, вот смеха будет XD")

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

func change_da_note(text : String, size : int = 18) :
	var note : Label3D = get_node("/root/main/office/decor/fnat_note/label_3d")
	note.text = text
	note.text = text.replace("\\n", "\n")
	note.font_size = size

func save_settings() :
	ResourceSaver.save(save, "user://fnat.tres")

func retranslate_title() :
	# yandere
	get_node("/root/main_menu/ui/title").text = lang.get_word("ui_title")
	get_node("/root/main_menu/ui/main/buttons/custom_night").text = lang.get_word("ui_custom")
	get_node("/root/main_menu/ui/main/buttons/story").text = lang.get_word("ui_story") + str(arc.save.night)
	get_node("/root/main_menu/ui/main/buttons/thanks").text = lang.get_word("ui_thanks")
	get_node("/root/main_menu/ui/thanks/label").text = lang.get_word("ui_thanks_text")
	get_node("/root/main_menu/ui/thanks/thanks_back").text = lang.get_word("ui_back")
	get_node("/root/main_menu/ui/main/control/label").text = lang.get_word("ui_volume")
	get_node("/root/main_menu/ui/main/control/v_box_container/v-sync").text = lang.get_word("ui_v-sync")
	get_node("/root/main_menu/ui/main/control/v_box_container/full-screen").text = lang.get_word("ui_fullscreen")
	get_node("/root/main_menu/ui/custom_night/cont/start").text = lang.get_word("ui_cont")
	get_node("/root/main_menu/ui/custom_night/cont/p_s_").text = lang.get_word("p.s.")
	get_node("/root/main_menu/ui/custom_night/cont/back").text = lang.get_word("ui_back")
	get_node("/root/main_menu/ui/disclaimer_back/title").text = lang.get_word("ui_dis_title")
	get_node("/root/main_menu/ui/disclaimer_back/text").text = lang.get_word("ui_dis_text")
	get_node("/root/main_menu/ui/disclaimer_back/ps").text = lang.get_word("ui_dis_p.s.")
	get_node("/root/main_menu/ui/disclaimer_back/cont").text = lang.get_word("ui_dis_cont")
	
	get_node("/root/main_menu/ui/loadout_back/loadout/flashlight").text = lang.get_word("ui_flashligh")
	get_node("/root/main_menu/ui/loadout_back/continue").text = lang.get_word("ui_cont")
	get_node("/root/main_menu/ui/loadout_back/story").text = lang.get_word("ui_cont")
	get_node("/root/main_menu/ui/loadout_back/loadout/flashlight_charge").text = lang.get_word("ui_flashlight_recharge")
	get_node("/root/main_menu/ui/loadout_back/loadout/pc").text = lang.get_word("ui_pc")
	get_node("/root/main_menu/ui/loadout_back/loadout/left").text = lang.get_word("ui_left")
	get_node("/root/main_menu/ui/loadout_back/loadout/light").text = lang.get_word("ui_light")
	get_node("/root/main_menu/ui/loadout_back/loadout/under").text = lang.get_word("ui_hide")
	get_node("/root/main_menu/ui/loadout_back/loadout/right").text = lang.get_word("ui_right")
	get_node("/root/main_menu/ui/loadout_back/loadout/scheme").text = lang.get_word("ui_scheme")
	get_node("/root/main_menu/ui/loadout_back/loadout/pause").text = lang.get_word("ui_pause")
	get_node("/root/main_menu/ui/loadout_back/loadout/cam").text = lang.get_word("ui_cam")
	get_node("/root/main_menu/ui/loadout_back/loadout/peek").text = lang.get_word("ui_peek")
	
	get_node("/root/main_menu/sub/thanks/da_rules/label").text = lang.get_word("da_rules")
	get_node("/root/main_menu/sub/thanks/board/thanks").text = lang.get_word("ui_thanks")
	get_node("/root/main_menu/sub/thanks/board/ad").text = lang.get_word("thanks_ad")
	
