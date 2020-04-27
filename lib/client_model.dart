import 'dart:convert';

Cliente clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Cliente.fromMap(jsonData);
}

String clientToJson(Cliente data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Cliente {
  int id;
  String nome;
  String sobrenome;
  bool marcado;

  Cliente({
    this.id,
    this.nome,
    this.sobrenome,
    this.marcado,
  });

  factory Cliente.fromMap(Map<String, dynamic> json) => new Cliente(
        id: json["id"],
        nome: json["nome"],
        sobrenome: json["sobrenome"],
        marcado: json["marcado"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "nome": nome,
        "sobrenome": sobrenome,
        "marcado": marcado,
      };
}


