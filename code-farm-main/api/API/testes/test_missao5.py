#test_missao1.py
import pytest
from analisadores.missao5 import AnalisadorMissao5

def analisar(codigo):
    return AnalisadorMissao5(codigo).analisar()

# Código CORRETO esperado pela missão
codigo_correto = '''
comida = "milho"

if comida == "milho":
    print("Galinha")
elif comida == "feno":
    print("Vaca")
else:
    print("Porco")
'''

def test_codigo_correto():
    resultado = analisar(codigo_correto)
    assert resultado["status"] == "sucesso"
    assert "Muito bem" in resultado["mensagens"][0]

def test_faltou_variavel_comida():
    codigo = '''
if comida == "milho":
    print("Galinha")
elif comida == "feno":
    print("Vaca")
else:
    print("Porco")
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "erro_semantico"
    assert "variável chamada 'comida'" in " ".join(resultado["mensagens"])
    assert resultado["dados"]["erro"] == "faltou_variavel"

def test_faltou_else():
    codigo = '''
comida = "milho"

if comida == "milho":
    print("Galinha")
elif comida == "feno":
    print("Vaca")
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "erro_semantico"
    assert "else" in " ".join(resultado["mensagens"])
    assert resultado["dados"]["erro"] == "faltou_else"

def test_faltou_print():
    codigo = '''
comida = "milho"

if comida == "milho":
    pass
elif comida == "feno":
    pass
else:
    pass
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "erro_semantico"
    assert "print()" in " ".join(resultado["mensagens"])
    assert resultado["dados"]["erro"] == "faltou_print"

def test_comparacao_errada():
    codigo = '''
comida = "milho"

if alimento == "milho":
    print("Galinha")
elif alimento == "feno":
    print("Vaca")
else:
    print("Porco")
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "erro_semantico"
    assert "comparar a variável 'comida'" in " ".join(resultado["mensagens"])
    assert resultado["dados"]["erro"] == "comparacao_errada"

def test_print_incorreto():
    codigo = '''
comida = "milho"

if comida == "milho":
    print("coisa")
elif comida == "feno":
    print("outra coisa")
else:
    print("nada a ver")
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "erro_semantico"
    assert "print()" in resultado["mensagens"][-1].lower()
    assert resultado["dados"]["erro"] == "print_incorreto"
