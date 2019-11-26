import 'package:ubsir_app/models/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ubsir_app/utils/nav.dart';
import 'package:ubsir_app/views/home/home.dart';

class BlocCadastro {
  onClickCadastro(formkey, tNome, tEmail, tSenha, tipoUsuario, context) async {
    final _formKey = formkey;
    final _tEmail = tEmail;
    final _tNome = tNome;
    final _tSenha = tSenha;
    bool _tipoUsuario = tipoUsuario;
    FirebaseAuth auth = FirebaseAuth.instance;
    Firestore db = Firestore.instance;

    if (!_formKey.currentState.validate()) {
      return;
    }

    String nome = _tNome.text;
    String email = _tEmail.text;
    String senha = _tSenha.text;

    Usuario usuario = Usuario();

    usuario.nome = nome;
    usuario.email = email;
    usuario.senha = senha;
    usuario.urlFoto = "https://firebasestorage.googleapis.com/v0/b/ubsir-774f7.appspot.com/o/perfil%2Fpadrao%2Fpadrao.jpg?alt=media&token=1ba1f379-3aed-4351-b158-b712ef7bbe25";
    usuario.tipoUsuario = _tipoUsuario ?  "motorista":"passageiro";

    auth.createUserWithEmailAndPassword(email: usuario.email, password: usuario.senha,).then((fireBaseUser) async{
      usuario.idUsuario = fireBaseUser.user.uid;

      db.collection("usuarios").document(usuario.idUsuario).setData(usuario.toMap());

      push(context, Home(), replace: true);
    });
  }
}
