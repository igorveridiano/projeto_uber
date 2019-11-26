import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ubsir_app/bloc/home/bloc_directions_provider.dart';
import 'package:ubsir_app/bloc/home/bloc_map.dart';
import 'package:ubsir_app/bloc/home/painel_motorista/bloc_motorista.dart';

class PainelMotorista extends StatefulWidget {
  BlocMotorista _blocMotorista;
  BlocDirectionsProvider api;

  PainelMotorista(this._blocMotorista, this.api);

  @override
  _PainelMotoristaState createState() =>
      _PainelMotoristaState(_blocMotorista, api);
}

class _PainelMotoristaState extends State<PainelMotorista> {
  BlocMotorista _blocMotorista;
  BlocMap _blocMapMotorista = BlocMap();
  BlocDirectionsProvider api;

  _PainelMotoristaState(this._blocMotorista, this.api);

  @override
  void initState() {
    super.initState();
    _blocMotorista.recuperarRequisicaoAtivaMotorista(
        context, _blocMotorista, _blocMapMotorista, api);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _blocMotorista.stream,
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

          if (snapshot.hasError) {
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Erro ao carregar os dados!"),
                ],
              ),
            );
          } else {
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
                List<DocumentSnapshot> requisicoes =
                    querySnapshot.documents.toList();
                DocumentSnapshot item = requisicoes[index];

                String idRequisicao = item["id"];
                String nomePassageiro = item["passageiro"]["nome"];
                String urlFotoPassageiro = item["passageiro"]["urlFoto"];
                String rua = item["destino"]["rua"];
                String numero = item["destino"]["numero"];

                return ListTile(
                  leading: CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.grey,
                    backgroundImage: urlFotoPassageiro != null
                        ? NetworkImage(urlFotoPassageiro)
                        : null,
                  ),
                  title: Text(nomePassageiro),
                  subtitle: Text("destino: $rua, $numero"),
                  onTap: () => _blocMotorista.onTapPainelCorrida(idRequisicao,
                      _blocMotorista, _blocMapMotorista, api, context),
                );
              },
            );
          }
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
