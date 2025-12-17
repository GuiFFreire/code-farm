extends CharacterBody2D

class_name Jogador

@export var velocidade_movimento: float = 96.0

@onready var _animador: AnimationPlayer = $Animador
@onready var _camera: Camera2D = $Camera

var _vetor_direcao: Vector2 = Vector2.ZERO
var _direcao_animacao: String = "baixo"

var _movimento_habilitado: bool = true

func _ready():
	add_to_group("Jogador")

func _process(delta: float) -> void:
	if _movimento_habilitado:	
		_obter_vetor_direcao()
		_movimentar_jogador()
		_obter_direcao_animacao()
		_animar_personagem()
	
func _obter_vetor_direcao() -> void:
	_vetor_direcao = Input.get_vector("mover_esquerda", "mover_direita", "mover_cima", "mover_baixo")

func _obter_direcao_animacao() -> void:
	# Se houver movimento na horizontal, prioriza essa direção
	if _vetor_direcao.x != 0:
		_direcao_animacao = "esquerda" if _vetor_direcao.x < 0 else "direita"
	# Se não houver movimento horizontal, mas houver na vertical, define a direção vertical
	elif _vetor_direcao.y != 0:
		_direcao_animacao = "cima" if _vetor_direcao.y < 0 else "baixo"

func _movimentar_jogador() -> void:
	velocity = _vetor_direcao * velocidade_movimento
	move_and_slide()

func _animar_personagem() -> void:
	if velocity: 
		_animador.play("andando_" + _direcao_animacao)
	else:
		_animador.play("parado_" + _direcao_animacao)

func _ao_entrar_area_detecao(objeto: Node2D) -> void:
	pass

func desativar_camera() -> void:
	_camera.position_smoothing_enabled = false

func ativar_camera() -> void:
	_camera.position_smoothing_enabled = true

func ativar_movimento() -> void:
	_movimento_habilitado = true

func desativar_movimento() -> void:
	_movimento_habilitado = false
	_animador.play("parado_" + _direcao_animacao)

func mover_para(posicao: Vector2, duracao: float = 0.5) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", posicao, duracao).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func tocar_animacao(nome: String, direcao: String = "") -> void:
	if direcao != "":
		_direcao_animacao = direcao
	_animador.play(nome)
