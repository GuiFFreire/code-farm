extends CharacterBody2D

class_name Jogador

@export var velocidade_movimento: float = 96.0
@export var cenas_permitidas: Array[String] = ["TerrenoFazenda", "TerrenoVila"]

@onready var _animador: AnimationPlayer = $Animador
@onready var _camera: Camera2D = $Camera
@onready var fala_visual: TextoPlaca = $TextoPlaca
@onready var ponto_fala: Marker2D = %PontoFala

var terreno_atual: String = "TerrenoFazenda"

var _vetor_direcao: Vector2 = Vector2.ZERO
var _direcao_animacao: String = "baixo"

var _movimento_habilitado: bool = true

# Quantidade de moedas que o jogador possui. Inicialmente 50.
var quantidade_moedas: int = 50

func _ready():
	add_to_group("Jogador")
	Global.emit_signal("atualizar_moedas", quantidade_moedas)

# ---------------------- FUNÇÕES DE ACESSO A MOEDAS ----------------------
func obter_moedas() -> int:
	return quantidade_moedas

func definir_moedas(valor: int) -> void:
	quantidade_moedas = max(0, valor)
	Global.emit_signal("atualizar_moedas", quantidade_moedas)

func adicionar_moedas(valor: int) -> void:
	if valor <= 0:
		return
	quantidade_moedas += valor
	Global.emit_signal("atualizar_moedas", quantidade_moedas)

func remover_moedas(valor: int) -> bool:
	if valor <= 0:
		return true
	if quantidade_moedas >= valor:
		quantidade_moedas -= valor
		Global.emit_signal("atualizar_moedas", quantidade_moedas)
		return true
	return false

func _process(delta: float) -> void:
	if _movimento_habilitado:	
		_obter_vetor_direcao()
		_movimentar_jogador()
		_obter_direcao_animacao()
		_animar_personagem()
		
		if Input.is_action_just_pressed("chamar_robo"):
			_tentar_chamar_robo()
	
func _obter_vetor_direcao() -> void:
	_vetor_direcao = Input.get_vector("mover_esquerda", "mover_direita", "mover_cima", "mover_baixo")

func _obter_direcao_animacao() -> void:
	if _vetor_direcao.x != 0:
		_direcao_animacao = "esquerda" if _vetor_direcao.x < 0 else "direita"
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
	
func _tentar_chamar_robo() -> void:
	if terreno_atual in cenas_permitidas:
		_mostrar_fala("Chamando o robô AGR.O...")
		
		await get_tree().create_timer(1.0).timeout
		
		var robos = get_tree().get_nodes_in_group("Robo")
		if robos.size() > 0:
			var robo = robos[0]
			
			var distancia = global_position.distance_to(robo.global_position)
			
			if distancia > 250.0:
				robo.atender_chamado(global_position)
				print("Robô estava longe e foi teleportado!")
			if robo._estado_atual == robo.Estados.PARADO:
				robo._alternar_estado()
	else:
		_mostrar_fala("Não posso chamar o AGR.O aqui.")
		print("Falha: O robô não pode 	entrar no terreno: ", terreno_atual)
		
func _mostrar_fala(texto_da_fala: String) -> void:
	
	fala_visual.exibir(texto_da_fala, ponto_fala.position)

	await get_tree().create_timer(3.0).timeout

	fala_visual.esconder()
