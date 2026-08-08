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
				#"summon" : print_output("ai {lvl} {name}")
				"toss" :
					var anim : fnat_animatronic = get_node("/root/main/" + comm[1])
					if anim != null : 
						anim.toss_roll()
						print_output("forsed toss " + anim.name)
					else : print_output("badgateway -> " + comm[1])
				"poewer_off" : arc.batary = -9999
				"flash_off" : arc.user.flashlight_brake()
				"note" : arc.change_da_note(arc.get_word("note" + comm[1]))
				"jumpscare" : 
					var anim : fnat_animatronic = get_node("/root/main/" + comm[1])
					if anim != null : anim.jumpscare()
					else : print_output("Kiss Your Sister. NOW")
				"anims" : 
					for i in arc.user.anims.size() :
						#print_output(arc.user.anims[i].name + " " + str(i), "#" + str(Color.hex(arc.user.anims[i].color)))
						print_output(arc.user.anims[i].name + " " + str(i), "#" + str(arc.user.anims[i].color.to_html()))
					#print_output("anim_name id")
					#print_output("chimera 0", "#e74e5f")
					#print_output("nerd 1", "#e7d08c")
					#print_output("noise 2", "#96ade7")
					#print_output("bear 3", "#b9f9b6")
				"ai" :
					var lvl : int = int(comm[1])
					var name : String = str(comm[2])
					var anim : fnat_animatronic = get_node("/root/main/" + name)
					if anim == null : print_output("Bad gateway -> " + name)
					else : 
						anim.ai_lvl = lvl
						print_output(name + " now has ai lvl " + str(lvl))
		"main_menu" :
			match comm[0] :
				"print" : print_output(new_text.replace("print ", ""))
				"all_star" :
					if get_node("/root/main_menu/ui/title/stars/" + str(6)).visible == true : return
					for i in range(7) :
						get_node("/root/main_menu/ui/title/stars/" + str(i)).visible = true
					get_node("/root/main_menu/audio").stream = load("res://resources/sounds/ambient/long/star_four.ogg")
					get_node("/root/main_menu/audio").play()
					print_output("gaymode activated!")
				"help" : print(1) # title
		_ : OS.crash("4655434B20594F55")
	if new_text != "!!" : last_comma = new_text
	input.text = ""
	input.release_focus()

func _ready() -> void:
	get_node("panel").visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("console") :
		get_node("panel").visible = !get_node("panel").visible
	if get_node("panel").visible == true : input.grab_focus()
