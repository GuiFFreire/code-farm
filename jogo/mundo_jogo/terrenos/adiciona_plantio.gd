class_name RegistroPlantio	
extends Node2D

const CENA_AREA_PLANTIO = preload('res://mundo_jogo/plantio/area_plantio.tscn')
const LINHAS: int = 5
const COLUNAS: int = 2

var _canteiros: Array = []

@export var origem_canteiro: Vector2 = Vector2(-114.0, -274.0)
@export var espacamento_plantio: Vector2 = Vector2(21.0, 21.0)

var _referencias_matriz: Dictionary = {}
var distancia_direita_canteiro: Vector2 = Vector2(64.0, 0.0)
var distancia_baixo_canteiro: Vector2 = Vector2(0.0, 128.0)

func _ready() -> void:
	gerar_canteiros()


func gerar_canteiros() -> void:
	#Canteiro 1
	instanciar_grupo(Vector2.ZERO)
	
	#Canteriro 2
	instanciar_grupo(distancia_baixo_canteiro)
	
	#Canteiro 3
	var deslocamento = 2 * distancia_baixo_canteiro
	instanciar_grupo(deslocamento)
	
	#Canteiro 4
	instanciar_grupo(distancia_direita_canteiro)
	
	#Canteiro 5
	deslocamento = distancia_baixo_canteiro + distancia_direita_canteiro
	instanciar_grupo(deslocamento)
	
	#Canteiro 6
	deslocamento = 2 * distancia_baixo_canteiro + distancia_direita_canteiro
	instanciar_grupo(deslocamento)


func instanciar_grupo(deslocamento: Vector2) -> void:
	var matriz: Array = []

	for linha in range(LINHAS):
		var espacos_da_linha: Array[Area2D] = []

		for coluna in range(COLUNAS):
			var area := CENA_AREA_PLANTIO.instantiate() as Area2D

			area.position = origem_canteiro + deslocamento + Vector2(
				coluna * espacamento_plantio.x,
				linha * espacamento_plantio.y
			)
			area.name = "Canteiro_%d_%d" % [
				int(area.position.x),
				int(area.position.y)
			]

			add_child(area)
			espacos_da_linha.append(area)

		matriz.append(espacos_da_linha)

	_canteiros.append(matriz)
	
func obter_espaco(
	id_canteiro: int,
	linha: int,
	coluna: int
) -> Area2D:
	if id_canteiro < 0 or id_canteiro >= _canteiros.size():
		return null

	if linha < 0 or linha >= LINHAS:
		return null

	if coluna < 0 or coluna >= COLUNAS:
		return null

	return _canteiros[id_canteiro][linha][coluna] as Area2D

func mostrar_referencias(id_canteiro: int) -> void:
	ocultar_referencias()

	if id_canteiro < 0 or id_canteiro >= _canteiros.size():
		return

	if _referencias_matriz.has(id_canteiro):
		var existente: Node2D = _referencias_matriz[id_canteiro]
		existente.show()
		return

	var referencias := Node2D.new()
	referencias.name = "ReferenciasMatriz_%d" % id_canteiro
	referencias.z_as_relative = false
	referencias.z_index = 20
	add_child(referencias)

	_referencias_matriz[id_canteiro] = referencias

	# Números das linhas, à esquerda da primeira coluna.
	for linha in range(LINHAS):
		var espaco := obter_espaco(id_canteiro, linha, 0)
		var posicao := referencias.to_local(espaco.global_position)

		_criar_numero(
			referencias,
			str(linha),
			posicao + Vector2(-22, 0)
		)

	# Números das colunas, acima da primeira linha.
	for coluna in range(COLUNAS):
		var espaco := obter_espaco(id_canteiro, 0, coluna)
		var posicao := referencias.to_local(espaco.global_position)

		_criar_numero(
			referencias,
			str(coluna),
			posicao + Vector2(0, -24)
		)


func ocultar_referencias() -> void:
	for valor in _referencias_matriz.values():
		var referencias: Node2D = valor

		if is_instance_valid(referencias):
			referencias.hide()


func _criar_numero(
	pai: Node2D,
	texto: String,
	centro: Vector2
) -> void:
	var numero := Label.new()
	numero.text = texto
	numero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	numero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	numero.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	numero.add_theme_font_size_override("font_size", 8)
	numero.add_theme_color_override("font_color", Color.WHITE)
	numero.add_theme_color_override("font_outline_color", Color.BLACK)
	numero.add_theme_constant_override("outline_size", 2)

	numero.size = Vector2(16, 16)
	numero.position = centro - numero.size / 2.0

	pai.add_child(numero)
