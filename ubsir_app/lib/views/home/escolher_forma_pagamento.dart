import 'package:flutter/material.dart';
import 'package:ubsir_app/bloc/home/painel_passageiro/bloc_dinheiro_cartao.dart';


class EscolherFormaPagamento extends StatefulWidget {
  BlocDinheiroCartao _blocDinheiroCartao;

  EscolherFormaPagamento(this._blocDinheiroCartao);

  @override
  _EscolherFormaPagamentoState createState() => _EscolherFormaPagamentoState(_blocDinheiroCartao);
}

class _EscolherFormaPagamentoState extends State<EscolherFormaPagamento> {
  BlocDinheiroCartao _blocDinheiroCartao;

  _EscolherFormaPagamentoState(this._blocDinheiroCartao);

  @override
  void initState() {
    super.initState();
    _blocDinheiroCartao.onChangedTipo(false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: _blocDinheiroCartao.stream,
        builder: (context, snapshot) {
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
        }
    );
  }
}
