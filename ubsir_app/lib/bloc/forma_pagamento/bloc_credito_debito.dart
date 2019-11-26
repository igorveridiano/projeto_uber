import 'dart:async';

class BlocCreditoDebito {
  final _streamController = StreamController<bool>();

  get stream => _streamController.stream;

  onChangedTipo(valor) {
    if (valor) {
      _streamController.add(true);
    } else {
      _streamController.add(false);
    }
  }

  void dispose() {
    _streamController.close();
  }
}