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


func abrir(bancada: Bancada) -> void:
	if not is_instance_valid(bancada):
		return
	_interface_padrao_estava_visivel = _interface_padrao.visible
	_interface_padrao.hide()

	if is_instance_valid(_bancada_atual):
		fechar()

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
	if not is_instance_valid(_bancada_atual):
		return

	var codigo: String = _editor.text

	if codigo.strip_edges().is_empty():
		_mensagens.text = "Escreva um código antes de executar."
		return

	if not is_instance_valid(_bancada_atual.bau):
		_mensagens.text = "Esta bancada não tem um baú associado."
		return

	_ao_alterar_codigo()

	print("Código recebido da bancada:\n", codigo)
	execucao_solicitada.emit(_bancada_atual, codigo)

	# Etapa atual: capturar o código, sem executar o robô.
	_mensagens.text = "A execução do robô ainda não está disponível."
	
