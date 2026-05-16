class_name ObjetoPlantio

extends StaticBody2D

@onready var _animador: AnimatedSprite2D = $Fases_Plantio
@onready var _timer: Timer = $Timer
@export var item: Item
var _objeto_coletavel: PackedScene

signal regar
signal terminado

var _frames: int
var _frame_atual: int = 0
const _tempo_crescimento: float = 3

func _ready() -> void:
	add_to_group("ObjetosPlantio")
	_preparar_estado_inicial()

func _preparar_estado_inicial():
	var caminho = "res://mundo_jogo/objeto_coletavel/objetos/%s.tscn" % item.nome
	_objeto_coletavel = load(caminho)
	_frames = _animador.sprite_frames.get_frame_count("fases")
	_processo_plantio(_frame_atual)

func _processo_plantio(frame: int) -> void:
	_frame_atual = frame
	if _frame_atual < _frames:
		_timer.start(_tempo_crescimento)
		await _timer.timeout
		_animador.frame = _frame_atual
		_animador.show()
		regar.emit(_frame_atual)
	else:
		terminado.emit()
		_processo_coletar()
			
func _processo_coletar():
	_animador.hide()
	var coletavel = _objeto_coletavel.instantiate()
	coletavel.global_position = Vector2.ZERO
	coletavel.tree_exited.connect(_terminar)
	add_child(coletavel)
	
func _terminar():
	queue_free()
	emit_signal("tree_exited")
	
