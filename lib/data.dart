class Translation {
  final int id;
  final int wordId;
  final String name;
  final int level;
  final String updateAt;

  Translation({
    required this.id,
    required this.wordId,
    required this.name,
    required this.level,
    this.updateAt = '',
  });
}

class Word {
  final int id;
  final String name;
  final String image;
  final List<Translation> translations;
  final String createdAt;

  Word({
    required this.id,
    required this.name,
    required this.image,
    required this.translations,
    this.createdAt = '',
  });
}
