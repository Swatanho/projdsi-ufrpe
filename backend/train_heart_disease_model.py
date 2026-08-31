from __future__ import annotations

import zipfile
from pathlib import Path

import joblib
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

TARGET_COLUMN = 'HeartDiseaseorAttack'
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

PROJECT_ROOT = Path(__file__).resolve().parent.parent
BACKEND_DIR = Path(__file__).resolve().parent
MODEL_PATH = BACKEND_DIR / 'heart_disease_model.pkl'
ZIP_PATH_CANDIDATES = [
    PROJECT_ROOT / 'archive.zip',
    BACKEND_DIR / 'archive.zip',
]


def find_archive_csv() -> str | None:
    for zip_path in ZIP_PATH_CANDIDATES:
        if not zip_path.exists():
            continue

        with zipfile.ZipFile(zip_path) as archive:
            for name in archive.namelist():
                if 'diabetes_binary' in name.lower() and name.lower().endswith('.csv'):
                    return name
    return None


def train_model_from_archive() -> None:
    zip_path = next((p for p in ZIP_PATH_CANDIDATES if p.exists()), None)
    if zip_path is None:
        raise FileNotFoundError('Arquivo archive.zip não encontrado na raiz do projeto ou no backend.')

    csv_name = find_archive_csv()
    if csv_name is None:
        raise FileNotFoundError('Nenhum CSV binário válido foi encontrado dentro do archive.zip.')

    with zipfile.ZipFile(zip_path) as archive:
        df = pd.read_csv(archive.open(csv_name))

    required = FEATURE_COLUMNS + [TARGET_COLUMN]
    missing = [col for col in required if col not in df.columns]
    if missing:
        raise ValueError(f'O dataset não contém as colunas esperadas: {missing}')

    model_df = df[required].copy()
    model_df[FEATURE_COLUMNS] = model_df[FEATURE_COLUMNS].apply(pd.to_numeric, errors='coerce')
    model_df[TARGET_COLUMN] = pd.to_numeric(model_df[TARGET_COLUMN], errors='coerce')
    model_df = model_df.dropna().reset_index(drop=True)

    if model_df.empty:
        raise ValueError('O dataset ficou vazio após limpar colunas inválidas.')

    X = model_df[FEATURE_COLUMNS]
    y = model_df[TARGET_COLUMN].astype(int)

    model = LogisticRegression(max_iter=2000, random_state=42)
    model.fit(X, y)

    predictions = model.predict(X)
    accuracy = accuracy_score(y, predictions)

    joblib.dump(model, MODEL_PATH)
    print(f'Modelo salvo em: {MODEL_PATH}')
    print(f'Acurácia no conjunto de treino: {accuracy:.4f}')


if __name__ == '__main__':
    train_model_from_archive()
