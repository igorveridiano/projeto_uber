import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ubsir_app/utils/nav.dart';
import 'package:ubsir_app/utils/usuarioFirebase.dart';
import 'package:ubsir_app/views/forma_pagamento/cadastro_forma_pagamento.dart';
import 'package:ubsir_app/views/forma_pagamento/editar_forma_pagamento.dart';

class BlocFormaPagamento {
  final _streamController = StreamController<QuerySnapshot>();
  get stream => _streamController.stream;

  recuperarFormaPagamento() async {
    FirebaseUser user = await UsuarioFirebase.getUsuarioAtual();
    Firestore db = Firestore.instance;

    final stream = db
        .collection("formas_pagamentos")
        .document(user.uid)
        .collection("cartoes")
        .snapshots();

    stream.listen((dados) {
      _streamController.add(dados);
    });
  }

  // Chama a pagina de cadastramento de forma de pagamento
  onPressedCadastrarFormaPagamento(context) {
    push(context, CadastroFormaPagamento());
  }

  // Fecha a tela forma de pagamento e retorna o cartão selecionado
  onTapCartaoSelecionado(context, cartao) {
    popCartao(context, cartao);
  }

  // Abre a tela de edição para o cartão selecionado
  onTapEditarCartaoSelecionado(context, cartao) {
    push(context, EditarFormaPagamento(cartao));
  }

  void dispose() {
    _streamController.close();
  }
}
