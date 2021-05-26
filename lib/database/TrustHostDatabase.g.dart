// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TrustHostDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorTrustHostDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$TrustHostDatabaseBuilder databaseBuilder(String name) =>
      _$TrustHostDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$TrustHostDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$TrustHostDatabaseBuilder(null);
}

class _$TrustHostDatabaseBuilder {
  _$TrustHostDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$TrustHostDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$TrustHostDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<TrustHostDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$TrustHostDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$TrustHostDatabase extends TrustHostDatabase {
  _$TrustHostDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  TrustHostDao? _trustHostDatabaseDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
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
            'CREATE TABLE IF NOT EXISTS `TrustHost` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `host` TEXT NOT NULL, `trustAt` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  TrustHostDao get trustHostDatabaseDao {
    return _trustHostDatabaseDaoInstance ??=
        _$TrustHostDao(database, changeListener);
  }
}

class _$TrustHostDao extends TrustHostDao {
  _$TrustHostDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _trustHostInsertionAdapter = InsertionAdapter(
            database,
            'TrustHost',
            (TrustHost item) => <String, Object?>{
                  'id': item.id,
                  'host': item.host,
                  'trustAt': _floorDateTimeConverter.encode(item.trustAt)
                },
            changeListener),
        _trustHostDeletionAdapter = DeletionAdapter(
            database,
            'TrustHost',
            ['id'],
            (TrustHost item) => <String, Object?>{
                  'id': item.id,
                  'host': item.host,
                  'trustAt': _floorDateTimeConverter.encode(item.trustAt)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TrustHost> _trustHostInsertionAdapter;

  final DeletionAdapter<TrustHost> _trustHostDeletionAdapter;

  @override
  Future<List<TrustHost>> findAllTrustHosts() async {
    return _queryAdapter.queryList('SELECT * FROM TrustHost',
        mapper: (Map<String, Object?> row) =>
            TrustHost(row['id'] as int?, row['host'] as String));
  }

  @override
  Stream<List<TrustHost>> findAllTrustHostsStream() {
    return _queryAdapter.queryListStream('SELECT * FROM TrustHost',
        mapper: (Map<String, Object?> row) =>
            TrustHost(row['id'] as int?, row['host'] as String),
        queryableName: 'TrustHost',
        isView: false);
  }

  @override
  Future<TrustHost?> findTrustHostByName(String host) async {
    return _queryAdapter.query('SELECT * FROM TrustHost WHERE host=?1',
        mapper: (Map<String, Object?> row) =>
            TrustHost(row['id'] as int?, row['host'] as String),
        arguments: [host]);
  }

  @override
  Future<void> insertTrustHost(TrustHost trustHost) async {
    await _trustHostInsertionAdapter.insert(
        trustHost, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteTrustHost(TrustHost trustHost) async {
    await _trustHostDeletionAdapter.delete(trustHost);
  }
}

// ignore_for_file: unused_element
final _floorDateTimeConverter = FloorDateTimeConverter();
