from __future__ import annotations

import zipfile
from pathlib import Path

import joblib
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from xgboost import XGBClassifier

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
LOGISTIC_MODEL_PATH = BACKEND_DIR / 'heart_disease_model_logistic_regression.pkl'
XGBOOST_MODEL_PATH = BACKEND_DIR / 'heart_disease_model_xgboost.pkl'
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

    x_train, x_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.2,
        random_state=42,
        stratify=y,
    )
    models = {
        'Regressão Logística': (
            Pipeline([
                ('scaler', StandardScaler()),
                (
                    'classifier',
                    LogisticRegression(max_iter=2000, random_state=42),
                ),
            ]),
            LOGISTIC_MODEL_PATH,
        ),
        'XGBoost': (
            XGBClassifier(
                n_estimators=300,
                max_depth=4,
                learning_rate=0.05,
                subsample=0.8,
                colsample_bytree=0.8,
                eval_metric='logloss',
                random_state=42,
                n_jobs=-1,
            ),
            XGBOOST_MODEL_PATH,
        ),
    }

    for label, (model, model_path) in models.items():
        model.fit(x_train, y_train)
        accuracy = accuracy_score(y_test, model.predict(x_test))
        joblib.dump(model, model_path)
        print(f'{label} salvo em: {model_path}')
        print(f'Acurácia no conjunto de teste: {accuracy:.4f}')


if __name__ == '__main__':
    train_model_from_archive()
