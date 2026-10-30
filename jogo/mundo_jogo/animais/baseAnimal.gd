extends CharacterBody2D

class_name BaseAnimal

enum ESTADO {ANDAR, PARAR}
var velocidade_movimento : float = 20
var tempo_parado : float = 3
var tempo_andando : float = 3
var tempo_fugindo : float = 3

@onready var _animador : AnimationPlayer = $AnimationPlayer
@onready var timer : Timer = $Timer
@onready var timer_som : Timer = $TimerSom
@onready var area_detecao : Area2D = $Area2D
@onready var som_normal : AudioStreamPlayer2D = $SomNormal
@onready var som_fugindo : AudioStreamPlayer2D = $SomFugindo

var _vetor_direcao : Vector2 = Vector2.ZERO
var _direcao_animacao: String = "baixo"
var _estado_atual : ESTADO = ESTADO.PARAR

## Alimentação compartilhada; a dieta usa os nomes dos recursos Item existentes.
@export var alimentos_aceitos: Array[String] = []
@export_range(16.0, 512.0, 1.0) var raio_busca_cocho: float = 160.0
@export_range(12.0, 64.0, 1.0) var distancia_comer: float = 24.0
@export_range(0.1, 30.0, 0.1) var tempo_para_comer: float = 1.0
@export_range(0.0, 300.0, 0.1) var intervalo_refeicoes: float = 3.0
@export var velocidade_ate_cocho: float = 32.0

var _cocho: Node2D
var _tempo_comendo: float = 0.0
var _tempo_fome_restante: float = 0.0
var _tempo_fuga_restante: float = 0.0

func _ready():
	timer.timeout.connect(_obter_estado)
	timer_som.timeout.connect(_tocar_som)
	area_detecao.body_entered.connect(_reagir_ao_personagem)
	_obter_estado()
	_tocar_som()

func _physics_process(delta: float) -> void:
	if alimentos_aceitos.is_empty():
		_controle()
		return
	_tempo_fome_restante = maxf(0.0, _tempo_fome_restante - delta)
	_tempo_fuga_restante = maxf(0.0, _tempo_fuga_restante - delta)
	# O animal só se aproxima da comida quando o jogador se afasta.
	for corpo in area_detecao.get_overlapping_bodies():
		if corpo.is_in_group("Jogador"):
			if _tempo_fuga_restante <= 0.0:
				_reagir_ao_personagem(corpo)
			_tempo_fuga_restante = tempo_fugindo
			_vetor_direcao = (global_position - corpo.global_position).normalized()
	if _tempo_fuga_restante > 0.0:
		_cocho = null
		_tempo_comendo = 0.0
		_estado_atual = ESTADO.ANDAR
		velocidade_movimento = 96.0
		_controle()
		return

	if not _pode_procurar_comida():
		_passear()
		return
	var destino = _buscar_cocho()
	if destino != _cocho:
		_tempo_comendo = 0.0
	_cocho = destino
	if not is_instance_valid(_cocho):
		_passear()
		return

	timer.stop()
	velocidade_movimento = velocidade_ate_cocho
	if global_position.distance_to(_cocho.global_position) > distancia_comer:
		_tempo_comendo = 0.0
		_estado_atual = ESTADO.ANDAR
		_vetor_direcao = global_position.direction_to(_cocho.global_position)
		_controle()
	else:
		velocity = Vector2.ZERO
		_vetor_direcao = Vector2.ZERO
		_estado_atual = ESTADO.PARAR
		_animar_personagem()
		_tempo_comendo += delta
		if _tempo_comendo >= tempo_para_comer:
			# A dieta é validada novamente ao consumir a última porção.
			var alimento: Item = _cocho.alimento_armazenado
			if aceita_alimento(alimento) and _cocho.consumir_porcao(alimento):
				_ao_terminar_refeicao()
			_tempo_comendo = 0.0
			_cocho = null

func _controle() -> void:
	if (_estado_atual == ESTADO.ANDAR):	
		_movimentar_jogador()
		_obter_direcao_animacao()
	else:
		_vetor_direcao = Vector2.ZERO
	_animar_personagem()

func _obter_vetor_direcao():
	_vetor_direcao = Vector2(
		randi_range(-1,1),
		randi_range(-1,1)
	)

