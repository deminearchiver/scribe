import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: "documents"),
)
class Document extends OfflineFirstWithSupabaseModel {
  Document({String? id, this.attributes = const {}})
    : id = id ?? const Uuid().v4();

  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  final Map<String, dynamic> attributes;
}
