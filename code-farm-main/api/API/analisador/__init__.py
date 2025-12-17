import os
import importlib

# Importa dinamicamente todos os arquivos missao*.py
diretorio = os.path.dirname(__file__)
for nome in os.listdir(diretorio):
    if nome.startswith("missao") and nome.endswith(".py"):
        nome_modulo = f"analisador.{nome[:-3]}"
        importlib.import_module(nome_modulo)
