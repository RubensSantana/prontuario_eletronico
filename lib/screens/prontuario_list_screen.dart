import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prontuario.dart';
import '../services/firestore_service.dart';
import 'formulario_prontuario_screen.dart';
import 'visualizar_prontuario_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProntuarioListScreen extends StatefulWidget {
  const ProntuarioListScreen({super.key});

  @override
  State<ProntuarioListScreen> createState() => _ProntuarioListScreenState();
}

class _ProntuarioListScreenState extends State<ProntuarioListScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _buscaController = TextEditingController();
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(() {
      setState(() {
        _filtro = _buscaController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, Prontuario p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Excluir prontuário de "${p.paciente}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true && p.id != null) {
      await firestoreService.deletarProntuario(p.id!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Prontuário excluído')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prontuários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Sair',
          ),
        ],
      ),

      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                labelText: 'Buscar por paciente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _filtro.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscaController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Lista de prontuários
          Expanded(
            child: StreamBuilder<List<Prontuario>>(
              stream: firestoreService.getProntuarios(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final todos = snapshot.data ?? [];
                // Aplica o filtro
                final filtrados = todos.where((p) {
                  return p.paciente.toLowerCase().contains(_filtro);
                }).toList();

                if (filtrados.isEmpty) {
                  return const Center(
                    child: Text('Nenhum prontuário encontrado.'),
                  );
                }

                return ListView.builder(
                  itemCount: filtrados.length,
                  itemBuilder: (context, index) {
                    final p = filtrados[index];
                    final dataFmt = DateFormat('dd/MM/yyyy').format(p.data);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(p.paciente),
                        subtitle: Text('$dataFmt — ${p.descricao}'),
                        trailing: Wrap(
                          spacing: 6,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VisualizarProntuarioScreen(
                                    prontuarioId: p.id!,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormularioProntuarioScreen(
                                    prontuarioParaEditar: p,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, p),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FormularioProntuarioScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
