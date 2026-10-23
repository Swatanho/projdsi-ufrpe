# Backend - Heart Helth

Este diretório contém a API do projeto em FastAPI.

## Estrutura

- `main.py` - aplicação FastAPI
- `heart_disease_model_logistic_regression.pkl` e `heart_disease_model_xgboost.pkl` - modelos treinados para predição
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

## Modelos de predição

A API oferece Regressão Logística e XGBoost. Treine os dois modelos usando o
dataset `archive.zip` na raiz do repositório:

```bash
python train_heart_disease_model.py
```

O treinamento cria `heart_disease_model_logistic_regression.pkl` e
`heart_disease_model_xgboost.pkl`. Reinicie a API depois do treinamento. A rota
`GET /models` informa as importâncias de cada modelo; `POST /predict?model_name=logistic_regression`
ou `POST /predict?model_name=xgboost` avalia os dados com o modelo escolhido.
