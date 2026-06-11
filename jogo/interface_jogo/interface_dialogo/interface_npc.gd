class_name InterfaceNPC

extends Control

@onready var _caixa_dialogo: Control = %CaixaDialogo
@onready var _painel_loja: PainelTroca = $PainelLoja

var foto
var personagem

func atualizar_personagem(novo_nome: String, caminho_foto: String) -> void:
	personagem = novo_nome
	foto = caminho_foto

func exibir_dialogo(texto: String) -> void: 
	await _caixa_dialogo.exibir_dialogo(texto, foto, personagem, _caixa_dialogo.TipoDeDialogo.DIALOGO)

func exibir_dialogo_com_escolhas(texto: String, escolhas: Array) -> int:
	return await _caixa_dialogo.exibir_dialogo_com_escolhas(texto, foto, personagem, escolhas)

func abrir_painel_loja(estoque_do_npc: EstoqueTroca) -> void:
	_painel_loja.abrir(estoque_do_npc)

func _ao_clicar_fechar_dialogo() -> void:
	hide()
	
	_caixa_dialogo.parar_som()
	
	_caixa_dialogo._limpar_botoes()
	
	if _painel_loja:
		_painel_loja.hide()
	
	Global.emit_signal("fim_dialogo_npc")
