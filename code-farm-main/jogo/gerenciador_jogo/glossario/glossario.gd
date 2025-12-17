class_name Glossario

extends Resource

var _termos_disponiveis: Dictionary = {
	"print()": {
		"nome": "Função print()",
		"descricao": "A função print() é usada para exibir mensagens na tela (console). Ela é muito útil para mostrar resultados, textos ou acompanhar a execução do programa.",
		"exemplo": "print(\"Olá, mundo!\")",
		"missao": 1
	},
	"#": {
		"nome": "# Comentários",
		"descricao": "Em Python, tudo que vem após o símbolo # em uma linha é ignorado pelo programa. Isso serve para deixar anotações no código, facilitando o entendimento.",
		"exemplo": "# Isso é um comentário explicativo",
		"missao": 2
	},
	'"""': {
		"nome": '""" Comentários """',
		"descricao": "Usa-se três aspas duplas para escrever comentários que ocupam várias linhas. Eles são úteis para explicar melhor o funcionamento do código ou escrever descrições longas.",
		"exemplo": "\"\"\"\nEste código faz parte do jogo Code Farm.\nEle ajuda a organizar e explicar o código faz.\n\"\"\"",
		"missao": 2
	},
	"variáveis": {
		"nome": "Variáveis",
		"descricao": "Variáveis são usadas para armazenar informações. Elas recebem um nome e podem guardar textos, números, listas e outros valores que podem mudar durante a execução do programa.",
		"exemplo": "copo = \"água\"",
		"missao": 3
	},
	"for": {
		"nome": "Laço for",
		"descricao": "O laço for é usado para repetir uma ação várias vezes. Com ele, você pode executar um bloco de código para cada valor dentro de uma sequência ou intervalo.",
		"exemplo": "for i in range(5):\n\tprint(\"Repetição número\", i)",
		"missao": 4
	},
	"if": {
		"nome": "Condicional if",
		"descricao": "O comando if é usado para executar uma parte do código somente se uma condição for verdadeira.",
		"exemplo": "if copo == \"água\":\n\tprint(\"É água mesmo!\")",
		"missao": 5
	},
	"elif": {
		"nome": "Condicional elif",
		"descricao": "elif é a abreviação de 'else if'. Ele permite testar uma nova condição se a anterior (if) for falsa.",
		"exemplo": "elif copo == \"suco\":\n\tprint(\"É suco!\")",
		"missao": 5
	},
	"else": {
		"nome": "Condicional else",
		"descricao": "O else é usado quando nenhuma das condições anteriores (if ou elif) foi verdadeira. Ele executa um código alternativo.",
		"exemplo": "else:\n\tprint(\"Não sei o que tem nesse copo!\")",
		"missao": 5
	},
}

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
