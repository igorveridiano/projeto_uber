import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ubsir_app/models/cartao.dart';
import 'package:ubsir_app/utils/nav.dart';
import 'package:ubsir_app/utils/usuarioFirebase.dart';

class BlocCadastroFormaPagamento {
  onClickCadastro(
      formkey, tNome, tNumeroCartao, tValidade, tipoCartao, context) async {
    final _formKey = formkey;
    final _tNumeroCartao = tNumeroCartao;
    final _tNome = tNome;
    final _tValidade = tValidade;
    bool _tipoCartao = tipoCartao;

    FirebaseUser user = await UsuarioFirebase.getUsuarioAtual();
    Firestore db = Firestore.instance;

    if (!_formKey.currentState.validate()) {
      return;
    }

    String nome = _tNome.text;
    String numeroCartao = _tNumeroCartao.text;
    String validade = _tValidade.text;

    Cartao cartao = Cartao();

    cartao.nome = nome;
    cartao.numero = numeroCartao;
    cartao.validade = validade;
    cartao.tipo = _tipoCartao ? "credito" : "debito";

    db
        .collection("formas_pagamentos")
        .document(user.uid)
        .collection("cartoes")
        .add(cartao.toMap())
        .then((snapshot) {
      pop(context, "Sucesso");
    });
  }
}
