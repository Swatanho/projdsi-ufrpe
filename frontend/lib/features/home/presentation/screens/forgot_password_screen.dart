import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _crmController = TextEditingController();

  // Cores alinhadas com o padrão do projeto
  static const primaryColor = Color(0xFF0D8279);
  static const backgroundColor = Color(0xFFF4F8F7);

  @override
  void dispose() {
    _crmController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    // Apenas feedback visual inicial (Frontend)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solicitação de redefinição enviada!'),
        backgroundColor: primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone / Logo
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.monitor_heart_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                // Título e Subtítulo
                const Text(
                  'Redefinir Senha',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173A3A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Informe o CRM para o qual deseja redefinir\na sua senha',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718383),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

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
                        'CRM',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173A3A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _crmController,
                        decoration: InputDecoration(
                          hintText: 'CRM-123456',
                          hintStyle: const TextStyle(color: Color(0xFF718383)),
                          prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF718383)),
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
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _handleResetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Redefinir Senha',
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
                const SizedBox(height: 36),

                // Botão de Voltar ao Login
                GestureDetector(
                  onTap: () {
                    // Retorna para a tela de Login (desempilha a rota atual)
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Voltar ao Login',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Rodapé de Segurança
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