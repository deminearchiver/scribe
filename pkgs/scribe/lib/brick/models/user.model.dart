import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:scribe/brick/models/note.model.dart';

import 'package:uuid/uuid.dart';

const uriFrom = r"Uri.parse(data[r'%ANNOTATED_NAME%']! as String])";
const uriTo = r"%INSTANCE_PROPERTY%.toString()";
const uriOrNullFrom =
    r"data[r'%ANNOTATED_NAME%'] != null ? Uri.tryParse(data[r'%ANNOTATED_NAME%']! as String) : null";
const uriOrNullTo = r"%INSTANCE_PROPERTY%?.toString()";

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: "users"),
)
class UserModel extends OfflineFirstWithSupabaseModel {
  UserModel({
    String? id,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
    required this.name,
    // this.notes = const [],
  }) : id = id ?? const Uuid().v4();

  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  final DateTime createdAt;
  final DateTime updatedAt;

  // @Supabase(fromGenerator: uriOrNullFrom, toGenerator: uriOrNullTo)
  // @Sqlite(
  //   columnType: Column.text,
  //   fromGenerator: uriOrNullFrom,
  //   toGenerator: uriOrNullTo,
  // )
  final String? avatarUrl;

  final String name;

  // final List<NoteModel> notes;
}
