import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pizzapp/model/pizza.dart';
import 'package:pizzapp/model/preset.dart';
import 'package:pizzapp/pages/novo_pedido.dart';
import 'package:pizzapp/services/pizza_service.dart';
import 'package:pizzapp/widgets/simple_banner.dart';
import 'package:pizzapp/widgets/pizza_view.dart';
import 'package:pizzapp/widgets/small_chip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const priceStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final fmtp = NumberFormat.compact(locale: 'pt_BR');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizzapp'),
      ),
      backgroundColor: Colors.grey[200],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0).copyWith(bottom: 96.0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(LucideIcons.utensilsCrossed, color: Colors.grey[600]!),
                const SizedBox(width: 7.0),
                Text('Os Mais Pedidos', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400, color: Colors.grey[600]!)),
              ],
            ),
          ),

          FutureBuilder<List<Preset>>(
            future: PizzaService.listPresets(),
            builder: (_, psnap) {
              if (psnap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = psnap.data ?? [];
              return Column(
                children: data.map((preset) => Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => NovoPedidoPage(preset: preset)));
                    },
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 90.0,
                                child: Stack(
                                  children: [
                                    PizzaViewSimpleAsync(
                                      sections: preset.sabores,
                                      slices: preset.fatias,
                                    ),
                              
                                    FutureBuilder<double>(
                                      future: calculaPrecoPizza(preset.sabores, preset.tamanho, preset.fatias, preset.desconto),
                                      builder: (_, vsnap) {
                                        if (vsnap.connectionState != ConnectionState.done) {
                                          return const Center(child: CircularProgressIndicator());
                                        }
                              
                                        final val = vsnap.data ?? 0.0;
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: theme.primaryColor,
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(fmt.format(val), style: priceStyle),
                                        );
                                      }
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(preset.nome, style: theme.textTheme.titleLarge),
                                    const SizedBox(height: 5.0),
                                    Wrap(
                                      spacing: 4.0,
                                      runSpacing: 4.0,
                                      children: [
                                        SmallChip('${fmtp.format(preset.tamanhoObject?.tamanho ?? 0.0)} cm', icon: LucideIcons.ruler),
                                        SmallChip('${preset.fatias} fatias', icon: LucideIcons.pizza),
                                        ...preset.sabores.map((e) => SmallChip("${e.fatias}x ${e.sabor?.nome ?? ''}")),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                              
                        if (preset.desconto > 0.0) Align(
                          alignment: Alignment.topRight,
                          child: SimpleBanner(text: '${fmtp.format(preset.desconto)}% OFF', color: Colors.green[800]!),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(LucideIcons.pizza, color: Colors.grey[600]!),
                const SizedBox(width: 7.0),
                Text('Pizzas', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400, color: Colors.grey[600]!)),
              ],
            ),
          ),

          FutureBuilder<List<Pizza>>(
            future: PizzaService.listPizzas(),
            builder: (_, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snap.data ?? [];
              return Column(
                children: data.map((e) => Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100.0,
                              child: Stack(
                                children: [
                                  PizzaViewSimpleSingleFlavor(flavor: e),

                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(fmt.format(e.valorDesconto), style: priceStyle),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.nome, style: theme.textTheme.titleLarge),
                                  Text(e.ingredientes.join(', '), style: theme.textTheme.subtitle1),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (e.desconto > 0.0) Align(
                        alignment: Alignment.topRight,
                        child: SimpleBanner(text: '${fmtp.format(e.desconto)}% OFF', color: Colors.green[800]!),
                      ),
                    ],
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        foregroundColor: theme.primaryColor,
        icon: const Icon(LucideIcons.chefHat),
        label: const Text('Monte a Sua'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NovoPedidoPage()));
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: theme.primaryColor,
        child: Container(
          height: 54,
        ),
      ),
    );
  }
}