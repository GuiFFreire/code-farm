extends MarginContainer

@onready var _quantidade := %Quantidade

func _ready() -> void:
	Global.conectar_sinal(Global, "atualizar_moedas",Callable(self, "atualizar_slot"))
	
func atualizar_slot(quantidade_moedas: int):
	_quantidade.text = str(quantidade_moedas)
