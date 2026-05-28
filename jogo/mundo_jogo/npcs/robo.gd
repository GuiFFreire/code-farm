extends CharacterBody2D

class_name Robo

# Sinal para que o sistema de missões saiba quando você falou com ele
signal interagiu

@export_group("Configurações")
@export var velocidade: float = 80.0
@export var distancia_minima: float = 45.0 # Distância para não ficar "em cima" do jogador

@onready var _animador: AnimationPlayer = $Animador
@onready var _label_interacao: Label = $LabelInteracao
@onready var _area_detecao: Area2D = $AreaDetecao
@onready var _sprite: Sprite2D = $Sprite

enum Estados { PARADO, SEGUINDO, MISSAO }
var _estado_atual = Estados.PARADO
var _alvo: Node2D = null
var _jogador_na_area: bool = false

func _ready() -> void:
	add_to_group("Robo")
	_label_interacao.hide()
	
	# Busca o jogador automaticamente pelo grupo que você já criou no jogador.gd
	var jogadores = get_tree().get_nodes_in_group("Jogador")
	if jogadores.size() > 0:
		_alvo = jogadores[0]
	
	# Conecta os sinais da Area2D via código para garantir que funcione
	_area_detecao.body_entered.connect(_on_body_entered)
	_area_detecao.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	# Só verifica clique se o jogador estiver perto
	if _jogador_na_area and Input.is_action_just_pressed("interagir"):
		_alternar_estado()

func _physics_process(_delta: float) -> void:
	if _estado_atual == Estados.SEGUINDO and _alvo:
		var distancia = global_position.distance_to(_alvo.global_position)
		
		if distancia > distancia_minima:
			var direcao = global_position.direction_to(_alvo.global_position)
			velocity = direcao * velocidade
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func _alternar_estado() -> void:
	if _estado_atual == Estados.PARADO:
		_estado_atual = Estados.SEGUINDO
	else:
		_estado_atual = Estados.PARADO
	
	_label_interacao.hide()
	interagiu.emit() # Avisa o Gerenciador de Missões

# Funções de detecção (IDÊNTICAS ao seu ObjetoInterativo.gd)
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jogador"):
		_jogador_na_area = true
		_label_interacao.show()
		if _animador.has_animation("destacar_objeto"):
			_animador.play("destacar_objeto")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jogador"):
		_jogador_na_area = false
		_label_interacao.hide()
		_animador.play("RESET")
