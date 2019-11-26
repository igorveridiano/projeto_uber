import 'package:firebase_auth/firebase_auth.dart';

class Usuario {
  String _idUsuario;
  String _nome;
  String _email;
  String _senha;
  String urlFoto;
  String _tipoUsuario;
  double _latitude;
  double _longitude;

  Usuario();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "uid": this.idUsuario,
      "nome": this.nome,
      "email": this.email,
      "urlFoto": this.urlFoto,
      "tipo": this.tipoUsuario,
      "latitude": this.latitude,
      "longitude": this.longitude,
    };

    return map;
  }

  static void clear() {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut();
  }

  String get tipoUsuario => _tipoUsuario;

  set tipoUsuario(String value) {
    _tipoUsuario = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }
}
