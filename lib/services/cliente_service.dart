import '../models/cliente_model.dart';
import '../repositories/cliente_repository.dart';

class ClienteService {
  final ClienteRepository _repository;

  ClienteService(this._repository);

  Future<int> salvarCliente(ClienteModel cliente) async {
    try {
      return await _repository.salvarCliente(cliente);
    } catch (e) {
      throw Exception('Falha ao salvar cliente: ${e.toString()}');
    }
  }

  Future<List<ClienteModel>> listarClientes() async {
    try {
      return await _repository.listarClientes();
    } catch (e) {
      throw Exception('Falha ao listar clientes: ${e.toString()}');
    }
  }

  Future<List<ClienteModel>> buscarClientesPorNome(String nome) async {
    try {
      return await _repository.buscarClientesPorNome(nome);
    } catch (e) {
      throw Exception('Falha ao buscar clientes: ${e.toString()}');
    }
  }

  Future<void> excluirCliente(int cdCliente) async {
    try {
      await _repository.excluirCliente(cdCliente);
    } catch (e) {
      throw Exception('Falha ao excluir cliente: ${e.toString()}');
    }
  }
}