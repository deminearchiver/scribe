// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20250122160937_up = [
  InsertColumn('created_at', Column.datetime, onTable: 'Reminder'),
  InsertColumn('updated_at', Column.datetime, onTable: 'Reminder')
];

const List<MigrationCommand> _migration_20250122160937_down = [
  DropColumn('created_at', onTable: 'Reminder'),
  DropColumn('updated_at', onTable: 'Reminder')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20250122160937',
  up: _migration_20250122160937_up,
  down: _migration_20250122160937_down,
)
class Migration20250122160937 extends Migration {
  const Migration20250122160937()
    : super(
        version: 20250122160937,
        up: _migration_20250122160937_up,
        down: _migration_20250122160937_down,
      );
}
