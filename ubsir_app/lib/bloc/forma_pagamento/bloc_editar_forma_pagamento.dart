import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ubsir_app/models/cartao.dart';
import 'package:ubsir_app/utils/nav.dart';
import 'package:ubsir_app/utils/usuarioFirebase.dart';

class BlocEditarFormaPagamento {
  onClickEditar(
      formKey, tNome, tNumeroCartao, tValidade, tipoCartao, context, id) async {
    final _formKey = formKey;
    final _tNumeroCartao = tNumeroCartao;
    final _tNome = tNome;
    final _tValidade = tValidade;
    bool _tipoCartao = tipoCartao;

    FirebaseUser user = await UsuarioFirebase.getUsuarioAtual();
    Firestore db = Firestore.instance;

    DocumentSnapshot snapshot = await db
        .collection("formas_pagamentos")
        .document(user.uid)
        .collection("cartoes")
        .document(id)
        .get();

    Map<String, dynamic> dados = snapshot.data;

    if (!_formKey.currentState.validate()) {
      return;
    }

    String nome = _tNome.text != null ? _tNome.text : dados["nome"];
    String numeroCartao =
        _tNumeroCartao.text != null ? _tNumeroCartao.text : dados["numero"];
    String validade =
        _tValidade.text != null ? _tValidade.text : dados["validade"];

    Cartao cartao = Cartao();

    cartao.nome = nome;
    cartao.numero = numeroCartao;
    cartao.validade = validade;
    cartao.tipo = _tipoCartao ? "credito" : "debito";

    db
        .collection("formas_pagamentos")
        .document(user.uid)
        .collection("cartoes")
        .document(id)
        .updateData(cartao.toMap())
        .then((snapshot) {
      pop(context, "Sucesso");
    });
  }
}
