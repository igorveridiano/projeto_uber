import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_maps_webservice/directions.dart';

class BlocDirectionsProvider extends ChangeNotifier{
  GoogleMapsDirections directionsApi = GoogleMapsDirections(apiKey: "AIzaSyDcReICJtbC03IFoR5WuFq5mkpXSMiSXgM");

  Set<maps.Polyline> _rota = Set();

  Set<maps.Polyline> get rotaAtual => _rota;

  findDirections(maps.LatLng de, maps.LatLng para) async {
    var origem = Location(de.latitude, de.longitude);
    var destino = Location(para.latitude, para.longitude);

    var resultado = await directionsApi.directionsWithLocation(origem, destino, travelMode: TravelMode.driving);

    print(resultado.toJson());

    Set<maps.Polyline> novaRota = Set();

    if (resultado.isOkay) {
      var rota = resultado.routes[0];
      var leg = rota.legs[0];

      print("resultado >>> $resultado");
      print("rota >>> $rota");
      print("leg >>> $leg");

      List<maps.LatLng> points = [];

      leg.steps.forEach((step) {
        points.add(maps.LatLng(step.startLocation.lat, step.startLocation.lng));
        points.add(maps.LatLng(step.endLocation.lat, step.endLocation.lng));
      });

      var line = maps.Polyline(
        points: points,
        polylineId: maps.PolylineId("melhor rota"),
        color: Colors.blue,
        width: 4,
      );
      novaRota.add(line);

      print(line);

      _rota = novaRota;
      notifyListeners();
    } else {
      print("ERRROR !!! ${resultado.status}");
    }
  }

  semRota(){
    _rota = null;
  }
}