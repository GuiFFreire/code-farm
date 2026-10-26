extends RoteiroMissao

const CHAVE_ETAPA := "missao3_etapa"
const CHAVE_PONTO := "missao3_proximo_ponto"
const CHAVE_PLANTIO := "missao3_plantio"

const ETAPAS_PENNY := [
	"apresentacao",
	"caminho_fazenda",
	"aguardando_travessia",
	"caminho_vila",
	"porta_salao",
	"aguardando_entrada_salao"
]

var _penny: Penny
var _chegada_vila: Marker2D

var _rota_fazenda: Array[Marker2D] = []
var _rota_vila: Array[Marker2D] = []

var _robo: Robo
var _bancada: Bancada
var _dados_plantio: Dictionary = {}

var _pronta: bool = false
var _plantio_preparado: bool = false

var _dialogando: bool = false
var _cancelou_dialogo: bool = false
var _avaliacao_agendada: bool = false


func manter_ativo_ao_fechar() -> bool:
	return true


func preparar() -> void:
	_penny = mundo_jogo.obter_elemento("Missao3") as Penny

	_chegada_vila = mundo_jogo.obter_elemento(
		"chegadaVilla"
	) as Marker2D

	var ponto4 := mundo_jogo.obter_elemento(
		"passo4"
	) as Marker2D

	var ponto5 := mundo_jogo.obter_elemento(
		"passo5"
	) as Marker2D

	if (
		not is_instance_valid(_penny)
		or not is_instance_valid(_chegada_vila)
		or not is_instance_valid(ponto4)
		or not is_instance_valid(ponto5)
	):
		push_error(
			"Missão 3: confira Penny e os marcadores da vila."
		)
		return

	if _penny.pontos_rota.is_empty():
		push_error(
			"Missão 3: configure a rota da fazenda."
		)
		return

	_rota_fazenda.assign(_penny.pontos_rota)
	_rota_vila.assign([ponto4, ponto5])

	_penny.percurso_concluido.connect(
		_ao_concluir_percurso
	)

	_penny.ponto_rota_alcancado.connect(
		_ao_alcancar_ponto
	)

	mundo_jogo.jogador_mudou_terreno.connect(
		_ao_jogador_mudar_terreno
	)

	Global.missao_fechada.connect(
		_ao_fechar_dialogo
	)

	_pronta = true

	# Compatibilidade com o progresso anterior da Penny.
	# Não reinicia um tutorial de plantio já iniciado.
	if (
		Global.progresso_missoes.get(
			"penny_entrou_salao", false
		)
		and _etapa() in ETAPAS_PENNY
	):
		_definir_etapa("comprar_sementes")

	# Também considera um save carregado em outro terreno.
	_ao_jogador_mudar_terreno(
		mundo_jogo.obter_jogador().terreno_atual
	)

	_restaurar_etapa()
	_preparar_plantio()


func _etapa() -> String:
	return Global.progresso_missoes.get(
		CHAVE_ETAPA,
		"apresentacao"
	)


func _definir_etapa(etapa: String) -> void:
	Global.progresso_missoes[CHAVE_ETAPA] = etapa
	Global.progresso_missoes[CHAVE_PONTO] = 0


func _restaurar_etapa() -> void:
	match _etapa():
		"apresentacao":
			_penny.mostrar_penny()
			_penny.terreno_atual = "TerrenoFazenda"

			if Global.progresso_missoes.get(
				"penny_chegou_inicio", false
			):
				_penny.ativar_interacao()
			else:
				_penny.caminhar_ate(
					_rota_fazenda[0].global_position,
					false
				)

		"caminho_fazenda":
			_iniciar_rota(
				_rota_fazenda,
				"TerrenoFazenda"
			)

		"aguardando_travessia":
			_penny.mostrar_penny()
			_penny.terreno_atual = "TerrenoFazenda"
			_penny.ativar_interacao()

		"caminho_vila":
			_iniciar_rota(
				_rota_vila,
				"TerrenoVila"
			)

		"porta_salao", "aguardando_entrada_salao":
			_penny.mostrar_penny()
			_penny.terreno_atual = "TerrenoVila"
			_penny.ativar_interacao()

		"comprar_sementes", "tutorial_plantio":
			_penny.ocultar_penny()


