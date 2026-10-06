extends Control

func _on_mouse_entered() -> void:
	scale *= 1.2

func _on_mouse_exited() -> void:
	scale = Vector2.ONE

func _on_pressed() -> void:
	SceneManager.change_scene("res://prefabs/misc/main.tscn", {"pattern" : "curtians"})
	self.disabled = false
