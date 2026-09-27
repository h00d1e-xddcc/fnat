extends CharacterBody2D
class_name fnat_user2d

# Скорость движения персонажа
@export var speed: float = 300.0
@export var is_can_walk : bool
@export var dialog : Control
@export var text : RichTextLabel
@export var area : Area2D
@export var selected : int
@export var data : Dictionary[String,String]
@export var interact : fnat_interact2d

func _physics_process(_delta: float) -> void:
	if dialog.visible == false :
		var direction = Input.get_vector("left", "right", "up", "down")

		if Input.is_action_just_pressed("left") : get_node("default").scale.x = 2.4
		if Input.is_action_just_pressed("right") : get_node("default").scale.x = -2.4

		velocity = direction * speed
		move_and_slide()

		if Input.is_action_just_pressed("pc") : 
			var array = area.get_overlapping_areas()
			for i in array.size() :
				if array[i] is fnat_interact2d : array[i].interact()

		if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up") :
			if get_node("/root/mi/ui/ui/black/white/v_box_container/0").visible : 
				arc_event.play_sfx({"path" = "ambient/mi/select", "form" = ".wav"})