func executar() -> void:
	if not _pronta:
		_liberar_jogador()
		return

	if _dialogando:
		return

	match _etapa():
		"apresentacao":
			var apresentou: bool = await _falar([
				"Olá! Você deve ser %s. Sou a Penny, trabalho na loja da vila."
				% Global.nome_jogador,

				"Então esta é a %s! Seu avô tinha muito carinho por este lugar."
				% Global.nome_fazenda_atual,

				"Que tal começar plantando morangos? Na loja onde trabalho, o corvo vende as sementes por 10 moedas cada.",

				"Venha comigo! Vamos pela saída ao sul da fazenda. Se você ficar para trás, eu espero."
			])

			if apresentou:
				_definir_etapa("caminho_fazenda")

				_iniciar_rota(
					_rota_fazenda,
					"TerrenoFazenda"
				)

				_salvar()

		"caminho_fazenda":
			var continuar: bool = await _falar([
				"Vamos continuar até a saída ao sul da fazenda!"
			])

			if continuar:
				_iniciar_rota(
					_rota_fazenda,
					"TerrenoFazenda"
				)

		"aguardando_travessia":
			await _falar([
				"É por aqui! Atravesse a passagem para chegarmos à vila."
			])

		"caminho_vila":
			var continuar: bool = await _falar([
				"A loja fica dentro do salão. Vamos continuar!"
			])

			if continuar:
				_iniciar_rota(
					_rota_vila,
					"TerrenoVila"
				)

		"porta_salao", "aguardando_entrada_salao":
			var conversou: bool = await _falar([
				"Chegamos! A loja fica dentro deste salão.",

				"Lá dentro você encontrará o corvo. Converse com ele e escolha Mostrar mercadoria para comprar suas sementes de morango.",

				"Depois da compra, volte para sua fazenda. O AGR.O poderá ajudar você a plantar!"
			])

			if conversou:
				_definir_etapa(
					"aguardando_entrada_salao"
				)
				_salvar()

		_:
			_liberar_jogador()


# --------------------------------------------------
# Percurso da Penny
# --------------------------------------------------

func _iniciar_rota(
	rota: Array[Marker2D],
	terreno: String
) -> void:
	_penny.mostrar_penny()
	_penny.terreno_atual = terreno
	_penny.pontos_rota.assign(rota)

	var proximo_ponto: int = Global.progresso_missoes.get(
		CHAVE_PONTO,
		0
	)

	_penny.iniciar_percurso(true, proximo_ponto)


func _ao_alcancar_ponto(proximo_indice: int) -> void:
	if _etapa() in ["caminho_fazenda", "caminho_vila"]:
		Global.progresso_missoes[CHAVE_PONTO] = proximo_indice


func _ao_concluir_percurso() -> void:
	if Global.missao_atual != 3:
		return

	match _etapa():
		"apresentacao":
			Global.progresso_missoes[
				"penny_chegou_inicio"
			] = true

		"caminho_fazenda":
			_definir_etapa("aguardando_travessia")

		"caminho_vila":
			_definir_etapa("porta_salao")
			_tentar_dialogo_porta.call_deferred()

	_salvar()


func _tentar_dialogo_porta() -> void:
	var jogador := mundo_jogo.obter_jogador()

	if (
		_etapa() == "porta_salao"
		and jogador.terreno_atual == "TerrenoVila"
		and jogador.pode_interagir()
		and not _dialogando
	):
		executar()


func _ao_jogador_mudar_terreno(
	terreno_destino: String
) -> void:
	if not _pronta or Global.missao_atual != 3:
		return

	var etapa: String = _etapa()

	if (
		terreno_destino == "TerrenoVila"
		and etapa in [
			"caminho_fazenda",
			"aguardando_travessia"
		]
	):
		_definir_etapa("caminho_vila")

		_penny.mostrar_penny()
		_penny.atravessar_para(
			_chegada_vila,
			"TerrenoVila",
			_rota_vila
		)

		_salvar()

	elif (
		terreno_destino == "TerrenoFazenda"
		and etapa in [
			"caminho_vila",
			"porta_salao",
			"aguardando_entrada_salao"
		]
	):
		var ultimo_ponto: Marker2D = _rota_fazenda.back()

		_penny.parar()
		_penny.global_position = ultimo_ponto.global_position
		_penny.terreno_atual = "TerrenoFazenda"

		_definir_etapa("aguardando_travessia")

		_penny.mostrar_penny()
		_penny.ativar_interacao()

		_salvar()

	elif (
		terreno_destino == "TerrenoSalao"
		and etapa in [
			"caminho_vila",
			"porta_salao",
			"aguardando_entrada_salao"
		]
	):
		Global.progresso_missoes[
			"penny_entrou_salao"
		] = true

		_definir_etapa("comprar_sementes")

		_penny.ocultar_penny()
		_salvar()

	_agendar_avaliacao_plantio()


