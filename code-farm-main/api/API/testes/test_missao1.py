#test_missao1.py

from analisador.missao1 import AnalisadorMissao1

def analisar(codigo):
    return AnalisadorMissao1(codigo).analisar()

def test_print_valido():
    resultado = analisar('print("Fazenda Alegria")')
    assert resultado["status"] == "sucesso"
    assert resultado["dados"]["nome_fazenda"] == "Fazenda Alegria"

def test_print_sem_aspas():
    resultado = analisar('print(123)')
    assert resultado["status"] == "erro_semantico"
    assert resultado["dados"]["nome_fazenda"] is None
    assert any("precisa exibir um texto entre aspas" in msg for msg in resultado["mensagens"])

def test_print_vazio():
    resultado = analisar('print()')
    assert resultado["status"] == "erro_semantico"
    assert resultado["dados"]["nome_fazenda"] is None
    assert any("O print está vazio" in msg for msg in resultado["mensagens"])

def test_sem_print():
    resultado = analisar('x = 10')
    assert resultado["status"] == "erro_semantico"
    assert resultado["dados"]["nome_fazenda"] is None
    assert any("precisa usar o comando print" in msg for msg in resultado["mensagens"])


