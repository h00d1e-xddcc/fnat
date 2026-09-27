extends Node2D
class_name fnat_interact2d

enum object_type {item, npc}
@export var type : object_type
@export var user : fnat_user2d
@export var line : String

func _ready() -> void:
	user = get_node("/root/mi/user")

func push_text(text : String, options : Array[String] =  [], _name : String = "") :
	line = _name
	user.dialog.visible = true
	user.text.visible_characters = 0
	user.text.text = text
	var target_value = user.text.text.length()
	for i in range(target_value) :
		user.text.visible_characters += 1
		arc_event.play_sfx({"path" = "ambient/mi/text", "form" = ".wav"})
		#if user.text.text[user.text.visible_characters] == "." : await get_tree().create_timer(1).timeout
		await get_tree().create_timer(randf_range(0.03, .06)).timeout
	await get_tree().create_timer(1).timeout
	if options != [] : 
		push_buttons(options)

func push_buttons(array : Array[String]) :
	for i in range(array.size()) :
		var button = get_node("/root/mi/ui/ui/black/white/v_box_container/" + str(i))
		button.text = array[i]
		button.visible = true
		await get_tree().create_timer(.25).timeout
	get_node("/root/mi/ui/ui/black/white/v_box_container/1").grab_focus()

func hide_buttons() :
	for i in range(3) :
		var button = get_node("/root/mi/ui/ui/black/white/v_box_container/" + str(i))
		button.visible = false

func hide_text(time : float = .0) :
	await get_tree().create_timer(time).timeout
	user.text.text = ""
	user.dialog.visible = false
	user.interact = null

func interact():
	user.interact = self
	match type :
		object_type.item :
			match name :
				"knife" :
					push_text("На столе лежит безупречный клинок. Взять?", ["да", "нет"], "knife")
				"door" :
					push_text("Перед тобой стоит дверь, ведущаяя в подвал.", ["спустится", "осмотреть дверь"], "door")
				"!mirror" :
					push_text("На этой стене нет зеркала.")
					hide_text(5.7)

func _on__pressed(extra_arg_0: int) -> void:
	hide_buttons()
	print(name)
	match user.interact.name :
		"knife" :
			match  extra_arg_0 :
				0 :
					get_node("/root/mi/main/knife").position = Vector2(2000, 2000)
					push_text("*Ты берешь с собой клинок")
					hide_text(2.57)
					arc_event.play_sfx({"path" = "ambient/mi/item", "form" = ".wav"})
				1 :
					hide_buttons()
					hide_text()
		"door" :
			match extra_arg_0 :
					0 :
						arc_event.play_sfx({"path" = "ambient/mi/escape", "form" = ".wav"})
						push_text("*Ты спускаешься в подвал, без оружия")
						hide_text(2.57)
					1 :
						push_text("*Осматривая каждую деталь на двери, ты случайно прикосаешься к ручке. Дверь пронзающим скрипящим воплем, приокрывается.")
						await get_tree().create_timer(12).timeout
						push_text("*Пытаясь разглядеть пустоту в подвале, тебя толкают со спины, прямо в подвал.")
						await get_tree().create_timer(6).timeout
						hide_text(2.57)
	line = ""
