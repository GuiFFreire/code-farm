class_name Penny
extends ObjetoBase

signal interagiu
signal percurso_concluido
signal ponto_rota_alcancado(proximo_indice: int)

@export var nome: String = "Penny"
@export_file("*.png") var foto: String = \
	"res://assets/imagens/npcs/Penny_face.png"

@export_group("Movimento")
@export var velocidade: float = 65.0
@export var distancia_para_esperar: float = 120.0
@export var distancia_para_continuar: float = 75.0
@export var terreno_atual: String = "TerrenoFazenda"

@export_group("Percurso")
# Coloque aqui os marcadores na ordem do caminho.
@export var pontos_rota: Array[Marker2D] = []
@onready var _colisao_penny: CollisionShape2D = $Collisao
@onready var _area_penny: Area2D = $AreaDetecao

var _chegada_iniciada: bool = false
var _interacao: ComportamentoInterativo
var _jogador: Jogador
var _aviso_espera: Label

var _destinos: PackedVector2Array = []
var _indice_destino: int = 0
var _andando: bool = false
var _esperar_jogador: bool = true
var _esperando: bool = false


func _ready() -> void:
	super._ready()

	_interacao = obter_comportamento(
		ComportamentoInterativo
	) as ComportamentoInterativo

	if _interacao == null:
		push_error(
			"Penny precisa de ComportamentoInterativo."
		)
		return

	_interacao.texto_interacao = "[E] conversar com Penny"
	_interacao.interagiu.connect(_ao_interagir)

	_aviso_espera = criar_label_interacao()
	_aviso_espera.text = "Estou esperando você!"
	_aviso_espera.hide()
	ocultar_penny()


func _ao_interagir() -> void:
	# O roteiro da missão recebe esse sinal e abre o diálogo.
	interagiu.emit()


func ativar_interacao() -> void:
	if _interacao != null:
		_interacao.ativar_interacao(self)


func desativar_interacao() -> void:
	if _interacao != null:
		_interacao.desativar_interacao()


func iniciar_percurso(
	esperar_jogador: bool = true,
	indice_inicial: int = 0
) -> bool:
	var destinos := PackedVector2Array()

	for ponto in pontos_rota:
		if is_instance_valid(ponto):
			destinos.append(ponto.global_position)

	if not _iniciar_movimento(destinos, esperar_jogador):
		return false

	_indice_destino = clampi(
		indice_inicial,
		0,
		_destinos.size() - 1
	)

	return true


# Útil para a chegada da Penny à frente da casa.
func caminhar_ate(
	destino: Vector2,
	esperar_jogador: bool = false
) -> bool:
	return _iniciar_movimento(
		PackedVector2Array([destino]),
		esperar_jogador
	)


func _iniciar_movimento(
	destinos: PackedVector2Array,
	esperar_jogador: bool
) -> bool:
	if destinos.is_empty():
		push_warning("Penny está sem pontos de percurso.")
		return false

	_destinos = destinos
	_indice_destino = 0
	_esperar_jogador = esperar_jogador
	_esperando = false
	_andando = true

	desativar_interacao()
	return true


func _physics_process(delta: float) -> void:
	if not _andando:
		return

	# Penny pode entrar na árvore antes do jogador.
	if not is_instance_valid(_jogador):
		_jogador = get_tree().get_first_node_in_group(
			"Jogador"
		) as Jogador

	if not is_instance_valid(_jogador):
		return

	# Espera durante diálogos e outras interfaces.
	if not _jogador.pode_interagir():
		_aviso_espera.hide()
		return

	if _esperar_jogador:
		_atualizar_espera()

		if _esperando:
			return

	var destino := _destinos[_indice_destino]

	global_position = global_position.move_toward(
		destino,
		velocidade * delta
	)

	if global_position.distance_to(destino) <= 1.0:
		global_position = destino
		_indice_destino += 1

		ponto_rota_alcancado.emit(_indice_destino)

		if _indice_destino >= _destinos.size():
			_finalizar_percurso()


func _atualizar_espera() -> void:
	var mesmo_terreno := (
		_jogador.terreno_atual == terreno_atual
	)

	var distancia := global_position.distance_to(
		_jogador.global_position
	)

	if not mesmo_terreno:
		_esperando = true
	elif distancia > distancia_para_esperar:
		_esperando = true
	elif distancia <= distancia_para_continuar:
		_esperando = false

	_aviso_espera.visible = _esperando and mesmo_terreno


func parar() -> void:
	_andando = false
	_esperando = false

	if is_instance_valid(_aviso_espera):
		_aviso_espera.hide()


func _finalizar_percurso() -> void:
	parar()
	ativar_interacao()
	percurso_concluido.emit()
	
	
func atravessar_para(
	marcador_chegada: Marker2D,
	novo_terreno: String,
	nova_rota: Array[Marker2D]
) -> void:
	parar()
	desativar_interacao()

	global_position = marcador_chegada.global_position
	terreno_atual = novo_terreno
	pontos_rota.assign(nova_rota)

	if not iniciar_percurso(true):
		ativar_interacao()
func ocultar_penny() -> void:
	parar()
	desativar_interacao()
	hide()

	_colisao_penny.set_deferred("disabled", true)
	_area_penny.set_deferred("monitoring", false)

	set_process(false)
	set_physics_process(false)


func mostrar_penny() -> void:
	show()

	_colisao_penny.set_deferred("disabled", false)
	_area_penny.set_deferred("monitoring", true)

	set_process(true)
	set_physics_process(true)


func iniciar_chegada() -> void:
	# Quando o jogador já entrou no salão, a guia fica escondida.
	if Global.progresso_missoes.get(
		"penny_entrou_salao", false
	):
		ocultar_penny()
		return

	if _chegada_iniciada:
		return

	if pontos_rota.is_empty():
		push_warning("Configure o marcador inicio na rota da Penny.")
		return

	var ponto_inicial := pontos_rota[0]

	if not is_instance_valid(ponto_inicial):
		push_warning("O marcador inicial da Penny não foi encontrado.")
		return

	_chegada_iniciada = true
	terreno_atual = "TerrenoFazenda"

	mostrar_penny()

	# Ao carregar um save, preserva a posição já restaurada.
	if Global.progresso_missoes.get(
		"penny_chegou_inicio", false
	):
		ativar_interacao()
		return

	percurso_concluido.connect(
		_ao_concluir_chegada,
		CONNECT_ONE_SHOT
	)

	# Parte da posição em que você colocou a instância.
	# Nesta chegada, ela não espera o jogador acompanhá-la.
	caminhar_ate(ponto_inicial.global_position, false)


func _ao_concluir_chegada() -> void:
	Global.progresso_missoes["penny_chegou_inicio"] = true
