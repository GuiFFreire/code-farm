class_name Bancada
extends ObjetoBase

signal abertura_solicitada(bancada: Bancada)

@export var bau: Bau

var codigo_digitado: String = ""
var _interacao: ComportamentoInterativo


func _ready() -> void:
	super._ready()

	_interacao = obter_comportamento(
		ComportamentoInterativo
	) as ComportamentoInterativo

	if _interacao == null:
		push_error("A bancada precisa de ComportamentoInterativo.")
		return

	add_to_group("Bancadas")
	_interacao.interagiu.connect(_ao_interagir)


func _ao_interagir() -> void:
	abertura_solicitada.emit(self)


func liberar_interacao() -> void:
	if _interacao != null:
		_interacao.liberar_interacao()
