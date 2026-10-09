class_name ComportamentoInterativo
extends ComportamentoObjeto

signal interagiu

@export var texto_interacao: String = "[E] para abrir":
	set(valor):
		texto_interacao = valor
		if is_instance_valid(_label):
			_label.text = valor
@export var ativo_ao_iniciar: bool = true

var _objeto: ObjetoBase
var _label: Label

var _detecao_ativa: bool = false
var _jogador_dentro: bool = false
var _interacao_em_execucao: bool = false


func nome_grupo() -> String:
	return "ObjetosInterativos"


func inicializar(objeto: ObjetoBase) -> void:
	_objeto = objeto
	_label = objeto.criar_label_interacao()
	_label.text = texto_interacao
	_label.hide()

	_detecao_ativa = ativo_ao_iniciar

<<<<<<< HEAD
func processar(objeto: ObjetoBase, _delta: float) -> void:
	if _detecao_ativa and _jogador_dentro and Input.is_action_just_pressed("interagir") and not _interacao_em_execucao and not interagiu.get_connections().is_empty():
		_label.hide()
		objeto.animador.play("RESET")
		_interacao_em_execucao = true
		emit_signal("interagiu")
=======
>>>>>>> feature/reuniao_09_10

func pode_interagir() -> bool:
	return (
		is_instance_valid(_objeto)
		and _detecao_ativa
		and _jogador_dentro
		and not _interacao_em_execucao
	)


func definir_selecionado(selecionado: bool) -> void:
	if not is_instance_valid(_label):
		return

	_label.visible = selecionado and pode_interagir()

	if _label.visible:
		_tocar_animacao("destacar_objeto")
	else:
		_tocar_animacao("RESET")


func executar_interacao() -> void:
	if not pode_interagir():
		return

	_interacao_em_execucao = true
	definir_selecionado(false)
	interagiu.emit()


func ao_detectar_entrada(
	_objeto_ref: ObjetoBase,
	corpo: Node2D
) -> void:
	if corpo.is_in_group("Jogador"):
		_jogador_dentro = true

<<<<<<< HEAD
func ao_detectar_saida(objeto: ObjetoBase, corpo: Node2D) -> void:
	if corpo.is_in_group("Jogador"):
		_label.hide()
		objeto.animador.play("RESET")
		_interacao_em_execucao = false
=======

func ao_detectar_saida(
	_objeto_ref: ObjetoBase,
	corpo: Node2D
) -> void:
	if corpo.is_in_group("Jogador"):
>>>>>>> feature/reuniao_09_10
		_jogador_dentro = false
		_interacao_em_execucao = false
		definir_selecionado(false)


func ativar_interacao(objeto: ObjetoBase = null) -> void:
	_detecao_ativa = true
	_interacao_em_execucao = false
<<<<<<< HEAD
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
=======


func desativar_interacao() -> void:
	_detecao_ativa = false
	definir_selecionado(false)


func liberar_interacao() -> void:
	_interacao_em_execucao = false


func _tocar_animacao(nome: String) -> void:
	if not is_instance_valid(_objeto):
		return

	if _objeto.animador.has_animation(nome):
		_objeto.animador.play(nome)
>>>>>>> feature/reuniao_09_10
