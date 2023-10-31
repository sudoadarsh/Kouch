import 'package:http/http.dart' as http;
import 'package:kouch/src/auth/kouch_auth.dart';
import 'package:kouch/src/errors/kouch_exception.dart';
import 'package:kouch/src/utils/kouch_parameters.dart';

abstract class _KouchDatabase {
  const _KouchDatabase();

  /// Creates a new database.
  /// Throws [KouchDatabaseException] if fails to create the database.
  /// * [shards] : Shards, aka the number of range partitions. Default is 8, unless overridden in the cluster config.
  /// * [replicas] : The number of copies of the database in the cluster. The default is 3, unless overridden in the cluster config .
  /// * [partitioned] : Whether to create a partitioned database. Default is false.
  Future<void> create({int shards, int replicas, bool partitioned});

  /// Deletes the database and all the documents and attachments contained within it.
  Future<void> delete();
}

class KouchDatabase implements _KouchDatabase {
  final String host;
  final KouchAuth auth;

  /// The name of the database.
  final String name;
  const KouchDatabase(this.host, this.auth, {required this.name});

  @override
  Future<void> create({
    int shards = 8,
    int replicas = 3,
    bool partitioned = false,
  }) async {
    // The query parameters.
    final Map<String, dynamic> query = {
      KouchParameters.q: shards.toString(),
      KouchParameters.n: replicas.toString(),
      KouchParameters.partitioned: partitioned.toString(),
    };
    // Create the request.
    final http.Response response = await http.put(
      Uri.parse("$host/$name").replace(queryParameters: query),
      headers: auth.authHeaders(),
    );
    // Validate the response.
    if (response.statusCode == 200 || response.statusCode == 201) {
      return; // Success.
    }
    throw KouchDatabaseException(response.body);
  }

  @override
  Future<void> delete() async {
    // Create the request.
    final http.Response response = await http.delete(
      Uri.parse("$host/$name"),
      headers: auth.authHeaders(),
    );
    // Validate the response.
    if (response.statusCode != 200) throw KouchDatabaseException(response.body);
    return; // Success.
  }
}
