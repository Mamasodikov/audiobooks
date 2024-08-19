class Book {
  String? id;
  String? audioUrl;
  String? imgUrl;
  String? title;
  String? author;

  Book({
    this.id,
    this.audioUrl,
    this.imgUrl,
    this.title,
    this.author,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String?,
      audioUrl: json['audioUrl'] as String?,
      imgUrl: json['imgUrl'] as String?,
      title: json['title'] as String?,
      author: json['author'] as String?,
    );
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String?,
      audioUrl: map['audioUrl'] as String?,
      imgUrl: map['imgUrl'] as String?,
      title: map['title'] as String?,
      author: map['author'] as String?,
    );
  }

  Map<String, String> toMap() {
    return {
      'id': id ?? '',
      'audioUrl': audioUrl ?? '',
      'imgUrl': imgUrl ?? '',
      'title': title ?? '',
      'author': author ?? '',
    };
  }

  // Adding copyWith method
  Book copyWith({
    String? id,
    String? audioUrl,
    String? imgUrl,
    String? title,
    String? author,
  }) {
    return Book(
      id: id ?? this.id,
      audioUrl: audioUrl ?? this.audioUrl,
      imgUrl: imgUrl ?? this.imgUrl,
      title: title ?? this.title,
      author: author ?? this.author,
    );
  }
}