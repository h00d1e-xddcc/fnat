extends Resource
class_name fnat_inventory

@export var slots : Array[fnat_cosmetic_item]
@export var slots_count : int = 32

func init() : 
	for i in range(slots.size()) : 
		slots[i] = fnat_cosmetic_item.new()

func redraw_all() :
	for i in slots.size() :
		arc.screen.inventory
