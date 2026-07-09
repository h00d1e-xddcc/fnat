extends Resource
class_name fnat_lange

@export var dictionary : Dictionary[String,String]

func retranslate_screen() :
	arc.get_node("/root/main/office/screen/sub/ui/label/cam").text = dictionary["ui_cam"]
	arc.get_node("/root/main/office/screen/sub/ui/label/scheme").text = dictionary["ui_scheme"]
	arc.get_node("/root/main/office/screen/sub/ui/audio").text = dictionary["ui_only_audio"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/info").text = dictionary["ui_start"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/buttons/ping_pong").text = dictionary["ui_ping_pong"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/buttons/play_sound").text = dictionary["ui_bait"]
