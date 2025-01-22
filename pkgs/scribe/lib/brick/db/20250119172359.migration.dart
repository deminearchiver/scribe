// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20250119172359_up = [
  InsertTable('Node'),
  InsertColumn('id', Column.varchar, onTable: 'Node', unique: true),
  InsertColumn('attributes', Column.varchar, onTable: 'Node'),
  CreateIndex(columns: ['id'], onTable: 'Node', unique: true)
];

const List<MigrationCommand> _migration_20250119172359_down = [
  DropTable('Node'),
  DropColumn('id', onTable: 'Node'),
  DropColumn('attributes', onTable: 'Node'),
  DropIndex('index_Node_on_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20250119172359',
  up: _migration_20250119172359_up,
  down: _migration_20250119172359_down,
)
class Migration20250119172359 extends Migration {
  const Migration20250119172359()
    : super(
        version: 20250119172359,
        up: _migration_20250119172359_up,
        down: _migration_20250119172359_down,
      );
}
