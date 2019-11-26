import 'package:flutter/material.dart';
import 'package:ubsir_app/models/usuario.dart';
import 'package:ubsir_app/utils/nav.dart';
import 'package:ubsir_app/views/forma_pagamento/forma_pagamento.dart';
import 'package:ubsir_app/views/home/home.dart';
import 'package:ubsir_app/views/login/login_page.dart';

class DrawerListMotorista extends StatelessWidget {
  Usuario usuario;

  DrawerListMotorista(this.usuario);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            usuario != null
                ? _header(usuario)
                : SizedBox(
              height: 100,
              child: CircularProgressIndicator(),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () => _onClickHome(context),
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text("Formas Pagamentos"),
              onTap: () => _onClickFormasPagamentos(context),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text("Configurações"),
              onTap: () => _onClickConfiguracoes(context),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Logout"),
              onTap: () => _onClickLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  UserAccountsDrawerHeader _header(user) {
    return UserAccountsDrawerHeader(
      accountName: Text(user.nome),
      accountEmail: Text(user.email),
      currentAccountPicture: CircleAvatar(
        backgroundImage: NetworkImage(user.urlFoto),
      ),
    );
  }

  _onClickLogout(context){
    Usuario.clear();
    push(context, LoginPage(), replace: true);
  }

  _onClickHome(BuildContext context) {
    push(context, Home(), replace: true);
  }

  _onClickFormasPagamentos(context) {
    push(context, FormaPagamento("editar"), replace: true);
  }

  _onClickConfiguracoes(context) {}
}