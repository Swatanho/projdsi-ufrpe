from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import joblib
import pandas as pd
from pydantic import BaseModel

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

model_path = Path(__file__).resolve().with_name('heart_disease_model.pkl')
model = joblib.load(model_path)

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

@app.post('/predict')
def predict(data: HeartDiseaseInput):
    payload = pd.DataFrame([data.model_dump()], columns=FEATURE_COLUMNS)
    prediction = model.predict(payload)[0]
    return {
        'prediction': int(prediction),
        'message': 'Risco de doença cardíaca detectado' if prediction == 1 else 'Sem indicação de doença cardíaca',
    }
