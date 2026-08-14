extends Node

@export var teto : bool = true

signal _noise_in_office
signal _passed_hour
signal _passed_half_night
signal _last_hour

signal _raining
signal _earth_shaking
signal _electro_sphere

# flags
# * - requare
# *type - 2d, 3d, ex/ternal
# *path - path_to_sfx
# volume
# delay
# max_distance
# node - path_node
# child - add_child
# sec - second_to_play
# rand - play_at_random_second
# by default sound type == "2d"

func connect_all():
	if _passed_hour.is_connected(hour_passed) : return
	_passed_hour.connect(hour_passed)
	_passed_half_night.connect(half_night)
	_last_hour.connect(last_hour)

func dissconect_all():
	_passed_hour.disconnect(hour_passed)
	_passed_half_night.disconnect(half_night)
	_last_hour.disconnect(last_hour)

func play_sfx(d : Dictionary = { "volume" = 0, "delay" = 0, "max_distance" = 0, "sec" = 0, "node" = "", "rand" = false, pos = Vector3.ZERO }) -> int :
	var dict : Dictionary = { "volume" = d.get("volume", 0), "delay" = d.get("delay", 0), "node" = d.get("node", ""), "rand" = d.get("rand", false), "path" = d.get("path", ""), "type" = d.get("type", "2d"), "sec" = d.get("sec", 0), "pos" = d.get("pos", Vector3.ZERO) }
	var sfx
	if dict["path"] == "" : return 0
	var audio : AudioStreamOggVorbis = load("res://resources/sounds/" + dict["path"] + ".ogg")
	if audio == null :
		audio = load("res://resources/sounds/user/alarm.ogg")

	match dict["type"] :
		"2d" : 
			sfx = AudioStreamPlayer.new()
			arc.add_child(sfx)
		"3d" : 
			sfx = AudioStreamPlayer3D.new()
			sfx.max_distance = dict.get("max_distance", 0)
			sfx.reparent(arc)
			sfx.global_position = dict["pos"]
			sfx.attenuation_filter_db = -10
			sfx.unit_size = 1
			sfx.attenuation_filter_cutoff_hz = 6400
		#"ex" : sfx = get_node(dict["node"])
		_ : 
			print("crash, " + dict["path"])
			return 0

	sfx.volume_db = dict.get("volume", 15)
	sfx.stream = audio
	sfx.name = dict["path"]
	sfx.finished.connect(func() : sfx.queue_free())
	
	if dict.get("delay") > 0 :
		await get_tree().create_timer(dict.get("delay")).timeout
	if dict["rand"] == true : sfx.play(randf_range(0, audio.get_length()))
	else : sfx.play(dict["sec"])
	return audio.get_length()

func play_some_event(event : String) :
	if arc.loss == true : return
	var dict : Dictionary = { "volume" = 0, "delay" = 0, "max_distance" = 0, "second" = 0, "node" = "", "child" = "", "rand" = false, "type" = "2d" }
	match event :
		#"long" :
		"start" :
			var roll = randi_range(0,15)
			match roll :
				0 : 
					dict["path"] = "ambient/short/dog" 
					dict["volume"] = -15
				1 : 
					dict["path"] = "ambient/short/impact" 
					dict["volume"] = -18
				2 : 
					dict["path"] = "ambient/short/horn" 
					dict["volume"] = -12
				3 :
					dict["path"] = "ambient/short/vent_tap" 
					dict["volume"] = -14
				4 :
					dict["path"] = "ambient/short/punch" 
					dict["volume"] = -16
				5 :
					dict["path"] = "ambient/long/roof_walk" 
					dict["volume"] = -13
				6 :
					dict["path"] = "ambient/short/siren" 
					dict["volume"] = -15
				7 :
					dict["path"] = "ambient/short/fall_pot" 
					dict["volume"] = -25
				8 :
					dict["path"] = "ambient/short/fall_armature" 
					dict["volume"] = -24
				9 :
					dict["path"] = "ambient/short/pipes" 
					dict["volume"] = -17
				10 :
					dict["path"] = "ambient/short/fire_alarm" 
					dict["volume"] = -24
				_: arc.user.blink(randf_range(0.15, 2.56))
				
		"mental":
			var roll = randi_range(0,6)
			dict["volume"] = randi_range(-20, -6)
			match roll :
				0 : dict["path"] = "anim/nchimera/sanity" + str(randi_range(0,2))
				1 : dict["path"] = "ambient/short/deerclops" + str(randi_range(0,2))
				2 : dict["path"] = "ambient/short/laugh"
				3 : dict["path"] = "anim/nchimera/" + str(randi_range(0,3))
				4 : dict["path"] = "anim/" + arc.user.anims[randi_range(0,4)].name + "/moved"
				5 : dict["path"] = "anim/it/breath" + str(randi_range(0,1))

	arc_event.play_sfx(dict)

