class_name SlotLoja
extends Button

# Emitimos este sinal quando o jogador clicar neste slot específico
signal slot_clicado(dados_do_item: ItemTroca)

@onready var _icone: TextureRect = %Icone
@onready var _quantidade: Label = %Quantidade
@onready var _preco: Label = %Preco

# Guardamos o resource aqui para saber quem somos
var _dados_item: ItemTroca 

func configurar(novo_item: ItemTroca) -> void:
	_dados_item = novo_item
	
	# Pega a textura, o preco e a quantidade
	_icone.texture = _dados_item.item.icone
	_preco.text = "$ " + str(_dados_item.preco)
	_quantidade.text = str(_dados_item.quantidade)

func _ready() -> void:
	# Conetando o botão à uma função interna
	pressed.connect(_ao_ser_clicado)

func _ao_ser_clicado() -> void:
	# Avisando a Interface qual item foi clicado
	slot_clicado.emit(_dados_item)
