// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20241209160825_up = [
  InsertTable('User'),
  InsertColumn('name', Column.varchar, onTable: 'User'),
  InsertColumn('id', Column.varchar, onTable: 'User', unique: true),
  CreateIndex(columns: ['id'], onTable: 'User', unique: true)
];

const List<MigrationCommand> _migration_20241209160825_down = [
  DropTable('User'),
  DropColumn('name', onTable: 'User'),
  DropColumn('id', onTable: 'User'),
  DropIndex('index_User_on_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20241209160825',
  up: _migration_20241209160825_up,
  down: _migration_20241209160825_down,
)
class Migration20241209160825 extends Migration {
  const Migration20241209160825()
    : super(
        version: 20241209160825,
        up: _migration_20241209160825_up,
        down: _migration_20241209160825_down,
      );
}
