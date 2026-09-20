import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';

class DoctorRegisterScreen extends StatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  State<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _crmController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  double _passwordStrength = 0.0;
  String _strengthLabel = '';

  // Formato aceito: CRM-123456
  static final _crmRegExp = RegExp(r'^crm-?\d{4,8}$', caseSensitive: false);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _crmController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _calculatePasswordStrength(String value) {
    double strength = 0.0;
    if (value.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _strengthLabel = '';
      });
      return;
    }

    if (value.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(value)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(value)) strength += 0.25;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) strength += 0.25;

    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.25) {
        _strengthLabel = 'Fraca';
      } else if (strength <= 0.50) {
        _strengthLabel = 'Média';
      } else if (strength <= 0.75) {
        _strengthLabel = 'Boa';
      } else {
        _strengthLabel = 'Forte';
      }
    });
  }

  Color _getStrengthColor() {
    if (_passwordStrength <= 0.25) return Colors.red;
    if (_passwordStrength <= 0.50) return Colors.orange;
    if (_passwordStrength <= 0.75) return Colors.amber;
    return const Color(0xFF0E5B53);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final crm = _crmController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validação extra: o formato do CRM precisa ser CRM-123456.
    if (!_crmRegExp.hasMatch(crm)) {
      _showError('Informe um CRM válido (ex.: CRM-123456).');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Cria a conta no Firebase Auth e o perfil no Firestore
      // (coleção `doctors/{uid}`).
      await AuthService.instance.signUp(
        name: name,
        crm: crm,
        password: password,
        email: email,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro criado com sucesso!'),
          backgroundColor: Color(0xFF0E5B53),
        ),
      );
      Navigator.pop(context);
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF263B3A),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0E5B53), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Etapa 1 de 1',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0E5B53),
                      ),
                    ),
                    Text(
                      '100%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: Color(0xFFE5E7EB),
                    color: Color(0xFF0E5B53),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Cadastre-se como médico',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Preencha seus dados profissionais para finalizar o registro.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 28),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Nome completo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF111827))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('Como podemos chamar você?', Icons.person_outline),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Informe seu nome.' : null,
                      ),
                      const SizedBox(height: 16),

                      const Text('CRM', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF111827))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _crmController,
                        decoration: _inputDecoration('000000', Icons.badge_outlined),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Informe seu CRM.' : null,
                      ),
                      const SizedBox(height: 16),

                      const Text('E-mail', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF111827))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration('nome@hospital.com', Icons.mail_outline),
                        validator: (value) => value == null || !value.contains('@') ? 'E-mail inválido.' : null,
                      ),
                      const SizedBox(height: 16),

                      const Text('Senha', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF111827))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: _calculatePasswordStrength,
                        decoration: InputDecoration(
                          hintText: 'Mínimo de 8 caracteres',
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF6B7280)),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0E5B53), width: 1.5)),
                        ),
                        validator: (value) => value == null || value.length < 8 ? 'Mínimo de 8 caracteres.' : null,
                      ),
                      const SizedBox(height: 6),
                      if (_passwordController.text.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Força da senha:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                            Text(_strengthLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getStrengthColor())),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: const Color(0xFFE5E7EB),
                          color: _getStrengthColor(),
                          minHeight: 6,
                        ),
                      ],
                      const SizedBox(height: 16),

                      const Text('Confirmar senha', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF111827))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'Repita sua senha',
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF6B7280)),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0E5B53), width: 1.5)),
                        ),
                        validator: (value) => value != _passwordController.text ? 'As senhas não coincidem.' : null,
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: const Color(0xFF0E5B53),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Salvar Cadastro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}