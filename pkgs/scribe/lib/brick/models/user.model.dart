import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: "users"),
)
class User extends OfflineFirstWithSupabaseModel {
  User({String? id, required this.name}) : id = id ?? const Uuid().v4();

  // Be sure to specify an index that IS NOT auto incremented in your table.
  // An offline-first strategy requires distributed clients to create
  // indexes without fear of collision.
  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  final String name;
}
