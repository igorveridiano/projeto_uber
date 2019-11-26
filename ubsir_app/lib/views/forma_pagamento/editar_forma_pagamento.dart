import 'package:flutter/material.dart';
import 'package:ubsir_app/bloc/forma_pagamento/bloc_credito_debito.dart';
import 'package:ubsir_app/bloc/forma_pagamento/bloc_editar_forma_pagamento.dart';
import 'package:ubsir_app/bloc/utils/bloc_validate.dart';
import 'package:ubsir_app/models/cartao.dart';
import 'package:ubsir_app/widgets/app_button.dart';
import 'package:ubsir_app/widgets/app_text.dart';

class EditarFormaPagamento extends StatefulWidget {
  Cartao cartao;

  EditarFormaPagamento(this.cartao);

  @override
  _EditarFormaPagamentoState createState() =>
      _EditarFormaPagamentoState(cartao);
}

class _EditarFormaPagamentoState extends State<EditarFormaPagamento> {
  Cartao cartao;

  final _formKey = GlobalKey<FormState>();
  final _tNome = TextEditingController();
  final _tNumeroCartao = TextEditingController();
  final _tValidade = TextEditingController();
  final _focusNumeroCartao = FocusNode();
  final _focusValidade = FocusNode();
  final _blocCreditodebito = BlocCreditoDebito();
  final _blocEditarFormaPagamento = BlocEditarFormaPagamento();

  _EditarFormaPagamentoState(this.cartao);

  @override
  void initState() {
    super.initState();
    _tNome.text = cartao.nome;
    _tNumeroCartao.text = cartao.numero;
    _tValidade.text = cartao.validade;

    if (cartao.tipo == "debito"){
      _blocCreditodebito.onChangedTipo(false);
    } else if (cartao.tipo == "credito"){
      _blocCreditodebito.onChangedTipo(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Forma Pagamento"),
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
                        "SALVAR",
                        buttonColor: Colors.black,
                        textColor: Colors.white,
                        onPressed: () =>
                            _blocEditarFormaPagamento.onClickEditar(
                          _formKey,
                          _tNome,
                          _tNumeroCartao,
                          _tValidade,
                          snapshot.data,
                          context,
                          cartao.id,
                        ),
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
