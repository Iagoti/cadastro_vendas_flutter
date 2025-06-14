class QueryResultModel {
  final List<Map<String, dynamic>> rows;

  QueryResultModel({required this.rows});

  Map<String, dynamic> toJson() {
    return {'rows': rows};
  }
}
