import 'package:brick_core/src/model.dart';
import 'package:brick_core/src/model_repository.dart';
import 'package:brick_core/src/provider.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:scribe/brick/models/reminder.model.dart';

import 'package:supabase_flutter/supabase_flutter.dart' as sf;
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: "notes"),
)
class Note extends OfflineFirstWithSupabaseModel {
  Note({
    String? id,
    required this.createdAt,
    required this.updatedAt,
    List<Reminder>? reminders,
    this.title,
  }) : id = id ?? const Uuid().v4(),
       reminders = reminders ?? <Reminder>[];

  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  final List<Reminder> reminders;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String? title;
}

// void _a() async {
//   final supabase = sf.Supabase.instance.client;
//   final data = await supabase.from("aaa").select();
// }
