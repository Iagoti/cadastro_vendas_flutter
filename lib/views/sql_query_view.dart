import 'package:cadastro_vendas_flutter/controllers/sql_query_controller.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class SqlQueryView extends StatefulWidget {
  const SqlQueryView({super.key});

  @override
  State<SqlQueryView> createState() => _SqlQueryViewState();
}

class _SqlQueryViewState extends State<SqlQueryView> {
  final _controller = SqlQueryController();
  final _sqlController = TextEditingController();
  String _resultJson = '';
  bool _isLoading = false;

  void _execute() async {
    if (_sqlController.text.isEmpty) {
      _showSnackBar('Por favor, digite uma consulta SQL');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final result = await _controller.executeQuery(_sqlController.text);
      setState(() {
        _resultJson = const JsonEncoder.withIndent('  ').convert(result.toJson());
      });
    } catch (e) {
      setState(() {
        _resultJson = 'Erro: ${e.toString()}';
      });
      _showSnackBar('Erro na consulta: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: const Color(0xFFC29C59),
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sqlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'SQL Query Executor',
          style: TextStyle(color: Color(0xFFC29C59)),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFC29C59)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _sqlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Digite a consulta SQL',
                labelStyle: const TextStyle(color: Color(0xFFC29C59)),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFC29C59)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFC29C59)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFC29C59), width: 2),
                ),
              ),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _execute,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC29C59),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                      'EXECUTAR CONSULTA',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: const Color(0xFFC29C59)),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _resultJson,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
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