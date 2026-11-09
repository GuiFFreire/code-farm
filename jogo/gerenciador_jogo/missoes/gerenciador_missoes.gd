class_name GerenciadorMissoes
extends Node

var mundo_jogo: MundoJogo
var interface_jogo: InterfaceJogo

var _objeto_missao_atual: Node2D
var _roteiro_missao_atual: RoteiroMissao


func configurar(
	mundo_jogo_ref: MundoJogo,
	interface_jogo_ref: InterfaceJogo
) -> void:
	mundo_jogo = mundo_jogo_ref
	interface_jogo = interface_jogo_ref

	Global.conectar_sinal(
		Global,
		"missao_fechada",
		Callable(self, "_ao_fechar_missao")
	)

	Global.conectar_sinal(
		Global,
		"missao_concluida",
		Callable(self, "_concluir_missao_atual")
	)


func executar() -> void:
	if (
		Global.missao_atual == 1
		and Global.progresso_missoes.get("missao1", 0) > 0
	):
		_ao_interagir_objeto()
		return

	_ativar_objeto_missao_atual()


func _ativar_objeto_missao_atual() -> void:
	_definir_interacao(false)
	_objeto_missao_atual = null

	if Global.concluiu_todas_missoes():
		print("Parabéns! Você concluiu todas as missões!")
		return

	var nome_objeto := "Missao%d" % Global.missao_atual
	_objeto_missao_atual = mundo_jogo.obter_elemento(nome_objeto)

	if not is_instance_valid(_objeto_missao_atual):
		push_warning("Objeto de missão não encontrado: " + nome_objeto)
		return

	if _objeto_missao_atual.has_method("obter_comportamento"):
		var comp = _objeto_missao_atual.obter_comportamento(
			ComportamentoInterativo
		)

		if comp:
			Global.conectar_sinal(
				comp,
				"interagiu",
				Callable(self, "_ao_interagir_objeto")
			)

	elif _objeto_missao_atual.has_signal("interagiu"):
		Global.conectar_sinal(
			_objeto_missao_atual,
			"interagiu",
			Callable(self, "_ao_interagir_objeto")
		)

	_definir_interacao(true)
	_carregar_roteiro()


func _definir_interacao(ativa: bool) -> void:
	if not is_instance_valid(_objeto_missao_atual):
		return

	if _objeto_missao_atual.has_method("obter_comportamento"):
		var comp = _objeto_missao_atual.obter_comportamento(
			ComportamentoInterativo
		)

		if comp:
			if ativa:
				comp.ativar_interacao(_objeto_missao_atual)
			else:
				comp.desativar_interacao()

	elif ativa and _objeto_missao_atual.has_method("ativar_interacao"):
		_objeto_missao_atual.ativar_interacao()

	elif not ativa and _objeto_missao_atual.has_method("desativar_interacao"):
		_objeto_missao_atual.desativar_interacao()


func _carregar_roteiro() -> void:
	if is_instance_valid(_roteiro_missao_atual):
		return

	var caminho := (
		"res://gerenciador_jogo/missoes/roteiros/missao%d.gd"
		% Global.missao_atual
	)

	_roteiro_missao_atual = load(caminho).new()
	_roteiro_missao_atual.configurar(mundo_jogo, interface_jogo)

	# O roteiro acompanha o ciclo de vida do mundo.
	mundo_jogo.add_child(_roteiro_missao_atual)

	_roteiro_missao_atual.preparar()


func _ao_interagir_objeto() -> void:
	if Global.retomando_missao:
		return

	_carregar_roteiro()

	if not is_instance_valid(_roteiro_missao_atual):
		return

	_definir_interacao(false)

	mundo_jogo.obter_jogador().desativar_movimento()
	interface_jogo.exibir_interface(InterfaceJogo.Interface.MISSAO)

	_roteiro_missao_atual.executar()


func _concluir_missao_atual() -> void:
	_definir_interacao(false)
	_descartar_roteiro()

	Global.missao_atual += 1

	var jogador := mundo_jogo.obter_jogador()
	Global.salvar_jogo(
		0,
		jogador.global_position,
		jogador.obter_moedas()
	)

	interface_jogo.exibir_interface(InterfaceJogo.Interface.PADRAO)
	jogador.ativar_movimento()

	_ativar_objeto_missao_atual()


func _ao_fechar_missao() -> void:
	if (
		is_instance_valid(_roteiro_missao_atual)
		and _roteiro_missao_atual.manter_ativo_ao_fechar()
	):
		return

	_descartar_roteiro()
	_definir_interacao(true)


func _descartar_roteiro() -> void:
	if is_instance_valid(_roteiro_missao_atual):
		_roteiro_missao_atual.queue_free()

	_roteiro_missao_atual = null


func reiniciar() -> void:
	_descartar_roteiro()
	_objeto_missao_atual = null
