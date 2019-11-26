class BlocValidate {
  static String validateLogin(String text) {
    if (text.isEmpty) {
      return "Digite o login.";
    } else {
      return null;
    }
  }

  static String validateSenha(String text) {
    if (text.isEmpty) {
      return "Digite a senha.";
    } else if (text.length < 8) {
      return "A senha deve ter no minimo 8 caracteres.";
    } else {
      return null;
    }
  }

  static String validateNome(String text) {
    if (text.isEmpty) {
      return "Digite o nome.";
    } else if (text.length < 2) {
      return "Digite o nome deve ter no minimo 2 caracteres.";
    } else {
      return null;
    }
  }

  static String validateLocalDestino(String text) {
    if (text.isEmpty) {
      return "Digite o destino.";
    } else {
      return null;
    }
  }

  static String validateData(String text) {
    if (text.isEmpty) {
      return "Digite a data de validade.";
    } else if (text.length != 5) {
      return "A data de validade esta incorreta, deveria estar no formato xx/xx";
    } else {
      return null;
    }
  }

  static String validateNumero(String text) {
    if (text.isEmpty) {
      return "Digite o numero do cartão.";
    } else if (text.length != 16) {
      return "O numero do crtão está incorreto, deveria ter 16 numeros";
    } else {
      return null;
    }
  }
}
