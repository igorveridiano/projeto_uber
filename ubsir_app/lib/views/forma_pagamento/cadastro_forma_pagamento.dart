import 'package:flutter/material.dart';
import 'package:ubsir_app/bloc/forma_pagamento/bloc_cadastro_forma_pagamento.dart';
import 'package:ubsir_app/bloc/forma_pagamento/bloc_credito_debito.dart';
import 'package:ubsir_app/bloc/utils/bloc_validate.dart';
import 'package:ubsir_app/widgets/app_button.dart';
import 'package:ubsir_app/widgets/app_text.dart';

class CadastroFormaPagamento extends StatefulWidget {
  @override
  _CadastroFormaPagamentoState createState() => _CadastroFormaPagamentoState();
}

class _CadastroFormaPagamentoState extends State<CadastroFormaPagamento> {
  final _formKey = GlobalKey<FormState>();
  final _tNome = TextEditingController();
  final _tNumeroCartao = TextEditingController();
  final _tValidade = TextEditingController();
  final _focusNumeroCartao = FocusNode();
  final _focusValidade = FocusNode();
  final _blocCreditodebito = BlocCreditoDebito();
  final _blocCadastroFormaPagamento = BlocCadastroFormaPagamento();

  @override
  void initState() {
    super.initState();
    _blocCreditodebito.onChangedTipo(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro Forma de Pagamento"),
        centerTitle: true,
      ),
      body: _body(),
    );
  }

  _body() {
    return Form(
      key: _formKey,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: StreamBuilder<bool>(
              stream: _blocCreditodebito.stream,
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
                        nextFocus: _focusNumeroCartao,
                        autofocus: true,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 8),
                      child: AppText(
                        "Numero Cartão",
                        "Digite o numero do cartão",
                        textColor: Colors.black,
                        labelColor: Colors.grey,
                        controller: _tNumeroCartao,
                        validator: BlocValidate.validateNumero,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        nextFocus: _focusValidade,
                        focusNode: _focusNumeroCartao,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 16),
                      child: AppText(
                        "Data de validade",
                        "Digite a data de validade",
                        textColor: Colors.black,
                        labelColor: Colors.grey,
                        controller: _tValidade,
                        validator: BlocValidate.validateData,
                        keyboardType: TextInputType.datetime,
                        focusNode: _focusValidade,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: <Widget>[
                          Text("Debito"),
                          Switch(
                            value: snapshot.data,
                            onChanged: (valor) {
                              _blocCreditodebito.onChangedTipo(valor);
                            },
                          ),
                          Text("Credito"),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: AppButton(
                        "CADASTRAR",
                        buttonColor: Colors.black,
                        textColor: Colors.white,
                        onPressed: () =>
                            _blocCadastroFormaPagamento.onClickCadastro(
                                _formKey,
                                _tNome,
                                _tNumeroCartao,
                                _tValidade,
                                snapshot.data,
                                context),
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
