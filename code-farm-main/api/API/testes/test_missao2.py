import pytest
from analisadores.missao2 import AnalisadorMissao2

def analisar(codigo, etapa):
    return AnalisadorMissao2(codigo=codigo, contexto={"etapa": etapa}).analisar()

# -------------------------------
# Parte 1: Comentários de uma linha
# -------------------------------

def test_comentarios_simples_ok():
    codigo = '''
# 1. Limpar o quarto
# 2. Comprar plantas
# 3. Pintar a parede
'''
    resultado = analisar(codigo, "parte1")
    assert resultado["status"] == "sucesso"
    assert "comentários de uma linha" in resultado["mensagens"][0]

def test_comentarios_insuficientes():
    codigo = '''
# Limpar
# Comprar
'''
    resultado = analisar(codigo, "parte1")
    assert resultado["status"] == "erro_semantico"
    assert "pelo menos 3" in resultado["mensagens"][0]
    assert resultado["dados"]["quantidade_comentarios"] == 2

def test_sem_comentarios():
    codigo = '''
print("Olá mundo")
'''
    resultado = analisar(codigo, "parte1")
    assert resultado["status"] == "erro_semantico"
    assert resultado["dados"]["quantidade_comentarios"] == 0

# -------------------------------
# Parte 2: Comentários de múltiplas linhas (""" """)
# -------------------------------

def test_comentario_multilinha_ok():
    codigo = """
\"\"\"
Este código organiza as tarefas da casa.
Serve como lembrete para não esquecer nada importante.
\"\"\"
"""
    resultado = analisar(codigo, "parte2")
    assert resultado["status"] == "sucesso"
    assert "comentário de múltiplas linhas" in resultado["mensagens"][0].lower()

def test_comentario_multilinha_curto_demais():
    codigo = '""" pequeno """'
    resultado = analisar(codigo, "parte2")
    assert resultado["status"] == "erro_semantico"
    assert "aspas triplas" in resultado["mensagens"][0]

def test_comentario_multilinha_sem_aspas():
    codigo = '''
# Isso não é um comentário de várias linhas
# Só linhas únicas
'''
    resultado = analisar(codigo, "parte2")
    assert resultado["status"] == "erro_semantico"
    assert "aspas triplas" in resultado["mensagens"][0]

def test_comentario_multilinha_via_expr():
    # Verifica também quando a string está fora do topo
    codigo = '''
print("Início")
""" comentário
em várias
linhas """
print("Fim")
'''
    resultado = analisar(codigo, "parte2")
    assert resultado["status"] == "sucesso"
