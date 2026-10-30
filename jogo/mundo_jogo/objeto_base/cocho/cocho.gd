extends ObjetoBase

@export_range(1, 100, 1) var capacidade: int = 10
# Categorias do Item permitidas no recipiente; a dieta pertence ao animal.
@export var tipos_permitidos: Array[String] = ["alimento"]
var quantidade_comida: int = 0
var alimento_armazenado: Item
var _interativo: ComportamentoInterativo

func _ready() -> void:
	super._ready()
	add_to_group("Cochos")
	_interativo = obter_comportamento(ComportamentoInterativo)
	_interativo.interagiu.connect(_ao_abastecer)
	$MensagemTimer.timeout.connect(func(): $Mensagem.hide())
	_atualizar_visual()

func _ao_abastecer() -> void:
	var mensagem = abastecer()
	if not mensagem.is_empty():
		$Mensagem.text = mensagem
		$Mensagem.show()
		$MensagemTimer.start()
	else:
		$Mensagem.hide()
	# Permite colocar outra porção sem precisar sair da área.
	_interativo.call_deferred("ativar_interacao", self)

func abastecer() -> String:
	if quantidade_comida >= capacidade:
		return "Cocho cheio!"
	var inventario = Global.inventario
	var pilha = inventario.slots[inventario.indice]
	if pilha.item == null or pilha.quantidade <= 0 or pilha.item.tipo not in tipos_permitidos:
		return "Selecione um alimento aceito na hotbar."
	if tem_comida() and pilha.item.nome != alimento_armazenado.nome:
		return "Esvazie o cocho antes de trocar o alimento."
	# Captura antes da remoção, que pode esvaziar o slot selecionado.
	var alimento = pilha.item
	inventario.remover()
	alimento_armazenado = alimento
	quantidade_comida += 1
	_atualizar_visual()
	return ""

func tem_comida() -> bool:
	return quantidade_comida > 0 and alimento_armazenado != null

func consumir_porcao(alimento_esperado: Item) -> bool:
	# Consome apenas o conteúdo que o solicitante acabou de consultar.
	if not tem_comida() or alimento_esperado != alimento_armazenado:
		return false
	quantidade_comida -= 1
	if quantidade_comida == 0:
		alimento_armazenado = null
	_atualizar_visual()
	return true

func _atualizar_visual() -> void:
	var acao = "Abastecer cocho"
	if tem_comida():
		acao = alimento_armazenado.nome.replace("_", " ")
	_interativo.texto_interacao = "[E] %s (%d/%d)" % [acao, quantidade_comida, capacidade]
	$ComidaNoCocho.visible = tem_comida()

func obter_estado_alimentacao() -> Dictionary:
	return {"quantidade": quantidade_comida, "alimento": alimento_armazenado}

func restaurar_estado_alimentacao(dados: Dictionary) -> void:
	quantidade_comida = clampi(dados.get("quantidade", 0), 0, capacidade)
	if quantidade_comida > 0:
		alimento_armazenado = dados.get("alimento") as Item
		if alimento_armazenado == null:
			quantidade_comida = 0
	else:
		alimento_armazenado = null
	_atualizar_visual()
