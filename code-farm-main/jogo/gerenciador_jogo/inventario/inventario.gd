class_name Inventario

extends Resource

@export var quantidade_max: int = 6
@export var slots: Array[PilhaItens] = []

func adicionar_item(item: Item) -> bool:
	for pilha in slots:
		var pilha_temp = PilhaItens.new()
		pilha_temp.item = item
		if pilha.pode_empilhar_com(pilha_temp):
			pilha.quantidade += 1
			Global.emit_signal("item_adicionado", pilha)
			return true
	
	if slots.size() < quantidade_max:
		var nova_pilha := PilhaItens.new()
		nova_pilha.item = item
		nova_pilha.quantidade = 1
		slots.append(nova_pilha)
		Global.emit_signal("item_adicionado", nova_pilha) # <==== Aqui!
		return true
	
	return false

func tem_itens(nomes: Array[String]) -> bool:
	var nomes_faltando = nomes.duplicate()
	for pilha in slots:
		if pilha.item.nome in nomes_faltando:
			nomes_faltando.erase(pilha.item.nome)
	
	return nomes_faltando.is_empty()

func remover_itens(nomes: Array[String]) -> void:
	var nomes_para_remover = nomes.duplicate()

	for i in range(slots.size() - 1, -1, -1):
		var pilha = slots[i]
		if pilha.item.nome in nomes_para_remover:
			pilha.quantidade -= 1
			if pilha.quantidade <= 0:
				slots.remove_at(i)
			nomes_para_remover.erase(pilha.item.nome)

	Global.emit_signal("inventario_atualizado")