# --------------------------------------------------
# Preparação do tutorial de plantio
# --------------------------------------------------

func _preparar_plantio() -> void:
	_robo = mundo_jogo.get_tree().get_first_node_in_group(
		"Robo"
	) as Robo

	_bancada = mundo_jogo.obter_elemento(
		"bancada"
	) as Bancada

	if (
		not is_instance_valid(_robo)
		or not is_instance_valid(_bancada)
	):
		push_error(
			"Missão 3: robô ou bancada não encontrados."
		)
		return

	if not is_instance_valid(_bancada.bau):
		push_error(
			"Missão 3: configure o baú associado à bancada."
		)
		return

	_dados_plantio = {
		"bau_explicado": false,
		"funcoes_explicadas": false,
		"rega_explicada": false,
		"colheita_explicada": false,
		"bancada_aberta": false,
		"plantou": false,
		"pronto": false,
		"colheu": false,
		"cultivos": {},
		"linha": 0,
		"coluna": 0,
		"finalizada": false
	}

	var dados_salvos: Variant = Global.progresso_missoes.get(
		CHAVE_PLANTIO,
		{}
	)

	if dados_salvos is Dictionary:
		_dados_plantio.merge(dados_salvos, true)

	Global.progresso_missoes[
		CHAVE_PLANTIO
	] = _dados_plantio

	Global.item_modificado.connect(
		_ao_modificar_item
	)

	_bancada.abertura_solicitada.connect(
		_ao_abrir_bancada
	)

	_bancada.acao_executada.connect(
		_ao_executar_acao_plantio
	)

	_robo.conversa_solicitada.connect(
		_ao_solicitar_conversa_robo
	)

	_plantio_preparado = true

	if _dados_plantio["finalizada"]:
		_concluir_tutorial_salvo.call_deferred()
	else:
		_agendar_avaliacao_plantio()


func _plantio_ativo() -> bool:
	return (
		_pronta
		and _plantio_preparado
		and Global.missao_atual == 3
		and _etapa() in [
			"comprar_sementes",
			"tutorial_plantio"
		]
		and is_instance_valid(_robo)
		and is_instance_valid(_bancada)
		and is_instance_valid(_bancada.bau)
	)


func _tem_semente(inventario: Inventario) -> bool:
	if inventario == null:
		return false

	for pilha in inventario.slots:
		if (
			pilha.item != null
			and pilha.quantidade > 0
			and pilha.item.nome == "semente_morango"
		):
			return true

	return false


func _etapa_plantio() -> String:
	var semente_jogador: bool = _tem_semente(
		Global.inventario
	)

	var semente_bau: bool = _tem_semente(
		_bancada.bau.inventario_bau
	)

	if not _dados_plantio["bau_explicado"]:
		if (
			semente_jogador
			or semente_bau
			or _dados_plantio["plantou"]
		):
			return "explicar_bau"

		return "aguardar_semente"

	if not _dados_plantio["funcoes_explicadas"]:
		if semente_bau or _dados_plantio["plantou"]:
			return "explicar_funcoes"

		return "guardar_semente"

	if not _dados_plantio["bancada_aberta"]:
		return "abrir_bancada"

	if not _dados_plantio["plantou"]:
		return "plantar"

	if not _dados_plantio["rega_explicada"]:
		return "explicar_rega"

	if not _dados_plantio["pronto"]:
		return "regar"

	if not _dados_plantio["colheita_explicada"]:
		return "explicar_colheita"

	if not _dados_plantio["colheu"]:
		return "colher"

	return "concluir"


func _agendar_avaliacao_plantio() -> void:
	if not _plantio_preparado or _avaliacao_agendada:
		return

	_avaliacao_agendada = true
	_avaliar_plantio.call_deferred()


