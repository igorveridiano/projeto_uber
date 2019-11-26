import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubsir_app/bloc/home/bloc_directions_provider.dart';
import 'package:ubsir_app/models/usuario.dart';
import 'package:ubsir_app/utils/nav.dart';
import 'package:ubsir_app/utils/status_requisicao.dart';
import 'package:ubsir_app/utils/usuarioFirebase.dart';
import 'package:ubsir_app/views/home/corrida_motorista.dart';
import 'package:ubsir_app/views/home/home.dart';

import '../bloc_map.dart';

class BlocMotorista {
  final _streamController = StreamController<QuerySnapshot>();
  get stream => _streamController.stream;
  final _streamControllerCorrida = StreamController<String>();
  get streamCorrida => _streamControllerCorrida.stream;

  String _statusCorrida;

  Firestore db = Firestore.instance;

  // Ouvinte das requisições dos passageiros que estão aguardando uma viagem
  _listenerRequisicoes() async {
    final stream = db
        .collection("requisicoes")
        .where("status", isEqualTo: StatusRequisicao.AGUARDANDO)
        .snapshots();

    stream.listen((dados) {
      _streamController.add(dados);
    });
  }

  // Metodo de aceite da corrida
  aceitarCorrida(context, id, Position localMotorista, blocMap) async {
    Usuario motorista = await UsuarioFirebase.getDadosUsuarioLogado();
    motorista.latitude = localMotorista.latitude;
    motorista.longitude = localMotorista.longitude;

    Map<String, dynamic> _dadosRequisicao;
    _dadosRequisicao = await _recuperaRequisicao(id);

    String idRequisicao = _dadosRequisicao["id"];
    blocMap.idRequisicao = idRequisicao;

    Map<String, dynamic> dadosRequisicaoAtualizada = {};
    dadosRequisicaoAtualizada["motorista"] = motorista.toMap();
    dadosRequisicaoAtualizada["status"] = StatusRequisicao.A_CAMINHO;

    db
        .collection("requisicoes")
        .document(idRequisicao)
        .updateData(dadosRequisicaoAtualizada)
        .then((x) {
      Map<String, dynamic> dadosRequisicaoAtualizadaPassageiro = {};
      dadosRequisicaoAtualizadaPassageiro["status"] =
          StatusRequisicao.A_CAMINHO;

      // Atualizando requisicao ativa do passageiro
      String idPassageiro = _dadosRequisicao["passageiro"]["uid"];
      db
          .collection("requisicao_ativa")
          .document(idPassageiro)
          .updateData(dadosRequisicaoAtualizadaPassageiro);

      Map<String, dynamic> dadosRequisicaoAtualizadaMotorista = {};
      dadosRequisicaoAtualizadaMotorista["idRequisicao"] = idRequisicao;
      dadosRequisicaoAtualizadaMotorista["idUsuario"] = motorista.idUsuario;
      dadosRequisicaoAtualizadaMotorista["status"] = StatusRequisicao.A_CAMINHO;

      // Criando requisicao ativa do motorista
      String idMotorista = motorista.idUsuario;
      db
          .collection("requisicao_ativa_motorista")
          .document(idMotorista)
          .setData(dadosRequisicaoAtualizadaMotorista);
    });

    _statusaCaminho();
  }

  // Inicia a corrida
  iniciarCorrida(idRequisicao) async {
    Map<String, dynamic> _dadosRequisicao;
    _dadosRequisicao = await _recuperaRequisicao(idRequisicao);

    db.collection("requisicoes").document(idRequisicao).updateData({
      "origem": {
        "latitude": _dadosRequisicao["motorista"]["latitude"],
        "longitude": _dadosRequisicao["motorista"]["longitude"]
      },
      "status": StatusRequisicao.VIAGEM
    });

    String idPassageiro = _dadosRequisicao["passageiro"]["uid"];
    db
        .collection("requisicao_ativa")
        .document(idPassageiro)
        .updateData({"status": StatusRequisicao.VIAGEM});

    String idMotorista = _dadosRequisicao["motorista"]["uid"];
    db
        .collection("requisicao_ativa_motorista")
        .document(idMotorista)
        .updateData({"status": StatusRequisicao.VIAGEM});
  }

  // Metodo para finalzar a corrida
  finalizarCorrida(idRequisicao) async {
    FirebaseUser user = await UsuarioFirebase.getUsuarioAtual();
    DocumentSnapshot snapshot =
        await db.collection("requisicoes").document(idRequisicao).get();

    Map<String, dynamic> dados = snapshot.data;
    String idPassageiro = dados["passageiro"]["uid"];

    double valor;

    db.collection("requisicoes").document(idRequisicao).updateData(
        {"status": StatusRequisicao.FINALIZADA, "valor": valor}).then((x) {
      db.collection("requisicao_ativa").document(idPassageiro).delete();
      db.collection("requisicao_ativa_motorista").document(user.uid).delete();
    });
  }

