class Tamanho {

  String cod, descricao;
  double tamanho;
  List<int> fatias;

  Tamanho({
    required this.cod,
    required this.descricao,
    required this.tamanho,
    required this.fatias
  });

  factory Tamanho.fromJson(Map<String, dynamic> ob) => Tamanho(
    cod: ob['cod'],
    descricao: ob['descricao'],
    tamanho: ob['tamanho'],
    fatias: List<int>.from(ob['fatias'] as List),
  );

}