import 'package:audiobooks/features/home/data/models/book_model.dart';
import 'package:audiobooks/features/home/data/models/category_model.dart';
import 'package:audiobooks/features/home/presentation/pages/book_detailed.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.book),
                SizedBox(width: 10),
                Text(
                  category.name ?? '-',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Container(
              height: 240.0, // Adjust height as needed
              child: FadingEdgeScrollView.fromScrollView(
                child: ListView.builder(
                  controller: ScrollController(),
                  scrollDirection: Axis.horizontal,
                  itemCount: category.books?.length,
                  itemBuilder: (context, index) {
                    final book = category.books?[index];
                    return BookCard(book: book ?? Book(), onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => BookDetailedPage.screen(book)));
                      },);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onPressed; // Callback for when the card is pressed

  const BookCard({Key? key, required this.book, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      onTap: onPressed, // Call the callback when the card is pressed
      child: Container(
        width: 120.0, // Adjust width as needed
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                book.imgUrl??'-',
                fit: BoxFit.cover,
                height: 150.0,
                width: 120.0,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              book.title??'-',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.0),
            Text(
              book.author??'-',
              style: TextStyle(fontSize: 12.0, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
