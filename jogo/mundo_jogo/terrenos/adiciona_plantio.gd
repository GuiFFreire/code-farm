extends Node2D

const CENA_AREA_PLANTIO = preload('res://mundo_jogo/plantio/area_plantio.tscn')

var posicao_canteiro: Array[Vector2] = [
	Vector2(-114.0, -274.0), Vector2(-93.0, -274.0),
	Vector2(-114.0, -253.0), Vector2(-93.0, -253.0),
	Vector2(-114.0, -232.0), Vector2(-93.0, -232.0),
	Vector2(-114.0, -211.0), Vector2(-93.0, -211.0),
	Vector2(-114.0, -190.0), Vector2(-93.0, -190.0)
]

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
	for posicao_area in posicao_canteiro:
		var area_plantio = CENA_AREA_PLANTIO.instantiate()
		
		area_plantio.position = posicao_area + deslocamento
		add_child(area_plantio)
	
