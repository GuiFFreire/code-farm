class_name ObjetoInterativo 

extends StaticBody2D

signal interagiu

@onready var _animador: AnimationPlayer = $Animador
@onready var _sprite: Sprite2D = $Sprite
@onready var _label_interacao: Label = $LabelInteracao

var _detecao_ativa: bool = false

var _jogador_dentro: bool = false
var _interecao_em_execucao: bool = false

func _ready() -> void:
	add_to_group("ObjetosInterativos")
	_preparar_estado_inicial()

func _preparar_estado_inicial():
	_label_interacao.hide()
	_label_interacao.global_position.y -= _sprite.region_rect.size.y

func _process(delta: float) -> void:
	_se_houver_interacao()

func _se_houver_interacao() -> void:
	if _jogador_dentro and Input.is_action_just_pressed("interagir") and not _interecao_em_execucao:
		_label_interacao.hide()
		_animador.play("RESET")
		_interecao_em_execucao = true
		emit_signal("interagiu")

func _ao_detectar_entrada(corpo: Node2D) -> void:
	if _detecao_ativa and corpo.is_in_group("Jogador"):
		_label_interacao.show()
		_animador.play("destacar_objeto")
		_jogador_dentro = true

func _ao_detectar_saida(corpo: Node2D) -> void:
	if _detecao_ativa and corpo.is_in_group("Jogador"):
		_label_interacao.hide()
		_animador.play("RESET")
		_interecao_em_execucao = false
		_jogador_dentro = false

func ativar_interacao() -> void:
	_detecao_ativa = true

func desativar_interacao() -> void:
	_detecao_ativa = false

func tocar_animacao(nome: String) -> void:
	_animador.play(nome)

func obter_largura() -> float:
	if _sprite.region_enabled:
		return _sprite.region_rect.size.x
	elif _sprite.texture:
		return _sprite.texture.get_width()
	return 0.0
