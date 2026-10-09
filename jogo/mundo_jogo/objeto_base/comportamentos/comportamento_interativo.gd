class_name ComportamentoInterativo
extends ComportamentoObjeto

signal interagiu

@export var texto_interacao: String = "[E] para abrir":
	set(valor):
		texto_interacao = valor
		if is_instance_valid(_label):
			_label.text = valor
@export var ativo_ao_iniciar: bool = true

var _label: Label
var _detecao_ativa: bool = false
var _jogador_dentro: bool = false
var _interacao_em_execucao: bool = false

func nome_grupo() -> String:
	return "ObjetosInterativos"

func inicializar(objeto: ObjetoBase) -> void:
	_label = objeto.criar_label_interacao()
	_label.text = texto_interacao
	_detecao_ativa = ativo_ao_iniciar

func processar(objeto: ObjetoBase, _delta: float) -> void:
	if _detecao_ativa and _jogador_dentro and Input.is_action_just_pressed("interagir") and not _interacao_em_execucao and not interagiu.get_connections().is_empty():
		_label.hide()
		objeto.animador.play("RESET")
		_interacao_em_execucao = true
		emit_signal("interagiu")

func ao_detectar_entrada(objeto: ObjetoBase, corpo: Node2D) -> void:
	if _detecao_ativa and corpo.is_in_group("Jogador"):
		_label.show()
		objeto.animador.play("destacar_objeto")
		_jogador_dentro = true

func ao_detectar_saida(objeto: ObjetoBase, corpo: Node2D) -> void:
	if corpo.is_in_group("Jogador"):
		_label.hide()
		objeto.animador.play("RESET")
		_interacao_em_execucao = false
		_jogador_dentro = false

func ativar_interacao(objeto: ObjetoBase = null) -> void:
	_detecao_ativa = true
	_interacao_em_execucao = false
	if objeto != null:
		_jogador_dentro = false
		for corpo in objeto.get_node("AreaDetecao").get_overlapping_bodies():
			if corpo.is_in_group("Jogador"):
				ao_detectar_entrada(objeto, corpo)
	if is_instance_valid(_label):
		_label.visible = _jogador_dentro

func desativar_interacao() -> void:
	_detecao_ativa = false
	if is_instance_valid(_label):
		_label.hide()
