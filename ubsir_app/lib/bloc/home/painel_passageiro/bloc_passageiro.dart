import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ubsir_app/bloc/home/bloc_map.dart';
import 'package:ubsir_app/models/cartao.dart';
import 'package:ubsir_app/models/destino.dart';
import 'package:ubsir_app/models/requisicao.dart';
import 'package:ubsir_app/models/usuario.dart';
import 'package:ubsir_app/utils/nav.dart';
import 'package:ubsir_app/utils/status_requisicao.dart';
import 'package:ubsir_app/utils/usuarioFirebase.dart';
import 'package:ubsir_app/views/forma_pagamento/forma_pagamento.dart';
import 'package:ubsir_app/views/home/home.dart';

import 'bloc_dinheiro_cartao.dart';

class BlocPassageiro {
  final _streamController = StreamController<String>();
  get stream => _streamController.stream;
  BlocDinheiroCartao _blocDinheiroCartao = BlocDinheiroCartao();

  Firestore db = Firestore.instance;

  bool verificador;
  String _formaPagamento;

  // Metodo que chama um veiculo.
  chamarVeiculo(TextEditingController destino, context1, formkey,
      localPassageiro, BlocMap blocMap, api) async {
    final _formKey = formkey;
    String endercoDestino = destino.text;

    if (!_formKey.currentState.validate()) {
      return;
    }

    List<Placemark> listaEnderecos =
        await Geolocator().placemarkFromAddress(endercoDestino);

    if (listaEnderecos != null && listaEnderecos.length > 0) {
      Placemark endereco = listaEnderecos[0];
      Destino destino = Destino();
      destino.cidade = endereco.administrativeArea;
      destino.cep = endereco.postalCode;
      destino.bairro = endereco.subLocality;
      destino.rua = endereco.thoroughfare;
      destino.numero = endereco.subThoroughfare;
      destino.latitude = endereco.position.latitude;
      destino.longitude = endereco.position.longitude;

      _blocDinheiroCartao.onChangedTipo(false);

      bool tipoPagamento;
      NumberFormat formatter = NumberFormat(",##0.00");
      double valor;
      String novoValor;

      valor = (num.parse(((((await Geolocator().distanceBetween(
                              localPassageiro.latitude,
                              localPassageiro.longitude,
                              destino.latitude,
                              destino.longitude)) /
                          1000) /
                      6) *
                  18)
              .toStringAsPrecision(2)))
          .toDouble();

      novoValor = formatter.format(valor);
      String enderecoConfirmacao =
          "\n Cidade: ${destino.cidade} \n Rua: ${destino.rua}, "
          "${destino.numero} \n Bairro: ${destino.bairro} \n Cep: ${destino.cep} \n Valor Corrida:$novoValor reais";

      // Mostra um dialog para confirmação dos dados de endereço de destino
      showDialog(
          context: context1,
          barrierDismissible: false,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text("Confirmação do endereço"),
                content: Text(enderecoConfirmacao),
                contentPadding: EdgeInsets.all(16),
                actions: <Widget>[
                  Column(
                    children: <Widget>[
                      StreamBuilder<bool>(
                        stream: _blocDinheiroCartao.stream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          tipoPagamento = snapshot.data;
                          return Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: <Widget>[
                                Text("Dinheiro"),
                                Switch(
                                  value: snapshot.data,
                                  onChanged: (valor) {
                                    _blocDinheiroCartao.onChangedTipo(valor);
                                  },
                                ),
                                Text("Cartao"),
                              ],
                            ),
                          );
                        },
                      ),
                      Row(
                        children: <Widget>[
                          FlatButton(
                            child: Text(
                              "Cancelar",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            onPressed: () {
                              push(context1, Home(), replace: true);
                            },
                          ),
                          FlatButton(
                            child: Text(
                              "Confirmar",
                              style: TextStyle(
                                color: Colors.green,
                              ),
                            ),
                            onPressed: () {
                              _salvarRequisicao(destino, localPassageiro,
                                  context1, blocMap, api, valor, tipoPagamento);
                              pop(context, "");
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
    }
  }

  // Metodo para cancelar o veiculo chamado
  cancelarVeiculoChamado(context) async {
    FirebaseUser user = await UsuarioFirebase.getUsuarioAtual();
    String idRequisicao;

    Map<String, dynamic> dadosRequisicaoAtualizada = {};
    dadosRequisicaoAtualizada["status"] = StatusRequisicao.CANCELADA;

    DocumentSnapshot ref =
        await db.collection("requisicao_ativa").document(user.uid).get();

    idRequisicao = ref["idRequisicao"];

    db
        .collection("requisicoes")
        .document(idRequisicao)
        .updateData(dadosRequisicaoAtualizada)
        .then((x) {
      db.collection("requisicao_ativa").document(user.uid).delete();
    });

    _statusCancelar();

    push(context, Home(), replace: true);
  }

  // Salva a forma de pagamento na requisicao do usuario
  _salvarFormaDepagamentoDaRequisicao(tipoPagamento, context) async {
    FirebaseUser user = await UsuarioFirebase.getUsuarioAtual();
    String idRequisicao;
    Cartao cartao;

    DocumentSnapshot snapshot =
        await db.collection("requisicao_ativa").document(user.uid).get();

    if (snapshot.data != null) {
      Map<String, dynamic> dados = snapshot.data;
      idRequisicao = dados["idRequisicao"];
    } else {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text("Nenhum pedido de veiculo encontrado"),
                contentPadding: EdgeInsets.all(16),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                    onPressed: () {
                      pop(context, "");
                    },
                  ),
                ],
              ),
            );
          });
    }

    if (idRequisicao != null && idRequisicao.isNotEmpty) {
      if (tipoPagamento == "cartão") {
        cartao = await pushCartao(context, FormaPagamento("selecionar"));
        db.collection("requisicoes").document(idRequisicao).updateData({
          "cartão": cartao.toMap(),
        });
      }
      push(context, Home(), replace: true);
    } else {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text("Nenhum pedido de veiculo encontrado"),
                contentPadding: EdgeInsets.all(16),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                    onPressed: () {
                      pop(context, "");
                    },
                  ),
                ],
              ),
            );
          });
    }
  }

  // Salvar o pedido do veiculo no Firebase
  _salvarRequisicao(Destino destino, Position localPassageiro, context,
      BlocMap blocMap, api, valor, tipoPagamento) async {
    Usuario passageiro = await UsuarioFirebase.getDadosUsuarioLogado();
    passageiro.latitude = localPassageiro.latitude;
    passageiro.longitude = localPassageiro.longitude;

    Requisicao requisicao = Requisicao();
    requisicao.destino = destino;
    requisicao.passageiro = passageiro;
    requisicao.status = StatusRequisicao.AGUARDANDO;
    requisicao.valor = valor;

    if (tipoPagamento) {
      formaPagamento = "cartão";
    } else {
      formaPagamento = "dinheiro";
    }

    requisicao.tipoPagamento = formaPagamento;

    // Salvar a requisicao
    db
        .collection("requisicoes")
        .document(requisicao.id)
        .setData(requisicao.toMap());

    //Salvar uma requisicao ativa
    Map<String, dynamic> dadosRequisicaoAtiva = {};
    dadosRequisicaoAtiva["idRequisicao"] = requisicao.id;
    dadosRequisicaoAtiva["idPassageiro"] = passageiro.idUsuario;
    dadosRequisicaoAtiva["status"] = StatusRequisicao.AGUARDANDO;

    db
        .collection("requisicao_ativa")
        .document(passageiro.idUsuario)
        .setData(dadosRequisicaoAtiva);

    _listenerRequisicao(
        requisicao.id, blocMap, context, "imagens/passageiro", api);
    verificador = false;
  }

  listenerRequisicaoAtiva(BlocMap blocMap, context, localImagem, api) async {
    FirebaseUser user = await UsuarioFirebase.getUsuarioAtual();

    DocumentSnapshot snapshot =
        await db.collection("requisicao_ativa").document(user.uid).get();

    if (snapshot.data != null) {
      verificador = true;
      Map<String, dynamic> dados = snapshot.data;
      String idRequisicao = dados["idRequisicao"];
      _listenerRequisicao(idRequisicao, blocMap, context, localImagem, api);
    } else {
      verificador = false;
      await blocMap.ultimaLocalizacaoConhecida(context, "p");
      await blocMap.listenerLocalizacao(
          context, "p", localImagem, "passageiro", api);
      await blocMap.exebirMarcador(
          LatLng(blocMap.localPassageiro.latitude,
              blocMap.localPassageiro.longitude),
          context,
          localImagem,
          "passageiro",
          api);
      _statusCancelar();
    }
  }

  _listenerRequisicao(
      idRequisicao, BlocMap blocMap, context, localImagem, api) async {
    db
        .collection("requisicoes")
        .document(idRequisicao)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data != null) {
        Map<String, dynamic> dados = snapshot.data;
        String status = dados["status"];
        blocMap.idRequisicao = idRequisicao;

        double passageiroLatitude;
        double passageiroLongitude;
        double motoristaLatitude;
        double motoristaLongitude;
        double destinoLatitude;
        double destinoLongitude;

        if (dados["passageiro"] != null) {
          if (dados["passageiro"]["latitude"] != null &&
              dados["passageiro"]["longitude"] != null) {
            passageiroLatitude = dados["passageiro"]["latitude"];
            passageiroLongitude = dados["passageiro"]["longitude"];
          }
        }

        if (dados["motorista"] != null) {
          if (dados["motorista"]["latitude"] != null &&
              dados["motorista"]["longitude"] != null) {
            motoristaLatitude = dados["motorista"]["latitude"];
            motoristaLongitude = dados["motorista"]["longitude"];
          }
        }

        if (dados["destino"] != null) {
          if (dados["destino"]["latitude"] != null &&
              dados["destino"]["longitude"] != null) {
            destinoLatitude = dados["destino"]["latitude"];
            destinoLongitude = dados["destino"]["longitude"];
          }
        }

        switch (status) {
          case StatusRequisicao.AGUARDANDO:
            if (verificador) {
              if (dados["tipo_pagamento"] == "cartão") {
                if (dados["cartão"] == null) {
                  _salvarFormaDepagamentoDaRequisicao(
                      dados["tipo_pagamento"], context);
                } else {
                  await blocMap.exebirMarcador(
                      LatLng(passageiroLatitude, passageiroLongitude),
                      context,
                      localImagem,
                      "passageiro",
                      api);
                  _statusAguardando();
                }
              } else {
                await blocMap.exebirMarcador(
                    LatLng(passageiroLatitude, passageiroLongitude),
                    context,
                    localImagem,
                    "passageiro",
                    api);
                _statusAguardando();
              }
            } else {
              push(context, Home(), replace: true);
              _statusAguardando();
            }
            break;
          case StatusRequisicao.A_CAMINHO:
            await blocMap.exebirDoisMarcadores(
                LatLng(motoristaLatitude, motoristaLongitude),
                LatLng(passageiroLatitude, passageiroLongitude),
                context,
                StatusRequisicao.A_CAMINHO,
                api);
            _statusaCaminho();
            break;
          case StatusRequisicao.VIAGEM:
            await blocMap.exebirDoisMarcadores(
                LatLng(motoristaLatitude, motoristaLongitude),
                LatLng(destinoLatitude, destinoLongitude),
                context,
                StatusRequisicao.VIAGEM,
                api);
            _statusViagem();
            break;
          case StatusRequisicao.FINALIZADA:
            push(context, Home(), replace: true);
            statusFinalizada();
            break;
        }
      }
    });
  }

  _statusAguardando() {
    _streamController.add(StatusRequisicao.AGUARDANDO);
  }

  _statusaCaminho() {
    _streamController.add(StatusRequisicao.A_CAMINHO);
  }

  _statusViagem() {
    _streamController.add(StatusRequisicao.VIAGEM);
  }

  statusFinalizada() {
    _streamController.add(StatusRequisicao.VEICULONAOCHAMADO);
  }

  _statusCancelar() {
    _streamController.add(StatusRequisicao.VEICULONAOCHAMADO);
  }

  String get formaPagamento => _formaPagamento;

  set formaPagamento(String value) {
    _formaPagamento = value;
  }

  void dispose() {
    _streamController.close();
    _blocDinheiroCartao.dispose();
  }
}