func _avaliar_plantio() -> void:
	_avaliacao_agendada = false

	if not is_instance_valid(_robo):
		return

	if not _plantio_ativo():
		_robo.liberar_conversa(self)
		return

	if _dados_plantio["finalizada"]:
		_robo.liberar_conversa(self)
		return

	if _dialogando:
		return

	var jogador := mundo_jogo.obter_jogador()

	if (
		jogador.terreno_atual != "TerrenoFazenda"
		or _etapa_plantio() == "aguardar_semente"
	):
		_robo.liberar_conversa(self)
		return

	if _etapa() != "tutorial_plantio":
		_definir_etapa("tutorial_plantio")
		_salvar()

	_robo.oferecer_conversa(
		self,
		"orientações de plantio"
	)


# --------------------------------------------------
# Eventos do inventário e da bancada
# --------------------------------------------------

func _ao_modificar_item(_pilha: PilhaItens) -> void:
	# A avaliação acontece depois que a transferência
	# termina de atualizar os inventários.
	_agendar_avaliacao_plantio()


func _ao_abrir_bancada(_bancada_aberta: Bancada) -> void:
	if not _plantio_ativo():
		return

	_dados_plantio["bancada_aberta"] = true

	_salvar()
	_agendar_avaliacao_plantio()


func _ao_executar_acao_plantio(acao: Dictionary) -> void:
	if not _plantio_ativo():
		return

	var tipo: String = str(acao.get("tipo", ""))
	var linha: int = int(acao.get("linha", -1))
	var coluna: int = int(acao.get("coluna", -1))

	var chave: String = "%d:%d" % [linha, coluna]
	var cultivos: Dictionary = _dados_plantio["cultivos"]

	match tipo:
		"plantar":
			if str(acao.get("cultura", "")) != "morango":
				return

			cultivos[chave] = {
				"regas": 0
			}

			_dados_plantio["plantou"] = true

		"regar":
			if not cultivos.has(chave):
				return

			var cultivo: Dictionary = cultivos[chave]
			cultivo["regas"] = int(
				cultivo.get("regas", 0)
			) + 1

			cultivos[chave] = cultivo

			var estado: Dictionary = acao.get(
				"estado_plantio",
				{}
			)

			if int(estado.get("estado", -1)) == (
				AreaPlantio.ESTADO.PRONTO
			):
				_dados_plantio["pronto"] = true

		"colher":
			if not cultivos.has(chave):
				return

			var cultivo: Dictionary = cultivos[chave]

			# A colheita precisa pertencer a um cultivo
			# plantado e regado pelo robô.
			if int(cultivo.get("regas", 0)) <= 0:
				return

			_dados_plantio["pronto"] = true
			_dados_plantio["colheu"] = true

			cultivos.erase(chave)

		_:
			return

	_dados_plantio["cultivos"] = cultivos
	_dados_plantio["linha"] = linha
	_dados_plantio["coluna"] = coluna

	_salvar()
	_agendar_avaliacao_plantio()


# --------------------------------------------------
# Conversas do robô
# --------------------------------------------------

func _ao_solicitar_conversa_robo() -> void:
	if not _plantio_ativo() or _dialogando:
		return

	if _dados_plantio["finalizada"]:
		return

	var jogador := mundo_jogo.obter_jogador()

	if (
		jogador.terreno_atual != "TerrenoFazenda"
		or not jogador.pode_interagir()
	):
		return

	var etapa: String = _etapa_plantio()
	var falas: Array = _falas_plantio(etapa)

	if falas.is_empty():
		return

	var terminou: bool = await _falar(falas, true)

	if not terminou:
		_agendar_avaliacao_plantio()
		return

	match etapa:
		"explicar_bau":
			_dados_plantio["bau_explicado"] = true

		"explicar_funcoes":
			_dados_plantio["funcoes_explicadas"] = true

		"explicar_rega":
			_dados_plantio["rega_explicada"] = true

		"explicar_colheita":
			_dados_plantio["colheita_explicada"] = true

		"concluir":
			_dados_plantio["finalizada"] = true
			_robo.liberar_conversa(self)

			_salvar()
			concluir_missao()
			return

	_salvar()
	_agendar_avaliacao_plantio()


