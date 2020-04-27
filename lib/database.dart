import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'client_model.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Clientes.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Cliente ("
          "id INTEGER PRIMARY KEY,"
          "nome TEXT,"
          "sobrenome TEXT,"
          "marcado BIT"
          ")");
    });
  }

  newCliente(Cliente newCliente) async {
    final db = await database;
    //get the biggest id in the tables
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Cliente");
    int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Cliente (id,nome,sobrenome,marcado)"
        " VALUES (?,?,?,?)",
        [id, newCliente.nome, newCliente.sobrenome, newCliente.marcado]);
    return raw;
  }

  blockOrUnblock(Cliente cliente) async {
    final db = await database;
    Cliente blocked = Cliente(
        id: cliente.id,
        nome: cliente.nome,
        sobrenome: cliente.sobrenome,
        marcado: !cliente.marcado);
    var res = await db.update("Cliente", blocked.toMap(),
        where: "id = ?", whereArgs: [cliente.id]);
    return res;
  }

  updateCliente(Cliente newCliente) async {
    final db = await database;
    var res = await db.update("Cliente", newCliente.toMap(),
        where: "id = ?", whereArgs: [newCliente.id]);
    return res;
  }

  getCliente(int id) async {
    final db = await database;
    var res = await db.query("Cliente", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Cliente.fromMap(res.first) : null;
  }

  Future<List<Cliente>> getBlockedClientes() async {
    final db = await database;

    print("works");
    var res = await db.query("Cliente", where: "blocked = ? ", whereArgs: [1]);

    List<Cliente> list =
        res.isNotEmpty ? res.map((c) => Cliente.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Cliente>> getAllClientes() async {
    final db = await database;
    var res = await db.query("Cliente");
    List<Cliente> list =
        res.isNotEmpty ? res.map((c) => Cliente.fromMap(c)).toList() : [];
    return list;
  }

  deleteCliente(int id) async {
    final db = await database;
    return db.delete("Cliente", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete from Cliente");
  }
}

