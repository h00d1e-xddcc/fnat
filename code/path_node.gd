extends Marker3D
class_name node_path

@export var neighbours: Array[node_path]
@export var flag : String
@export var flags : Array[String]
@export var occupation : String
@export var is_random : bool = false
@export var pose : String
@export var face : String

func get_random() -> node_path :
	var a = randi_range(0, neighbours.size()) -1
	if a == -1 : a = 0
	return neighbours[a]

func get_pose() -> String :
	if is_random == true : return pose
	var anim : fnat_animatronic = get_node("/root/main/" + occupation)
	match flag :
		"window", "office" : return anim.pose_hunting.pick_random()
		#"idle" : return flags.get(0) зачем здесь эта строчка?
		_ : return anim.pose_default.pick_random()
