import 'package:flutter/material.dart';

import '../../../../models/patient_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/doctor_service.dart';
import '../../../../services/patient_service.dart';
import 'agenda_screen.dart';
import '../../../../features/patients/screens/patient_register_screen.dart';
import 'doctor_profile_screen.dart';
import 'patient_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.patientsStream, this.doctorProfileStream});

  final Stream<List<PatientModel>>? patientsStream;
  final Stream<DoctorModel>? doctorProfileStream;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;
  late Stream<List<PatientModel>> _patientsStream;
  late final Stream<DoctorModel> _doctorProfileStream;

  @override
  void initState() {
    super.initState();
    _patientsStream =
        widget.patientsStream ?? PatientService().watchAllPatients();
    _doctorProfileStream =
        widget.doctorProfileStream ?? DoctorService.instance.profileStream();
  }

  void _retryLoadingPatients() {
    setState(() => _patientsStream = PatientService().watchAllPatients());
  }

  void _openPatientRegister() {
    final doctorId = AuthService.instance.currentUserId;
    if (doctorId == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientRegisterScreen(doctorId: doctorId),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPatientDetails(PatientModel patient) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PatientDetailsScreen(patient: patient)),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente encerrar a sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(), // O CABEÇALHO ATUALIZADO
                    const SizedBox(height: 20),
                    _buildSearchField(),
                    const SizedBox(height: 14),
                    _buildNewPatientButton(),
                    const SizedBox(height: 14),
                    _buildPatientDirectory(),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // CABEÇALHO CORRIGIDO: Usa a variável _doctorName que fomos buscar ao Firestore
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saudação com o nome real do médico logado (Firestore).
              StreamBuilder<DoctorModel>(
                stream: _doctorProfileStream,
                builder: (context, snapshot) {
                  final name = snapshot.data?.name;
                  final greeting = (name == null || name.isEmpty)
                      ? 'Olá, Dr(a).'
                      : 'Olá, $name';
                  return Text(
                    greeting,
                    style: const TextStyle(
                      color: Color(0xFF718383),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              const Text(
                'Todos os pacientes',
                style: TextStyle(
                  color: Color(0xFF173A3A),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _confirmLogout,
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout, color: Color(0xFF56706F), size: 21),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Buscar paciente',
        hintStyle: const TextStyle(color: Color(0xFF778C8B), fontSize: 13),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF66807F),
          size: 22,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFD8E5E3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFF0D8279), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildNewPatientButton() {
    return SizedBox(
      width: double.infinity,
      height: 41,
      child: ElevatedButton.icon(
        onPressed: _openPatientRegister,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Novo Paciente'),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF0D8279),
          foregroundColor: Colors.white,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildPatientDirectory() {
    return StreamBuilder<List<PatientModel>>(
      stream: _patientsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _PatientLoadError(onRetry: _retryLoadingPatients);
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF0D8279)),
            ),
          );
        }

        final query = _searchController.text.trim().toLowerCase();
        final patients = (snapshot.data ?? const <PatientModel>[])
            .where((patient) => patient.name.toLowerCase().contains(query))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pacientes cadastrados',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF173A3A),
                  ),
                ),
                Text(
                  '${patients.length} pacientes',
                  style: const TextStyle(
                    color: Color(0xFF0D8279),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            if (patients.isEmpty)
              _EmptyPatients(
                message: query.isEmpty
                    ? 'Nenhum paciente cadastrado ainda'
                    : 'Nenhum paciente encontrado',
              )
            else
              ...patients.map(_buildPatientCard),
          ],
        );
      },
    );
  }

  Widget _buildPatientCard(PatientModel patient) {
    final registeredAt = MaterialLocalizations.of(
      context,
    ).formatMediumDate(patient.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFD8E5E3)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: () => _openPatientDetails(patient),
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        patient.name,
                        style: const TextStyle(
                          color: Color(0xFF173A3A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const _PatientBadge(label: 'CADASTRADO'),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${patient.age} anos • ${patient.gender} • IMC ${patient.bmi.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Color(0xFF718383),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Cadastrado em $registeredAt',
                        style: const TextStyle(
                          color: Color(0xFF718383),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF718383),
                      size: 19,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0EAE8))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.notifications_none,
            label: 'Pacientes',
            selected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _NavItem(
            icon: Icons.access_time,
            label: 'Agenda',
            selected: _selectedTab == 1,
            onTap: () { 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AgendaScreen(),
                ),
              );
            },
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'Perfil',
            selected: _selectedTab == 2,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyPatients extends StatelessWidget {
  const _EmptyPatients({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Color(0xFF718383), fontSize: 13),
        ),
      ),
    );
  }
}

class _PatientLoadError extends StatelessWidget {
  const _PatientLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'Não foi possível carregar os pacientes.',
            style: TextStyle(color: Color(0xFF718383), fontSize: 13),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Tentar novamente'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0D8279),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientBadge extends StatelessWidget {
  const _PatientBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD9F0ED),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0B7770),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF087A72) : const Color(0xFF718383);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
