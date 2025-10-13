// lib/screens/formulario_prontuario_screen.dart
import 'package:flutter/material.dart';
import '../models/prontuario.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';

class FormularioProntuarioScreen extends StatefulWidget {
  final Prontuario? prontuarioParaEditar;

  const FormularioProntuarioScreen({Key? key, this.prontuarioParaEditar})
    : super(key: key);

  @override
  _FormularioProntuarioScreenState createState() =>
      _FormularioProntuarioScreenState();
}

class _FormularioProntuarioScreenState
    extends State<FormularioProntuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pacienteController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _service = FirestoreService();
  DateTime _data = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.prontuarioParaEditar != null) {
      _pacienteController.text = widget.prontuarioParaEditar!.paciente;
      _descricaoController.text = widget.prontuarioParaEditar!.descricao;
      _data = widget.prontuarioParaEditar!.data;
    }
  }

  @override
  void dispose() {
    _pacienteController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final prontuario = Prontuario(
        id: widget.prontuarioParaEditar?.id,
        paciente: _pacienteController.text.trim(),
        descricao: _descricaoController.text.trim(),
        data: _data,
      );

      if (widget.prontuarioParaEditar == null) {
        await _service.adicionarProntuario(prontuario);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Prontuário criado')));
      } else {
        await _service.atualizarProntuario(prontuario);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Prontuário atualizado')));
      }

      Navigator.pop(context);
    }
  }

  Future<void> _selecionarData() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() => _data = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(_data);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.prontuarioParaEditar == null
              ? 'Novo Prontuário'
              : 'Editar Prontuário',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _pacienteController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Paciente',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe o nome'
                    : null,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe a descrição'
                    : null,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Data: $dateLabel'),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _selecionarData,
                    child: const Text('Selecionar data'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
