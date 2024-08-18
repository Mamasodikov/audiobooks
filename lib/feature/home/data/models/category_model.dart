import 'book_model.dart';

List<Category> parseCategories(List<dynamic> jsonList) {
  return jsonList.map((item) {
    // Assuming each item in the list is a Map<String, dynamic>
    final Map<String, dynamic> categoryMap = item as Map<String, dynamic>;

    // Extracting category name and books
    final String categoryName = categoryMap.keys.first; // Get the first key as category name
    final List<dynamic> booksList = categoryMap[categoryName] as List<dynamic>;

    return Category.fromJson(categoryName, booksList);
  }).toList();
}

class Category {
   String? name;
   List<Book>? books;

  Category({
     this.name,
     this.books,
  });

  factory Category.fromJson(String name, List<dynamic> json) {
    return Category(
      name: name,
      books: json.map((book) => Book.fromJson(book)).toList(),
    );
  }
}