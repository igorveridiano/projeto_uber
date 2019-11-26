import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubsir_app/bloc/home/bloc_directions_provider.dart';
import 'package:ubsir_app/bloc/home/bloc_map.dart';
import 'package:ubsir_app/bloc/home/painel_motorista/bloc_motorista.dart';
import 'package:ubsir_app/bloc/utils/bloc_usuario.dart';
import 'package:ubsir_app/models/usuario.dart';
import 'package:ubsir_app/utils/status_requisicao.dart';
import 'package:ubsir_app/widgets/app_button.dart';
import 'package:ubsir_app/widgets/drawer_list_motorista.dart';

class CorridaMotorista extends StatefulWidget {
  BlocMap _blocMapMotorista;
  BlocMotorista _blocMotorista;
  BlocDirectionsProvider api;
  String _idRequisicao;

  CorridaMotorista(this._idRequisicao, this._blocMapMotorista,
      this._blocMotorista, this.api);

  @override
  _CorridaMotoristaState createState() => _CorridaMotoristaState(
      _idRequisicao, _blocMapMotorista, _blocMotorista, api);
}

class _CorridaMotoristaState extends State<CorridaMotorista> {
  final _blocUsuario = BlocUsuario();
  BlocMap _blocMapMotorista;
  BlocMotorista _blocMotorista;
  BlocDirectionsProvider api;
  String _idRequisicao;

  _CorridaMotoristaState(this._idRequisicao, this._blocMapMotorista,
      this._blocMotorista, this.api);

  @override
  void initState() {
    super.initState();
    _blocMapMotorista.ultimaLocalizacaoConhecida(context, "m");
    _blocMotorista.statusCorrida = "";
    _blocUsuario.recuperarUsuario();
    _blocMapMotorista.listenerLocalizacao(
        context, "m", "imagens/motorista.png", "motorista", api);
    _blocMotorista.listenerRequisicao(_idRequisicao, _blocMapMotorista, context,
        "imagens/motorista.png", api);
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
              title: Text("Painel Corrida${_blocMotorista.statusCorrida}"),
              centerTitle: true,
            ),
            body: _body(),
            drawer: DrawerListMotorista(usuario),
          );
        });
  }

  StreamBuilder<CameraPosition> _body() {
    return StreamBuilder<CameraPosition>(
      stream: _blocMapMotorista.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        CameraPosition cameraPosition = snapshot.data;
        return StreamBuilder<String>(
            stream: _blocMotorista.streamCorrida,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              String corridaAceitaStatus = snapshot.data;
              return Container(
                child: Stack(
                  children: <Widget>[
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: cameraPosition,
                      onMapCreated: _blocMapMotorista.onMapcreated,
                      myLocationButtonEnabled: false,
                      markers: _blocMapMotorista.marcadores,
                      polylines: api.rotaAtual,
                    ),
                    Visibility(
                      visible: corridaAceitaStatus == StatusRequisicao.A_CAMINHO ? true: false,
                      child: Positioned(
                        right: 0,
                        left: 0,
                        bottom: 60,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: AppButton(
                            _textButton1(corridaAceitaStatus),
                            buttonColor: _buttonColor1(corridaAceitaStatus),
                            textColor: Colors.white,
                            onPressed: () => _onPressedAceitarCorrida1(
                                corridaAceitaStatus, context, _idRequisicao),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      left: 0,
                      bottom: 0,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: AppButton(
                          _textButton2(corridaAceitaStatus),
                          buttonColor: _buttonColor2(corridaAceitaStatus),
                          textColor: Colors.white,
                          onPressed: () => _onPressedAceitarCorrida2(
                              corridaAceitaStatus, context, _idRequisicao),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  _onPressedAceitarCorrida1(corridaAceitaStatus, context, _idRequisicao) {
    switch (corridaAceitaStatus) {
      case StatusRequisicao.AGUARDANDO:
        break;
      case StatusRequisicao.A_CAMINHO:
        _blocMotorista.statusCorrida = " - A caminho do passageiro";
        return _blocMotorista.iniciarCorrida(_idRequisicao);
        break;
      case StatusRequisicao.VIAGEM:
        break;
      case StatusRequisicao.FINALIZADA:
        break;
      case StatusRequisicao.VEICULONAOCHAMADO:
        break;
    }
  }

  _onPressedAceitarCorrida2(corridaAceitaStatus, context, _idRequisicao) {
    switch (corridaAceitaStatus) {
      case StatusRequisicao.AGUARDANDO:
        return _blocMotorista.aceitarCorrida(context, _idRequisicao,
            _blocMapMotorista.localMotorista, _blocMapMotorista);
        break;
      case StatusRequisicao.A_CAMINHO:
        return _blocMotorista.cancelarCorrida();
        break;
      case StatusRequisicao.VIAGEM:
        _blocMotorista.statusCorrida = " - Em viagem";
        return _blocMotorista.finalizarCorrida(_idRequisicao);
        break;
      case StatusRequisicao.FINALIZADA:
        break;
      case StatusRequisicao.VEICULONAOCHAMADO:
        break;
    }
  }

  _buttonColor1(corridaAceitaStatus) {
    switch (corridaAceitaStatus) {
      case StatusRequisicao.AGUARDANDO:
        break;
      case StatusRequisicao.A_CAMINHO:
        return Colors.black;
        break;
      case StatusRequisicao.VIAGEM:
        break;
      case StatusRequisicao.FINALIZADA:
        break;
      case StatusRequisicao.VEICULONAOCHAMADO:
        break;
    }
  }

  _textButton1(corridaAceitaStatus) {
    switch (corridaAceitaStatus) {
      case StatusRequisicao.AGUARDANDO:
        break;
      case StatusRequisicao.A_CAMINHO:
        return "INICIAR CORRIDA";
        break;
      case StatusRequisicao.VIAGEM:
        break;
      case StatusRequisicao.FINALIZADA:
        break;
      case StatusRequisicao.VEICULONAOCHAMADO:
        break;
    }
  }

  _buttonColor2(corridaAceitaStatus) {
    switch (corridaAceitaStatus) {
      case StatusRequisicao.AGUARDANDO:
        return Colors.black;
        break;
      case StatusRequisicao.A_CAMINHO:
        return Colors.red;
        break;
      case StatusRequisicao.VIAGEM:
        return Colors.black;
        break;
      case StatusRequisicao.FINALIZADA:
        break;
      case StatusRequisicao.VEICULONAOCHAMADO:
        break;
    }
  }

  _textButton2(corridaAceitaStatus) {
    switch (corridaAceitaStatus) {
      case StatusRequisicao.AGUARDANDO:
        return "ACEITAR CORRIDA";
        break;
      case StatusRequisicao.A_CAMINHO:
        return "CANCELAR";
        break;
      case StatusRequisicao.VIAGEM:
        return "FINALIZAR CORRIDA";
        break;
      case StatusRequisicao.FINALIZADA:
        break;
      case StatusRequisicao.VEICULONAOCHAMADO:
        break;
    }
  }
}
