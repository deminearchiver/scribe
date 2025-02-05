import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:scribe/brick/models/note.model.dart';
import 'package:scribe/brick/models/user.model.dart';

import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: "reminders"),
)
class ReminderModel extends OfflineFirstWithSupabaseModel {
  ReminderModel({
    String? id,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    this.notificationId,
  }) : id = id ?? const Uuid().v4();

  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  @Supabase(foreignKey: "note_id")
  final NoteModel note;

  @Sqlite(ignore: true)
  String get noteId => note.id;

  final DateTime createdAt;
  final DateTime updatedAt;

  @Supabase(ignore: true)
  final int? notificationId;
}
