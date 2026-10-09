class_name InterfaceBancada
extends Control

signal execucao_solicitada(bancada: Bancada, codigo: String)

@onready var _editor: CodeEdit = %CodeEdit
@onready var _mensagens: Label = %Mensagens
@onready var _botao_limpar: Button = %BotaoLimpar
@onready var _botao_executar: Button = %BotaoVerificar
@onready var _botao_fechar: Button = $Fechar/MarginContainer/BotaoFechar
@onready var _botao_glossario: Button = $BotaoGlossario
@onready var _interface_padrao: Control = $"../InterfacePadrao"

const API_PLANTIO: String = "https://code-farm-x5um.onrender.com/analisar_plantio"

var _http: HTTPRequest
var _pedido_bancada: Bancada
var _consultando: bool = false

var _interface_padrao_estava_visivel: bool = false

var _bancada_atual: Bancada
var _jogador: Jogador


func _ready() -> void:
	hide()

	_botao_limpar.pressed.connect(_ao_limpar)
	_botao_executar.pressed.connect(_ao_executar)
	_botao_fechar.pressed.connect(fechar)
	_editor.text_changed.connect(_ao_alterar_codigo)
	_botao_glossario.pressed.connect(_ao_abrir_glossario)
	
	_http = HTTPRequest.new()
	_http.timeout = 30.0
	_http.body_size_limit = 1048576
	add_child(_http)
	_http.request_completed.connect(_ao_receber_plantio)


func abrir(bancada: Bancada) -> void:
	if not is_instance_valid(bancada):
		return

	if is_instance_valid(_bancada_atual):
		fechar()

	_interface_padrao_estava_visivel = _interface_padrao.visible
	_interface_padrao.hide()

	_bancada_atual = bancada
	_editor.text = bancada.codigo_digitado
	_editor.editable = true
	_mensagens.text = ""

	_jogador = get_tree().get_first_node_in_group(
		"Jogador"
	) as Jogador

	if is_instance_valid(_jogador):
		_jogador.desativar_movimento()

	show()
	_editor.grab_focus()


func fechar() -> void:
	_cancelar_consulta()
	var tinha_bancada_aberta := is_instance_valid(_bancada_atual)

	_ao_alterar_codigo()
	_editor.release_focus()
	hide()

	if tinha_bancada_aberta:
		_bancada_atual.liberar_interacao()
		_interface_padrao.visible = _interface_padrao_estava_visivel

	if is_instance_valid(_jogador):
		_jogador.ativar_movimento()

	_bancada_atual = null
	_jogador = null


func _ao_alterar_codigo() -> void:
	if is_instance_valid(_bancada_atual):
		_bancada_atual.codigo_digitado = _editor.text


func _ao_limpar() -> void:
	_editor.clear()
	_mensagens.text = ""
	_editor.grab_focus()

func _ao_abrir_glossario() -> void:
	_editor.release_focus()
	Global.abrir_glossario.emit()
	
func _ao_executar() -> void:
	if _consultando:
		return

	if not is_instance_valid(_bancada_atual):
		return

	if _editor.text.strip_edges().is_empty():
		_mensagens.text = "Escreva um código antes de executar."
		return

	if not is_instance_valid(_bancada_atual.bau):
		_mensagens.text = "Esta bancada não tem um baú associado."
		return

	if not is_instance_valid(_bancada_atual.registro_plantio):
		_mensagens.text = "Associe o registro de plantio à bancada."
		return

	_ao_alterar_codigo()
	_pedido_bancada = _bancada_atual
	_definir_consulta(true)
	_mensagens.text = "Analisando código..."

	var erro := _http.request(
		API_PLANTIO,
		PackedStringArray(["Content-Type: application/json"]),
		HTTPClient.METHOD_POST,
		JSON.stringify({"codigo": _editor.text})
	)

	if erro != OK:
		_pedido_bancada = null
		_definir_consulta(false)
		_mensagens.text = "Não foi possível iniciar a consulta à API."
		
func _definir_consulta(ativa: bool) -> void:
	_consultando = ativa
	_botao_executar.disabled = ativa
	_botao_limpar.disabled = ativa
	_editor.editable = not ativa


func _cancelar_consulta() -> void:
	if is_instance_valid(_http):
		_http.cancel_request()

	_pedido_bancada = null
	_definir_consulta(false)


func _ao_receber_plantio(
	resultado: int,
	codigo_http: int,
	_headers: PackedStringArray,
	corpo: PackedByteArray
) -> void:
	var bancada := _pedido_bancada
	_pedido_bancada = null
	_definir_consulta(false)

	if not is_instance_valid(bancada):
		return

	if bancada != _bancada_atual:
		return

	if resultado != HTTPRequest.RESULT_SUCCESS:
		_mensagens.text = "Falha de conexão. Confira se a API está rodando."
		return

	if codigo_http != 200:
		_mensagens.text = "A API respondeu com erro HTTP %d." % codigo_http
		return

	var resposta: Variant = JSON.parse_string(corpo.get_string_from_utf8())

	if not resposta is Dictionary:
		_mensagens.text = "A API devolveu uma resposta inválida."
		return

	if resposta.get("status", "") != "sucesso":
		var mensagens: Variant = resposta.get("mensagens", [])
		var textos := PackedStringArray()

		if mensagens is Array:
			for mensagem in mensagens:
				textos.append(str(mensagem))

		_mensagens.text = (
			"\n".join(textos)
			if not textos.is_empty()
			else "Não foi possível analisar o código."
		)
		return

	var dados: Variant = resposta.get("dados", {})

	if not dados is Dictionary:
		_mensagens.text = "A resposta não contém dados válidos."
		return

	var acoes: Variant = dados.get("acoes", [])

	if not acoes is Array:
		_mensagens.text = "A resposta não contém uma lista de ações."
		return

	_mensagens.text = bancada.executar_acoes(acoes)
	
