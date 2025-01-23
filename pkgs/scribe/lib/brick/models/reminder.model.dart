import 'package:brick_core/src/model.dart';
import 'package:brick_core/src/model_repository.dart';
import 'package:brick_core/src/provider.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:scribe/brick/models/note.model.dart';

import 'package:supabase_flutter/supabase_flutter.dart' as sf;
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: "reminders"),
)
class Reminder extends OfflineFirstWithSupabaseModel {
  Reminder({
    String? id,
    // Associations
    required this.note,

    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? const Uuid().v4();

  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  // Associations
  final Note note;

  final DateTime createdAt;
  final DateTime updatedAt;
}

// void _a() async {
//   final supabase = sf.Supabase.instance.client;
//   final data = await supabase.from("aaa").select();
// }
