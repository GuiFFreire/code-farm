import ast


def analisar_plantio(codigo: str) -> dict:
    def erro(mensagem: str, status: str = "erro_semantico") -> dict:
        return {
            "status": status,
            "mensagens": [mensagem],
            "dados": {},
        }

    if len(codigo) > 10_000:
        return erro("O código ultrapassou o limite de tamanho.")

    try:
        arvore = ast.parse(codigo)
    except SyntaxError as exc:
        return erro(
            f"Linha {exc.lineno}, coluna {exc.offset}: {exc.msg}",
            "erro_sintatico",
        )
    except (ValueError, RecursionError):
        return erro("Não foi possível analisar esse código.")

    if not arvore.body:
        return erro("Escreva pelo menos um comando plantar().")

    if len(arvore.body) > 100:
        return erro("Use no máximo 100 comandos por execução.")

    acoes = []

    for instrucao in arvore.body:
        linha_codigo = instrucao.lineno

        if not (
            isinstance(instrucao, ast.Expr)
            and isinstance(instrucao.value, ast.Call)
        ):
            return erro(
                f"Linha {linha_codigo}: use plantar(\"morango\", linha, coluna)."
            )

        chamada = instrucao.value

        if not (
            isinstance(chamada.func, ast.Name)
            and chamada.func.id == "plantar"
        ):
            return erro(
                f"Linha {linha_codigo}: somente a função plantar() está disponível."
            )

        if len(chamada.args) != 3 or chamada.keywords:
            return erro(
                f"Linha {linha_codigo}: plantar() recebe cultura, linha e coluna."
            )

        if not all(isinstance(arg, ast.Constant) for arg in chamada.args):
            return erro(
                f"Linha {linha_codigo}: use o nome entre aspas e coordenadas inteiras."
            )

        cultura, linha, coluna = [arg.value for arg in chamada.args]

        if type(cultura) is not str or cultura != "morango":
            return erro(
                f"Linha {linha_codigo}: a cultura disponível é \"morango\"."
            )

        if type(linha) is not int or type(coluna) is not int:
            return erro(
                f"Linha {linha_codigo}: linha e coluna precisam ser números inteiros."
            )

        if not (0 <= linha < 5 and 0 <= coluna < 2):
            return erro(
                f"Linha {linha_codigo}: use linhas de 0 a 4 e colunas de 0 a 1."
            )

        acoes.append({
            "tipo": "plantar",
            "cultura": cultura,
            "linha": linha,
            "coluna": coluna,
            "linha_codigo": linha_codigo,
        })

    return {
        "status": "sucesso",
        "mensagens": [],
        "dados": {"acoes": acoes},
    }