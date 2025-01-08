// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20241209160825.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{const Migration20241209160825()};

/// A consumable database structure including the latest generated migration.
final schema =
    Schema(20241209160825, generatorVersion: 1, tables: <SchemaTable>{
  SchemaTable('User', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('id', Column.varchar, unique: true),
    SchemaColumn('name', Column.varchar)
  }, indices: <SchemaIndex>{
    SchemaIndex(columns: ['id'], unique: true)
  })
});
