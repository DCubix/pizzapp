import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pizzapp/dialog/pizza_flavor_dialog.dart';
import 'package:pizzapp/model/pizza.dart';
import 'package:pizzapp/model/preset.dart';
import 'package:pizzapp/model/tamanho.dart';
import 'package:pizzapp/services/pizza_service.dart';
import 'package:pizzapp/widgets/pizza_view.dart';
import 'package:pizzapp/widgets/quantity_picker.dart';
import 'package:pizzapp/widgets/selectable_button.dart';

Future<double> calculaPrecoPizza(List<PresetSabor> sabores, String tamanhoCod, int maxFatias, [ double desconto = 0.0 ]) async {
  final ids = sabores.map((e) => e.id).toList();
  final pizzas = await Future.wait(ids.map((e) => PizzaService.getPizza(e)));
  final pizzasFilter = pizzas.isNotEmpty ?
    pizzas.where((e) => e != null).map((e) => e!).toList() :
    <Pizza>[];
  final pizzasMap = <int, Pizza>{};
  for (final piz in pizzasFilter) {
    pizzasMap[piz.id!] = piz;
  }

  // calcula valor da pizza em tamanho grande (padrão)
  double valorTamanhoGrande =
    // calcula preço de cada sabor
    sabores.map((sab) => pizzasMap[sab.id]!.valorDesconto * sab.razaoPreco(maxFatias))
    // reduz e gera o valor total
    .reduce((value, element) => value + element);

  // calcula valor do tamanho selecionado
  final tamanhoGrande = await PizzaService.getTamanho('grande');
  if (tamanhoGrande == null) {
    return 0.0;
  }

  final tamanho = await PizzaService.getTamanho(tamanhoCod);
  if (tamanho == null) {
    return 0.0;
  }

  /**
   * tamGrd == valTamGrd
   * tamSel == x
   * x * tamGrd = valTamGrd * tamSel
   * x = (valTamGrd * tamSel) / tamGrd
   */
  double valorTamanhoSelecionado =
    (tamanho.tamanho * valorTamanhoGrande) / tamanhoGrande.tamanho;

  // Aplica desconto
  valorTamanhoSelecionado -= valorTamanhoSelecionado * (desconto / 100.0);

  return valorTamanhoSelecionado;
}


class NovoPedidoPage extends StatefulWidget {
  const NovoPedidoPage({ this.preset, super.key });

  final Preset? preset;

  @override
  State<NovoPedidoPage> createState() => _NovoPedidoPageState();
}

class _NovoPedidoPageState extends State<NovoPedidoPage> {

  List<PizzaSection> _sections = [];
  Tamanho? _tamanho;
  int _fatias = 8;

  List<Tamanho> _tamanhos = [];

  int _totalSlices() {
    if (_sections.isEmpty) return 0;
    return _sections.map((e) => e.pieces).reduce((a, b) => a + b);
  }

  _ajustaFatias() {
    while (_fatias < _totalSlices()) {
      _sections[0].pieces--;
    }
    _sections = _sections.where((p) => p.pieces > 0).toList();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      final tams = await PizzaService.listTamanhos();
      setState(() {
        _tamanhos = tams;
      });
      
      if (widget.preset != null) {
        for (final sabor in widget.preset!.sabores) {
          _sections.add(PizzaSection(flavor: sabor.sabor!, pieces: sabor.fatias));
        }
        _tamanho = widget.preset!.tamanhoObject!;
        _fatias = widget.preset!.fatias;
        setState(() {
          
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final fmtp = NumberFormat.compact(locale: 'pt_BR');
    final roundness = size.width / 2;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pedido'),
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Main pizza viewer
          Material(
            elevation: 8.0,
            color: Colors.white,
            child: SizedBox(
              height: 280.0,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Transform.scale(
                      scaleX: 1.6,
                      child: Container(
                        height: 180.0,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(roundness),
                            topRight: Radius.circular(roundness),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: SizedBox(
                      width: 260.0,
                      height: 260.0,
                      child: PizzaView(
                        sections: _sections,
                        slices: _fatias,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0).copyWith(bottom: 96.0),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Icon(LucideIcons.ruler, color: Colors.grey[600]!),
                      const SizedBox(width: 7.0),
                      Text('Tamanho', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w400, color: Colors.grey[600]!)),
                    ],
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: _tamanhos.map((tam) => SelectableButton(
                        text: tam.descricao,
                        underText: '(${fmtp.format(tam.tamanho)} cm)',
                        selected: _tamanho != null && _tamanho!.cod == tam.cod,
                        onTap: () {
                          setState(() {
                            _tamanho = tam;
                            _fatias = _tamanho!.fatias.reduce(min);
                            _ajustaFatias();
                          });
                        },
                      )).toList(),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Icon(LucideIcons.slice, color: Colors.grey[600]!),
                      const SizedBox(width: 7.0),
                      Text('Fatias', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w400, color: Colors.grey[600]!)),
                    ],
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _tamanho == null ?
                      const Center(child: Text('Por favor selecione um tamanho acima.')) :
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.center,
                        children: _tamanho!.fatias.map((index) => SelectableButton(
                          text: index == 1 ? 'Inteira' : '$index Fatia${index > 1 ? "s" : ""}',
                          selected: _fatias == index,
                          onTap: () {
                            setState(() {
                              _fatias = index;
                              _ajustaFatias();
                            });
                          },
                        )).toList(),
                      ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Icon(LucideIcons.pizza, color: Colors.grey[600]!),
                      const SizedBox(width: 7.0),
                      Text('Sabores', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w400, color: Colors.grey[600]!)),
                    ],
                  ),
                ),

                ..._sections.map((e) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    title: Text(e.flavor.nome),
                    subtitle: Text(e.flavor.ingredientes.join(', ')),
                    isThreeLine: true,
                    leading: PizzaViewSimpleSingleFlavor(flavor: e.flavor),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Fatias', style: TextStyle(color: Colors.grey[700]!)),
                        QuantityPicker(
                          quantity: e.pieces,
                          allowAdd: _totalSlices() < _fatias,
                          onChange: (quantity) {
                            setState(() {
                              e.pieces = quantity;
                            });
                          },
                          onDelete: () {
                            setState(() {
                              _sections = _sections.where((p) => p.flavor.id != e.flavor.id).toList();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                )),

                const SizedBox(height: 16.0),

                if (_totalSlices() < _fatias && _tamanho != null) Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final pizza = await showDialog<Pizza>(
                        context: context,
                        builder: (_) => const PizzaFlavorDialog(),
                      );
                      if (pizza != null) {
                        setState(() {
                          _sections.add(PizzaSection(flavor: pizza, pieces: 1));
                        });
                      }
                    },
                    icon: const Icon(LucideIcons.plus),
                    label: const Text('Adicionar Sabor'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(LucideIcons.fileCheck),
        label: const Text('Confirmar'),
      ),
    );
  }
}
