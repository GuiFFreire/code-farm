class_name Tooltip 

extends Control

@onready var _comando = %Comando
@onready var _descricao = %Descricao

var _ativo: bool = false

func _ready() -> void:
	hide()

func _process(_delta):
	if _ativo:
		global_position = get_viewport().get_mouse_position() - Vector2(0, size.y + 4)

func exibir(nome: String, descricao: String, exemplo: String) -> void:
	_ativo = true
	_comando.text = nome
	_descricao.text = "Descrição: %s\nExemplo: %s" % [descricao, exemplo]
	show()

func esconder():
	_ativo = false
	hide()
