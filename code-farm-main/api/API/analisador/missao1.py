#missao1.py

import ast
from .base import AnalisadorMissao
from roteador import registrar_missao

@registrar_missao(1)
class AnalisadorMissao1(AnalisadorMissao):
    def analisar_semantica(self) -> dict:
        mensagens = []
        nome_fazenda = None
        sucesso = False

        for node in ast.walk(self.tree):
            if isinstance(node, ast.Expr) and isinstance(node.value, ast.Call):
                call = node.value
                if isinstance(call.func, ast.Name) and call.func.id == "print":
                    if call.args:
                        arg = call.args[0]
                        if isinstance(arg, ast.Constant) and isinstance(arg.value, str):
                            nome_fazenda = arg.value
                            mensagens.append("Comando print() encontrado com string.")
                            sucesso = True
                        else:
                            mensagens.append("O print precisa exibir um texto entre aspas.")
                    else:
                        mensagens.append("O print está vazio.")

        if sucesso:
            return {
                "status": "sucesso",
                "mensagens": mensagens,
                "dados": {
                    "nome_fazenda": nome_fazenda
                }
            }
        else:
            mensagens.append("Você precisa usar o comando print() com um texto entre aspas.")
            return {
                "status": "erro_semantico",
                "mensagens": mensagens,
                "dados": {}
            }