func _movimentar_jogador() -> void:
	velocity = _vetor_direcao * velocidade_movimento
	move_and_slide()
	
	# tratando colisoes com o cenario
	if get_slide_collision_count() > 0:
		_vetor_direcao = -_vetor_direcao
		# modifica tambem a animacao
		_obter_direcao_animacao()
		_animar_personagem()

func _obter_direcao_animacao() -> void:
	# Se houver movimento na horizontal, prioriza essa direção
	if _vetor_direcao.x != 0:
		_direcao_animacao = "esquerda" if _vetor_direcao.x < 0 else "direita"
	# Se não houver movimento horizontal, mas houver na vertical, define a direção vertical
	elif _vetor_direcao.y != 0:
		_direcao_animacao = "cima" if _vetor_direcao.y < 0 else "baixo"

func _animar_personagem() -> void:
	if _vetor_direcao != Vector2.ZERO: 
		_animador.play("andando_" + _direcao_animacao)
	else:
		_animador.play("parado_" + _direcao_animacao)

func _obter_estado() -> void:
	if _tempo_fuga_restante > 0.0 or is_instance_valid(_cocho):
		return
	velocidade_movimento = 20
	if(_estado_atual == ESTADO.PARAR):
		_estado_atual = ESTADO.ANDAR
		_obter_vetor_direcao()
		timer.start(tempo_andando)
	elif(_estado_atual == ESTADO.ANDAR):
		_estado_atual = ESTADO.PARAR
		_obter_vetor_direcao()
		timer.start(tempo_parado)

func _reagir_ao_personagem(corpo: Node2D) -> void:
	if not corpo.is_in_group("Jogador"):
		return
	if not alimentos_aceitos.is_empty():
		_tempo_fuga_restante = tempo_fugindo
	_tempo_comendo = 0.0
	_cocho = null
	if randi() % 100 < 10 and !som_normal.playing and !som_fugindo.playing:
		som_fugindo.play()
	velocidade_movimento = 96
	_estado_atual = ESTADO.ANDAR
	_vetor_direcao = (global_position - corpo.global_position).normalized()
	timer.stop()
	timer.start(tempo_fugindo)

func _tocar_som():
	var tempo = 5 + (randi() % 16)
	if !som_fugindo.playing:
		som_normal.play()
	timer_som.start(tempo)

func _buscar_cocho() -> Node2D:
	var mais_proximo: Node2D = null
	var distancia_minima = raio_busca_cocho
	for candidato in get_tree().get_nodes_in_group("Cochos"):
		if candidato.get_parent() != get_parent() or not candidato.is_visible_in_tree() or not candidato.tem_comida() or not aceita_alimento(candidato.alimento_armazenado):
			continue
		var distancia = global_position.distance_to(candidato.global_position)
		if distancia > distancia_minima:
			continue
		var consulta = PhysicsRayQueryParameters2D.create(global_position, candidato.global_position, collision_mask, [get_rid()])
		var obstaculo = get_world_2d().direct_space_state.intersect_ray(consulta)
		if not obstaculo.is_empty() and obstaculo["collider"] != candidato:
			continue
		mais_proximo = candidato
		distancia_minima = distancia
	return mais_proximo

func _passear() -> void:
	_cocho = null
	_tempo_comendo = 0.0
	if timer.is_stopped():
		_obter_estado()
	_controle()

func _pode_procurar_comida() -> bool:
	return _tempo_fome_restante <= 0.0

func _ao_terminar_refeicao() -> void:
	_tempo_fome_restante = intervalo_refeicoes

func obter_estado_alimentacao() -> Dictionary:
	return {
		"fome_restante": _tempo_fome_restante,
		"fuga_restante": _tempo_fuga_restante
	}

func restaurar_estado_alimentacao(dados: Dictionary) -> void:
	_tempo_fome_restante = maxf(0.0, dados.get("fome_restante", 0.0))
	_tempo_fuga_restante = maxf(0.0, dados.get("fuga_restante", 0.0))
	# O alimento só é consumido no final; uma refeição interrompida recomeça.
	_tempo_comendo = 0.0
	_cocho = null

func aceita_alimento(item: Item) -> bool:
	return item != null and item.nome in alimentos_aceitos
