import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:ubsir_app/utils/nav.dart';
import 'package:ubsir_app/views/home/home.dart';
import 'package:ubsir_app/views/login/login_page.dart';

class BlocVerificarUsuario {
  Future verificaUsuarioLogado1(context) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    if (usuarioLogado == null) {
      push(context, LoginPage(), replace: true);
    }
  }

  Future verificaUsuarioLogado2(context) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    if (usuarioLogado != null) {
      push(context, Home(), replace: true);
    }
  }
}