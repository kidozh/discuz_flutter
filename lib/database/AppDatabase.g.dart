// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
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

  SmileyDao? _smileyDaoInstance;

  BlockUserDao? _blockUserDaoInstance;

  FavoriteThreadDao? _favoriteThreadDaoInstance;

  FavoriteForumDao? _favoriteForumDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 5,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
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
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `FavoriteThreadInDatabase` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `favid` INTEGER NOT NULL, `uid` INTEGER NOT NULL, `idInServer` INTEGER NOT NULL, `idType` TEXT NOT NULL, `spaceUid` INTEGER NOT NULL, `title` TEXT NOT NULL, `description` TEXT NOT NULL, `author` TEXT NOT NULL, `replies` INTEGER NOT NULL, `date` INTEGER NOT NULL, `discuz_id` INTEGER NOT NULL, FOREIGN KEY (`discuz_id`) REFERENCES `Discuz` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Smiley` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `code` TEXT NOT NULL, `relativePath` TEXT NOT NULL, `dateTime` INTEGER NOT NULL, `discuz_id` INTEGER NOT NULL, FOREIGN KEY (`discuz_id`) REFERENCES `Discuz` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `BlockUser` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `uid` INTEGER NOT NULL, `name` TEXT NOT NULL, `insertTime` INTEGER NOT NULL, `updateTime` INTEGER NOT NULL, `discuz_id` INTEGER NOT NULL, FOREIGN KEY (`discuz_id`) REFERENCES `Discuz` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `FavoriteForumInDatabase` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `favid` INTEGER NOT NULL, `uid` INTEGER NOT NULL, `idKey` INTEGER NOT NULL, `idType` TEXT NOT NULL, `title` TEXT NOT NULL, `description` TEXT NOT NULL, `date` INTEGER NOT NULL, `discuz_id` INTEGER NOT NULL, FOREIGN KEY (`discuz_id`) REFERENCES `Discuz` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');

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

  @override
  SmileyDao get smileyDao {
    return _smileyDaoInstance ??= _$SmileyDao(database, changeListener);
  }

  @override
  BlockUserDao get blockUserDao {
    return _blockUserDaoInstance ??= _$BlockUserDao(database, changeListener);
  }

  @override
  FavoriteThreadDao get favoriteThreadDao {
    return _favoriteThreadDaoInstance ??=
        _$FavoriteThreadDao(database, changeListener);
  }

  @override
  FavoriteForumDao get favoriteForumDao {
    return _favoriteForumDaoInstance ??=
        _$FavoriteForumDao(database, changeListener);
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
  Future<Discuz?> findDiscuzByBaseURL(String baseURL) async {
    return _queryAdapter.query(
        'SELECT * FROM Discuz WHERE baseURL = ?1 LIMIT 1',
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
        arguments: [baseURL]);
  }

  @override
  Future<int> insertDiscuz(Discuz discuz) {
    return _discuzInsertionAdapter.insertAndReturnId(
        discuz, OnConflictStrategy.replace);
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
  Stream<ViewHistory?> threadHistoryExistInDatabase(int discuzId, int tid) {
    return _queryAdapter.queryStream(
        'SELECT * FROM ViewHistory WHERE discuz_id=?1 AND identification=?2 LIMIT 1',
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
        arguments: [discuzId, tid],
        queryableName: 'ViewHistory',
        isView: false);
  }

  @override
  Stream<ViewHistory?> forumExistInDatabaseStream(int discuzId, int fid) {
    return _queryAdapter.queryStream(
        'SELECT * FROM ViewHistory WHERE discuz_id=?1 AND identification=?2 LIMIT 1',
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
        arguments: [discuzId, fid],
        queryableName: 'ViewHistory',
        isView: false);
  }

  @override
  Future<ViewHistory?> forumExistInDatabase(int discuzId, int fid) async {
    return _queryAdapter.query(
        'SELECT * FROM ViewHistory WHERE discuz_id=?1 AND identification=?2 LIMIT 1',
        mapper: (Map<String, Object?> row) => ViewHistory(row['id'] as int?, row['title'] as String, row['subject'] as String, row['description'] as String, row['type'] as String, row['identification'] as int, row['author'] as String, row['authorId'] as int, row['discuz_id'] as int, _floorDateTimeConverter.decode(row['updateTime'] as int)),
        arguments: [discuzId, fid]);
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

class _$SmileyDao extends SmileyDao {
  _$SmileyDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _smileyInsertionAdapter = InsertionAdapter(
            database,
            'Smiley',
            (Smiley item) => <String, Object?>{
                  'id': item.id,
                  'code': item.code,
                  'relativePath': item.relativePath,
                  'dateTime': _floorDateTimeConverter.encode(item.dateTime),
                  'discuz_id': item.discuzId
                },
            changeListener),
        _smileyDeletionAdapter = DeletionAdapter(
            database,
            'Smiley',
            ['id'],
            (Smiley item) => <String, Object?>{
                  'id': item.id,
                  'code': item.code,
                  'relativePath': item.relativePath,
                  'dateTime': _floorDateTimeConverter.encode(item.dateTime),
                  'discuz_id': item.discuzId
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Smiley> _smileyInsertionAdapter;

  final DeletionAdapter<Smiley> _smileyDeletionAdapter;

  @override
  Future<List<Smiley>> findAllSmileyByDiscuzId(int discuzId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SMILEY WHERE discuz_id=?1 ORDER BY dateTime DESC LIMIT 20',
        mapper: (Map<String, Object?> row) => Smiley(row['code'] as String, row['relativePath'] as String),
        arguments: [discuzId]);
  }

  @override
  Stream<List<Smiley>> findAllSmileyStreamByDiscuzId(int discuzId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM SMILEY WHERE discuz_id=?1 ORDER BY dateTime DESC LIMIT 20',
        mapper: (Map<String, Object?> row) =>
            Smiley(row['code'] as String, row['relativePath'] as String),
        arguments: [discuzId],
        queryableName: 'Smiley',
        isView: false);
  }

  @override
  Future<Smiley?> findSmileyByDiscuzIdAndCode(int discuzId, String code) async {
    return _queryAdapter.query(
        'SELECT * FROM SMILEY WHERE discuz_id=?1 AND code=?2 LIMIT 1',
        mapper: (Map<String, Object?> row) =>
            Smiley(row['code'] as String, row['relativePath'] as String),
        arguments: [discuzId, code]);
  }

  @override
  Future<int> insertSmiley(Smiley smiley) {
    return _smileyInsertionAdapter.insertAndReturnId(
        smiley, OnConflictStrategy.replace);
  }

  @override
  Future<int> deleteSmiley(Smiley smiley) {
    return _smileyDeletionAdapter.deleteAndReturnChangedRows(smiley);
  }
}

class _$BlockUserDao extends BlockUserDao {
  _$BlockUserDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _blockUserInsertionAdapter = InsertionAdapter(
            database,
            'BlockUser',
            (BlockUser item) => <String, Object?>{
                  'id': item.id,
                  'uid': item.uid,
                  'name': item.name,
                  'insertTime': _floorDateTimeConverter.encode(item.insertTime),
                  'updateTime': _floorDateTimeConverter.encode(item.updateTime),
                  'discuz_id': item.discuzId
                },
            changeListener),
        _blockUserDeletionAdapter = DeletionAdapter(
            database,
            'BlockUser',
            ['id'],
            (BlockUser item) => <String, Object?>{
                  'id': item.id,
                  'uid': item.uid,
                  'name': item.name,
                  'insertTime': _floorDateTimeConverter.encode(item.insertTime),
                  'updateTime': _floorDateTimeConverter.encode(item.updateTime),
                  'discuz_id': item.discuzId
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<BlockUser> _blockUserInsertionAdapter;

  final DeletionAdapter<BlockUser> _blockUserDeletionAdapter;

  @override
  Future<List<BlockUser>> isUserBlocked(int uid, int discuzId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM BlockUser WHERE uid =?1 AND discuz_id=?2 LIMIT 2',
        mapper: (Map<String, Object?> row) => BlockUser(
            row['id'] as int?,
            row['uid'] as int,
            row['name'] as String,
            row['discuz_id'] as int,
            _floorDateTimeConverter.decode(row['updateTime'] as int)),
        arguments: [uid, discuzId]);
  }

  @override
  Future<void> deleteBlockUserByUid(int uid, int discuzId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM BlockUser WHERE uid = ?1 AND discuz_id = ?2',
        arguments: [uid, discuzId]);
  }

  @override
  Stream<List<BlockUser>> getBlockUserListStream(int discuzId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM BlockUser WHERE discuz_id=?1',
        mapper: (Map<String, Object?> row) => BlockUser(
            row['id'] as int?,
            row['uid'] as int,
            row['name'] as String,
            row['discuz_id'] as int,
            _floorDateTimeConverter.decode(row['updateTime'] as int)),
        arguments: [discuzId],
        queryableName: 'BlockUser',
        isView: false);
  }

  @override
  Future<int> insertBlockUser(BlockUser blockUser) {
    return _blockUserInsertionAdapter.insertAndReturnId(
        blockUser, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteBlockUser(BlockUser blockUser) {
    return _blockUserDeletionAdapter.deleteAndReturnChangedRows(blockUser);
  }
}

class _$FavoriteThreadDao extends FavoriteThreadDao {
  _$FavoriteThreadDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _favoriteThreadInDatabaseInsertionAdapter = InsertionAdapter(
            database,
            'FavoriteThreadInDatabase',
            (FavoriteThreadInDatabase item) => <String, Object?>{
                  'id': item.id,
                  'favid': item.favid,
                  'uid': item.uid,
                  'idInServer': item.idInServer,
                  'idType': item.idType,
                  'spaceUid': item.spaceUid,
                  'title': item.title,
                  'description': item.description,
                  'author': item.author,
                  'replies': item.replies,
                  'date': _floorDateTimeConverter.encode(item.date),
                  'discuz_id': item.discuzId
                },
            changeListener),
        _favoriteThreadInDatabaseDeletionAdapter = DeletionAdapter(
            database,
            'FavoriteThreadInDatabase',
            ['id'],
            (FavoriteThreadInDatabase item) => <String, Object?>{
                  'id': item.id,
                  'favid': item.favid,
                  'uid': item.uid,
                  'idInServer': item.idInServer,
                  'idType': item.idType,
                  'spaceUid': item.spaceUid,
                  'title': item.title,
                  'description': item.description,
                  'author': item.author,
                  'replies': item.replies,
                  'date': _floorDateTimeConverter.encode(item.date),
                  'discuz_id': item.discuzId
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<FavoriteThreadInDatabase>
      _favoriteThreadInDatabaseInsertionAdapter;

  final DeletionAdapter<FavoriteThreadInDatabase>
      _favoriteThreadInDatabaseDeletionAdapter;

  @override
  Future<List<FavoriteThreadInDatabase>> getFavoriteThreadList(
      int discuzId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM FavoriteThreadInDatabase WHERE discuz_id=?1',
        mapper: (Map<String, Object?> row) => FavoriteThreadInDatabase(
            row['id'] as int?,
            row['favid'] as int,
            row['uid'] as int,
            row['idInServer'] as int,
            row['idType'] as String,
            row['spaceUid'] as int,
            row['title'] as String,
            row['description'] as String,
            row['author'] as String,
            row['replies'] as int,
            _floorDateTimeConverter.decode(row['date'] as int),
            row['discuz_id'] as int),
        arguments: [discuzId]);
  }

  @override
  Stream<List<FavoriteThreadInDatabase>> getFavoriteThreadListStream(
      int discuzId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM FavoriteThreadInDatabase WHERE discuz_id=?1 ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => FavoriteThreadInDatabase(
            row['id'] as int?,
            row['favid'] as int,
            row['uid'] as int,
            row['idInServer'] as int,
            row['idType'] as String,
            row['spaceUid'] as int,
            row['title'] as String,
            row['description'] as String,
            row['author'] as String,
            row['replies'] as int,
            _floorDateTimeConverter.decode(row['date'] as int),
            row['discuz_id'] as int),
        arguments: [discuzId],
        queryableName: 'FavoriteThreadInDatabase',
        isView: false);
  }

  @override
  Future<FavoriteThreadInDatabase?> getFavoriteThreadByTid(
      int idInServer, int discuzId) async {
    return _queryAdapter.query(
        'SELECT * FROM FavoriteThreadInDatabase WHERE idInServer=?1 AND discuz_id=?2  LIMIT 1',
        mapper: (Map<String, Object?> row) => FavoriteThreadInDatabase(row['id'] as int?, row['favid'] as int, row['uid'] as int, row['idInServer'] as int, row['idType'] as String, row['spaceUid'] as int, row['title'] as String, row['description'] as String, row['author'] as String, row['replies'] as int, _floorDateTimeConverter.decode(row['date'] as int), row['discuz_id'] as int),
        arguments: [idInServer, discuzId]);
  }

  @override
  Stream<FavoriteThreadInDatabase?> getFavoriteThreadStreamByTid(
      int idInServer, int discuzId) {
    return _queryAdapter.queryStream(
        'SELECT * FROM FavoriteThreadInDatabase WHERE idInServer=?1 AND discuz_id=?2 LIMIT 1',
        mapper: (Map<String, Object?> row) => FavoriteThreadInDatabase(
            row['id'] as int?,
            row['favid'] as int,
            row['uid'] as int,
            row['idInServer'] as int,
            row['idType'] as String,
            row['spaceUid'] as int,
            row['title'] as String,
            row['description'] as String,
            row['author'] as String,
            row['replies'] as int,
            _floorDateTimeConverter.decode(row['date'] as int),
            row['discuz_id'] as int),
        arguments: [idInServer, discuzId],
        queryableName: 'FavoriteThreadInDatabase',
        isView: false);
  }

  @override
  Future<int> insertFavoriteThread(
      FavoriteThreadInDatabase favoriteThreadInDatabase) {
    return _favoriteThreadInDatabaseInsertionAdapter.insertAndReturnId(
        favoriteThreadInDatabase, OnConflictStrategy.replace);
  }

  @override
  Future<void> removeFavoriteThread(
      FavoriteThreadInDatabase favoriteThreadInDatabase) async {
    await _favoriteThreadInDatabaseDeletionAdapter
        .delete(favoriteThreadInDatabase);
  }
}

class _$FavoriteForumDao extends FavoriteForumDao {
  _$FavoriteForumDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _favoriteForumInDatabaseInsertionAdapter = InsertionAdapter(
            database,
            'FavoriteForumInDatabase',
            (FavoriteForumInDatabase item) => <String, Object?>{
                  'id': item.id,
                  'favid': item.favid,
                  'uid': item.uid,
                  'idKey': item.idKey,
                  'idType': item.idType,
                  'title': item.title,
                  'description': item.description,
                  'date': _floorDateTimeConverter.encode(item.date),
                  'discuz_id': item.discuzId
                },
            changeListener),
        _favoriteForumInDatabaseDeletionAdapter = DeletionAdapter(
            database,
            'FavoriteForumInDatabase',
            ['id'],
            (FavoriteForumInDatabase item) => <String, Object?>{
                  'id': item.id,
                  'favid': item.favid,
                  'uid': item.uid,
                  'idKey': item.idKey,
                  'idType': item.idType,
                  'title': item.title,
                  'description': item.description,
                  'date': _floorDateTimeConverter.encode(item.date),
                  'discuz_id': item.discuzId
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<FavoriteForumInDatabase>
      _favoriteForumInDatabaseInsertionAdapter;

  final DeletionAdapter<FavoriteForumInDatabase>
      _favoriteForumInDatabaseDeletionAdapter;

  @override
  Future<List<FavoriteForumInDatabase>> getFavoriteForumList(
      int discuzId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM FavoriteForumInDatabase WHERE discuz_id=?1',
        mapper: (Map<String, Object?> row) => FavoriteForumInDatabase(
            row['id'] as int?,
            row['favid'] as int,
            row['uid'] as int,
            row['idKey'] as int,
            row['idType'] as String,
            row['title'] as String,
            row['description'] as String,
            _floorDateTimeConverter.decode(row['date'] as int),
            row['discuz_id'] as int),
        arguments: [discuzId]);
  }

  @override
  Stream<List<FavoriteForumInDatabase>> getFavoriteForumListStream(
      int discuzId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM FavoriteForumInDatabase WHERE discuz_id=?1 ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => FavoriteForumInDatabase(
            row['id'] as int?,
            row['favid'] as int,
            row['uid'] as int,
            row['idKey'] as int,
            row['idType'] as String,
            row['title'] as String,
            row['description'] as String,
            _floorDateTimeConverter.decode(row['date'] as int),
            row['discuz_id'] as int),
        arguments: [discuzId],
        queryableName: 'FavoriteForumInDatabase',
        isView: false);
  }

  @override
  Future<FavoriteForumInDatabase?> getFavoriteForumByFid(
      int idInServer, int discuzId) async {
    return _queryAdapter.query(
        'SELECT * FROM FavoriteForumInDatabase WHERE idKey=?1 AND discuz_id=?2  LIMIT 1',
        mapper: (Map<String, Object?> row) => FavoriteForumInDatabase(row['id'] as int?, row['favid'] as int, row['uid'] as int, row['idKey'] as int, row['idType'] as String, row['title'] as String, row['description'] as String, _floorDateTimeConverter.decode(row['date'] as int), row['discuz_id'] as int),
        arguments: [idInServer, discuzId]);
  }

  @override
  Stream<FavoriteForumInDatabase?> getFavoriteForumStreamByFid(
      int idInServer, int discuzId) {
    return _queryAdapter.queryStream(
        'SELECT * FROM FavoriteForumInDatabase WHERE idKey=?1 AND discuz_id=?2 LIMIT 1',
        mapper: (Map<String, Object?> row) => FavoriteForumInDatabase(
            row['id'] as int?,
            row['favid'] as int,
            row['uid'] as int,
            row['idKey'] as int,
            row['idType'] as String,
            row['title'] as String,
            row['description'] as String,
            _floorDateTimeConverter.decode(row['date'] as int),
            row['discuz_id'] as int),
        arguments: [idInServer, discuzId],
        queryableName: 'FavoriteForumInDatabase',
        isView: false);
  }

  @override
  Future<int> insertFavoriteForum(
      FavoriteForumInDatabase favoriteThreadInDatabase) {
    return _favoriteForumInDatabaseInsertionAdapter.insertAndReturnId(
        favoriteThreadInDatabase, OnConflictStrategy.replace);
  }

  @override
  Future<void> removeFavoriteForum(
      FavoriteForumInDatabase favoriteThreadInDatabase) async {
    await _favoriteForumInDatabaseDeletionAdapter
        .delete(favoriteThreadInDatabase);
  }
}

// ignore_for_file: unused_element
final _floorDateTimeConverter = FloorDateTimeConverter();
