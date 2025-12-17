class_name PilhaItens

extends Resource

@export var item: Item
@export var quantidade: int = 1

func pode_empilhar_com(outro: PilhaItens) -> bool:
	return item == outro.item and item.pode_empilhar
