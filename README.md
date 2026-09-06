# Heart Health

Projeto full-stack para diagnóstico e acompanhamento de saúde, com backend em Python/FastAPI e frontend em Flutter.

## Estrutura

- `backend/` - API com FastAPI, modelo de predição e endpoints
- `frontend/` - aplicativo móvel/web em Flutter

## Como executar

### Backend
```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# ou .venv\Scripts\activate  # Windows
pip install -r requirements.txt
uvicorn main:app --reload
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## Tecnologias

- Python + FastAPI
- Flutter + Dart
- Machine Learning com scikit-learn
