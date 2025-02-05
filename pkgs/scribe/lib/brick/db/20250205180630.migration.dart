// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20250205180630_up = [
  InsertTable('NoteModel'),
  InsertTable('ReminderModel'),
  InsertTable('UserModel'),
  InsertColumn('id', Column.varchar, onTable: 'NoteModel', unique: true),
  InsertForeignKey('NoteModel', 'UserModel', foreignKeyColumn: 'user_UserModel_brick_id', onDeleteCascade: false, onDeleteSetDefault: false),
  InsertColumn('created_at', Column.datetime, onTable: 'NoteModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'NoteModel'),
  InsertColumn('title', Column.varchar, onTable: 'NoteModel'),
  InsertColumn('raw_quill_delta', Column.varchar, onTable: 'NoteModel'),
  InsertColumn('id', Column.varchar, onTable: 'ReminderModel', unique: true),
  InsertForeignKey('ReminderModel', 'NoteModel', foreignKeyColumn: 'note_NoteModel_brick_id', onDeleteCascade: false, onDeleteSetDefault: false),
  InsertColumn('created_at', Column.datetime, onTable: 'ReminderModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'ReminderModel'),
  InsertColumn('notification_id', Column.integer, onTable: 'ReminderModel'),
  InsertColumn('id', Column.varchar, onTable: 'UserModel', unique: true),
  InsertColumn('created_at', Column.datetime, onTable: 'UserModel'),
  InsertColumn('updated_at', Column.datetime, onTable: 'UserModel'),
  InsertColumn('avatar_url', Column.varchar, onTable: 'UserModel'),
  InsertColumn('name', Column.varchar, onTable: 'UserModel'),
  CreateIndex(columns: ['id'], onTable: 'NoteModel', unique: true),
  CreateIndex(columns: ['id'], onTable: 'ReminderModel', unique: true),
  CreateIndex(columns: ['id'], onTable: 'UserModel', unique: true)
];

const List<MigrationCommand> _migration_20250205180630_down = [
  DropTable('NoteModel'),
  DropTable('ReminderModel'),
  DropTable('UserModel'),
  DropColumn('id', onTable: 'NoteModel'),
  DropColumn('user_UserModel_brick_id', onTable: 'NoteModel'),
  DropColumn('created_at', onTable: 'NoteModel'),
  DropColumn('updated_at', onTable: 'NoteModel'),
  DropColumn('title', onTable: 'NoteModel'),
  DropColumn('raw_quill_delta', onTable: 'NoteModel'),
  DropColumn('id', onTable: 'ReminderModel'),
  DropColumn('note_NoteModel_brick_id', onTable: 'ReminderModel'),
  DropColumn('created_at', onTable: 'ReminderModel'),
  DropColumn('updated_at', onTable: 'ReminderModel'),
  DropColumn('notification_id', onTable: 'ReminderModel'),
  DropColumn('id', onTable: 'UserModel'),
  DropColumn('created_at', onTable: 'UserModel'),
  DropColumn('updated_at', onTable: 'UserModel'),
  DropColumn('avatar_url', onTable: 'UserModel'),
  DropColumn('name', onTable: 'UserModel'),
  DropIndex('index_NoteModel_on_id'),
  DropIndex('index_ReminderModel_on_id'),
  DropIndex('index_UserModel_on_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20250205180630',
  up: _migration_20250205180630_up,
  down: _migration_20250205180630_down,
)
class Migration20250205180630 extends Migration {
  const Migration20250205180630()
    : super(
        version: 20250205180630,
        up: _migration_20250205180630_up,
        down: _migration_20250205180630_down,
      );
}
