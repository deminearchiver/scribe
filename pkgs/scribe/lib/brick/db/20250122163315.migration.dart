// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20250122163315_up = [
  InsertTable('_brick_Note_reminders'),
  InsertTable('Note'),
  InsertForeignKey('_brick_Note_reminders', 'Note', foreignKeyColumn: 'l_Note_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertForeignKey('_brick_Note_reminders', 'Reminder', foreignKeyColumn: 'f_Reminder_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertColumn('id', Column.varchar, onTable: 'Note', unique: true),
  InsertColumn('created_at', Column.datetime, onTable: 'Note'),
  InsertColumn('updated_at', Column.datetime, onTable: 'Note'),
  CreateIndex(columns: ['l_Note_brick_id', 'f_Reminder_brick_id'], onTable: '_brick_Note_reminders', unique: true),
  CreateIndex(columns: ['id'], onTable: 'Note', unique: true)
];

const List<MigrationCommand> _migration_20250122163315_down = [
  DropTable('_brick_Note_reminders'),
  DropTable('Note'),
  DropColumn('l_Note_brick_id', onTable: '_brick_Note_reminders'),
  DropColumn('f_Reminder_brick_id', onTable: '_brick_Note_reminders'),
  DropColumn('id', onTable: 'Note'),
  DropColumn('created_at', onTable: 'Note'),
  DropColumn('updated_at', onTable: 'Note'),
  DropIndex('index__brick_Note_reminders_on_l_Note_brick_id_f_Reminder_brick_id'),
  DropIndex('index_Note_on_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20250122163315',
  up: _migration_20250122163315_up,
  down: _migration_20250122163315_down,
)
class Migration20250122163315 extends Migration {
  const Migration20250122163315()
    : super(
        version: 20250122163315,
        up: _migration_20250122163315_up,
        down: _migration_20250122163315_down,
      );
}
