extends Marker3D
class_name node_path

@export var neighbours: Array[node_path]
@export var pose: Array[String]
@export var flag : String
@export var occupation : String

func get_random() -> node_path :
	var a = randi_range(0, neighbours.size()) -1
	if a == -1 : a = 0
	return neighbours[a]

func get_pose() -> String :
	if pose.size() == 0 : return "default"
	var a = randi_range(0, pose.size()) -1
	if a == -1 : a = 0
	return pose[a]
