// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20250123123903.migration.dart';
part '20250119172359.migration.dart';
part '20250122151401.migration.dart';
part '20250122160937.migration.dart';
part '20250122163315.migration.dart';
part '20250122163827.migration.dart';
part '20250122171051.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{
  const Migration20250123123903(),
  const Migration20250119172359(),
  const Migration20250122151401(),
  const Migration20250122160937(),
  const Migration20250122163315(),
  const Migration20250122163827(),
  const Migration20250122171051()
};

/// A consumable database structure including the latest generated migration.
final schema = Schema(20250123123903, generatorVersion: 1, tables: <SchemaTable>{
  SchemaTable('Node', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('id', Column.varchar, unique: true),
    SchemaColumn('document_Document_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'Document',
        onDeleteCascade: false,
        onDeleteSetDefault: false),
    SchemaColumn('attributes', Column.varchar)
  }, indices: <SchemaIndex>{
    SchemaIndex(columns: ['id'], unique: true)
  }),
  SchemaTable('Reminder', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('id', Column.varchar, unique: true),
    SchemaColumn('note_Note_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'Note',
        onDeleteCascade: false,
        onDeleteSetDefault: false),
    SchemaColumn('created_at', Column.datetime),
    SchemaColumn('updated_at', Column.datetime)
  }, indices: <SchemaIndex>{
    SchemaIndex(columns: ['id'], unique: true)
  }),
  SchemaTable('_brick_Note_reminders', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('l_Note_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'Note',
        onDeleteCascade: true,
        onDeleteSetDefault: false),
    SchemaColumn('f_Reminder_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'Reminder',
        onDeleteCascade: true,
        onDeleteSetDefault: false)
  }, indices: <SchemaIndex>{
    SchemaIndex(
        columns: ['l_Note_brick_id', 'f_Reminder_brick_id'], unique: true)
  }),
  SchemaTable('Note', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('id', Column.varchar, unique: true),
    SchemaColumn('created_at', Column.datetime),
    SchemaColumn('updated_at', Column.datetime),
    SchemaColumn('title', Column.varchar)
  }, indices: <SchemaIndex>{
    SchemaIndex(columns: ['id'], unique: true)
  }),
  SchemaTable('Document', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('id', Column.varchar, unique: true),
    SchemaColumn('attributes', Column.varchar)
  }, indices: <SchemaIndex>{
    SchemaIndex(columns: ['id'], unique: true)
  })
});
