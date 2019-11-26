import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ubsir_app/models/cartao.dart';
import 'package:ubsir_app/models/destino.dart';
import 'package:ubsir_app/models/usuario.dart';

class Requisicao {
  String _id;
  String _status;
  Usuario _passageiro;
  Usuario _motorista;
  Destino _destino;
  String _tipoPagamento;
  Cartao _cartao;
  double _valor;

  Requisicao() {
    Firestore db = Firestore.instance;

    DocumentReference ref = db.collection("requisicoes").document();
    this.id = ref.documentID;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> dadosPassageiro = {
      "nome": this.passageiro.nome,
      "email": this.passageiro.email,
      "tipo": this.passageiro.tipoUsuario,
      "urlFoto": this.passageiro.urlFoto,
      "uid": this.passageiro.idUsuario,
      "latitude": this.passageiro.latitude,
      "longitude": this.passageiro.longitude,
    };

    Map<String, dynamic> dadosDestino = {
      "rua": this.destino.rua,
      "numero": this.destino.numero,
      "bairro": this.destino.bairro,
      "cep": this.destino.cep,
      "latitude": this.destino.latitude,
      "longitude": this.destino.longitude,
    };

    Map<String, dynamic> dadosRequisicao = {
      "id": this.id,
      "status": this.status,
      "passageiro": dadosPassageiro,
      "motorista": null,
      "destino": dadosDestino,
      "tipo_pagamento": tipoPagamento,
      "cartão": null,
      "valor": valor,
    };

    return dadosRequisicao;
  }

  Destino get destino => _destino;

  set destino(Destino value) {
    _destino = value;
  }

  Usuario get motorista => _motorista;

  set motorista(Usuario value) {
    _motorista = value;
  }

  Usuario get passageiro => _passageiro;

  set passageiro(Usuario value) {
    _passageiro = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  double get valor => _valor;

  set valor(double value) {
    _valor = value;
  }

  String get tipoPagamento => _tipoPagamento;

  set tipoPagamento(String value) {
    _tipoPagamento = value;
  }

  Cartao get cartao => _cartao;

  set cartao(Cartao value) {
    _cartao = value;
  }
}
