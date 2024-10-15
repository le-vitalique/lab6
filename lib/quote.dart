class Quote{
  final int? id;
  final String quote;
  final String author;

  Quote({this.id, required this.quote, required this.author});

  Quote.fromJson(dynamic json) : this(
    id: json['id'],
    quote: json['quote'],
    author: json['author'],
  );
}