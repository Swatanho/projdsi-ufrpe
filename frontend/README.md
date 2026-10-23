# HeartHealth Frontend

Aplicativo Flutter conectado ao Firebase Authentication, Cloud Firestore e à API FastAPI de predição.

## Camadas

- `lib/models/` - entidades e conversão de dados (`DoctorModel`, `PatientModel`, `PredictionModel`, `AppointmentModel`)
- `lib/repositories/` - acesso direto ao Firebase Authentication e Cloud Firestore
- `lib/services/` - casos de uso de médicos, autenticação, pacientes e integração com a API
- `lib/features/*/presentation/` - telas e componentes organizados por funcionalidade
- `lib/core/theme/` - tema compartilhado

Cada camada tem um único diretório canônico: serviços em `lib/services/`, modelos em
`lib/models/` e telas/widgets em `lib/features/`. A tela inicial é
`lib/features/home/presentation/screens/home_screen.dart`.

## Firebase

O Firebase é inicializado em `lib/main.dart` usando `lib/firebase_options.dart`. As opções atuais apontam para o projeto `hearthealth-dsi` e estão configuradas para Android, Web e Windows.

Os perfis são armazenados em `doctors/{uid}` e novos pacientes em `patients/{patientId}`, com o `doctorId` responsável no documento. A Home consulta o grupo de coleções `patients`, incluindo registros antigos em `doctors/{uid}/patients/{patientId}`. Como isso expõe dados clínicos entre médicos, a leitura exige autenticação e a escrita na coleção raiz continua restrita ao médico dono do paciente. As regras estão em `firestore.rules` na raiz. Para publicá-las:

```bash
firebase deploy --only firestore:rules --project hearthealth-dsi
```

## API de predição

Inicie o backend em `backend/` com `uvicorn main:app --reload`. A URL padrão é `http://localhost:8000` na Web e `http://10.0.2.2:8000` no emulador Android. Para outro endereço, configure `API_BASE_URL`:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

Em dispositivos físicos ou produção, use um endereço alcançável pelo dispositivo e HTTPS; o tráfego HTTP está liberado no Android apenas para loopback e o emulador local.

## Execução

```bash
flutter pub get
flutter run
```
