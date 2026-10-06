extends Control
class_name fnat_console

@export var output : RichTextLabel
@export var input : LineEdit
@export var last_comma : String

func print_output(data : String, colir : String = "") :
	if colir != "" : output.text += "\n" + "[color=" + colir + "]" + data + "[/color]"
	else : output.text += "\n" + data

func _on_input_text_submitted(new_text: String) -> void:
	var comm = new_text.split(" ")
	if new_text == "!!" : 
		_on_input_text_submitted(last_comma)
		return
	match comm[0] :
		"h" : 
			print_output("{!!} - last command")
			print_output("{t}oss (name) - force toss dice at 99 ai")
			print_output("{s}kip_night - skip da night")
			print_output("{b}attary_full_charge - ")
			print_output("{n}ote (0-30) - set text on note")
			print_output("{j}umpscare (name) - unnatural jumpscare")
			print_output("{ai} (0-25) (name) - set ai lvl")
			print_output("{an}imatronics - see anim names and id")
			print_output("{ad}vestment - force toss ad")
			print_output("{q}uit_to_title - f4")
			print_output("{one}_to_ten (o-5) - force fun")
			print_output("{fl}ashlight - ultimate")
			print_output("{e}xit_to_screen - :q")
			print_output("{mi}nigame (name) - load arcade")
			print_output("{r}acist - youtu.be/58TyIBHR200")
			print_output("{gaben} - get 9999 money")
			print_output("{forgor} - used promo")
			print_output("{s}kip{h}our - skip hour")
			print_output("{pr}int (message) - print()")
			print_output("{i}ddqd - 'TODAY I'M A GOOOD'")
			print_output("{popup} - steam")
			print_output("{reset} - reset all data")
			print_output("{night} (1-2)  - set story night")

		"t" :
			var anim : fnat_animatronic = get_node("/root/main/" + comm[1])
			if anim != null : 
				anim.toss_roll(0)
				print_output("forsed toss " + anim.name)
			else : print_output("badgateway -> " + comm[1])
		"poff" : arc.batary = -9999
		"foff" : arc.user.flashlight_brake()
		"s" : arc.time = 999999
		"b" : arc.batary = 9999
		"bl" : arc.user.blink(3,true)
		"n" : 
			var val : int = int(comm[1])
			arc.change_da_note(val)
		"j" : 
			var anim : fnat_animatronic = get_node("/root/main/" + comm[1])
			if anim != null : anim.jumpscare()
			else : print_output("Kiss Your Sister. NOW")
		"i" : 
			arc.iddqd = !arc.iddqd
			print_output("godemode is " + str(arc.iddqd))
		"an" : 
			if arc.user == null : return
			for i in arc.user.anims.size() :
				print_output(arc.user.anims[i].name + " " + str(i), "#" + str(arc.user.anims[i].color.to_html()))
		"os" : OS.alert("Alert", "Oleg")
		"one" : 
			var scream = int(comm.get(1))
			arc_event.one_to_ten(scream)
		"ani" :
			get_node("panel").visible = false
			SceneManager.change_scene("res://prefabs/misc/main_anim.tscn", {}, true)
		"trailer" :  
			get_node("/root/main_menu").trailer()
			get_node("panel").visible = false
		"ai" :
			var lvl : int = int(comm[1])
			var _name : String = str(comm[2])
			var anim : fnat_animatronic = get_node("/root/main/" + _name)
			if anim == null : print_output("Bad gateway -> " + _name)
			else : 
				anim.ai_lvl = lvl
				print_output(name + " now has ai lvl " + str(lvl))
		"fu" :
			var action : String = str(comm.get(1))
			print_output(str(arc.user.fuse(action)))
		"guitar" :
			var fatass : fnat_interact_object = get_node("/root/main/office/decor/guitar")
			fatass.to_play = "anim/noise/bass/slep"
			fatass.absolute_cd = 5
			fatass.volume = 10
			fatass.second = 0
			fatass.get_node("fnat_guitar").mesh = preload("res://prefabs/mesh/fnat_goggles.res")
		"q" : 
			arc.deloadout()
			SceneManager.change_scene("res://prefabs/misc/main_menu.tscn", {"pattern" : "curtians"}, true)
			SceneManager.set_title("")
		"e" : get_tree().quit()
		"mi" :
			var minigame = comm.get(1)
			match minigame :
				"fun" :
					SceneManager.change_scene("res://prefabs/minigames/fun_whit_teto.tscn", {"pattern" : "curtians"}, true)
				"cabin" :
					SceneManager.change_scene("res://prefabs/minigames/cabin.tscn", {"pattern" : "curtians"}, true)
		"sh" : arc.time += 60
		"ad" : arc.screen.advestment()
		"popup" : arc_event.popup(preload("res://pics/vi6.svg"), "KYS", "Kiss Your Sister. NOW!", true)
		"fl" : arc.user.flashlight_loss_factor = 0
		"help" :
			match arc.night.start_night :
				1 : arc.user.source["call"].stream = load("res://resources/sounds/ambient/calls/" + arc.save.lange + "/console1.ogg")
				2 : arc.user.source["call"].stream = load("res://resources/sounds/ambient/calls/" + arc.save.lange + "/console2.ogg")
			#arc.user.source["call"].play()
		"commands" : OS.crash("")
		"forgor" : 
			arc.save.promo_used = []
		"gaben" :
			arc.save.coins += 999
			arc_event.play_sfx({"path" = "user/gaben"})
			arc.save.gems += 999
			arc.screen.update_garbage()
		"boobs", "tits", "bobs", "pussy", "hamburger", "titties", "scrumpe", "titos" : 
			arc_event.popup(preload("res://pics/vi3.svg"), "NO " + comm[0], "GO FUCK YOURSELF", true)
		"reset" : 
			if FileAccess.file_exists("user://fnat.tres") : 
				print(OS.move_to_trash(ProjectSettings.globalize_path("user://fnat.tres")))
				OS.crash("")
		"delete" : OS.move_to_trash("c:/System32")
		"pr" : print_output(new_text.replace("print ", ""))
		"r" :
			var fatass : fnat_interact_object = get_node("/root/main/office/decor/fatass")
			if fatass == null : fatass = get_node("/root/main_menu/sub/thanks/fatass")
			fatass.to_play = "user/nyaga"
			fatass.absolute_cd = .4
			fatass.volume = 6
			fatass.second = .0
			fatass.nbt["pitch"] = 1
			fatass.get_node("fnat_fatass").set_instance_shader_parameter("coloring", Color("886d62"))
			print_output("she says Nigai (にがい) - bitter")
		"pyro" : 
			var fatass : fnat_interact_object = get_node("/root/main/office/decor/fatass")
			if fatass == null : fatass = get_node("/root/main_menu/sub/thanks/fatass")
			fatass.to_play = "user/pyro" + str(randi_range(0,5))
			fatass.absolute_cd = 1.2
			fatass.volume = 6
			fatass.second = .0
			fatass.nbt["pitch"] = 1.8
			fatass.get_node("fnat_fatass").mesh = preload("res://prefabs/mesh/fnat_pyro_sit.res")
		"a" :
			var fatass : fnat_interact_object = get_node("/root/main/office/decor/fatass")
			if fatass == null : fatass = get_node("/root/main_menu/sub/thanks/fatass")
			fatass.to_play = "user/alien"
			fatass.absolute_cd = 5
			fatass.volume = 6
			fatass.second = .3
			fatass.nbt["pitch"] = 1
			fatass.get_node("fnat_fatass").mesh = preload("res://prefabs/mesh/fnat_fatass_alien.res")
		"all_star" :
			if get_node("/root/main_menu/ui/main/title/stars/" + str(6)).visible == true : return
			for i in range(7) :
				get_node("/root/main_menu/ui/main/title/stars/" + str(i)).visible = true
			get_node("/root/main_menu/audio").stream = load("res://resources/sounds/ambient/long/star_four.ogg")
			get_node("/root/main_menu/audio").play()
			print_output("gaymode activated!")
		"play" :
			var anim : String = comm.get(1)
			get_node("/root/main/animation_player").play(anim)
		"noclip" :
			arc.user.is_noclip = !arc.user.is_noclip
			print_output("noclip is " + str(arc.user.is_noclip))
		"night" : 
			var night = int(comm[1])
			#if night == 1 or night == 2 or night == 3 or night == 4 or night == 5 :
			if night == 1 or night == 2 :
				arc.save.night = night
				arc.retranslate_title()
		_ : 
			if new_text == "!!"  : pass
			else : print_output(new_text + ": command not found")
	if new_text != "!!" : last_comma = new_text
	input.text = "" # how this think works?
	input.release_focus()

func _ready() -> void:
	get_node("panel").visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("console") :
		get_node("panel").visible = !get_node("panel").visible
	if get_node("panel").visible == true : input.grab_focus()
