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
	if new_text == "!!" : _on_input_text_submitted(last_comma) 
	match get_node("/root").get_child(3).name :
		"main" : # office
			match comm[0] :
				"h" : 
					print_output("{t}oss (name)")
					print_output("{s}kip_night")
					print_output("{b}attary_full_charge")
					print_output("{n}ote (0-12)")
					print_output("{j}umpscare (name)")
					print_output("{ai} (0-25) (name)")
					print_output("{an}imatronics")
					print_output("{q}uit_to_title")
					print_output("{e}xit_to_screen")
					print_output("{s}kip{h}our")

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
				"n" : arc.change_da_note(arc.get_word("note" + comm[1]))
				"j" : 
					var anim : fnat_animatronic = get_node("/root/main/" + comm[1])
					if anim != null : anim.jumpscare()
					else : print_output("Kiss Your Sister. NOW")
				"an" : 
					for i in arc.user.anims.size() :
						print_output(arc.user.anims[i].name + " " + str(i), "#" + str(arc.user.anims[i].color.to_html()))
				"ai" :
					var lvl : int = int(comm[1])
					var name : String = str(comm[2])
					var anim : fnat_animatronic = get_node("/root/main/" + name)
					if anim == null : print_output("Bad gateway -> " + name)
					else : 
						anim.ai_lvl = lvl
						print_output(name + " now has ai lvl " + str(lvl))
				"q" : 
					arc.deloadout()
					SceneManager.change_scene("res://prefabs/misc/main_menu.tscn", {"pattern" : "curtians"}, true)
					SceneManager.set_title("")
				"e" : get_tree().quit()
				"sh" : arc.time += 60
				"help" :
					match arc.night.start_night :
						1 : arc.user.source["call"].stream = load("res://resources/sounds/ambient/calls/" + arc.save.lange + "/console1.ogg")
						2 : arc.user.source["call"].stream = load("res://resources/sounds/ambient/calls/" + arc.save.lange + "/console2.ogg")
					arc.user.source["call"].play()
				"commands" : OS.crash("")
				"reset" : 
					arc.save.night = 1
					arc.retranslate_title()
				"print" : print_output(new_text.replace("print ", ""))
				"all_star" :
					if get_node("/root/main_menu/ui/title/stars/" + str(6)).visible == true : return
					for i in range(7) :
						get_node("/root/main_menu/ui/title/stars/" + str(i)).visible = true
					get_node("/root/main_menu/audio").stream = load("res://resources/sounds/ambient/long/star_four.ogg")
					get_node("/root/main_menu/audio").play()
					print_output("gaymode activated!")
				"night" : 
					var night = int(comm[1])
					if night == 1 or night == 2 or night == 3 or night == 4 or night == 5 :
						arc.save.night = night
						arc.retranslate_title()
	if new_text != "!!" : last_comma = new_text
	input.text = ""
	input.release_focus()

func _ready() -> void:
	get_node("panel").visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("console") :
		get_node("panel").visible = !get_node("panel").visible
	if get_node("panel").visible == true : input.grab_focus()
