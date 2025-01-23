// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20250122171051_up = [
  InsertTable('Document'),
  InsertForeignKey('Node', 'Document', foreignKeyColumn: 'document_Document_brick_id', onDeleteCascade: false, onDeleteSetDefault: false),
  InsertColumn('id', Column.varchar, onTable: 'Document', unique: true),
  InsertColumn('attributes', Column.varchar, onTable: 'Document'),
  CreateIndex(columns: ['id'], onTable: 'Document', unique: true)
];

const List<MigrationCommand> _migration_20250122171051_down = [
  DropTable('Document'),
  DropColumn('document_Document_brick_id', onTable: 'Node'),
  DropColumn('id', onTable: 'Document'),
  DropColumn('attributes', onTable: 'Document'),
  DropIndex('index_Document_on_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20250122171051',
  up: _migration_20250122171051_up,
  down: _migration_20250122171051_down,
)
class Migration20250122171051 extends Migration {
  const Migration20250122171051()
    : super(
        version: 20250122171051,
        up: _migration_20250122171051_up,
        down: _migration_20250122171051_down,
      );
}
