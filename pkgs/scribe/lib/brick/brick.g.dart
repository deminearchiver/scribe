// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_core/query.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/db.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/brick_sqlite.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_supabase/brick_supabase.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:scribe/brick/models/document.model.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:uuid/uuid.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_core/src/model.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_core/src/model_repository.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_core/src/provider.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:scribe/brick/models/note.model.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:supabase_flutter/supabase_flutter.dart' as sf;
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:scribe/brick/models/reminder.model.dart';// GENERATED CODE DO NOT EDIT
// ignore: unused_import
import 'dart:convert';
import 'package:brick_sqlite/brick_sqlite.dart' show SqliteModel, SqliteAdapter, SqliteModelDictionary, RuntimeSqliteColumnDefinition, SqliteProvider;
import 'package:brick_supabase/brick_supabase.dart' show SupabaseProvider, SupabaseModel, SupabaseAdapter, SupabaseModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first/brick_offline_first.dart' show RuntimeOfflineFirstDefinition;
// ignore: unused_import, unused_shown_name
import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;

import '../brick/models/node.model.dart';
import '../brick/models/reminder.model.dart';
import '../brick/models/note.model.dart';
import '../brick/models/document.model.dart';

part 'adapters/node_adapter.g.dart';
part 'adapters/reminder_adapter.g.dart';
part 'adapters/note_adapter.g.dart';
part 'adapters/document_adapter.g.dart';

/// Supabase mappings should only be used when initializing a [SupabaseProvider]
final Map<Type, SupabaseAdapter<SupabaseModel>> supabaseMappings = {
  Node: NodeAdapter(),
  Reminder: ReminderAdapter(),
  Note: NoteAdapter(),
  Document: DocumentAdapter()
};
final supabaseModelDictionary = SupabaseModelDictionary(supabaseMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  Node: NodeAdapter(),
  Reminder: ReminderAdapter(),
  Note: NoteAdapter(),
  Document: DocumentAdapter()
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
