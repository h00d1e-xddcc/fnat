extends Node

@export var teto : bool = true

signal noise_in_office
signal passed_hour
signal passed_half_night
signal last_hour
signal raining
signal earth_shaking
signal electro_sphere

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

func play_sfx(d : Dictionary = { "volume" = 0, "delay" = 0, "max_distance" = 0, "sec" = 0, "node" = "", "child" = "", "rand" = false }) -> int :
	var dict : Dictionary = { "volume" = d.get("volume", 0), "delay" = d.get("delay", 0), "node" = d.get("node", ""), "child" = d.get("child", ""), "rand" = d.get("rand", false), "path" = d.get("path", ""), "type" = d.get("type", "2d"), "sec" = d.get("sec", 0) }
	var sfx
	var audio : AudioStreamOggVorbis = load("res://resources/sounds/" + dict["path"] + ".ogg")
	if audio == null :
		audio = load("res://resources/sounds/user/alarm.ogg")
		push_error("sound eggor >" + dict["path"])

	match dict["type"] :
		"2d" : 
			sfx = AudioStreamPlayer.new()
			arc.add_child(sfx)
		"3d" : 
			sfx = AudioStreamPlayer3D.new()
			sfx.max_distance = dict.get("max_distance", 0)
			if dict.get("node") != "" : sfx.reparent(get_node("node"))
			sfx.positon = Vector3.ZERO
			sfx.position = Vector3.ZERO
			sfx.attenuation_filter_db = -10
			sfx.unit_size = 1
			sfx.attenuation_filter_cutoff_hz = 6400
		"ex" : sfx = get_node(dict["node"])
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

func play_teto() :
	if teto == true :
		teto = false
		play_sfx({"path" = "user/teto", "volume" = -10})
		match arc.user.state :
			arc.user.action.sit :
				arc.fatass.global_rotation_degrees =+ Vector3(randi_range(-10,10), 31, randi_range(-10,10))
				await get_tree().create_timer(.257).timeout
				arc.fatass.global_rotation_degrees = Vector3(0,31,0)
			_ :
				arc.fatass.global_rotation_degrees =+ Vector3(randi_range(-10,10), 176, randi_range(-10,10))
				await get_tree().create_timer(.257).timeout
				arc.fatass.global_rotation_degrees = Vector3(0,176,0)
		teto = true

func play_some_event(event : String) :
	var dict : Dictionary = { "volume" = 0, "delay" = 0, "max_distance" = 0, "second" = 0, "node" = "", "child" = "", "rand" = false, "type" = "2d" }
	match event :
		#"long" :
		"start" :
			var roll = randi_range(0,15)
			match roll :
				0 : 
					dict["path"] = "ambient/random/dog" 
					dict["volume"] = 3
				1 : 
					dict["path"] = "ambient/random/crows" 
					dict["volume"] = -12
				2 : 
					dict["path"] = "ambient/random/horn" 
					dict["volume"] = -3
				3 :
					dict["path"] = "ambient/rainstorm" 
					dict["volume"] = 4
				4 :
					dict["path"] = "ambient/random/punch" 
					dict["volume"] = 14
				5 :
					dict["path"] = "ambient/random/roof_walk" 
					dict["volume"] = 13
				6 :
					dict["path"] = "ambient/random/siren" 
					dict["volume"] = 0
				7 :
					dict["path"] = "ambient/random/fall_pot" 
					dict["volume"] = -15
				8 :
					dict["path"] = "ambient/random/fall_armature" 
					dict["volume"] = -17
				9 :
					dict["path"] = "ambient/random/pipes" 
					dict["volume"] = -10
				10 :
					dict["path"] = "ambient/fire_alarm" 
					dict["volume"] = -16
				_: arc.user.blink(randf_range(0.15, 2.56))
				
		"mental":
			var roll = randi_range(0,5)
			match roll :
				0 : 
					dict["path"] = "ambient/random/sanity" + str(randi_range(0,2))
					dict["volume"] = -0
				1 : 
					dict["path"] = "ambient/random/deerclops" + str(randi_range(0,2))
					dict["volume"] = -10
				2 : 
					dict["path"] = "ambient/random/laugh"
					dict["volume"] = 10
				3 : 
					dict["path"] = "anim/spotted"
					dict["volume"] = -3
				4 : 
					dict["path"] = "anim/" + arc.user.anims[randi_range(0,3)].name + "/moved"
					dict["volume"] = -8
				5 : 
					dict["path"] = "anim/it/breath" + str(randi_range(0,1))
					dict["volume"] = -9
		
	arc_event.play_sfx(dict)

#func summin_nir()

#func summon_rin()
