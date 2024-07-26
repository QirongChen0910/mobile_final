// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
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

  ReservationDAO? _reservationDaoInstance;

  CustomerDAO? _customerDaoInstance;

  FlightDAO? _flightDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
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
            'CREATE TABLE IF NOT EXISTS `Reservation` (`reservationID` INTEGER PRIMARY KEY AUTOINCREMENT, `reservationName` TEXT NOT NULL, `customerName` TEXT NOT NULL, `flightName` TEXT NOT NULL, `Date` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Customer` (`customerID` INTEGER PRIMARY KEY AUTOINCREMENT, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Flight` (`flightID` INTEGER PRIMARY KEY AUTOINCREMENT, `flightName` TEXT NOT NULL, `departureCity` TEXT NOT NULL, `destination` TEXT NOT NULL, `departureTime` TEXT NOT NULL, `arrivalTime` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ReservationDAO get reservationDao {
    return _reservationDaoInstance ??=
        _$ReservationDAO(database, changeListener);
  }

  @override
  CustomerDAO get customerDao {
    return _customerDaoInstance ??= _$CustomerDAO(database, changeListener);
  }

  @override
  FlightDAO get flightDao {
    return _flightDaoInstance ??= _$FlightDAO(database, changeListener);
  }
}

class _$ReservationDAO extends ReservationDAO {
  _$ReservationDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _reservationInsertionAdapter = InsertionAdapter(
            database,
            'Reservation',
            (Reservation item) => <String, Object?>{
                  'reservationID': item.reservationID,
                  'reservationName': item.reservationName,
                  'customerName': item.customerName,
                  'flightName': item.flightName,
                  'Date': item.Date
                }),
        _reservationDeletionAdapter = DeletionAdapter(
            database,
            'Reservation',
            ['reservationID'],
            (Reservation item) => <String, Object?>{
                  'reservationID': item.reservationID,
                  'reservationName': item.reservationName,
                  'customerName': item.customerName,
                  'flightName': item.flightName,
                  'Date': item.Date
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Reservation> _reservationInsertionAdapter;

  final DeletionAdapter<Reservation> _reservationDeletionAdapter;

  @override
  Future<List<Reservation>> getAllItems() async {
    return _queryAdapter.queryList('SELECT * FROM Reservation',
        mapper: (Map<String, Object?> row) => Reservation(
            row['reservationName'] as String,
            row['customerName'] as String,
            row['flightName'] as String,
            row['Date'] as String,
            reservationID: row['reservationID'] as int?));
  }

  @override
  Future<void> insertItem(Reservation reservation) async {
    await _reservationInsertionAdapter.insert(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteItem(Reservation reservation) async {
    await _reservationDeletionAdapter.delete(reservation);
  }
}

class _$CustomerDAO extends CustomerDAO {
  _$CustomerDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _customerInsertionAdapter = InsertionAdapter(
            database,
            'Customer',
            (Customer item) => <String, Object?>{
                  'customerID': item.customerID,
                  'firstName': item.firstName,
                  'lastName': item.lastName
                }),
        _customerDeletionAdapter = DeletionAdapter(
            database,
            'Customer',
            ['customerID'],
            (Customer item) => <String, Object?>{
                  'customerID': item.customerID,
                  'firstName': item.firstName,
                  'lastName': item.lastName
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Customer> _customerInsertionAdapter;

  final DeletionAdapter<Customer> _customerDeletionAdapter;

  @override
  Future<List<Customer>> getAllCustomers() async {
    return _queryAdapter.queryList('SELECT * FROM Customer',
        mapper: (Map<String, Object?> row) => Customer(
            row['firstName'] as String, row['lastName'] as String,
            customerID: row['customerID'] as int?));
  }

  @override
  Future<void> insertCustomer(Customer customer) async {
    await _customerInsertionAdapter.insert(customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCustomer(Customer customer) async {
    await _customerDeletionAdapter.delete(customer);
  }
}

class _$FlightDAO extends FlightDAO {
  _$FlightDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _flightInsertionAdapter = InsertionAdapter(
            database,
            'Flight',
            (Flight item) => <String, Object?>{
                  'flightID': item.flightID,
                  'flightName': item.flightName,
                  'departureCity': item.departureCity,
                  'destination': item.destination,
                  'departureTime': item.departureTime,
                  'arrivalTime': item.arrivalTime
                }),
        _flightUpdateAdapter = UpdateAdapter(
            database,
            'Flight',
            ['flightID'],
            (Flight item) => <String, Object?>{
                  'flightID': item.flightID,
                  'flightName': item.flightName,
                  'departureCity': item.departureCity,
                  'destination': item.destination,
                  'departureTime': item.departureTime,
                  'arrivalTime': item.arrivalTime
                }),
        _flightDeletionAdapter = DeletionAdapter(
            database,
            'Flight',
            ['flightID'],
            (Flight item) => <String, Object?>{
                  'flightID': item.flightID,
                  'flightName': item.flightName,
                  'departureCity': item.departureCity,
                  'destination': item.destination,
                  'departureTime': item.departureTime,
                  'arrivalTime': item.arrivalTime
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Flight> _flightInsertionAdapter;

  final UpdateAdapter<Flight> _flightUpdateAdapter;

  final DeletionAdapter<Flight> _flightDeletionAdapter;

  @override
  Future<List<Flight>> getAllFlights() async {
    return _queryAdapter.queryList('SELECT * FROM Flight',
        mapper: (Map<String, Object?> row) => Flight(
            row['flightName'] as String,
            row['departureCity'] as String,
            row['destination'] as String,
            row['departureTime'] as String,
            row['arrivalTime'] as String,
            flightID: row['flightID'] as int?));
  }

  @override
  Future<void> insertFlight(Flight flight) async {
    await _flightInsertionAdapter.insert(flight, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateFlight(Flight flight) async {
    await _flightUpdateAdapter.update(flight, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteFlight(Flight flight) async {
    await _flightDeletionAdapter.delete(flight);
  }
}
