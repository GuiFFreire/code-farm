class_name CaixaDialogo 

extends Control

@onready var _foto: TextureRect = $MarginContainer/NinePatchRect/HBoxContainer/MarginContainer/NinePatchRect/TextureRect
@onready var _personagem: Label = $MarginContainer/NinePatchRect/HBoxContainer/MarginContainer2/VBoxContainer/Label
@onready var _dialogo: RichTextLabel = $MarginContainer/NinePatchRect/HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer/FundoEditorTexto2/MarginContainer/RichTextLabel
@onready var _som_caractere: AudioStreamPlayer = $SomCaracteresExibindo

enum TipoDeDialogo {
	DIALOGO,
	CODIGO
}

var _velocidade_exibicao_char: float = 0.03
var _dialogo_ativo: bool = false
var _exibindo_texto: bool = false
var _exibicao_interrompida: bool = false
var _aguardando_confirmacao: bool = false

func _process(_delta: float) -> void:
	_ao_passar_texto()

func _ao_passar_texto():
	if Input.is_action_just_pressed("ui_accept"):
		if _exibindo_texto:
			_exibicao_interrompida = true
		elif _aguardando_confirmacao:
			_aguardando_confirmacao = false

func exibir_dialogo(texto: String, foto: String, personagem: String, tipo: TipoDeDialogo) -> void:
	_personagem.text = personagem
	_foto.texture = load(foto)
	_dialogo.bbcode_enabled = true
	
	_dialogo.text = ""
	_dialogo.clear()

	match tipo:
		TipoDeDialogo.DIALOGO:
			texto = _formatar_termos(texto)
		TipoDeDialogo.CODIGO:
			texto = _formatar_codigos(texto)

	_dialogo.text = texto
	_dialogo.visible_characters = 0

	await _exibir_texto_animado(texto)
	await _aguardar_confirmacao_usuario()

func _exibir_texto_animado(texto: String) -> void:
	_exibindo_texto = true
	_exibicao_interrompida = false
	_dialogo.visible_characters = 0
	
	_som_caractere.stream.loop = true
	_som_caractere.play()
		
	while _dialogo.visible_characters < _dialogo.get_total_character_count():
		if _exibicao_interrompida:
			_dialogo.visible_characters = texto.length()
			break
		
		await get_tree().create_timer(_velocidade_exibicao_char).timeout
		_dialogo.visible_characters += 1
		
	_exibindo_texto = false
	_som_caractere.stop()

func _aguardar_confirmacao_usuario():
	_aguardando_confirmacao = true
	while _aguardando_confirmacao:
		await get_tree().process_frame
		
func _formatar_termos(texto: String) -> String:
	var termos_aprendidos = Global.glossario.obter_lista_termos_aprendidos()
	var substituicoes := []
	var tokens_usados := 0

	for termo in termos_aprendidos:
		var regex = RegEx.new()
		var termo_regex = "(?<!\\w)" + escapar_regex(termo) + "(?!\\w)"

		if regex.compile(termo_regex) != OK:
			continue

		var token = "<<TERMO_%d>>" % tokens_usados
		tokens_usados += 1

		substituicoes.append({ "token": token, "termo": termo })

		texto = regex.sub(texto, token, true)

	for item in substituicoes:
		var termo = item["termo"]
		var token = item["token"]
		var bbcode = "[url=%s][font=res://assets/fontes/ExpressionPro.ttf][color=#ffffff][b]%s[/b][/color][/font][/url]" % [termo, termo]
		texto = texto.replace(token, bbcode)

	return texto

func escapar_regex(texto: String) -> String:
	var especiais := ['\\', '.', '+', '*', '?', '^', '$', '(', ')', '[', ']', '{', '}', '|']
	for c in especiais:
		texto = texto.replace(c, "\\" + c)
	return texto

func _formatar_codigos(texto: String) -> String:
	return "[code][color=#dcdcdc]%s[/color][/code]" % texto

func parar_som() -> void:
	_som_caractere.stop()
