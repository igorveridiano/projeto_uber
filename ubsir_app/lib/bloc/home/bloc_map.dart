import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubsir_app/bloc/home/bloc_directions_provider.dart';
import 'package:ubsir_app/utils/status_requisicao.dart';
import 'package:ubsir_app/utils/usuarioFirebase.dart';

class BlocMap {
  final _streamController = StreamController<CameraPosition>();
  get stream => _streamController.stream;

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marcadores = {};

  Firestore db = Firestore.instance;

  Position _localPassageiro;
  Position _localMotorista;
  String _idRequisicao;

  // Cria o mapa do google
  onMapcreated(GoogleMapController controller) async {
    FirebaseUser user = await UsuarioFirebase.getUsuarioAtual();

    _controller.complete(controller);
  }

  // Pega a ultima localização conhecida do usuario
  ultimaLocalizacaoConhecida(context, tipo) async {
    Position position = await Geolocator().getLastKnownPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    CameraPosition cameraPosition;

    if (position != null) {
      cameraPosition = CameraPosition(
        target: LatLng(
          position.latitude,
          position.longitude,
        ),
        zoom: 19,
      );

      _streamController.add(cameraPosition);

      if (tipo == "m") {
        localMotorista = position;
      } else if (tipo == "p") {
        localPassageiro = position;
      }
    }
  }

  // Listener para escutar a localização do usuario, para atuliza-la conforme ele se locomove
  listenerLocalizacao(context, tipo, localImagem, tipoUsuario, api) {
    var geolocator = Geolocator();
    var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) async {
      CameraPosition cameraPosition;
      cameraPosition = CameraPosition(
        target: LatLng(
          position.latitude,
          position.longitude,
        ),
        zoom: 19,
      );

      _streamController.add(cameraPosition);

      if (idRequisicao != null && idRequisicao.isNotEmpty) {
        UsuarioFirebase.atualizarDadosUsuarios(
            idRequisicao, position.latitude, position.longitude, tipoUsuario);
      } else {
        exebirMarcador(LatLng(position.latitude, position.longitude), context,
            localImagem, tipoUsuario, api);
      }

      if (tipo == "m") {
        localMotorista = position;
      } else if (tipo == "p") {
        localPassageiro = position;
      }
    });
  }

  // Movimentar a camera do mapa para o localização atual do usuario
  movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  // Exibir um icone personalizado do passageiro ou motorista
  exebirMarcador(LatLng local, context, localImagem, tipo, BlocDirectionsProvider api) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio: pixelRatio,
      ),
      localImagem,
    ).then((BitmapDescriptor icone) {
      Marker marcadorPasssageiro = Marker(
        markerId: MarkerId("marcador-$tipo"),
        position: LatLng(local.latitude, local.longitude),
        infoWindow: InfoWindow(title: "Meu Local"),
        icon: icone,
      );
      marcadores.add(marcadorPasssageiro);
    });

    CameraPosition cameraPosition;

    if (local != null) {
      cameraPosition = CameraPosition(
        target: LatLng(
          local.latitude,
          local.longitude,
        ),
        zoom: 19,
      );
    }

    api.semRota();

    movimentarCamera(cameraPosition);
  }

  // Exibir um icone personalizado dois marcadores
  exebirDoisMarcadores(LatLng motoristaPosicao, LatLng passageiroPosicao,
      context, status, api) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    Set<Marker> _listaMarcadores = {};
    String marcadorMotorista;
    String marcadorPassageiro;
    String id1;
    String id2;
    String titulo1;
    String titulo2;

    marcadorMotorista = "imagens/motorista.png";
    id1 = "marcador-motorista";
    titulo1 = "Local Motorista";
    if (status == StatusRequisicao.VIAGEM) {
      marcadorPassageiro = "imagens/destino.png";
      id2 = "marcador-destino";
      titulo2 = "Local Destino";
    } else {
      marcadorPassageiro = "imagens/passageiro.png";
      id2 = "marcador-passageiro";
      titulo2 = "Local Passageiro";
    }

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio: pixelRatio,
      ),
      marcadorMotorista,
    ).then((BitmapDescriptor icone) {
      Marker marcadorMotorista = Marker(
        markerId: MarkerId(id1),
        position: LatLng(motoristaPosicao.latitude, motoristaPosicao.longitude),
        infoWindow: InfoWindow(title: titulo1),
        icon: icone,
      );
      _listaMarcadores.add(marcadorMotorista);
    });

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio: pixelRatio,
      ),
      marcadorPassageiro,
    ).then((BitmapDescriptor icone) {
      Marker marcadorPassageiro = Marker(
        markerId: MarkerId(id2),
        position:
            LatLng(passageiroPosicao.latitude, passageiroPosicao.longitude),
        infoWindow: InfoWindow(title: titulo2),
        icon: icone,
      );
      _listaMarcadores.add(marcadorPassageiro);
    });

    marcadores = _listaMarcadores;

    var latitudeSudoeste =
        min(motoristaPosicao.latitude, passageiroPosicao.latitude);
    var longitudeSudoeste =
        min(motoristaPosicao.longitude, passageiroPosicao.longitude);
    var latitudeNordeste =
        max(motoristaPosicao.latitude, passageiroPosicao.latitude);
    var longitudeNordeste =
        max(motoristaPosicao.longitude, passageiroPosicao.longitude);

    print("buscando direçoes");
    await api.findDirections(motoristaPosicao, passageiroPosicao);

    api.rotaAtual.first.points.forEach((point) {
      latitudeSudoeste = min(latitudeSudoeste, point.latitude);
      longitudeSudoeste = min(longitudeSudoeste, point.longitude);
      latitudeNordeste = max(latitudeNordeste, point.latitude);
      longitudeNordeste = max(longitudeNordeste, point.longitude);
    });

    LatLngBounds limites = LatLngBounds(
        northeast: LatLng(latitudeNordeste, longitudeNordeste),
        southwest: LatLng(latitudeSudoeste, longitudeSudoeste));

    movimentarCameraBounds(limites);
  }

  // Movimentar a camera do mapa para o localização atual do passageiro e motorista, para centralizar os dois
  movimentarCameraBounds(LatLngBounds limites) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(limites, 100));
  }

  Set<Marker> get marcadores => _marcadores;

  set marcadores(Set<Marker> value) {
    _marcadores = value;
  }

  Position get localPassageiro => _localPassageiro;

  set localPassageiro(Position value) {
    _localPassageiro = value;
  }

  Position get localMotorista => _localMotorista;

  set localMotorista(Position value) {
    _localMotorista = value;
  }

  String get idRequisicao => _idRequisicao;

  set idRequisicao(String value) {
    _idRequisicao = value;
  }

  Completer<GoogleMapController> get controller => _controller;

  set controller(Completer<GoogleMapController> value) {
    _controller = value;
  }

  void dispose() {
    _streamController.close();
  }
}
