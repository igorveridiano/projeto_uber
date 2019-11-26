class Cartao {
  String _id;
  String _tipo;
  String _numero;
  String _nome;
  String _validade;

  Cartao();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "id": this.id,
      "tipo": this.tipo,
      "numero": this.numero,
      "nome": this.nome,
      "validade": this.validade,
    };

    return map;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get validade => _validade;

  set validade(String value) {
    _validade = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get numero => _numero;

  set numero(String value) {
    _numero = value;
  }

  String get tipo => _tipo;

  set tipo(String value) {
    _tipo = value;
  }
}
