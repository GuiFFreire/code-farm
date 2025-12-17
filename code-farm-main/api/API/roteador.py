# roteador.py

REGISTRO_ANALISADORES = {}

def registrar_missao(id_missao: int):
    def decorador(classe):
        REGISTRO_ANALISADORES[id_missao] = classe
        return classe
    return decorador

def obter_analisador(id_missao: int, codigo: str, contexto: dict = None):
    cls = REGISTRO_ANALISADORES.get(id_missao)
    if cls is None:
        raise ValueError(f"Missão {id_missao} não registrada para a analise de código. Por favor, contate um desenvolvedor para solucionar o problema.")
    return cls(codigo, contexto)
