import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _crmController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Cores de acordo com o design
  static const primaryColor = Color(0xFF0D8279);
  static const backgroundColor = Color(0xFFF4F8F7);

  // Formato aceito: CRM-123456
  static final _crmRegExp = RegExp(r'^crm-?\d{4,8}$', caseSensitive: false);

  @override
  void dispose() {
    _nameController.dispose();
    _crmController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF778C8B)),
      prefixIcon: Icon(icon, color: const Color(0xFF66807F)),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF66807F),
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            )
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD8E5E3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF263B3A),
      ),
    );
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final crm = _crmController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.length < 3) {
      _showError('Informe seu nome completo.');
      return;
    }
    if (!_crmRegExp.hasMatch(crm)) {
      _showError('Informe um CRM válido (ex.: CRM-123456).');
      return;
    }
    if (password.length < 6) {
      _showError('A senha deve ter pelo menos 6 caracteres.');
      return;
    }
    if (password != confirmPassword) {
      _showError('As senhas não coincidem.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.signUp(
        name: name,
        crm: crm,
        password: password,
      );

      // Após o cadastro o usuário já fica autenticado. O `app.dart`
      // observa o estado da sessão e exibe a HomeScreen, então
      // basta fechar esta tela.
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF173A3A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Criar conta',
          style: TextStyle(
            color: Color(0xFF173A3A),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                // Ícone / Logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.monitor_heart_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cadastre-se',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173A3A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Crie sua conta de médico para avaliar\npacientes e consultar predições.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF718383),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Card do Formulário
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFD8E5E3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nome completo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173A3A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        decoration: _buildInputDecoration(
                          hint: 'Dra. Maria Oliveira',
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'CRM',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173A3A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _crmController,
                        decoration: _buildInputDecoration(
                          hint: 'CRM-123456',
                          icon: Icons.badge_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Senha',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173A3A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _buildInputDecoration(
                          hint: 'Mínimo de 6 caracteres',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Confirmar senha',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173A3A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscurePassword,
                        onSubmitted: (_) => _handleRegister(),
                        decoration: _buildInputDecoration(
                          hint: 'Repita a senha',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
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
                              : const Text(
                                  'Criar conta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Mensagem no Rodapé
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: primaryColor),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Seus dados de saúde são protegidos e criptografados.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718383),
                        ),
                      ),
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
}
