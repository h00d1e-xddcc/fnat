extends Node3D

@export var audio : AudioStreamPlayer3D
@export var chimera : Node3D

func _ready() -> void:
	arc.queue_free()
	audio.volume_db = arc.volume
	audio.play()
	await get_tree().create_timer(15).timeout
	audio.stream = preload("res://resources/sounds/user/win.wav")
	audio.play()
	OS.shell_open("https://www.teamfortress.com")
	
	await get_tree().create_timer(40).timeout
	audio.stream = preload("res://resources/sounds/anim/noise/scream.wav")
	audio.play()
	chimera.visible = true
	
	await get_tree().create_timer(2.57).timeout
	SceneManager.change_scene("res://prefabs/misc/main_menu.tscn", {"pattern" : "curtians"} )
	

# что я делаю со своей жизнью не так?
# это не хорор, почему, я делаю цирк, а не хоррор?
# емааае, какая же это тупая шуткаааа, чувааак
# открыть страницу тф2 и воспроизвести его аудио, это я не знаю отсытки какие-то дегроидные

# а почему хорор должен быть обязательно страшным? 
# чисто в теории, мало палигональная, без текстурная графика, она не может быть страшной,
# в таком случае, надо или атмосферой со звуками давить, или не делать хоррор
# ну, в любом случае, как первый проект, сделанный в этой среде разработки, как по мне засчитано
# да, есть не ровности и царапины, но в целом проект почти готов, как минимум демо, или как лучше назвать?
# зачем я пишу здесь, если у меня obsidian есть?
# в любом случае, с нуля за месяц с лишним, для первого опыта в godot это клево, наверное?
