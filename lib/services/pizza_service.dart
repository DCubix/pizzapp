import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pizzapp/model/pizza.dart';
import 'package:pizzapp/model/preset.dart';
import 'package:pizzapp/model/tamanho.dart';

class PizzaService {

  static Future<List<Pizza>> listPizzas() async {
    final pizzasText = await rootBundle.loadString('assets/pizzas.json');
    final pizzasObj = json.decode(pizzasText);
    return (pizzasObj as List).map((e) => Pizza.fromJson(e)).toList();
  }

  static Future<List<Tamanho>> listTamanhos() async {
    final tamanhosText = await rootBundle.loadString('assets/tamanhos.json');
    final tamanhosObj = json.decode(tamanhosText);
    return (tamanhosObj as List).map((e) => Tamanho.fromJson(e)).toList();
  }

  static Future<List<Preset>> listPresets() async {
    final presetsText = await rootBundle.loadString('assets/presets.json');
    final presetsObj = json.decode(presetsText);
    final presets = (presetsObj as List).map((e) => Preset.fromJson(e)).toList();
    await Future.forEach(presets, (Preset p) async {
      await p.fetchTamanho();
      return Future.wait(p.sabores.map((e) => e.fetchSabor()));
    });
    return presets;
  }

  static Future<Pizza?> getPizza(int id) async {
    final pizzas = await listPizzas();
    final pizza = pizzas.where((e) => e.id == id);
    return pizza.isNotEmpty ? pizza.first : null;
  }

  static Future<Tamanho?> getTamanho(String cod) async {
    final tamanhos = await listTamanhos();
    final tamanho = tamanhos.where((e) => e.cod == cod);
    return tamanho.isNotEmpty ? tamanho.first : null;
  }

}