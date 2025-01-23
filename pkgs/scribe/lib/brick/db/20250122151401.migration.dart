// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20250122151401_up = [
  InsertTable('Reminder'),
  InsertColumn('id', Column.varchar, onTable: 'Reminder', unique: true),
  CreateIndex(columns: ['id'], onTable: 'Reminder', unique: true)
];

const List<MigrationCommand> _migration_20250122151401_down = [
  DropTable('Reminder'),
  DropColumn('id', onTable: 'Reminder'),
  DropIndex('index_Reminder_on_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20250122151401',
  up: _migration_20250122151401_up,
  down: _migration_20250122151401_down,
)
class Migration20250122151401 extends Migration {
  const Migration20250122151401()
    : super(
        version: 20250122151401,
        up: _migration_20250122151401_up,
        down: _migration_20250122151401_down,
      );
}
