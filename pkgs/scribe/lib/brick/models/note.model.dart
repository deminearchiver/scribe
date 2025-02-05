import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scribe/brick/models/reminder.model.dart';
import 'package:scribe/brick/models/user.model.dart';

import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: "notes"),
)
class NoteModel extends OfflineFirstWithSupabaseModel {
  // factory NoteModel({
  //   String? id,
  //   List<ReminderModel> reminders = const [],
  //   DateTime? createdAt,
  //   DateTime? updatedAt,
  //   String? title,
  //   Map<String, dynamic> rawQuillDelta = const {"ops": []},
  // }) => _NoteModel(
  //   id: id ?? const Uuid().v4(),

  //   createdAt: createdAt ?? DateTime.now(),
  //   updatedAt: updatedAt ?? createdAt ?? DateTime.now(),
  //   reminders:
  //       reminders is EqualUnmodifiableListView
  //           ? reminders
  //           : EqualUnmodifiableListView(reminders),
  //   title: title,
  //   rawQuillDelta:
  //       rawQuillDelta is EqualUnmodifiableMapView
  //           ? rawQuillDelta
  //           : EqualUnmodifiableMapView(rawQuillDelta),
  // );
  NoteModel({
    String? id,
    required this.user,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.title,
    Map<String, dynamic> rawQuillDelta = const {"ops": []},
  }) : id = id ?? const Uuid().v4(),

       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now(),
       rawQuillDelta =
           rawQuillDelta is EqualUnmodifiableMapView
               ? rawQuillDelta
               : EqualUnmodifiableMapView(rawQuillDelta);

  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  @Supabase(foreignKey: "user_id")
  final UserModel user;

  @Sqlite(ignore: true)
  String get userId => user.id;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String? title;

  final Map<String, dynamic> rawQuillDelta;

  // @useResult
  // NoteModel copyWith({
  //   String id,
  //   List<ReminderModel> reminders,
  //   DateTime createdAt,
  //   DateTime updatedAt,
  //   String title,
  //   Map<String, dynamic> rawQuillDelta,
  // });
}

abstract interface class NoteModelBase {}

// class _NoteModel extends OfflineFirstWithSupabaseModel implements NoteModel {
//   _NoteModel({
//     required this.id,
//     required this.reminders,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.title,
//     required this.rawQuillDelta,
//   });

//   @override
//   final String id;

//   @override
//   final List<ReminderModel> reminders;

//   @override
//   final DateTime createdAt;

//   @override
//   final DateTime updatedAt;

//   @override
//   final String? title;

//   @override
//   final Map<String, dynamic> rawQuillDelta;

//   @pragma("vm:prefer-inline")
//   @override
//   NoteModel copyWith({
//     Object id = _sentinel,
//     Object reminders = _sentinel,
//     Object createdAt = _sentinel,
//     Object updatedAt = _sentinel,
//     Object title = _sentinel,
//     Object rawQuillDelta = _sentinel,
//   }) {
//     if (id == _sentinel &&
//         reminders == _sentinel &&
//         createdAt == _sentinel &&
//         updatedAt == _sentinel &&
//         title == _sentinel &&
//         rawQuillDelta == _sentinel) {
//       return this;
//     }
//     return _NoteModel(
//       id: id == _sentinel ? this.id : id as String,

//       reminders:
//           reminders == _sentinel
//               ? this.reminders
//               : reminders as List<ReminderModel>,
//       createdAt:
//           createdAt == _sentinel ? this.createdAt : createdAt as DateTime,
//       updatedAt:
//           updatedAt == _sentinel ? this.updatedAt : updatedAt as DateTime,
//       title: title == _sentinel ? this.title : title as String,
//       rawQuillDelta:
//           rawQuillDelta == _sentinel
//               ? this.rawQuillDelta
//               : rawQuillDelta as Map<String, dynamic>,
//     );
//   }

//   @override
//   String toString() {
//     return "NoteModel(id: $id, reminders: $reminders, createdAt: $createdAt, updatedAt: $updatedAt, title: $title, rawQuillDelta: $rawQuillDelta)";
//   }
// }

class _Sentinel {
  const _Sentinel();
}

const Object _sentinel = _Sentinel();
