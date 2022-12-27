class Pizza {
  int? id;
  String nome, imagem;
  List<String> ingredientes;
  double valor, desconto;

  Pizza({
    this.id,
    required this.nome,
    required this.imagem,
    required this.ingredientes,
    required this.valor,
    required this.desconto,
  });

  factory Pizza.fromJson(Map<String, dynamic> ob) => Pizza(
    id: ob['id'],
    nome: ob['nome'],
    imagem: ob['imagem'],
    ingredientes: List<String>.from((ob['ingredientes'] ?? <dynamic>[])),
    valor: ob['valor'] ?? 0.0,
    desconto: ob['desconto'] ?? 0.0,
  );

  double get valorDesconto {
    if (desconto <= 0.0) return valor;
    return valor - (valor * (desconto / 100.0));
  }

}

class PizzaSection {
  Pizza flavor;
  int pieces, offset;

  PizzaSection({
    required this.flavor,
    required this.pieces,
    this.offset = 0,
  });

}
