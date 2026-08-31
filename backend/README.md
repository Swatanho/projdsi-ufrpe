# Backend - Meu Projeto Saúde

Este diretório contém a API do projeto em FastAPI.

## Estrutura

- `main.py` - aplicação FastAPI
- `heart_disease_model.pkl` - modelo treinado para predição
- `requirements.txt` - dependências do backend

## Execução

```bash
cd backend
python -m venv .venv
source .venv/bin/activate   # Linux/macOS
# ou .venv\Scripts\activate # Windows
pip install -r requirements.txt
uvicorn main:app --reload
```

A API ficará disponível em `http://localhost:8000`.
