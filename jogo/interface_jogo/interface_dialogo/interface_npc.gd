class_name InterfaceNPC

extends Control

@onready var _caixa_dialogo: Control = %CaixaDialogo
@onready var _painel_troca: PainelTroca = $PainelTroca
@onready var _botao_fechar: Control = $Fechar

var foto
var personagem

func atualizar_personagem(novo_nome: String, caminho_foto: String) -> void:
	personagem = novo_nome
	foto = caminho_foto

func exibir_dialogo(texto: String) -> void: 
	_caixa_dialogo.show()
	await _caixa_dialogo.exibir_dialogo(texto, foto, personagem, _caixa_dialogo.TipoDeDialogo.DIALOGO)

func exibir_dialogo_com_escolhas(texto: String, escolhas: Array) -> int:
	return await _caixa_dialogo.exibir_dialogo_com_escolhas(texto, foto, personagem, escolhas)

func abrir_painel_troca(estoque_do_npc: EstoqueTroca) -> void:
	_caixa_dialogo.hide()
	_botao_fechar.global_position.x = 145
	_painel_troca.abrir(estoque_do_npc)

func _ao_clicar_fechar_dialogo() -> void:
	hide()
	
	_caixa_dialogo.parar_som()
	
	_caixa_dialogo._limpar_botoes()
	
	if _painel_troca:
		_painel_troca.hide()
		_botao_fechar.global_position.x = 0
	
	Global.emit_signal("fim_dialogo_npc")
