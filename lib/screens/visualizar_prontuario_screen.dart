import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prontuario.dart';
import '../services/firestore_service.dart';

class VisualizarProntuarioScreen extends StatefulWidget {
  final String prontuarioId;

  const VisualizarProntuarioScreen({super.key, required this.prontuarioId});

  @override
  State<VisualizarProntuarioScreen> createState() =>
      _VisualizarProntuarioScreenState();
}

class _VisualizarProntuarioScreenState
    extends State<VisualizarProntuarioScreen> {
  final _service = FirestoreService();
  Prontuario? _prontuario;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarProntuario();
  }

  Future<void> _carregarProntuario() async {
    final p = await _service.getProntuarioPorId(widget.prontuarioId);
    setState(() {
      _prontuario = p;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_prontuario == null) {
      return const Scaffold(
        body: Center(child: Text('Prontuário não encontrado.')),
      );
    }

    final dataFmt = DateFormat('dd/MM/yyyy').format(_prontuario!.data);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Prontuário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paciente:', style: Theme.of(context).textTheme.titleMedium),
            Text(
              _prontuario!.paciente,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Text('Data:', style: Theme.of(context).textTheme.titleMedium),
            Text(dataFmt, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            Text('Descrição:', style: Theme.of(context).textTheme.titleMedium),
            Text(
              _prontuario!.descricao,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
