@tool
extends EditorPlugin

var importer: ResourceImporterGIFTexture
var preview: ResourcePreviewGIFTexture

func _enter_tree() -> void:
	importer = ResourceImporterGIFTexture.new()
	add_import_plugin(importer)
	
	preview = ResourcePreviewGIFTexture.new()
	EditorInterface.get_resource_previewer().add_preview_generator(preview)

func _exit_tree() -> void:
	if importer:
		remove_import_plugin(importer)
		importer = null
	if preview:
		EditorInterface.get_resource_previewer().remove_preview_generator(preview)
		preview = null
