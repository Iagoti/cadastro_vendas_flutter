import 'package:cadastro_vendas_flutter/models/query_result_model.dart';
import 'package:cadastro_vendas_flutter/repositories/sql_query_repository.dart';

class SqlQueryService {
  final SqlQueryRepository _repository = SqlQueryRepository();

  Future<QueryResultModel> execute(String sql) async {
    final result = await _repository.executeQuery(sql);
    return QueryResultModel(rows: result);
  }
}