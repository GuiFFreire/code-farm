import pytest
from analisadores.missao4 import AnalisadorMissao4

def analisar(codigo):
    return AnalisadorMissao4(codigo=codigo).analisar()

# -------------------------------
# Testes de sucesso
# -------------------------------

def test_codigo_correto_com_for_e_print():
    codigo = '''
for i in range(1, 6):
    print("Regando alface", i)
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "sucesso"
    assert resultado["dados"]["quantidade_regas"] == 5
    assert resultado["dados"]["erro"] is None

# -------------------------------
# Testes de erro
# -------------------------------

def test_faltou_for():
    codigo = '''
print("Regando alface 1")
print("Regando alface 2")
print("Regando alface 3")
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "erro_semantico"
    assert resultado["dados"]["erro"] == "faltou_for"

def test_faltou_print():
    codigo = '''
for i in range(1, 6):
    pass
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "erro_semantico"
    assert resultado["dados"]["erro"] == "faltou_print"

def test_range_menor_que_5():
    codigo = '''
for i in range(1, 4):
    print("Regando alface", i)
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "erro_semantico"
    assert resultado["dados"]["quantidade_regas"] == 3
    assert resultado["dados"]["erro"] is None

def test_range_maior_que_5():
    codigo = '''
for i in range(1, 8):
    print("Regando alface", i)
'''
    resultado = analisar(codigo)
    assert resultado["status"] == "erro_semantico"
    assert resultado["dados"]["quantidade_regas"] == 7
    assert resultado["dados"]["erro"] is None

def test_range_com_step():
    codigo = '''
for i in range(1, 10, 2):
    print("Regando alface", i)
'''
    resultado = analisar(codigo)
    # range(1, 10, 2) => 1, 3, 5, 7, 9 → 5 iterações
    assert resultado["status"] == "sucesso"
    assert resultado["dados"]["quantidade_regas"] == 5

def test_range_start_maior_que_stop():
    codigo = '''
for i in range(5, 1):
    print("Regando alface", i)
'''
    resultado = analisar(codigo)
    # Isso gera 0 iterações
    assert resultado["status"] == "erro_semantico"
    assert resultado["dados"]["quantidade_regas"] == 0