  // Metodo de cancelar a corrida
  cancelarCorrida() async {
    FirebaseUser user = await UsuarioFirebase.getUsuarioAtual();
    String idRequisicao;

    Map<String, dynamic> dadosRequisicaoAtualizada = {};
    dadosRequisicaoAtualizada["status"] = StatusRequisicao.AGUARDANDO;
    dadosRequisicaoAtualizada["motorista"] = null;

    DocumentSnapshot ref = await db
        .collection("requisicao_ativa_motorista")
        .document(user.uid)
        .get();

    idRequisicao = ref["idRequisicao"];

    db
        .collection("requisicoes")
        .document(idRequisicao)
        .updateData(dadosRequisicaoAtualizada)
        .then((x) {
      db.collection("requisicao_ativa_motorista").document(user.uid).delete();
    });

    _statusCancelar();
  }

  // Verificar se a requisição a ser aceita existe e a retorna
  _recuperaRequisicao(String idRequisicao) async {
    Map<String, dynamic> _dadosRequisicao;

    DocumentSnapshot documentSnapshot =
        await db.collection("requisicoes").document(idRequisicao).get();

    return _dadosRequisicao = documentSnapshot.data;
  }

  // Ouvinte verificando se a requisição foi mudada
  listenerRequisicao(
      String id, BlocMap blocMap, context, localImagem, api) async {
    Map<String, dynamic> _dadosRequisicao;
    _dadosRequisicao = await _recuperaRequisicao(id);

    String idRequisicao = _dadosRequisicao["id"];

    db
        .collection("requisicoes")
        .document(idRequisicao)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data != null) {
        Map<String, dynamic> dados = snapshot.data;
        String status = dados["status"];

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
            await blocMap.listenerLocalizacao(
                context, "m", localImagem, "motorista", api);
            await blocMap.exebirMarcador(
                LatLng(blocMap.localMotorista.latitude,
                    blocMap.localMotorista.longitude),
                context,
                localImagem,
                "motorista",
                api);
            _statusAguardando();
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
      } else {
        await blocMap.listenerLocalizacao(
            context, "m", localImagem, "motorista", api);
        await blocMap.exebirMarcador(
            LatLng(blocMap.localMotorista.latitude,
                blocMap.localMotorista.longitude),
            context,
            localImagem,
            "motorista",
            api);
        _statusCancelar();
      }
    });
  }

  // Metodo que chama o painel da corrida para a corrida selecionada
  onTapPainelCorrida(
      String idRequisicao,
      BlocMotorista blocMotorista,
      BlocMap blocMapMotorista,
      BlocDirectionsProvider api,
      BuildContext context) {
    push(context,
        CorridaMotorista(idRequisicao, blocMapMotorista, blocMotorista, api),
        replace: true);
  }

  // Veirifica se o motorista tem alguma corrida ativa, senão recupera as corridas de passageiros que estão aguardando
  recuperarRequisicaoAtivaMotorista(
      context, blocMotorista, BlocMap blocMap, api) async {
    FirebaseUser user = await UsuarioFirebase.getUsuarioAtual();

    DocumentSnapshot documentSnapshot = await db
        .collection("requisicao_ativa_motorista")
        .document(user.uid)
        .get();

    var dadosRequisicao = documentSnapshot.data;

    if (dadosRequisicao == null) {
      _listenerRequisicoes();
    } else {
      String idRequisicao = dadosRequisicao["idRequisicao"];
      blocMap.idRequisicao = idRequisicao;
      push(context, CorridaMotorista(idRequisicao, blocMap, blocMotorista, api),
          replace: true);
    }
  }

  _statusAguardando() {
    _streamControllerCorrida.add(StatusRequisicao.AGUARDANDO);
  }

  _statusaCaminho() {
    _streamControllerCorrida.add(StatusRequisicao.A_CAMINHO);
  }

  _statusViagem() {
    _streamControllerCorrida.add(StatusRequisicao.VIAGEM);
  }

  statusFinalizada() {
    _streamControllerCorrida.add(StatusRequisicao.VEICULONAOCHAMADO);
  }

  _statusCancelar() {
    _streamControllerCorrida.add(StatusRequisicao.VEICULONAOCHAMADO);
  }

  String get statusCorrida => _statusCorrida;

  set statusCorrida(String value) {
    _statusCorrida = value;
  }

  void dispose() {
    _streamController.close();
  }
}
