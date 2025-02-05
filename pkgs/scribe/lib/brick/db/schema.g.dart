// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20250205180630.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{
  const Migration20250205180630(),};

/// A consumable database structure including the latest generated migration.
final schema = Schema(20250205180630, generatorVersion: 1, tables: <SchemaTable>{
  SchemaTable('NoteModel', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('id', Column.varchar, unique: true),
    SchemaColumn('user_UserModel_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'UserModel',
        onDeleteCascade: false,
        onDeleteSetDefault: false),
    SchemaColumn('created_at', Column.datetime),
    SchemaColumn('updated_at', Column.datetime),
    SchemaColumn('title', Column.varchar),
    SchemaColumn('raw_quill_delta', Column.varchar)
  }, indices: <SchemaIndex>{
    SchemaIndex(columns: ['id'], unique: true)
  }),
  SchemaTable('ReminderModel', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('id', Column.varchar, unique: true),
    SchemaColumn('note_NoteModel_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'NoteModel',
        onDeleteCascade: false,
        onDeleteSetDefault: false),
    SchemaColumn('created_at', Column.datetime),
    SchemaColumn('updated_at', Column.datetime),
    SchemaColumn('notification_id', Column.integer)
  }, indices: <SchemaIndex>{
    SchemaIndex(columns: ['id'], unique: true)
  }),
  SchemaTable('UserModel', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('id', Column.varchar, unique: true),
    SchemaColumn('created_at', Column.datetime),
    SchemaColumn('updated_at', Column.datetime),
    SchemaColumn('avatar_url', Column.varchar),
    SchemaColumn('name', Column.varchar)
  }, indices: <SchemaIndex>{
    SchemaIndex(columns: ['id'], unique: true)
  })
});
