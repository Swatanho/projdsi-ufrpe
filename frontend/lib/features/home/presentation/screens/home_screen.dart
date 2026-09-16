import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';
import 'prediction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;

  final List<_Patient> _patients = const [
    _Patient(
      name: 'Ana Silva',
      age: 42,
      gender: 'Feminino',
      registeredAt: '12/03/2024',
      risk: _RiskLevel.high,
    ),
    _Patient(
      name: 'Carlos Mendes',
      age: 58,
      gender: 'Masculino',
      registeredAt: '08/03/2024',
      risk: _RiskLevel.high,
    ),
    _Patient(
      name: 'Beatriz Costa',
      age: 36,
      gender: 'Feminino',
      registeredAt: '05/03/2024',
      risk: _RiskLevel.low,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPrediction() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PredictionScreen()),
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
    final query = _searchController.text.trim().toLowerCase();
    final visiblePatients = _patients
        .where((patient) => patient.name.toLowerCase().contains(query))
        .toList();

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
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildSearchField(),
                    const SizedBox(height: 14),
                    _buildNewPatientButton(),
                    const SizedBox(height: 14),
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
                          '${visiblePatients.length} pacientes',
                          style: const TextStyle(
                            color: Color(0xFF0D8279),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    if (visiblePatients.isEmpty)
                      const _EmptyPatients()
                    else
                      ...visiblePatients.map(_buildPatientCard),
                    const SizedBox(height: 14),
                    const _InformationCard(),
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

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome do médico logado, lido do Firestore.
              StreamBuilder<DoctorProfile>(
                stream: AuthService.instance.doctorProfileStream(),
                builder: (context, snapshot) {
                  final name = snapshot.data?.name.trim() ?? '';
                  final greeting =
                      name.isEmpty ? 'Olá, médico(a)' : 'Olá, Dr(a). $name';
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
                'Seus pacientes',
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
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF56706F),
              size: 21,
            ),
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
        prefixIcon: const Icon(Icons.search, color: Color(0xFF66807F), size: 22),
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
        onPressed: _openPrediction,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Novo Paciente'),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF0D8279),
          foregroundColor: Colors.white,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildPatientCard(_Patient patient) {
    final isHighRisk = patient.risk == _RiskLevel.high;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFD8E5E3)),
      ),
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
              _RiskBadge(label: isHighRisk ? 'ALTO' : 'BAIXO', high: isHighRisk),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                '${patient.age} anos • ${patient.gender}',
                style: const TextStyle(color: Color(0xFF718383), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Cadastrado em ${patient.registeredAt}',
                  style: const TextStyle(color: Color(0xFF718383), fontSize: 11),
                ),
              ),
              TextButton(
                onPressed: _openPrediction,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF087A72),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Ver paciente',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
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
            onTap: () => setState(() => _selectedTab = 1),
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'Perfil',
            selected: _selectedTab == 2,
            onTap: () => setState(() => _selectedTab = 2),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFD8E5E3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.circle, size: 7, color: Color(0xFF2CA27A)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'O painel usa dados cadastrais e histórico de risco\npara priorizar acompanhamento.',
              style: TextStyle(
                color: Color(0xFF718383),
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPatients extends StatelessWidget {
  const _EmptyPatients();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'Nenhum paciente encontrado',
          style: TextStyle(color: Color(0xFF718383), fontSize: 13),
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.label, required this.high});

  final String label;
  final bool high;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: high ? const Color(0xFFFFA52F) : const Color(0xFFD9F0ED),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: high ? const Color(0xFF263B3A) : const Color(0xFF0B7770),
          fontSize: 10,
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

class _Patient {
  const _Patient({
    required this.name,
    required this.age,
    required this.gender,
    required this.registeredAt,
    required this.risk,
  });

  final String name;
  final int age;
  final String gender;
  final String registeredAt;
  final _RiskLevel risk;
}

enum _RiskLevel { high, low }
