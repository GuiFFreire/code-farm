# 🌾 Code Farm

**Code Farm** é um jogo educacional desenvolvido em [Godot Engine](https://godotengine.org/) com backend em [Python + FastAPI](https://fastapi.tiangolo.com/), com o objetivo de ensinar programação em Python de forma interativa e lúdica.

## 🧠 Objetivo

O jogo visa ensinar conceitos fundamentais da linguagem Python por meio de missões, desafios e interação com personagens em um ambiente de fazenda.

## 🗂 Estrutura do projeto
code-farm/  
├── jogo/        → Projeto Godot (Godot 4) — deve ser aberto e testado diretamente na Godot Engine  
├── api/         → API Python com FastAPI — deve ser executada em paralelo para fornecer validações dinâmicas  
├── LICENSE      → Licença do projeto  
└── README.md    → Este arquivo  

## 🎮 Como rodar o jogo

### Requisitos
- [Godot Engine 4.x](https://godotengine.org/download)

### Instruções
1. Abra o Godot.
2. Clique em **"Importar Projeto"**.
3. Selecione a pasta `jogo/` dentro do repositório.
4. Execute o projeto normalmente com **F5**.

## 🧪 Como rodar a API (backend Python)

### Requisitos
- Python 3.10 ou superior
- Pip

### Instalação
Abra o terminal e execute:

```
cd api
python -m venv venv
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows

pip install -r requirements.txt
```

### Execução da API
```
bash
Copiar
Editar
uvicorn main:app --reload
```

#### A API estará disponível em:
```
http://127.0.0.1:8000
```

## 🧰 Tecnologias utilizadas
- Godot Engine 4 – motor de jogo
- Python 3.10
- FastAPI – framework para APIs web
- Pydantic – validação de dados na API
- Uvicorn – servidor ASGI para FastAPI

## 📚 Organização pedagógica
- Cada missão no jogo apresenta um novo conceito de programação (ex: print(), for, comentários).
- A API valida o código enviado pelo jogador e fornece feedback personalizado.
- O sistema é expansível com novas missões e regras.

## ✅ Status
✔️ Funcional  
🚧 Em desenvolvimento contínuo  

## 📄 Licença
Este projeto está licenciado sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.
