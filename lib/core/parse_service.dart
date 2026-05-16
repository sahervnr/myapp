import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ParseService {
  static const String _taskClassName = 'Task';

  Future<List<ParseObject>> fetchRemoteTasks() async {
    final QueryBuilder<ParseObject> taskQuery = QueryBuilder<ParseObject>(
      ParseObject(_taskClassName),
    )..orderByDescending('createdAt');

    final ParseResponse response = await taskQuery.query();
    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    }
    return [];
  }

  Future<ParseResponse> commitTaskRecord({
    required String title,
    required String description,
    ParseObject? existingRecord,
  }) async {
    final record = existingRecord ?? ParseObject(_taskClassName);
    record.set<String>('title', title);
    record.set<String>('description', description);
    return await record.save();
  }

  Future<ParseResponse> removeTaskRecord(ParseObject pointer) async {
    return await pointer.delete();
  }
}
