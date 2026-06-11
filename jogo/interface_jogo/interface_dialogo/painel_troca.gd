class_name PainelTroca
extends Control

@onready var _grid_npc: GridContainer = %GridContainerNPC
const CENA_SLOT = preload("res://gerenciador_jogo/gerenciador_npcs/troca/slot_troca.tscn")

func abrir(estoque: EstoqueTroca) -> void:
	show()
	_preencher_loja(estoque)

func _preencher_loja(estoque: EstoqueTroca) -> void:
	# Lógica de limpar e instanciar slots fica isolada aqui
	for filho in _grid_npc.get_children():
		filho.queue_free()
		
	for item_loja in estoque.itens_a_venda:
		var slot = CENA_SLOT.instantiate()
		_grid_npc.add_child(slot)
		slot.configurar(item_loja)
		slot.slot_clicado.connect(_ao_clicar_item)

func _ao_clicar_item(dados: ItemTroca) -> void:
	# TO DO
	print("Processando compra de: ", dados.item.nome)
