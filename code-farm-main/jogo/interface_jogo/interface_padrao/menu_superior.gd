class_name MenuSuperior 

extends Control

func _ao_clicar_botao_glossario() -> void:
	Global.emit_signal("abrir_glossario")
