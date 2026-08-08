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
	
	#arc.get_node("/root/main/office/screen/sub/ui/scheme/map/").text = dictionary["room_"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/office").text = dictionary["room_office"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/staff").text = dictionary["room_staff"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/kitchen").text = dictionary["room_kitchen"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/parts_and_service").text = dictionary["room_parts_and_service"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/ware").text = dictionary["room_ware"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/janitor").text = dictionary["room_janitor"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/maze").text = dictionary["room_maze"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/playground").text = dictionary["room_playground"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/foye").text = dictionary["room_foye"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/admin").text = dictionary["room_admin"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/ware").text = dictionary["room_ware"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/backstage").text = dictionary["room_backstage"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/arcade").text = dictionary["room_arcade"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/downstairs").text = dictionary["room_downstairs"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/toilet").text = dictionary["room_toilet"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/jeffry").text = dictionary["room_jeffry"]
	arc.get_node("/root/main/office/screen/sub/ui/scheme/map/swim").text = dictionary["room_swim"]

func get_lange() -> String :
	return resource_path.get_file().get_basename()
