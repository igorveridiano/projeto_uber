import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubsir_app/bloc/home/bloc_directions_provider.dart';
import 'package:ubsir_app/bloc/home/bloc_map.dart';
import 'package:ubsir_app/bloc/home/painel_passageiro/bloc_passageiro.dart';
import 'package:ubsir_app/bloc/utils/bloc_validate.dart';
import 'package:ubsir_app/utils/status_requisicao.dart';
import 'package:ubsir_app/widgets/app_button.dart';

class PainelPassageiro extends StatefulWidget {
  BlocMap blocMapPassageiro;
  BlocPassageiro blocPassageiro;
  BlocDirectionsProvider api;

  PainelPassageiro(this.blocMapPassageiro, this.blocPassageiro, this.api);

  @override
  _PainelPassageiroState createState() =>
      _PainelPassageiroState(blocMapPassageiro, blocPassageiro, api);
}

class _PainelPassageiroState extends State<PainelPassageiro> {
  BlocMap _blocMapPassageiro;
  BlocPassageiro _blocPassageiro;
  BlocDirectionsProvider api;

  final _tLocalDestino = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _PainelPassageiroState(
      this._blocMapPassageiro, this._blocPassageiro, this.api);

  @override
  void initState() {
    super.initState();
    _blocMapPassageiro.ultimaLocalizacaoConhecida(context, "p");
    _blocMapPassageiro.listenerLocalizacao(
        context, "p", "imagens/passageiro.png", "passageiro", api);
    _blocPassageiro.listenerRequisicaoAtiva(
        _blocMapPassageiro, context, "imagens/passageiro.png", api);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CameraPosition>(
        stream: _blocMapPassageiro.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          CameraPosition cameraPosition = snapshot.data;
          return Form(
            key: _formKey,
            child: StreamBuilder<String>(
                stream: _blocPassageiro.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  String veiculoChamadoStatus = snapshot.data;
                  return Container(
                    child: Stack(
                      children: <Widget>[
                        GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: cameraPosition,
                          onMapCreated: _blocMapPassageiro.onMapcreated,
                          //myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          markers: _blocMapPassageiro.marcadores,
                          polylines: api.rotaAtual,
                        ),
                        Visibility(
                          visible: veiculoChamadoStatus ==
                                  StatusRequisicao.VEICULONAOCHAMADO
                              ? true
                              : false,
                          child: Stack(
                            children: <Widget>[
                              minhaLocalizacaoText(),
                              localDestinoText(),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          left: 0,
                          bottom: 0,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: AppButton(
                              _textButton(veiculoChamadoStatus),
                              buttonColor: _buttonColor(veiculoChamadoStatus),
                              textColor: Colors.white,
                              onPressed: () => _onPressedVeiculoChamado(
                                  veiculoChamadoStatus,
                                  _tLocalDestino,
                                  context,
                                  _formKey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          );
        });
  }

  _onPressedVeiculoChamado(
      veiculoChamadoStatus, _tLocalDestino, context, _formKey) {
    switch (veiculoChamadoStatus) {
      case StatusRequisicao.AGUARDANDO:
        return _blocPassageiro.cancelarVeiculoChamado(context);
        break;
      case StatusRequisicao.A_CAMINHO:
        return null;
        break;
      case StatusRequisicao.VIAGEM:
        return null;
        break;
      case StatusRequisicao.FINALIZADA:
        break;
      case StatusRequisicao.VEICULONAOCHAMADO:
        return _blocPassageiro.chamarVeiculo(_tLocalDestino, context, _formKey,
            _blocMapPassageiro.localPassageiro, _blocMapPassageiro, api);
        break;
    }
  }

  _buttonColor(veiculoChamadoStatus) {
    switch (veiculoChamadoStatus) {
      case StatusRequisicao.AGUARDANDO:
        return Colors.red;
        break;
      case StatusRequisicao.A_CAMINHO:
        return Colors.grey;
        break;
      case StatusRequisicao.VIAGEM:
        return Colors.grey;
        break;
      case StatusRequisicao.FINALIZADA:
        break;
      case StatusRequisicao.VEICULONAOCHAMADO:
        return Colors.black;
        break;
    }
  }

  _textButton(veiculoChamadoStatus) {
    switch (veiculoChamadoStatus) {
      case StatusRequisicao.AGUARDANDO:
        return "CANCELAR";
        break;
      case StatusRequisicao.A_CAMINHO:
        return "MOTORISTA A CAMINHO";
        break;
      case StatusRequisicao.VIAGEM:
        return "VIAGEM";
        break;
      case StatusRequisicao.FINALIZADA:
        break;
      case StatusRequisicao.VEICULONAOCHAMADO:
        return "CHAMAR VEÍCULO";
        break;
    }
  }

  Positioned localDestinoText() {
    return Positioned(
      top: 55,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(3),
            color: Colors.white,
          ),
          child: TextFormField(
            controller: _tLocalDestino,
            validator: BlocValidate.validateLocalDestino,
            decoration: InputDecoration(
              icon: Container(
                  margin: EdgeInsets.only(left: 20),
                  width: 10,
                  height: 10,
                  child: Icon(
                    Icons.local_taxi,
                    color: Colors.black,
                  )),
              hintText: "Digite o destino",
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: 15,
                top: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Positioned minhaLocalizacaoText() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(3),
            color: Colors.white,
          ),
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              icon: Container(
                  margin: EdgeInsets.only(left: 20),
                  width: 10,
                  height: 10,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                  )),
              hintText: "Meu Local",
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: 15,
                top: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
