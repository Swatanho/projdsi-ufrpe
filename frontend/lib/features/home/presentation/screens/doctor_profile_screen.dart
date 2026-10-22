import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _nameController = TextEditingController();
  final _crmController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosPerfil();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _crmController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // 1. Carrega os dados do utilizador logado para preencher os campos
  Future<void> _carregarDadosPerfil() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _mostrarErro('Utilizador não autenticado.');
        return;
      }

      _emailController.text = user.email ?? '';
      final snapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user.uid)
          .get();

      if (!snapshot.exists) {
        _mostrarErro('Perfil não encontrado na base de dados.');
        return;
      }

      final data = snapshot.data()!;
      _nameController.text = data['name'] as String? ?? '';
      _crmController.text = data['crm'] as String? ?? '';
      _phoneController.text = data['phone'] as String? ?? '';
    } catch (e) {
      _mostrarErro('Erro ao carregar dados: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Função que atualiza os dados no Firestore encontrando o ID dinamicamente
  Future<void> _atualizarPerfil() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _mostrarErro('Utilizador não autenticado.');
        return;
      }

      final doctorReference = FirebaseFirestore.instance
          .collection('doctors')
          .doc(user.uid);
      final doctorSnapshot = await doctorReference.get();
      if (!doctorSnapshot.exists) {
        _mostrarErro('Perfil não encontrado na base de dados.');
        return;
      }

      await doctorReference.update({
        'name': _nameController.text.trim(),
        'crm': _crmController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Color(0xFF0D8279),
        ),
      );
    } on FirebaseException catch (e) {
      _mostrarErro('Erro ao atualizar: [${e.code}] ${e.message}');
    } catch (e) {
      _mostrarErro('Erro inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: const Color(0xFFB42318),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),
      body: SafeArea(
        child: Column(
          children: [
            // Título superior
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Meu Perfil',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF173A3A),
                      ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0D8279),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: [
                          // Card de Header / Avatar do Médico
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFD8E5E3)),
                            ),
                            child: Column(
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Color(0xFFEAF7F5),
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 48,
                                    color: Color(0xFF0D8279),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _nameController.text.isNotEmpty
                                      ? _nameController.text
                                      : 'Médico',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF173A3A),
                                  ),
                                ),
                                if (_crmController.text.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'CRM: ${_crmController.text}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF718383),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Card com os Campos do Formulário
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFD8E5E3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Informações Pessoais',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF173A3A),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Nome Completo',
                                  icon: Icons.person_outline_rounded,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: _crmController,
                                  label: 'CRM',
                                  icon: Icons.badge_outlined,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'E-mail',
                                  icon: Icons.email_outlined,
                                  readOnly: true,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: _phoneController,
                                  label: 'Telefone',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: TextStyle(
        color: readOnly ? const Color(0xFF718383) : const Color(0xFF173A3A),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF718383), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF0D8279), size: 22),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF0F5F4) : const Color(0xFFFAFCFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD8E5E3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D8279), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0EAE8))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                label: const Text('Voltar'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF173A3A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFCEE3E0)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _atualizarPerfil,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D8279),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}