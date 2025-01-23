import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:scribe/brick/models/document.model.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: "nodes"),
)
class Node extends OfflineFirstWithSupabaseModel {
  Node({required this.id, required this.document, this.attributes = const {}});

  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  final Document document;

  final Map<String, dynamic> attributes;
}
