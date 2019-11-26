import 'package:flutter/material.dart';
import 'package:ubsir_app/bloc/cadastro/bloc_passageiro_motorista.dart';
import 'package:ubsir_app/bloc/cadastro/bloc_cadastro.dart';
import 'package:ubsir_app/bloc/utils/bloc_validate.dart';
import 'package:ubsir_app/widgets/app_button.dart';
import 'package:ubsir_app/widgets/app_text.dart';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _blocPassageiroMotorista = BlocPassageiroMotorista();
  final _blocCadastro = BlocCadastro();
  final _tNome = TextEditingController();
  final _tEmail = TextEditingController();
  final _tSenha = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _focusSenha = FocusNode();
  final _focusEmail = FocusNode();

  @override
  void initState() {
    super.initState();
    _blocPassageiroMotorista.onChangedTipo(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
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
        child: SingleChildScrollView(
          child: StreamBuilder<bool>(
              stream: _blocPassageiroMotorista.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        bottom: 8,
                        top: 8,
                      ),
                      child: AppText(
                        "Nome",
                        "Digite o nome",
                        textColor: Colors.black,
                        labelColor: Colors.grey,
                        controller: _tNome,
                        validator: BlocValidate.validateNome,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        nextFocus: _focusEmail,
                        autofocus: true,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 8),
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
                        focusNode: _focusEmail,
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
                      child: Row(
                        children: <Widget>[
                          Text("Passageiro"),
                          Switch(
                            value: snapshot.data,
                            onChanged: (valor) {
                              _blocPassageiroMotorista.onChangedTipo(valor);
                            },
                          ),
                          Text("Motorista"),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: AppButton(
                        "CADASTRAR",
                        buttonColor: Colors.black,
                        textColor: Colors.white,
                        onPressed: () => _blocCadastro.onClickCadastro(_formKey, _formKey,
                            _tEmail, _tSenha, snapshot.data, context),
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _blocPassageiroMotorista.dispose();
  }
}
