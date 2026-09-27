@tool
extends EditorPlugin

const QrCodeRect := preload("res://addons/kenyoni/qr_code/qr_code_rect.gd")

func _enter_tree() -> void:
    self.add_custom_type("QRCodeRect", "TextureRect", QrCodeRect, preload("res://addons/kenyoni/qr_code/icon.svg"))

func _exit_tree() -> void:
    self.remove_custom_type("QRCodeRect")