func _falas_plantio(etapa: String) -> Array:
	var linha: int = int(_dados_plantio["linha"])
	var coluna: int = int(_dados_plantio["coluna"])

	var comando_plantar: String = 'plantar("morango", 0, 0)'

	var comando_regar: String = "regar(%d, %d)" % [
		linha,
		coluna
	]

	var comando_colher: String = "colher(%d, %d)" % [
		linha,
		coluna
	]

	match etapa:
		"explicar_bau":
			var introducao: String = (
				"Você trouxe sementes de morango! Posso ajudar no plantio."
			)

			if _tem_semente(_bancada.bau.inventario_bau):
				introducao = (
					"Vejo que você já colocou sementes no baú. Vamos aprender a plantar comigo!"
				)

			return [
				introducao,

				"Para trabalhar pela bancada, eu utilizo as sementes do baú associado a ela.",

				"As sementes no seu inventário servem para o plantio manual. Para eu plantar, coloque-as nesse baú.",

				"Aproxime-se do baú, pressione E e transfira as sementes para ele.",

				"Enquanto aprendemos, E abre minhas orientações. Se quiser que eu siga você ou pare, use Shift+E.",

				"Depois de guardar as sementes, feche o baú e converse comigo novamente."
			]

		"guardar_semente":
			return [
				"Ainda precisamos colocar uma semente de morango no baú associado à bancada.",

				"Abra o baú com E e transfira a semente do seu inventário para ele.",

				"Se estiver sem sementes, você pode comprar mais com o corvo na loja.",

				"Depois, feche o baú e converse comigo."
			]

		"explicar_funcoes":
			return [
				"Agora temos sementes disponíveis! O próximo passo é usar a bancada para me dar instruções.",

				"Você já utilizou print(). Ele é um exemplo de função.",

				"Uma função reúne instruções para realizar uma tarefa. Para chamar uma função, escrevemos seu nome seguido de parênteses.",

				"Os valores dentro dos parênteses são chamados de argumentos. Eles informam os detalhes necessários para a tarefa.",

				"No nosso sistema, as funções plantar(), regar() e colher() já estão disponíveis. Você vai chamá-las para controlar meu trabalho.",

				"Vamos começar com este exemplo:",

				{"codigo": comando_plantar},

				"morango informa o que será plantado. O primeiro zero indica a linha e o segundo indica a coluna do espaço no canteiro da bancada.",

				"A contagem começa em zero. Neste canteiro, as linhas vão de 0 a 4 e as colunas de 0 a 1.",
				
				"Você também pode consultar essas explicações no glossário. Lá estão as funções, os argumentos, as coordenadas e as orientações sobre o baú e a bancada. Use o botão de glossário da bancada sempre que precisar!",
				
				"Abra a bancada com E, escreva o comando e execute. Ele utiliza uma semente do baú.",

				"Escolha um espaço vazio. Se a posição 0, 0 estiver ocupada, use outra linha ou coluna.",

				"Depois que eu plantar, feche a bancada e converse comigo novamente."
			]

		"abrir_bancada", "plantar":
			return [
				"Abra a bancada com E e execute uma chamada da função plantar().",

				{"codigo": comando_plantar},

				"Esse exemplo planta morango na linha 0 e coluna 0. Você pode escolher outro espaço vazio do canteiro.",

				"Lembre-se de manter uma semente de morango no baú associado à bancada.",

				"Depois do plantio, feche a bancada e converse comigo."
			]

		"explicar_rega":
			var regas: PackedStringArray = []

			for indice in range(5):
				regas.append(comando_regar)

			return [
				"Plantio realizado! Agora vamos aprender a regar.",

				"A função regar() recebe a linha e a coluna da planta que deve receber água.",

				"Para o espaço que você utilizou, a chamada é:",

				{"codigo": comando_regar},

				"No sistema atual, cada chamada faz o morango avançar uma etapa do crescimento. Desde o plantio, são cinco chamadas para chegar à colheita.",

				"Se ainda não regou essa planta, pode executar estas cinco chamadas:",

				{"codigo": "\n".join(regas)},

				"Apague o comando plantar() antes de executar a rega. Executá-lo novamente na mesma posição tentaria plantar em um espaço ocupado.",

				"Se já executou algumas regas, faça apenas as que faltam. Quando a planta estiver pronta, o sistema avisará se você tentar regar novamente.",

				"Quando terminar, feche a bancada e converse comigo."
			]

		"regar":
			return [
				"A planta ainda precisa crescer. Use regar() na posição em que ela foi plantada.",

				{"codigo": comando_regar},

				"Você pode repetir a chamada em linhas diferentes para executar várias regas.",

				"Quando o morango estiver pronto para colher, feche a bancada e converse comigo."
			]

		"explicar_colheita":
			return [
				"O morango ficou pronto! Agora vamos usar a função colher().",

				"Assim como regar(), colher() recebe a linha e a coluna do espaço.",

				{"codigo": comando_colher},

				"Substitua os comandos anteriores por essa chamada e execute na bancada.",

				"Eu recolherei o morango e ele será guardado no baú associado à bancada.",

				"Depois da colheita, feche a bancada e converse comigo."
			]

		"colher":
			return [
				"Agora execute colher() na posição do morango que você plantou e regou comigo.",

				{"codigo": comando_colher},

				"A planta precisa estar pronta para a colheita. O produto será guardado no baú.",

				"Depois, feche a bancada e volte a conversar comigo."
			]

		"concluir":
			return [
				"Você conseguiu! Plantou, regou e colheu um morango usando funções para orientar meu trabalho.",

				"O morango colhido foi guardado no baú. Você pode repetir esse processo em outros espaços do canteiro.",

				"Agora que terminamos o tutorial, E volta a servir para me fazer seguir você ou parar.",
				
				"Se esquecer algum comando, consulte o glossário! As explicações e os exemplos de plantar(), regar() e colher() continuam disponíveis para você.",
			]

	return []


