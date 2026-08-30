class_name PainelTroca
extends Control

@onready var grid_npc: GridContainer = %GridContainerNPC
@onready var grid_jogador: GridContainer = %GridContainerJogador
const CENA_SLOT = preload("res://gerenciador_jogo/gerenciador_npcs/troca/slot_troca.tscn")
@onready var tooltip: CenterContainer = $"../TooltipConfirmacao"

var _estoque_npc_atual: EstoqueTroca

func _ready() -> void:
	tooltip.transacao_confirmada.connect(_processar_transacao)

func abrir(estoque: EstoqueTroca) -> void:
	_estoque_npc_atual = estoque
	show()
	_preencher_loja(estoque)

func _preencher_loja(estoque: EstoqueTroca) -> void:
	# Lógica de limpar e instanciar slots fica isolada aqui
	for filho in grid_npc.get_children():
		filho.queue_free()
		
	for item_npc in estoque.itens_a_venda:
		var slot = CENA_SLOT.instantiate()
		grid_npc.add_child(slot)
		slot.configurar(item_npc)
		slot.slot_clicado.connect(_ao_clicar_para_comprar)

func _ao_clicar_para_comprar(dados: ItemTroca) -> void:
	tooltip.abrir_tooltip_confirmacao("Comprar", dados)

func _ao_clicar_para_vender(dados: ItemTroca) -> void:
	tooltip.abrir_tooltip_confirmacao("Vender", dados)


func _processar_transacao(acao: String, dados: ItemTroca) -> void:
	# Tenta obter a instância do jogador na cena
	var jogadores = get_tree().get_nodes_in_group("Jogador")
	if jogadores.size() == 0:
		push_error("PainelTroca: nenhum jogador encontrado para processar transação.")
		return
	var jogador = jogadores[0]

	if acao == "Comprar":
		if jogador.obter_moedas() >= dados.preco:
			# Remove moedas do jogador e adiciona o item
			jogador.remover_moedas(dados.preco)
			Global.inventario.adicionar_item(dados.item)
		else:
			return # Sai sem atualizar a tela
		
	elif acao == "Vender":
		# Adiciona moedas ao jogador e remove o item do inventário
		jogador.adicionar_moedas(dados.preco)
		Global.inventario.remover_item(dados.item)
		
	_preencher_loja(_estoque_npc_atual)
