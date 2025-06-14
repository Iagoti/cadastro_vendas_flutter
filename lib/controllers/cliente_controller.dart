import '../models/cliente_model.dart';
import '../services/cliente_service.dart';

class ClienteController {
  final ClienteService _service;

  ClienteController(this._service);

  Future<int> salvarCliente(ClienteModel cliente) async {
    return await _service.salvarCliente(cliente);
  }

  Future<List<ClienteModel>> listarClientes() async {
    return await _service.listarClientes();
  }

  Future<List<ClienteModel>> buscarClientesPorNome(String nome) async {
    return await _service.buscarClientesPorNome(nome);
  }

  Future<void> excluirCliente(int cdCliente) async {
    await _service.excluirCliente(cdCliente);
  }
}