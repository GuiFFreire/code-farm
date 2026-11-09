class_name Glossario

extends Resource

var _termos_disponiveis: Dictionary = {
	"print()": {
		"nome": "Função print()",
		"descricao": "A função print() é usada para exibir mensagens na tela (console). Ela é muito útil para mostrar resultados, textos ou acompanhar a execução do programa.",
		"tipo":"Exemplo:",
		"exemplo": "print(\"Olá, mundo!\")",
		"missao": 1
	},
	"#": {
		"nome": "# Comentários",
		"descricao": "Em Python, tudo que vem após o símbolo # em uma linha é ignorado pelo programa. Isso serve para deixar anotações no código, facilitando o entendimento.",
		"tipo":"Exemplo:",
		"exemplo": "# Isso é um comentário explicativo",
		"missao": 10
	},
	'"""': {
		"nome": '""" Comentários """',
		"descricao": "Usa-se três aspas duplas para escrever comentários que ocupam várias linhas. Eles são úteis para explicar melhor o funcionamento do código ou escrever descrições longas.",
		"tipo":"Exemplo:",
		"exemplo": "\"\"\"\nEste código faz parte do jogo Code Farm.\nEle ajuda a organizar e explicar o código faz.\n\"\"\"",
		"missao": 10
	},
	"variáveis": {
		"nome": "Variáveis",
		"descricao": "Variáveis são usadas para armazenar informações. Elas recebem um nome e podem guardar textos, números, listas e outros valores que podem mudar durante a execução do programa.",
		"tipo":"Exemplo:",
		"exemplo": "nomeFazenda = \"Fazenda Girassol\"\nprint(nomeFazenda)",
		"missao": 2
	},
		"missao_3": {
		"nome": "Primeiros cultivos",
		"descricao": "Penny apresentou a loja da vila, onde o corvo vende sementes. Na fazenda, o AGR.O ensina a utilizar a bancada e chamar funções para cuidar do plantio.",
		"tipo": "Tarefas:",
		"exemplo": "1. Acompanhe Penny até o salão.\n2. Compre sementes de morango com o corvo.\n3. Volte à fazenda e converse com o AGR.O.\n4. Guarde as sementes no baú da bancada.\n5. Utilize plantar(), regar() e colher().\n6. Converse com o AGR.O após a colheita.",
		"missao": 3
	},
	"for": {
		"nome": "Laço for",
		"descricao": "O laço for é usado para repetir uma ação várias vezes. Com ele, você pode executar um bloco de código para cada valor dentro de uma sequência ou intervalo.",
		"tipo":"Exemplo:",
		"exemplo": "for i in range(5):\n\tprint(\"Repetição número\", i)",
		"missao": 10
	},
	"if": {
		"nome": "Condicional if",
		"descricao": "O comando if é usado para executar uma parte do código somente se uma condição for verdadeira.",
		"tipo":"Exemplo:",
		"exemplo": "if copo == \"água\":\n\tprint(\"É água mesmo!\")",
		"missao": 10
	},
	"elif": {
		"nome": "Condicional elif",
		"descricao": "elif é a abreviação de 'else if'. Ele permite testar uma nova condição se a anterior (if) for falsa.",
		"tipo":"Exemplo:",
		"exemplo": "elif copo == \"suco\":\n\tprint(\"É suco!\")",
		"missao": 10
	},
	"else": {
		"nome": "Condicional else",
		"descricao": "O else é usado quando nenhuma das condições anteriores (if ou elif) foi verdadeira. Ele executa um código alternativo.",
		"tipo":"Exemplo:",
		"exemplo": "else:\n\tprint(\"Não sei o que tem nesse copo!\")",
		"missao": 10
	},
}

# --- DADOS DAS MISSÕES (NOVO) ---