func _concluir_tutorial_salvo() -> void:
	if (
		_plantio_ativo()
		and _dados_plantio.get("finalizada", false)
	):
		_robo.liberar_conversa(self)
		concluir_missao()


# --------------------------------------------------
# Diálogo compartilhado entre Penny e robô
# --------------------------------------------------

func _falar(
	falas: Array,
	pelo_robo: bool = false
) -> bool:
	if _dialogando:
		return false

	if pelo_robo:
		if not is_instance_valid(_robo):
			return false

		# Reserva o robô durante a conversa.
		# Isso impede deslocamentos ou outros trabalhos.
		if not _robo.iniciar_trabalho(self):
			return false

		_robo.liberar_conversa(self)

		configurar_personagem(
			Global.nome_robo,
			Global.foto_robo
		)
	else:
		_penny.desativar_interacao()

		configurar_personagem(
			_penny.nome,
			_penny.foto
		)

	_dialogando = true
	_cancelou_dialogo = false

	mundo_jogo.obter_jogador().desativar_movimento()

	interface_jogo.exibir_interface(
		InterfaceJogo.Interface.MISSAO
	)

	_interface_missao.definir_editor_visivel(false)

	for fala in falas:
		if fala is Dictionary:
			var trecho: Dictionary = fala
			await codigo(str(trecho.get("codigo", "")))
		else:
			await dialogo(str(fala))

		if _cancelou_dialogo:
			_encerrar_dialogo(pelo_robo)
			return false

	_encerrar_dialogo(pelo_robo)
	return true


func _encerrar_dialogo(pelo_robo: bool) -> void:
	_dialogando = false

	_interface_missao.definir_editor_visivel(true)
	_liberar_jogador()

	if pelo_robo:
		if is_instance_valid(_robo):
			_robo.finalizar_trabalho(self)
	else:
		if is_instance_valid(_penny) and _penny.visible:
			_penny.ativar_interacao()

	_agendar_avaliacao_plantio()


func _ao_fechar_dialogo() -> void:
	if _dialogando:
		_cancelou_dialogo = true


func _liberar_jogador() -> void:
	interface_jogo.exibir_interface(
		InterfaceJogo.Interface.PADRAO
	)

	mundo_jogo.obter_jogador().ativar_movimento()


func _salvar() -> void:
	var jogador := mundo_jogo.obter_jogador()

	Global.salvar_jogo(
		0,
		jogador.global_position,
		jogador.obter_moedas()
	)


func _exit_tree() -> void:
	if is_instance_valid(_robo):
		_robo.liberar_conversa(self)
		_robo.finalizar_trabalho(self)