func play_random():
	if arc.loss : return
	while true :
		await get_tree().create_timer(randi_range(10, 50)).timeout
		if arc.loss == true : break
		play_some_event("start")

func step_hour() :
	if arc.loss : return
	while true :
		if arc.loss == true : break
		await get_tree().create_timer(60).timeout
		arc_event.emit_signal("_passed_hour")

func set_up_ambient() :
	var hiest_diff : int
	for i in arc.night.diff.size() :
		if arc.night.diff[i] > i : hiest_diff = arc.night.diff[i]
	print(hiest_diff)
	if hiest_diff > 1 : 
		arc.user.source["amb"].stream = preload("res://resources/sounds/ambient/long/start/0.ogg")
		arc.user.source["whitout"].stream = preload("res://resources/sounds/ambient/long/whitout/1.ogg")
	if hiest_diff > 10 : 
		arc.user.source["amb"].stream = preload("res://resources/sounds/ambient/long/start/1.ogg")
		arc.user.source["whitout"].stream = preload("res://resources/sounds/ambient/long/whitout/0.ogg")
	if hiest_diff > 19 : 
		arc.user.source["amb"].stream = preload("res://resources/sounds/ambient/long/start/2.ogg")
		arc.user.source["whitout"].stream = preload("res://resources/sounds/ambient/long/whitout/2.ogg")

	arc.user.source["amb"].play(randi_range(0,7))
	arc.user.source["whitout"].play(randi_range(0,7))
	arc.user.source["whitout"].volume_db = -5
	arc.user.source["whitout"].stream_paused = true

func hour_passed() :
	if arc.loss  : return
	var roll = randi_range(0, 100)
	if roll > 90 : free_bear()
	match arc.screen.hour :
		4 : arc_event.emit_signal("_passed_half_night")
		7 : arc_event.emit_signal("_last_hour")

func half_night() :
	arc_event.play_sfx({"path" = "anim/nerd/rage" + str(randi_range(0, 4)), "volume" = -12})

func last_hour() :
	var hiest_diff : int
	for i in arc.night.diff.size() :
		if arc.night.diff[i] > i : hiest_diff = arc.night.diff[i]
	print(hiest_diff)
	if hiest_diff > 16 :
		if arc.user.spot_light.visible == true :
			arc.user.source["amb"].stream = preload("res://resources/sounds/ambient/long/last_hour.ogg")
			arc.user.source["amb"].play()
		else : arc.user.source["amb"].stream = preload("res://resources/sounds/ambient/long/last_hour.ogg")
	if arc.night.diff[4] > 10 : free_bear()

func rotate_kitchen_door() :
	var door = get_node("/root/main/estab/door4/door")
	door.rotation = Quaternion.from_euler(Vector3(0,90,0))

func free_bear() : 
	if get_node("/root/main/bear").is_lock == true and arc.night.diff[4] < 10 : return
	var door = get_node("/root/main/estab/door4/door")
	door.rotation_degrees = Vector3(90,90,0)
	door.position = Vector3(0.463, 0, -.4)
	arc_event.play_sfx({"path" = "anim/door_brake", "volume" = -3})
	get_node("/root/main/bear").is_lock = false
	get_node("/root/main/bear").move()
#func summin_nir()

#func summon_rin()
