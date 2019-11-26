import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ubsir_app/bloc/forma_pagamento/bloc_forma_pagamento.dart';
import 'package:ubsir_app/bloc/utils/bloc_usuario.dart';
import 'package:ubsir_app/models/cartao.dart';
import 'package:ubsir_app/models/usuario.dart';
import 'package:ubsir_app/widgets/drawer_list_motorista.dart';
import 'package:ubsir_app/widgets/drawer_list_passageiro.dart';

class FormaPagamento extends StatefulWidget {
  String tipo;

  FormaPagamento(this.tipo);

  @override
  _FormaPagamentoState createState() => _FormaPagamentoState(tipo);
}

class _FormaPagamentoState extends State<FormaPagamento> {
  final _blocFormaPagamento = BlocFormaPagamento();
  BlocUsuario _blocUsuario = BlocUsuario();
  String tipoDeFuncao;

  _FormaPagamentoState(this.tipoDeFuncao);

  @override
  void initState() {
    super.initState();
    _blocUsuario.recuperarUsuario();
    _blocFormaPagamento.recuperarFormaPagamento();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Usuario>(
        stream: _blocUsuario.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          Usuario usuario = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text("Formas de Pagamento"),
              centerTitle: true,
            ),
            body: _body(),
            drawer: usuario.tipoUsuario == "passageiro"
                ? DrawerListPassageiro(usuario)
                : DrawerListMotorista(usuario),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () =>
                  _blocFormaPagamento.onPressedCadastrarFormaPagamento(context),
            ),
          );
        });
  }

  _body() {
    return StreamBuilder<QuerySnapshot>(
        stream: _blocFormaPagamento.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                children: <Widget>[
                  CircularProgressIndicator(),
                ],
              ),
            );
          }
          QuerySnapshot querySnapshot = snapshot.data;

          return ListView.separated(
            itemCount: querySnapshot.documents.length,
            separatorBuilder: (context, index) {
              return Divider(
                height: 2,
                color: Colors.grey,
              );
            },
            itemBuilder: (context, index) {
              List<DocumentSnapshot> cartoes = querySnapshot.documents.toList();
              DocumentSnapshot item = cartoes[index];

              String id = item.documentID;
              String tipo = item["tipo"];
              String numero = item["numero"];
              String nome = item["nome"];
              String validade = item["validade"];

              Cartao cartao = Cartao();

              cartao.id = id;
              cartao.tipo = tipo;
              cartao.numero = numero;
              cartao.nome = nome;
              cartao.validade = validade;

              return ListTile(
                title: Column(
                  children: <Widget>[
                    Text(nome),
                    Text("Cartão: $numero"),
                  ],
                ),
                subtitle: Text("tipo:$tipo, validade: $validade"),
                onTap: () => tipoDeFuncao == "selecionar"
                    ? _blocFormaPagamento.onTapCartaoSelecionado(
                        context, cartao)
                    : _blocFormaPagamento.onTapEditarCartaoSelecionado(
                        context, cartao),
              );
            },
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    _blocUsuario.dispose();
    _blocFormaPagamento.dispose();
  }
}
