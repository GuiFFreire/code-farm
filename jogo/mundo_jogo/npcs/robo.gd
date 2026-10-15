extends CharacterBody2D

class_name Robo

signal interagiu
signal deslocamento_finalizado(sucesso: bool)

@export_group("Configurações")
@export var velocidade: float = 80.0
@export var distancia_minima: float = 60.0 # Onde ele para de andar
@export var distancia_limite: float = 200.0 # Se o jogador passar disso, o robô desiste

@onready var _label_interacao: Label = $LabelInteracao
@onready var _area_detecao: Area2D = $AreaDetecao

enum Estados { PARADO, SEGUINDO }
var _estado_atual = Estados.PARADO
var _alvo: Node2D = null
var _jogador_na_area: bool = false
var _dono_trabalho: Node
var _destino_trabalho: Vector2
var _em_deslocamento: bool = false

func _ready() -> void:
	add_to_group("Robo")
	_label_interacao.hide()
	
	var jogadores = get_tree().get_nodes_in_group("Jogador")
	if jogadores.size() > 0:
		_alvo = jogadores[0]
	
	_area_detecao.body_entered.connect(_on_body_entered)
	_area_detecao.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if is_instance_valid(_dono_trabalho):
		return

	if _alvo is Jogador and not _alvo.pode_interagir():
		return
	if _jogador_na_area and Input.is_action_just_pressed("interagir"):
		_alternar_estado()

func _physics_process(_delta: float) -> void:
	if is_instance_valid(_dono_trabalho):
		velocity = Vector2.ZERO

		if _em_deslocamento:
			global_position = global_position.move_toward(
				_destino_trabalho,
				maxf(velocidade, 1.0) * _delta
			)

			if global_position.distance_to(_destino_trabalho) <= 0.5:
				global_position = _destino_trabalho
				_em_deslocamento = false
				deslocamento_finalizado.emit(true)
		return
	if _estado_atual == Estados.SEGUINDO and _alvo:
		var distancia = global_position.distance_to(_alvo.global_position)

		if distancia < distancia_limite:
			if distancia > distancia_minima:
				var direcao = global_position.direction_to(_alvo.global_position)
				velocity = direcao * velocidade
			else:
				velocity = Vector2.ZERO
		else:
			# O jogador sumiu ou entrou em uma passagem
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func _atualizar_texto_instrucao() -> void:
	if _estado_atual == Estados.PARADO:
		_label_interacao.text = "[E] Para Seguir"
	else:
		_label_interacao.text = "[E] Para Parar"

func _alternar_estado() -> void:
	if is_instance_valid(_dono_trabalho):
		return
	if _estado_atual == Estados.PARADO:
		_estado_atual = Estados.SEGUINDO
	else:
		_estado_atual = Estados.PARADO
	
	_atualizar_texto_instrucao()
	interagiu.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jogador"):
		_jogador_na_area = true
		_atualizar_texto_instrucao()
		_label_interacao.visible = not is_instance_valid(_dono_trabalho)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jogador"):
		_jogador_na_area = false
		_label_interacao.hide()
		
func atender_chamado(posicao_jogador: Vector2) -> void:
	if is_instance_valid(_dono_trabalho):
		return

	var direcao_aparecer = Vector2(-40, -10) 
	global_position = posicao_jogador + direcao_aparecer
	
	_estado_atual = Estados.SEGUINDO
	_atualizar_texto_instrucao()

func iniciar_trabalho(dono: Node) -> bool:
	if not is_instance_valid(dono):
		return false

	if is_instance_valid(_dono_trabalho):
		return false

	_dono_trabalho = dono
	_em_deslocamento = false
	velocity = Vector2.ZERO
	_label_interacao.hide()
	return true


func ir_ate(destino: Vector2, dono: Node) -> bool:
	if not is_instance_valid(_dono_trabalho):
		return false

	if _dono_trabalho != dono or _em_deslocamento:
		return false

	if global_position.distance_to(destino) <= 0.5:
		return true

	_destino_trabalho = destino
	_em_deslocamento = true

	var chegou: bool = await deslocamento_finalizado
	return chegou


func finalizar_trabalho(dono: Node) -> void:
	if _dono_trabalho != dono:
		return

	var estava_andando := _em_deslocamento

	_dono_trabalho = null
	_em_deslocamento = false
	velocity = Vector2.ZERO

	if estava_andando:
		deslocamento_finalizado.emit(false)

	_atualizar_texto_instrucao()
	_label_interacao.visible = _jogador_na_area


func _exit_tree() -> void:
	if _em_deslocamento:
		_em_deslocamento = false
		deslocamento_finalizado.emit(false)