var _missoes_disponiveis: Dictionary = {
	"missao_0": {
		"nome": "O Legado do Avô",
		"descricao": "14 de Agosto Meus ossos já não aguentam o peso da enxada... Trabalhei no porão em algo que pode salvar esta fazenda. Deixei o projeto escondido sob o tapete da sala. Por favor, termine o que comecei.'",
		"tipo":"Tarefas:",
		"exemplo": "Encontre a passagem sob o tapete e descubra o projeto no porão.",
		"missao": 0
	},
	"missao_1": {
	"nome": "Introdução ao AGR.O",
	"descricao": "O projeto secreto do meu avô era um robô de fazenda! O AGR.O parece ser tecnologia de ponta, mas está com o banco de dados desatualizado. Precisei me registrar como o novo administrador e dar uma identidade oficial para a propriedade.",
	"tipo": "Tarefas:",
	"exemplo": "1. Registre seu nome no sistema do robô usando o comando print().\n2. Interaja com a placa na entrada e use o print() para dar um nome à fazenda.",
	"missao": 1
	},
	"missao_2": {
	"nome": "Nomeando a fazenda",
	"descricao": "O AGR.O é tem bastante potencial, vamos ver o que ele é capaz de fazer. Vou começar a dar a essa fazenda a minha cara. Primeiro ela precisa um nome.",
	"tipo": "Tarefas:",
		"exemplo": "1. Interaja com a placa na entrada.\n2. Guarde o nome da fazenda na variável nomeFazenda.\n3. Exiba o valor usando print(nomeFazenda).",
	"missao": 2
	},
		"funções": {
		"nome": "Funções",
		"descricao": "Uma função reúne instruções para realizar uma tarefa. Para chamá-la, escrevemos seu nome seguido de parênteses. No jogo, plantar(), regar() e colher() já estão disponíveis para orientar o robô.",
		"tipo": "Exemplo de chamada:",
		"exemplo": 'plantar("morango", 0, 0)',
		"missao": 3
	},

	"argumentos": {
		"nome": "Argumentos",
		"descricao": "Argumentos são os valores informados dentro dos parênteses de uma chamada de função. Eles indicam os detalhes da tarefa. Em plantar(), informamos a cultura, a linha e a coluna.",
		"tipo": "Exemplo:",
		"exemplo": 'plantar("morango", 2, 1)\n\n"morango": cultura\n2: linha\n1: coluna',
		"missao": 3
	},

	"coordenadas": {
		"nome": "Coordenadas do canteiro",
		"descricao": "Um espaço do canteiro é identificado pela linha e pela coluna, nessa ordem. A contagem começa em zero: as linhas vão de 0 a 4 e as colunas de 0 a 1. Use a mesma posição para plantar, regar e colher uma planta.",
		"tipo": "Exemplo:",
		"exemplo": "regar(2, 1)\n\nRega o espaço da linha 2 e coluna 1.",
		"missao": 3
	},

	"plantar()": {
		"nome": "Função plantar()",
		"descricao": "Orienta o robô a plantar uma semente no canteiro associado à bancada. Recebe a cultura, a linha e a coluna. O espaço precisa estar vazio e a semente deve estar no baú associado à bancada.",
		"tipo": "Exemplo:",
		"exemplo": 'plantar("morango", 0, 0)',
		"missao": 3
	},

	"regar()": {
		"nome": "Função regar()",
		"descricao": "Orienta o robô a regar uma planta na linha e coluna informadas. Cada chamada avança uma etapa do crescimento. No sistema atual, um morango recém-plantado precisa de cinco chamadas para ficar pronto para colher.",
		"tipo": "Exemplo para um morango recém-plantado:",
		"exemplo": "regar(0, 0)\nregar(0, 0)\nregar(0, 0)\nregar(0, 0)\nregar(0, 0)",
		"missao": 3
	},

	"colher()": {
		"nome": "Função colher()",
		"descricao": "Orienta o robô a colher uma planta pronta na linha e coluna informadas. O produto é guardado no baú associado à bancada e o espaço fica disponível para um novo plantio.",
		"tipo": "Exemplo:",
		"exemplo": "colher(0, 0)",
		"missao": 3
	},

	"baú": {
		"nome": "Baú de plantio",
		"descricao": "O robô utiliza as sementes do baú associado à bancada. Antes de executar plantar(), transfira uma semente do seu inventário para esse baú. Os produtos colhidos pelo robô também são guardados nele.",
		"tipo": "Como utilizar:",
		"exemplo": "1. Aproxime-se do baú e pressione E.\n2. Transfira as sementes para ele.\n3. Feche o baú e utilize a bancada.",
		"missao": 3
	},

	"bancada": {
		"nome": "Bancada de programação",
		"descricao": "Na bancada, você escreve e executa os comandos que orientam o plantio com o robô. Ela utiliza um canteiro e um baú associados. O botão de glossário permite consultar as explicações durante a programação.",
		"tipo": "Como utilizar:",
		"exemplo": "1. Abra a bancada com E.\n2. Escreva os comandos.\n3. Execute e acompanhe o robô.\n4. Antes da próxima tarefa, substitua os comandos que não deseja repetir.",
		"missao": 3
	},
}



# --- FUNÇÕES DAS MISSÕES (NOVO) ---

func _obter_missoes_desbloqueadas() -> Dictionary:
	var desbloqueadas := {}
	for missao in _missoes_disponiveis:
		var dados = _missoes_disponiveis[missao]
		if dados.get("missao") <= Global.missao_atual:
			desbloqueadas[missao] = dados
	return desbloqueadas

func obter_lista_missoes() -> Array:
	return _obter_missoes_desbloqueadas().keys()

func obter_dados_missao(missao: String) -> Dictionary:
	return _obter_missoes_desbloqueadas()[missao]

func _obter_termos_aprendidos() -> Dictionary:
	var aprendidos := {}
	for termo in _termos_disponiveis:
		var dados = _termos_disponiveis[termo]
		if dados.get("missao") <= Global.missao_atual:
			aprendidos[termo] = dados
	return aprendidos

func obter_lista_termos_aprendidos() -> Array:
	return _obter_termos_aprendidos().keys()

func obter_dados_termo(termo: String) -> Dictionary:
	return _obter_termos_aprendidos()[termo]

func possui_termo(termo: String) -> bool:
	return _obter_termos_aprendidos().has(termo)
