class_name SlotHotbar

extends MarginContainer

@onready var _icone := %Icone
@onready var _quantidade := %Quantidade

var pilha: PilhaItens

func atualizar_slot(nova_pilha: PilhaItens) -> void:
	pilha = nova_pilha
	_icone.texture = pilha.item.icone
	_quantidade.text = str(pilha.quantidade)

func limpar_slot() -> void:
	pilha = null
	_icone.texture = null
	_quantidade.text = ""
