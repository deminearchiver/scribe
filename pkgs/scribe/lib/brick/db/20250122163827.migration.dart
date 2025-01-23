// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20250122163827_up = [
  InsertForeignKey('Reminder', 'Note', foreignKeyColumn: 'note_Note_brick_id', onDeleteCascade: false, onDeleteSetDefault: false)
];

const List<MigrationCommand> _migration_20250122163827_down = [
  DropColumn('note_Note_brick_id', onTable: 'Reminder')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20250122163827',
  up: _migration_20250122163827_up,
  down: _migration_20250122163827_down,
)
class Migration20250122163827 extends Migration {
  const Migration20250122163827()
    : super(
        version: 20250122163827,
        up: _migration_20250122163827_up,
        down: _migration_20250122163827_down,
      );
}
