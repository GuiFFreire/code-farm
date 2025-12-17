class_name Copo

extends Node2D

@onready var _animador = %Animador

func tocar_animacao(nome: String) -> void:
	_animador.play(nome)
