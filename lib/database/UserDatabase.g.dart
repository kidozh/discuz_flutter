// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorUserDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$UserDatabaseBuilder databaseBuilder(String name) =>
      _$UserDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$UserDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$UserDatabaseBuilder(null);
}

class _$UserDatabaseBuilder {
  _$UserDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$UserDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$UserDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<UserDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$UserDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$UserDatabase extends UserDatabase {
  _$UserDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _userDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `User` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `auth` TEXT NOT NULL, `saltkey` TEXT NOT NULL, `username` TEXT NOT NULL, `avatarUrl` TEXT NOT NULL, `groupId` INTEGER NOT NULL, `uid` INTEGER NOT NULL, `readPerm` INTEGER NOT NULL, `discuz_id` INTEGER NOT NULL, FOREIGN KEY (`discuz_id`) REFERENCES `Discuz` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Discuz` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `discuzVersion` TEXT NOT NULL, `charset` TEXT NOT NULL, `apiVersion` INTEGER NOT NULL, `pluginVersion` TEXT NOT NULL, `regname` TEXT NOT NULL, `qqconnect` INTEGER NOT NULL, `wsqqqconnect` TEXT NOT NULL, `wsqhideregister` TEXT NOT NULL, `siteName` TEXT NOT NULL, `siteId` TEXT NOT NULL, `uCenterURL` TEXT NOT NULL, `defaultFid` TEXT NOT NULL, `baseURL` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'User',
            (User item) => <String, Object?>{
                  'id': item.id,
                  'auth': item.auth,
                  'saltkey': item.saltkey,
                  'username': item.username,
                  'avatarUrl': item.avatarUrl,
                  'groupId': item.groupId,
                  'uid': item.uid,
                  'readPerm': item.readPerm,
                  'discuz_id': item.discuzId
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  @override
  Future<List<User>> findAllUsers() async {
    return _queryAdapter.queryList('SELECT * FROM User',
        mapper: (Map<String, Object?> row) => User(
            row['id'] as int?,
            row['auth'] as String,
            row['saltkey'] as String,
            row['username'] as String,
            row['avatarUrl'] as String,
            row['groupId'] as int,
            row['uid'] as int,
            row['readPerm'] as int,
            row['discuz_id'] as int));
  }

  @override
  Stream<List<User>> findAllDiscuzStream() {
    return _queryAdapter.queryListStream('SELECT * FROM User',
        mapper: (Map<String, Object?> row) => User(
            row['id'] as int?,
            row['auth'] as String,
            row['saltkey'] as String,
            row['username'] as String,
            row['avatarUrl'] as String,
            row['groupId'] as int,
            row['uid'] as int,
            row['readPerm'] as int,
            row['discuz_id'] as int),
        queryableName: 'User',
        isView: false);
  }

  @override
  Future<List<User>> findAllUsersByDiscuzId(int discuzId) async {
    return _queryAdapter.queryList('SELECT * FROM User WHERE discuzId=?1',
        mapper: (Map<String, Object?> row) => User(
            row['id'] as int?,
            row['auth'] as String,
            row['saltkey'] as String,
            row['username'] as String,
            row['avatarUrl'] as String,
            row['groupId'] as int,
            row['uid'] as int,
            row['readPerm'] as int,
            row['discuz_id'] as int),
        arguments: [discuzId]);
  }

  @override
  Future<void> insert(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.replace);
  }
}
