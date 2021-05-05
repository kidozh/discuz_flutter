// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _userDaoInstance;

  DiscuzDao? _discuzDaoInstance;

  ViewHistoryDao? _viewHistoryDaoInstance;

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
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ViewHistory` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `subject` TEXT NOT NULL, `description` TEXT NOT NULL, `type` TEXT NOT NULL, `identification` INTEGER NOT NULL, `author` TEXT NOT NULL, `authorId` INTEGER NOT NULL, `insertTime` INTEGER NOT NULL, `updateTime` INTEGER NOT NULL, `discuz_id` INTEGER NOT NULL, FOREIGN KEY (`discuz_id`) REFERENCES `Discuz` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  DiscuzDao get discuzDao {
    return _discuzDaoInstance ??= _$DiscuzDao(database, changeListener);
  }

  @override
  ViewHistoryDao get viewHistoryDao {
    return _viewHistoryDaoInstance ??=
        _$ViewHistoryDao(database, changeListener);
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
            changeListener),
        _userDeletionAdapter = DeletionAdapter(
            database,
            'User',
            ['id'],
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

  final DeletionAdapter<User> _userDeletionAdapter;

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
    return _queryAdapter.queryList('SELECT * FROM User WHERE discuz_id=?1',
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
  Stream<List<User>> findAllUsersStreamByDiscuzId(int discuzId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM User WHERE discuz_id=?1',
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
        arguments: [discuzId],
        queryableName: 'User',
        isView: false);
  }

  @override
  Future<User?> findUsersByDiscuzIdAndUid(int discuzId, int uid) async {
    return _queryAdapter.query(
        'SELECT * FROM User WHERE discuz_id=?1 AND uid=?2 LIMIT 1',
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
        arguments: [discuzId, uid]);
  }

  @override
  Future<int> insert(User user) {
    return _userInsertionAdapter.insertAndReturnId(
        user, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteUser(User user) async {
    await _userDeletionAdapter.delete(user);
  }
}

class _$DiscuzDao extends DiscuzDao {
  _$DiscuzDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _discuzInsertionAdapter = InsertionAdapter(
            database,
            'Discuz',
            (Discuz item) => <String, Object?>{
                  'id': item.id,
                  'discuzVersion': item.discuzVersion,
                  'charset': item.charset,
                  'apiVersion': item.apiVersion,
                  'pluginVersion': item.pluginVersion,
                  'regname': item.regname,
                  'qqconnect': item.qqconnect ? 1 : 0,
                  'wsqqqconnect': item.wsqqqconnect,
                  'wsqhideregister': item.wsqhideregister,
                  'siteName': item.siteName,
                  'siteId': item.siteId,
                  'uCenterURL': item.uCenterURL,
                  'defaultFid': item.defaultFid,
                  'baseURL': item.baseURL
                },
            changeListener),
        _discuzDeletionAdapter = DeletionAdapter(
            database,
            'Discuz',
            ['id'],
            (Discuz item) => <String, Object?>{
                  'id': item.id,
                  'discuzVersion': item.discuzVersion,
                  'charset': item.charset,
                  'apiVersion': item.apiVersion,
                  'pluginVersion': item.pluginVersion,
                  'regname': item.regname,
                  'qqconnect': item.qqconnect ? 1 : 0,
                  'wsqqqconnect': item.wsqqqconnect,
                  'wsqhideregister': item.wsqhideregister,
                  'siteName': item.siteName,
                  'siteId': item.siteId,
                  'uCenterURL': item.uCenterURL,
                  'defaultFid': item.defaultFid,
                  'baseURL': item.baseURL
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Discuz> _discuzInsertionAdapter;

  final DeletionAdapter<Discuz> _discuzDeletionAdapter;

  @override
  Future<List<Discuz>> findAllDiscuzs() async {
    return _queryAdapter.queryList('SELECT * FROM Discuz',
        mapper: (Map<String, Object?> row) => Discuz(
            row['id'] as int?,
            row['baseURL'] as String,
            row['discuzVersion'] as String,
            row['charset'] as String,
            row['apiVersion'] as int,
            row['pluginVersion'] as String,
            row['regname'] as String,
            (row['qqconnect'] as int) != 0,
            row['wsqqqconnect'] as String,
            row['wsqhideregister'] as String,
            row['siteName'] as String,
            row['siteId'] as String,
            row['uCenterURL'] as String,
            row['defaultFid'] as String));
  }

  @override
  Stream<List<Discuz>> findAllDiscuzStream() {
    return _queryAdapter.queryListStream('SELECT * FROM Discuz',
        mapper: (Map<String, Object?> row) => Discuz(
            row['id'] as int?,
            row['baseURL'] as String,
            row['discuzVersion'] as String,
            row['charset'] as String,
            row['apiVersion'] as int,
            row['pluginVersion'] as String,
            row['regname'] as String,
            (row['qqconnect'] as int) != 0,
            row['wsqqqconnect'] as String,
            row['wsqhideregister'] as String,
            row['siteName'] as String,
            row['siteId'] as String,
            row['uCenterURL'] as String,
            row['defaultFid'] as String),
        queryableName: 'Discuz',
        isView: false);
  }

  @override
  Future<void> insertDiscuz(Discuz discuz) async {
    await _discuzInsertionAdapter.insert(discuz, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteDiscuz(Discuz discuz) async {
    await _discuzDeletionAdapter.delete(discuz);
  }
}

class _$ViewHistoryDao extends ViewHistoryDao {
  _$ViewHistoryDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _viewHistoryInsertionAdapter = InsertionAdapter(
            database,
            'ViewHistory',
            (ViewHistory item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'subject': item.subject,
                  'description': item.description,
                  'type': item.type,
                  'identification': item.identification,
                  'author': item.author,
                  'authorId': item.authorId,
                  'insertTime': _floorDateTimeConverter.encode(item.insertTime),
                  'updateTime': _floorDateTimeConverter.encode(item.updateTime),
                  'discuz_id': item.discuzId
                },
            changeListener),
        _viewHistoryDeletionAdapter = DeletionAdapter(
            database,
            'ViewHistory',
            ['id'],
            (ViewHistory item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'subject': item.subject,
                  'description': item.description,
                  'type': item.type,
                  'identification': item.identification,
                  'author': item.author,
                  'authorId': item.authorId,
                  'insertTime': _floorDateTimeConverter.encode(item.insertTime),
                  'updateTime': _floorDateTimeConverter.encode(item.updateTime),
                  'discuz_id': item.discuzId
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ViewHistory> _viewHistoryInsertionAdapter;

  final DeletionAdapter<ViewHistory> _viewHistoryDeletionAdapter;

  @override
  Future<List<ViewHistory>> findAllViewHistoriesByDiscuzId(int discuzId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ViewHistory WHERE discuz_id=?1 ORDER BY updateTime DESC',
        mapper: (Map<String, Object?> row) => ViewHistory(
            row['id'] as int?,
            row['title'] as String,
            row['subject'] as String,
            row['description'] as String,
            row['type'] as String,
            row['identification'] as int,
            row['author'] as String,
            row['authorId'] as int,
            row['discuz_id'] as int,
            _floorDateTimeConverter.decode(row['updateTime'] as int)),
        arguments: [discuzId]);
  }

  @override
  Stream<List<ViewHistory>> findAllViewHistoriesStreamByDiscuzId(int discuzId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM ViewHistory WHERE discuz_id=?1 ORDER BY updateTime DESC',
        mapper: (Map<String, Object?> row) => ViewHistory(
            row['id'] as int?,
            row['title'] as String,
            row['subject'] as String,
            row['description'] as String,
            row['type'] as String,
            row['identification'] as int,
            row['author'] as String,
            row['authorId'] as int,
            row['discuz_id'] as int,
            _floorDateTimeConverter.decode(row['updateTime'] as int)),
        arguments: [discuzId],
        queryableName: 'ViewHistory',
        isView: false);
  }

  @override
  Future<void> deleteAllViewHistory() async {
    await _queryAdapter.queryNoReturn('DELETE FROM ViewHistory');
  }

  @override
  Future<void> deleteViewHistoryByBBSId(int discuzId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM ViewHistory WHERE discuz_id=?1',
        arguments: [discuzId]);
  }

  @override
  Future<int> insertViewHistory(ViewHistory viewHistory) {
    return _viewHistoryInsertionAdapter.insertAndReturnId(
        viewHistory, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteViewHistory(ViewHistory viewHistory) {
    return _viewHistoryDeletionAdapter.deleteAndReturnChangedRows(viewHistory);
  }

  @override
  Future<int> deleteViewHistories(List<ViewHistory> viewHistories) {
    return _viewHistoryDeletionAdapter
        .deleteListAndReturnChangedRows(viewHistories);
  }

  @override
  Future<void> deleteAllHistories() async {
    if (database is sqflite.Transaction) {
      await super.deleteAllHistories();
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.viewHistoryDao.deleteAllHistories();
      });
    }
  }
}

// ignore_for_file: unused_element
final _floorDateTimeConverter = FloorDateTimeConverter();
