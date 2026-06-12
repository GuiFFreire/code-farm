class_name Inventario

extends Resource

@export var quantidade_max: int = 6
@export var slots: Array[PilhaItens] = []
var indice: int = 0

func _init() -> void:
	for i in range(quantidade_max):
		var pilha = PilhaItens.new()
		pilha.item = null
		pilha.quantidade = 0
		slots.append(pilha)
	Global.conectar_sinal(Global, "indice_atualizado", Callable(self, "atualizar_indice"))

func atualizar_indice(_indice: int) -> void:
	indice = _indice

func adicionar_item(item: Item, _indice: int = indice) -> bool:
	var pilha_temp = PilhaItens.new()
	pilha_temp.item = item
	for slot in slots:
		if slot.item != null and slot.pode_empilhar_com(pilha_temp):
			slot.quantidade += 1
			Global.emit_signal("item_modificado", slot)
			return true
	
	for slot in slots:
		if slot.item == null:
			slot.item = item
			slot.quantidade = 1
			Global.emit_signal("item_modificado", slot)
			return true
	
	return false

func tem_itens(nomes: Array[String]) -> bool:
	var nomes_faltando = nomes.duplicate()
	for pilha in slots:
		if pilha.item.nome in nomes_faltando:
			nomes_faltando.erase(pilha.item.nome)
	
	return nomes_faltando.is_empty()
	
func remover() -> Item:
	slots[indice].quantidade -= 1
	var item: Item = slots[indice].item
	if slots[indice].quantidade == 0:
		slots[indice].item = null
		
	Global.emit_signal("item_modificado", slots[indice])
	return item
	
func verificar_tipo(tipo_permitido: String) -> bool:
	if slots[indice].item == null:
		return false
	
	return tipo_permitido == slots[indice].item.tipo
	
func largar_item() -> Item:
	if slots[indice].item == null:
		return null
	return remover()

func mover_item(indice_origem: int, indice_destino: int) -> void:
	var pilha_origem: PilhaItens = slots[indice_origem]
	var pilha_destino: PilhaItens = slots[indice_destino]

	if pilha_destino.item != null and pilha_destino.pode_empilhar_com(pilha_origem):
		pilha_destino.quantidade += pilha_origem.quantidade
		pilha_origem.item = null
		pilha_origem.quantidade = 0
	else:
		var item_temp: Item = pilha_destino.item
		var qtd_temp: int = pilha_destino.quantidade
		pilha_destino.item = pilha_origem.item
		pilha_destino.quantidade = pilha_origem.quantidade
		pilha_origem.item = item_temp
		pilha_origem.quantidade = qtd_temp

	Global.emit_signal("item_modificado", pilha_origem)
	Global.emit_signal("item_modificado", pilha_destino)
