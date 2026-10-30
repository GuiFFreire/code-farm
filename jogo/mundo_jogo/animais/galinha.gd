extends BaseAnimal
## A galinha compartilha a alimentação e acrescenta a postura de ovos.
@export_range(0.1, 300.0, 0.1) var tempo_para_ovo: float = 5.0
@export var cena_ovo: PackedScene = preload("res://mundo_jogo/objeto_base/objetos_coletaveis/ovo.tscn")
var _tempo_ovo_restante: float = -1.0

func _ready() -> void:
	super._ready()
	add_to_group("Galinhas")

func _physics_process(delta: float) -> void:
	_atualizar_postura(delta)
	super._physics_process(delta)

func _pode_procurar_comida() -> bool:
	return _tempo_ovo_restante < 0.0 and super._pode_procurar_comida()

func _ao_terminar_refeicao() -> void:
	_tempo_ovo_restante = tempo_para_ovo

func _atualizar_postura(delta: float) -> void:
	if _tempo_ovo_restante < 0.0:
		return
	_tempo_ovo_restante = maxf(0.0, _tempo_ovo_restante - delta)
	if _tempo_ovo_restante == 0.0:
		botar_ovo()

func botar_ovo() -> void:
	if _tempo_ovo_restante != 0.0 or cena_ovo == null:
		return
	var ovo = cena_ovo.instantiate() as Node2D
	if ovo == null:
		return
	get_parent().add_child(ovo)
	ovo.global_position = global_position + Vector2(0, 10)
	_tempo_ovo_restante = -1.0
	_tempo_fome_restante = intervalo_refeicoes

func obter_estado_alimentacao() -> Dictionary:
	var dados = super.obter_estado_alimentacao()
	dados["ovo_restante"] = _tempo_ovo_restante
	return dados

func restaurar_estado_alimentacao(dados: Dictionary) -> void:
	super.restaurar_estado_alimentacao(dados)
	_tempo_ovo_restante = maxf(-1.0, dados.get("ovo_restante", -1.0))
