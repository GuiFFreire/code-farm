class_name PainelTroca
extends Control

@onready var grid_npc: GridContainer = %GridContainerNPC
const CENA_SLOT = preload("res://gerenciador_jogo/gerenciador_npcs/troca/slot_troca.tscn")
@onready var tooltip: CenterContainer = $"../TooltipConfirmacao"

var _estoque_npc_atual: EstoqueTroca

func _ready() -> void:
	tooltip.transacao_confirmada.connect(_processar_transacao)

func abrir(estoque: EstoqueTroca) -> void:
	_estoque_npc_atual = estoque
	tooltip.hide()
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

	# Recebe o arraste também sobre os botões, ícones e fundos da loja.
	for controle: Control in find_children("*", "Control", true, false):
		controle.set_drag_forwarding(Callable(), _can_drop_data, _drop_data)

func _can_drop_data(_posicao: Vector2, dados: Variant) -> bool:
	return is_visible_in_tree() and not tooltip.visible and _obter_dados_venda(dados) != null

func _drop_data(posicao: Vector2, dados: Variant) -> void:
	if not _can_drop_data(posicao, dados):
		return

	var item_loja: ItemTroca = _obter_dados_venda(dados)
	var venda := ItemTroca.new()
	venda.item = item_loja.item
	venda.preco = item_loja.preco
	venda.quantidade = 1
	_ao_clicar_para_vender(venda)

func _obter_dados_venda(dados: Variant) -> ItemTroca:
	if not dados is Dictionary or _estoque_npc_atual == null:
		return null
	var slot_origem: SlotHotbar = dados.get("slot_origem") as SlotHotbar
	if not is_instance_valid(slot_origem) or slot_origem.pilha == null:
		return null
	if slot_origem.pilha.item == null or slot_origem.pilha.quantidade <= 0:
		return null

	# Usa o preço já cadastrado; itens fora do estoque não podem ser vendidos.
	for item_loja in _estoque_npc_atual.itens_a_venda:
		if item_loja != null and item_loja.item == slot_origem.pilha.item and item_loja.preco > 0:
			return item_loja
	return null

func _ao_clicar_para_comprar(dados: ItemTroca) -> void:
	tooltip.abrir_tooltip_confirmacao("Comprar", dados)

func _ao_clicar_para_vender(dados: ItemTroca) -> void:
	tooltip.abrir_tooltip_confirmacao("Vender", dados)


func _processar_transacao(acao: String, dados: ItemTroca) -> void:
	if not is_visible_in_tree():
		return
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
		# Só paga se uma unidade foi realmente removida do inventário.
		if not Global.inventario.remover_item(dados.item):
			return
		jogador.adicionar_moedas(dados.preco)
		
	_preencher_loja(_estoque_npc_atual)
