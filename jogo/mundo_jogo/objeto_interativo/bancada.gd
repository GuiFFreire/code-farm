class_name Bancada
extends ObjetoBase

signal abertura_solicitada(bancada: Bancada)

@export var bau: Bau
@export_range(0, 5, 1) var id_canteiro: int = 0
@export var registro_plantio: RegistroPlantio
@export var deslocamento_parada_bau: Vector2 = Vector2(0, 26)
@export var deslocamento_parada_plantio: Vector2 = Vector2(0, 16)

var _executando: bool = false
var _versao_execucao: int = 0
var _robo_execucao: Robo
var codigo_digitado: String = ""
var _interacao: ComportamentoInterativo


func _ready() -> void:
	super._ready()

	_interacao = obter_comportamento(
		ComportamentoInterativo
	) as ComportamentoInterativo

	if _interacao == null:
		push_error("A bancada precisa de ComportamentoInterativo.")
		return

	add_to_group("Bancadas")
	_interacao.interagiu.connect(_ao_interagir)


func _ao_interagir() -> void:
	abertura_solicitada.emit(self)


func liberar_interacao() -> void:
	if _interacao != null:
		_interacao.liberar_interacao()
		
func executar_acoes(acoes: Array) -> String:
	if _executando:
		return "Esta bancada já está executando comandos."

	if not is_instance_valid(registro_plantio):
		return "Esta bancada não tem um registro de plantio associado."

	if not is_instance_valid(bau):
		return "Esta bancada não tem um baú associado."

	if acoes.is_empty():
		return "Nenhuma ação recebida."

	_robo_execucao = get_tree().get_first_node_in_group("Robo") as Robo

	if not is_instance_valid(_robo_execucao):
		return "O robô não está disponível no mundo."

	if not _robo_execucao.iniciar_trabalho(self):
		_robo_execucao = null
		return "O robô já está trabalhando em outra bancada."

	_executando = true
	_versao_execucao += 1
	var versao := _versao_execucao

	var resultado: String = await _executar_lista(acoes, versao)

	# Uma execução antiga não pode encerrar uma execução nova.
	if versao == _versao_execucao:
		cancelar_execucao()

	return resultado


func _executar_lista(acoes: Array, versao: int) -> String:
	var concluidas: int = 0

	for valor in acoes:
		if not _execucao_valida(versao):
			return "Execução cancelada. As ações já realizadas foram mantidas."

		if not valor is Dictionary:
			return "A API devolveu uma ação inválida."

		var acao: Dictionary = valor
		var tipo: String = str(acao.get("tipo", ""))
		var linha: int = int(acao.get("linha", -1))
		var coluna: int = int(acao.get("coluna", -1))
		var linha_codigo: int = int(acao.get("linha_codigo", 0))

		if tipo not in ["plantar", "regar", "colher"]:
			return "Ação desconhecida: %s." % tipo

		var espaco := registro_plantio.obter_espaco(
			id_canteiro, linha, coluna
		) as AreaPlantio

		if not is_instance_valid(espaco):
			return "Linha %d: esse espaço não existe." % linha_codigo

		# Para plantar, primeiro simula buscar a semente.
		if tipo == "plantar":
			var chegou_bau: bool = await _mover_robo(
				bau.global_position + deslocamento_parada_bau,
				versao
			)

			if not chegou_bau:
				return "Execução interrompida no caminho até o baú."

		if not _execucao_valida(versao) or not is_instance_valid(espaco):
			return "Execução cancelada."

		# Todos os comandos precisam chegar ao espaço.
		var chegou_espaco: bool = await _mover_robo(
			espaco.global_position + deslocamento_parada_plantio,
			versao
		)

		if not chegou_espaco:
			return "Execução interrompida no caminho até o canteiro."

		if not is_instance_valid(espaco):
			return "O espaço de plantio não está mais disponível."

		var erro: String = ""

		match tipo:
			"plantar":
				var cultura: String = str(acao.get("cultura", ""))
				var semente := _buscar_semente(cultura)

				if semente == null:
					erro = "Não há sementes de %s no baú." % cultura
				else:
					erro = espaco.plantar_semente(
						semente, bau.inventario_bau
					)

			"regar":
				erro = espaco.regar_por_codigo()

			"colher":
				erro = espaco.colher_por_codigo(
					bau.inventario_bau
				)

		if not erro.is_empty():
			return (
				"Linha %d: %s\nAções concluídas antes do erro: %d."
				% [linha_codigo, erro, concluidas]
			)

		# A ação já aconteceu. Na colheita, falta o retorno visual.
		concluidas += 1

		if tipo == "colher":
			var voltou: bool = await _mover_robo(
				bau.global_position + deslocamento_parada_bau,
				versao
			)

			if not voltou:
				return "Retorno interrompido. O produto já foi guardado no baú."

		# Pequena pausa para distinguir comandos no mesmo espaço.
		await get_tree().create_timer(0.35, false).timeout

		if not _execucao_valida(versao):
			return "Execução cancelada. As ações já realizadas foram mantidas."

	return "Execução concluída! Ações realizadas: %d." % concluidas


func _buscar_semente(cultura: String) -> Item:
	for pilha in bau.inventario_bau.slots:
		if pilha.item == null or pilha.quantidade <= 0:
			continue

		if (
			pilha.item.tipo == "semente"
			and pilha.item.nome == "semente_" + cultura
		):
			return pilha.item

	return null

func _execucao_valida(versao: int) -> bool:
	return (
		_executando
		and versao == _versao_execucao
		and is_instance_valid(_robo_execucao)
		and is_instance_valid(bau)
		and is_instance_valid(registro_plantio)
	)


func _mover_robo(destino: Vector2, versao: int) -> bool:
	if not _execucao_valida(versao):
		return false

	var chegou: bool = await _robo_execucao.ir_ate(destino, self)
	return chegou and _execucao_valida(versao)


func cancelar_execucao() -> void:
	_versao_execucao += 1
	_executando = false

	var robo := _robo_execucao
	_robo_execucao = null

	if is_instance_valid(robo):
		robo.finalizar_trabalho(self)


func _exit_tree() -> void:
	cancelar_execucao()
