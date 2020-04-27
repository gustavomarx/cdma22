import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'client_model.dart';
import 'database.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // data for testing
  List<Cliente> testClients = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CDMA22 - Clientes"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              DBProvider.db.deleteAll();
              setState(() {});
            },
          )
        ],
      ),
      body: FutureBuilder<List<Cliente>>(
        future: DBProvider.db.getAllClientes(),
        builder: (BuildContext context, AsyncSnapshot<List<Cliente>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Cliente item = snapshot.data[index];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    DBProvider.db.deleteCliente(item.id);
                  },
                  child: ListTile(
                    title: Text(item.nome + " " + item.sobrenome),
                    leading: Text(item.id.toString()),
                    trailing: Checkbox(
                      onChanged: (bool value) {
                        DBProvider.db.blockOrUnblock(item);
                        setState(() {});
                      },
                      value: item.marcado,
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _addCliente(context);
          setState(() {});
        },
      ),
    );
  }
}

String _cliente;
String _sobrenome;
void _addCliente(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      var alertDialog = AlertDialog(
        title: Text("Adicionar cliente"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Nome do cliente",
                    hintText: "João",
                  ),
                  onChanged: (valor) {
                    _cliente = valor;
                  }),
              TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Sobrenome do cliente",
                    hintText: "da Silva",
                  ),
                  onChanged: (valor) {
                    _sobrenome = valor;
                  }),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _salvarCliente();
              Navigator.of(context).pop();
            },
            child: Text("Incluir"),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancelar"),
          ),
        ],
      );
      return alertDialog;
    },
  );
}

_salvarCliente() async {
  Cliente cliente = Cliente(
    nome: _cliente,
    sobrenome: _sobrenome,
    marcado: false,
  );

  await DBProvider.db.newCliente(cliente);

  
}
