import pytest
from analisadores.missao3 import AnalisadorMissao3

def analisar(codigo):
    return AnalisadorMissao3(codigo=codigo).analisar()

# -------------------------------
# Testes de sucesso
# -------------------------------

def test_duas_variaveis_diferentes_com_strings():
    codigo = '''
copo1 = "água"
copo2 = "suco"
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "sucesso"
    assert "variaveis_definidas" in resultado["dados"]
    assert len(resultado["dados"]["variaveis_definidas"]) >= 2
    assert resultado["dados"]["total_atribuicoes"] >= 2

def test_mais_de_duas_variaveis():
    codigo = '''
copo1 = "café"
copo2 = "leite"
copo3 = "suco"
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "sucesso"

# -------------------------------
# Testes de erro
# -------------------------------

def test_uma_variavel_so():
    codigo = 'copo = "água"'
    resultado = analisar(codigo)
    assert resultado["status"] == "erro_semantico"
    assert resultado["dados"]["total_atribuicoes"] == 1

def test_duas_variaveis_sem_valor_string():
    codigo = '''
copo1 = 10
copo2 = 20
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "erro_semantico"
    assert resultado["dados"]["total_atribuicoes"] == 0

def test_sem_atribuicao():
    codigo = '''
print("olá")
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "erro_semantico"
    assert resultado["dados"]["variaveis_definidas"] == []

def test_reutilizando_mesma_variavel():
    codigo = '''
copo = "água"
copo = "suco"
'''
    resultado = analisar(codigo)
    # Apesar de 2 atribuições, só 1 variável: erro
    assert resultado["status"] == "erro_semantico"
    assert resultado["dados"]["total_atribuicoes"] == 2
    assert len(resultado["dados"]["variaveis_definidas"]) == 1
