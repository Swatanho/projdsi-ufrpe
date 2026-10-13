import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      if (user != null && user.email != null) {
        // Preenche o e-mail logo à partida (só de leitura)
        _emailController.text = user.email!;
        
        // Procura o documento associado a este e-mail
        final query = await FirebaseFirestore.instance
            .collection('doctors')
            .where('email', isEqualTo: user.email)
            .get();

        if (query.docs.isNotEmpty) {
          final data = query.docs.first.data();
          _nameController.text = data['name'] ?? '';
          _crmController.text = data['crm'] ?? '';
          _phoneController.text = data['phone'] ?? '';
        }
      }
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
      if (user == null || user.email == null) {
        _mostrarErro('Utilizador não autenticado.');
        return;
      }

      // Procura o documento correto através do e-mail
      final query = await FirebaseFirestore.instance
          .collection('doctors')
          .where('email', isEqualTo: user.email)
          .get();

      if (query.docs.isEmpty) {
        _mostrarErro('Perfil não encontrado na base de dados.');
        return;
      }

      // Extrai o ID automático do documento no Firestore
      final docId = query.docs.first.id;

      // Faz o update apontando para o ID exato
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(docId)
          .update({
        'name': _nameController.text.trim(),
        'crm': _crmController.text.trim(),
        'phone': _phoneController.text.trim(),
        // O email não é atualizado aqui para não quebrar o login
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
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
        backgroundColor: Colors.red[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _crmController,
                    decoration: const InputDecoration(
                      labelText: 'CRM',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // O campo de E-mail deve estar bloqueado para edição 
                  // (pois é a nossa chave de ligação primária)
                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: const Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.grey[200],
  ),
),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _atualizarPerfil,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal, // Ajusta para a cor da tua app
                    ),
                    child: const Text(
                      'Guardar Alterações',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}