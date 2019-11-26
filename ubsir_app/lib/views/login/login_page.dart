import 'package:flutter/material.dart';
import 'package:ubsir_app/bloc/login/bloc_login.dart';
import 'package:ubsir_app/bloc/utils/bloc_VerificarUsuario.dart';
import 'package:ubsir_app/widgets/app_button.dart';
import 'package:ubsir_app/widgets/app_text.dart';
import 'package:ubsir_app/bloc/utils/bloc_validate.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _tEmail = TextEditingController();
  final _tSenha = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _focusSenha = FocusNode();
  final _blocVerificarUsuario = BlocVerificarUsuario();

  @override
  void initState() {
    super.initState();
    _blocVerificarUsuario.verificaUsuarioLogado2(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        centerTitle: true,
      ),
      body: _body(context),
    );
  }

  _body(context) {
    return Form(
      key: _formKey,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    bottom: 8,
                    top: 8,
                  ),
                  child: AppText(
                    "E-mail",
                    "Digite o e-mail",
                    textColor: Colors.black,
                    labelColor: Colors.grey,
                    controller: _tEmail,
                    validator: BlocValidate.validateLogin,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    nextFocus: _focusSenha,
                    autofocus: true,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 16),
                  child: AppText(
                    "Senha",
                    "Digite a senha",
                    textColor: Colors.black,
                    labelColor: Colors.grey,
                    obscureText: true,
                    controller: _tSenha,
                    validator: BlocValidate.validateSenha,
                    focusNode: _focusSenha,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: AppButton(
                    "LOGIN",
                    buttonColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () => BlocLogin.onClickLogin(
                        _formKey, _tEmail, _tSenha, context),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    child: Text(
                      "Não tem conta? Cadastre-se!",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => BlocLogin.onTapCadastro(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
