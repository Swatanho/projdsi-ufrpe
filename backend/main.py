from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import joblib
import pandas as pd
from pydantic import BaseModel

from predictor import PredictorDCV

app = FastAPI(title='Heart Helth', version='1.0.0')

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)

FEATURE_COLUMNS = [
    'HighBP',
    'HighChol',
    'CholCheck',
    'BMI',
    'Smoker',
    'Stroke',
    'PhysActivity',
    'Fruits',
    'Veggies',
    'HvyAlcoholConsump',
    'AnyHealthcare',
    'NoDocbcCost',
    'GenHlth',
    'MentHlth',
    'PhysHlth',
    'DiffWalk',
    'Sex',
    'Age',
    'Education',
    'Income',
]

BACKEND_DIR = Path(__file__).resolve().parent
MODEL_PATHS = {
    'logistic_regression': BACKEND_DIR / 'heart_disease_model_logistic_regression.pkl',
    'xgboost': BACKEND_DIR / 'heart_disease_model_xgboost.pkl',
}
MODEL_LABELS = {
    'logistic_regression': 'Regressão Logística',
    'xgboost': 'XGBoost',
}
models = {name: joblib.load(path) for name, path in MODEL_PATHS.items()}

DCV_MODEL_ID = 'dcv'
DCV_MODEL_LABEL = 'XGBoost (PISI3)'
dcv_predictor = PredictorDCV.carregar(BACKEND_DIR / 'dcv_modelo.pkl')


def _dcv_feature_importances():
    """Importancias globais do modelo DCV (Booster nativo do XGBoost)."""
    pesos = dcv_predictor._modelo.get_score(importance_type='gain')
    brutos = [float(pesos.get(feature, 0.0)) for feature in dcv_predictor.features]
    total = sum(brutos)
    importancias = [
        {'feature': feature, 'importance': (valor / total) if total else 0.0}
        for feature, valor in zip(dcv_predictor.features, brutos)
    ]
    importancias.sort(key=lambda item: item['importance'], reverse=True)
    return importancias

class HeartDiseaseInput(BaseModel):
    HighBP: int
    HighChol: int
    CholCheck: int
    BMI: int
    Smoker: int
    Stroke: int
    PhysActivity: int
    Fruits: int
    Veggies: int
    HvyAlcoholConsump: int
    AnyHealthcare: int
    NoDocbcCost: int
    GenHlth: int
    MentHlth: int
    PhysHlth: int
    DiffWalk: int
    Sex: int
    Age: int
    Education: int
    Income: int

@app.get('/')
def root():
    return {'message': 'API Heart Health online'}


@app.get('/models')
def list_models():
    available_models = []
    for model_name, estimator in models.items():
        if model_name == 'logistic_regression':
            raw_importances = abs(
                estimator.named_steps['classifier'].coef_[0],
            )
        else:
            raw_importances = estimator.feature_importances_

        total_importance = float(raw_importances.sum())
        importances = [
            {
                'feature': feature,
                'importance': float(value / total_importance)
                if total_importance
                else 0.0,
            }
            for feature, value in zip(FEATURE_COLUMNS, raw_importances)
        ]
        importances.sort(key=lambda item: item['importance'], reverse=True)
        available_models.append({
            'id': model_name,
            'label': MODEL_LABELS[model_name],
            'feature_importances': importances,
        })

    available_models.append({
        'id': DCV_MODEL_ID,
        'label': DCV_MODEL_LABEL,
        'feature_importances': _dcv_feature_importances(),
    })

    return {'models': available_models}


@app.post('/predict')
def predict(data: HeartDiseaseInput, model_name: str = 'logistic_regression'):
    if model_name == DCV_MODEL_ID:
        return _predict_dcv(data)

    estimator = models.get(model_name)
    if estimator is None:
        raise HTTPException(
            status_code=400,
            detail=(
                'Modelo inválido. Opções: '
                + ', '.join(list(MODEL_LABELS.values()) + [DCV_MODEL_LABEL])
            ),
        )

    payload = pd.DataFrame([data.model_dump()], columns=FEATURE_COLUMNS)
    prediction = estimator.predict(payload)[0]
    positive_class_index = list(estimator.classes_).index(1)
    risk_percentage = float(
        estimator.predict_proba(payload)[0][positive_class_index] * 100,
    )
    return {
        'prediction': int(prediction),
        'risk_percentage': risk_percentage,
        'model_name': model_name,
        'message': 'Risco de doença cardíaca detectado' if prediction == 1 else 'Sem indicação de doença cardíaca',
    }


def _predict_dcv(data):
    """Predicao com o modelo DCV (contrato PISI3): threshold + faixas de risco."""
    resultado = dcv_predictor.prever(data.model_dump())
    probabilidade = resultado['probabilidade']
    classificacao = resultado['classificacao']

    mensagens = {
        'alto': 'Risco elevado de doença cardíaca detectado',
        'moderado': 'Atenção: risco moderado de doença cardíaca',
        'baixo': 'Sem indicação de doença cardíaca',
    }
    return {
        'prediction': 1 if classificacao == 'alto' else 0,
        'risk_percentage': float(probabilidade * 100),
        'model_name': DCV_MODEL_ID,
        'message': mensagens.get(classificacao, mensagens['baixo']),
        'classificacao': classificacao,
        'threshold': dcv_predictor.threshold,
        'versao': dcv_predictor.versao,
    }
