extends SyntaxHighlighter

class_name PythonSyntaxHighlighter

const KEYWORDS = [
	"and", "as", "assert", "async", "await",
	"break", "class", "continue", "def", "del",
	"elif", "else", "except", "False", "finally",
	"for", "from", "global", "if", "import",
	"in", "is", "lambda", "None", "nonlocal",
	"not", "or", "pass", "raise", "return",
	"True", "try", "while", "with", "yield"
]

const BUILTIN_FUNCTIONS = [
	"print", "len", "range", "int", "str", "float",
	"bool", "list", "dict", "set", "tuple", "input",
	"open", "type", "isinstance", "super", "enumerate"
]

var keyword_color = Color(0.8, 0.2, 0.2)   # Vermelho forte
var function_color = Color(0.2, 0.4, 0.8)   # Azul
var user_function_color = Color(0.5, 0.0, 0.8) # Roxo azulado
var string_color = Color(0.0, 0.6, 0.2)     # Verde
var number_color = Color(0.6, 0.0, 0.6)     # Roxo
var comment_color = Color(0.4, 0.4, 0.4)    # Cinza
var operator_color = Color(0.8, 0.5, 0.2)   # Laranja

var multiline_string = false
var multiline_string_char = ""

func _get_line_syntax_highlighting(line_number: int) -> Dictionary:
	var highlights = {}
	var line = get_text_edit().get_line(line_number)

	var i = 0
	var inside_string = multiline_string
	var string_char = multiline_string_char
	var expect_function_name = false

	while i < line.length():
		var c = line[i]

		# Comentários
		if c == "#" and not inside_string:
			highlights[i] = {"color": comment_color, "length": line.length() - i}
			break

		# Strings multilinhas
		elif not inside_string and (line.substr(i, 3) == "\"\"\"" or line.substr(i, 3) == "'''"):
			var start = i
			inside_string = true
			string_char = line.substr(i, 3)
			i += 3
			while i < line.length():
				if line.substr(i, 3) == string_char:
					i += 3
					inside_string = false
					string_char = ""
					break
				i += 1
			highlights[start] = {"color": string_color, "length": i - start}
			continue

		# Strings normais
		elif not inside_string and (c == "\"" or c == "'"):
			var start = i
			inside_string = true
			string_char = c
			i += 1
			while i < line.length():
				if line[i] == string_char and line[i - 1] != "\\":
					i += 1
					inside_string = false
					break
				i += 1
			highlights[start] = {"color": string_color, "length": i - start}
			continue

		# Palavras-chave, funções e identificadores
		elif not inside_string and (is_letter(c) or c == "_"):
			var start = i
			var word = ""
			while i < line.length() and is_identifier_char(line[i]):
				word += line[i]
				i += 1

			if word in KEYWORDS:
				highlights[start] = {"color": keyword_color, "length": word.length()}
				expect_function_name = (word == "def")
			elif expect_function_name:
				highlights[start] = {"color": user_function_color, "length": word.length()}
				expect_function_name = false
			elif word in BUILTIN_FUNCTIONS:
				highlights[start] = {"color": function_color, "length": word.length()}
			# Variáveis normais não são coloridas
			continue

		# Números
		elif not inside_string and is_digit(c):
			var start = i
			while i < line.length() and (is_digit(line[i]) or line[i] == "."):
				i += 1
			highlights[start] = {"color": number_color, "length": i - start}
			continue

		# Operadores e símbolos
		elif not inside_string and is_operator_start(c):
			var start = i
			var op = c
			i += 1
			# Checa se é um operador composto tipo "==", "+=", etc.
			if i < line.length() and is_operator_part(op + line[i]):
				op += line[i]
				i += 1
			highlights[start] = {"color": operator_color, "length": op.length()}
			continue

		# Outros caracteres (espaço, etc.)
		else:
			i += 1

	multiline_string = inside_string
	multiline_string_char = string_char
	return highlights

# Funções auxiliares
func is_letter(c: String) -> bool:
	return c.length() == 1 and ((c >= "a" and c <= "z") or (c >= "A" and c <= "Z"))

func is_digit(c: String) -> bool:
	return c.length() == 1 and (c >= "0" and c <= "9")

func is_identifier_char(c: String) -> bool:
	return is_letter(c) or is_digit(c) or c == "_"

func is_operator_start(c: String) -> bool:
	return c in ["+", "-", "*", "/", "%", "=", ">", "<", ":", ".", ",", "(", ")", "{", "}", "[", "]"]

func is_operator_part(op: String) -> bool:
	return op in ["==", "!=", "<=", ">=", "+=", "-=", "*=", "/="]
