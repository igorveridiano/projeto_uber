import 'package:flutter/material.dart';
import 'package:ubsir_app/models/cartao.dart';

Future<String> push(context, Widget page, {bool replace = false}) {
  if (replace) {
    return Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return page;
    }));
  }
  return Navigator.push(context,
      MaterialPageRoute(builder: (BuildContext context) {
    return page;
  }));
}

Future<Cartao> pushCartao(context, Widget page, {bool replace = false}) {
  if (replace) {
    return Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
          return page;
        }));
  }
  return Navigator.push(context,
      MaterialPageRoute(builder: (BuildContext context) {
        return page;
      }));
}

pop(context, String text) => Navigator.pop(context, text);

popCartao(context, Cartao cartao) => Navigator.pop(context, cartao);
