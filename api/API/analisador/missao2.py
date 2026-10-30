import ast

from .base import AnalisadorMissao
from roteador import registrar_missao


@registrar_missao(2)
class AnalisadorMissao2(AnalisadorMissao):
    def analisar_semantica(self) -> dict:
        instrucoes = self.tree.body

        if len(instrucoes) != 2:
            return self._erro(
                "Escreva duas instruções: primeiro "
                'nomeFazenda = "Nome da sua fazenda" e depois '
                "print(nomeFazenda)."
            )

        atribuicao, exibicao = instrucoes

        # A primeira instrução precisa criar a variável solicitada.
        if (
            not isinstance(atribuicao, ast.Assign)
            or len(atribuicao.targets) != 1
            or not isinstance(atribuicao.targets[0], ast.Name)
            or atribuicao.targets[0].id != "nomeFazenda"
        ):
            return self._erro(
                "Primeiro crie a variável nomeFazenda usando =. "
                "Respeite as letras maiúsculas e minúsculas."
            )

        valor = atribuicao.value

        if (
            not isinstance(valor, ast.Constant)
            or not isinstance(valor.value, str)
        ):
            return self._erro(
                "Guarde um texto entre aspas na variável. "
                'Exemplo: nomeFazenda = "Fazenda Girassol".'
            )

        nome_fazenda = valor.value.strip()

        if not nome_fazenda:
            return self._erro(
                "Escolha um nome para a fazenda. "
                "O texto não pode ficar vazio ou conter apenas espaços."
            )

        # A segunda instrução precisa exibir o valor da variável.
        if (
            not isinstance(exibicao, ast.Expr)
            or not isinstance(exibicao.value, ast.Call)
        ):
            return self._erro(
                "Depois de criar a variável, escreva print(nomeFazenda)."
            )

        chamada = exibicao.value

        if (
            not isinstance(chamada.func, ast.Name)
            or chamada.func.id != "print"
            or len(chamada.args) != 1
            or chamada.keywords
        ):
            return self._erro(
                "Use print(nomeFazenda) para exibir o nome guardado."
            )

        argumento = chamada.args[0]

        if (
            not isinstance(argumento, ast.Name)
            or argumento.id != "nomeFazenda"
        ):
            return self._erro(
                "Dentro do print(), use nomeFazenda sem aspas. "
                "Assim você exibe o valor da variável."
            )

        return {
            "status": "sucesso",
            "mensagens": [
                "Você guardou o nome em uma variável e exibiu seu valor!"
            ],
            "dados": {
                "nome_fazenda": nome_fazenda
            }
        }

    def _erro(self, mensagem: str) -> dict:
        return {
            "status": "erro_semantico",
            "mensagens": [mensagem],
            "dados": {}
        }