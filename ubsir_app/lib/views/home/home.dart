import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubsir_app/bloc/home/bloc_directions_provider.dart';
import 'package:ubsir_app/bloc/home/bloc_map.dart';
import 'package:ubsir_app/bloc/home/painel_motorista/bloc_motorista.dart';
import 'package:ubsir_app/bloc/home/painel_passageiro/bloc_passageiro.dart';
import 'package:ubsir_app/bloc/utils/bloc_VerificarUsuario.dart';
import 'package:ubsir_app/bloc/utils/bloc_usuario.dart';
import 'package:ubsir_app/models/usuario.dart';
import 'package:ubsir_app/views/home/painel_motorista.dart';
import 'package:ubsir_app/views/home/painel_passageiro.dart';
import 'package:ubsir_app/widgets/drawer_list_motorista.dart';
import 'package:ubsir_app/widgets/drawer_list_passageiro.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _blocVerificarUsuario = BlocVerificarUsuario();
  BlocUsuario _blocUsuario = BlocUsuario();
  BlocMap _blocMapPassageiro = BlocMap();
  BlocPassageiro _blocPassageiro = BlocPassageiro();
  BlocMotorista _blocMotorista = BlocMotorista();

  @override
  void initState() {
    super.initState();
    _blocVerificarUsuario.verificaUsuarioLogado1(context);
    _blocUsuario.recuperarUsuario();
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
                  title: Text("Home"),
                  centerTitle: true,
                ),
                body: _body(usuario),
                drawer: usuario.tipoUsuario == "passageiro"
                    ? DrawerListPassageiro(usuario)
                    : DrawerListMotorista(usuario),
              );
            }
          );

  }

  _body(usuario) {
    return Consumer<BlocDirectionsProvider>(
      builder: (BuildContext context, BlocDirectionsProvider api, Widget child) {
        return usuario.tipoUsuario == "passageiro"
            ? PainelPassageiro(_blocMapPassageiro, _blocPassageiro, api)
            : PainelMotorista(_blocMotorista, api);
      }
    );
  }

  @override
  void dispose() {
    super.dispose();
    _blocUsuario.dispose();
  }
}
