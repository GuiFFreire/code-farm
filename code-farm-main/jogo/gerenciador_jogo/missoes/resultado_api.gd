class_name ResultadoAPI

extends Resource

enum Status {
	SUCESSO,
	ERRO_SINTATICO,
	ERRO_SEMANTICO,
	ERRO_DESCONHECIDO
}

var status: Status = Status.ERRO_DESCONHECIDO
var mensagens: Array = []
var dados: Dictionary = {}

func definir_status(status: Status):
	self.status = status

func definir_mensagens(mensagens: Array):
	self.mensagens = mensagens

func definir_dados(dados: Dictionary):
	self.dados = dados
