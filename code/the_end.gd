extends Node3D

@export var audio : AudioStreamPlayer3D
@export var chimera : Node3D

func _ready() -> void:
	arc.queue_free()
	audio.volume_db = arc.volume
	audio.play()
	await get_tree().create_timer(15).timeout
	#audio.stream = preload("res://resources/sounds/user/win.wav")
	audio.play()
	
	await get_tree().create_timer(40).timeout
	#audio.stream = preload("res://resources/sounds/anim/noise/scream.wav")
	audio.play()
	chimera.visible = true
	
	await get_tree().create_timer(2.57).timeout
	SceneManager.change_scene("res://prefabs/misc/main_menu.tscn", {"pattern" : "curtians"} )
