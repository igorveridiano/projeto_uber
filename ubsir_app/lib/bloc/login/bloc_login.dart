import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ubsir_app/utils/nav.dart';
import 'package:ubsir_app/views/cadastro/cadastro_page.dart';
import 'package:ubsir_app/views/home/home.dart';

class BlocLogin {
  static onClickLogin(formkey, tEmail, tSenha, context) async {
    final _formKey = formkey;
    final _tEmail = tEmail;
    final _tSenha = tSenha;

    if (!_formKey.currentState.validate()) {
      return;
    }

    String email = _tEmail.text;
    String senha = _tSenha.text;

    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(
      email: email,
      password: senha,
    )
        .then((FirebaseUser) {
      push(context, Home(), replace: true);
    }).catchError((erro) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text(
                    "Erro ao autenticar o usuario, verifique o E-mail e a senha e tente novamente."),
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          });
    });
  }

  static onTapCadastro(context) {
    push(context, CadastroPage());
  }
}
