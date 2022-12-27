import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pizzapp/model/pizza.dart';
import 'package:pizzapp/services/pizza_service.dart';
import 'package:pizzapp/widgets/pizza_view.dart';

class PizzaFlavorDialog extends StatelessWidget {
  const PizzaFlavorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sabores'),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
      content: SizedBox(
        width: 300,
        height: 300,
        child: FutureBuilder<List<Pizza>>(
          future: PizzaService.listPizzas(),
          builder: (_, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snap.data ?? [];
            return ListView.separated(
              separatorBuilder: (_, __) => const Divider(),
              itemCount: data.length,
              itemBuilder: (_, index) {
                final e = data[index];
                return ListTile(
                  leading: SizedBox(
                    width: 48.0,
                    child: Center(child: PizzaViewSimpleSingleFlavor(flavor: e)),
                  ),
                  title: Text(e.nome),
                  subtitle: Text(e.ingredientes.join(', ')),
                  trailing: const Icon(LucideIcons.plus),
                  onTap: () {
                    Navigator.pop(context, e);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}