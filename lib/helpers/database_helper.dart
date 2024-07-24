import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('customers.db');
    return _database!;
  }//

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const customerTable = '''CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        address TEXT NOT NULL,
        birthday TEXT NOT NULL
      )''';

    await db.execute(customerTable);
  }

  Future<int> create(Customer customer) async {
    final db = await instance.database;
    return await db.insert('customers', customer.toMap());
  }

  Future<Customer?> readCustomer(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'customers',
      columns: ['id', 'firstName', 'lastName', 'address', 'birthday'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Customer>> readAllCustomers() async {
    final db = await instance.database;
    const orderBy = 'firstName ASC';
    final result = await db.query('customers', orderBy: orderBy);

    return result.map((json) => Customer.fromMap(json)).toList();
  }

  Future<int> update(Customer customer) async {
    final db = await instance.database;
    return db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
