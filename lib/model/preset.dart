import 'package:pizzapp/model/pizza.dart';
import 'package:pizzapp/model/tamanho.dart';
import 'package:pizzapp/services/pizza_service.dart';

class PresetSabor {
  int id, fatias;

  Pizza? sabor;

  PresetSabor({
    required this.id,
    required this.fatias,
    this.sabor,
  });

  factory PresetSabor.fromJson(Map<String, dynamic> ob) => PresetSabor(
    id: ob['id'],
    fatias: ob['fatias'],
  );

  double razaoPreco(int fatias) {
    return fatias.toDouble() / fatias;
  }

  Future fetchSabor() async {
    sabor = await PizzaService.getPizza(id);
  }

}

class Preset {
  String nome, tamanho;
  int fatias;
  List<PresetSabor> sabores;
  double desconto;

  Tamanho? tamanhoObject;

  Preset({
    required this.nome,
    required this.tamanho,
    required this.fatias,
    required this.sabores,
    required this.desconto,
  });

  factory Preset.fromJson(Map<String, dynamic> ob) => Preset(
    nome: ob['nome'],
    tamanho: ob['tamanho'],
    fatias: ob['fatias'],
    sabores: List.from(ob['sabores'] as List).map((e) => PresetSabor.fromJson(e)).toList(),
    desconto: ob['desconto'],
  );

  Future fetchTamanho() async {
    tamanhoObject = await PizzaService.getTamanho(tamanho);
  }

}