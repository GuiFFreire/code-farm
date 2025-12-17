#base.py

from abc import ABC, abstractmethod

class AnalisadorMissao(ABC):
    def __init__(self, codigo: str, contexto: dict = None):
        self.codigo = codigo
        self.contexto = contexto or {}

    def analisar(self) -> dict:
        erro = self.analisar_sintaxe()
        if erro:
            return erro
        return self.analisar_semantica()

    def analisar_sintaxe(self) -> dict | None:
        import ast
        try:
            self.tree = ast.parse(self.codigo)
            return None
        except SyntaxError as e:
            return {
                "status": "erro_sintatico",
                "mensagens": [f"Erro de sintaxe na linha {e.lineno}: {e.msg}"],
                "dados": {}
            }

    @abstractmethod
    def analisar_semantica(self) -> dict:
        pass
