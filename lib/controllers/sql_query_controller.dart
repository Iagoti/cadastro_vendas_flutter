import 'package:cadastro_vendas_flutter/models/query_result_model.dart';
import 'package:cadastro_vendas_flutter/services/sql_query_service.dart';

class SqlQueryController {
  final SqlQueryService _service = SqlQueryService();

  Future<QueryResultModel> executeQuery(String sql) async {
    return await _service.execute(sql);
  }
}