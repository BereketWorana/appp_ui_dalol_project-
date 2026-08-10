import 'package:flutter/material.dart';

class CommentsSheet extends StatelessWidget {
  const CommentsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.65,
      minChildSize: 0.4,

      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),

          child: Column(
            children: [
              const SizedBox(height: 12),

              // Drag handle
              Container(
                width: 45,
                height: 5,

                decoration: BoxDecoration(
                  color: Colors.black26,

                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                "Comments",

                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // Comments
              Expanded(
                child: ListView(
                  controller: controller,

                  padding: const EdgeInsets.all(16),

                  children: const [
                    CommentItem(
                      name: "Abebe",
                      comment: "Amazing hotel, I want to visit here!",
                      image: "assets/images/r9.jpg",
                    ),

                    CommentItem(
                      name: "Mimi",
                      comment: "Beautiful place 🔥",
                      image: "assets/images/r1.jpg",
                    ),

                    CommentItem(
                      name: "Hana",
                      comment: "The service looks excellent.",
                      image: "assets/images/r7.jpg",
                    ),

                    CommentItem(
                      name: "Dawit",
                      comment: "Best hotel in Addis!",
                      image: "assets/images/r11.jpg",
                    ),
                  ],
                ),
              ),

              // Comment input
              Container(
                padding: const EdgeInsets.all(12),

                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),

                child: Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.black),

                        decoration: InputDecoration(
                          hintText: "Add comment...",

                          hintStyle: TextStyle(color: Colors.black45),

                          filled: true,

                          fillColor: Color(0xFFF2F2F2),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),

                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    CircleAvatar(
                      backgroundColor: Colors.black,

                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CommentItem extends StatelessWidget {
  final String name;
  final String comment;
  final String image;

  const CommentItem({
    super.key,
    required this.name,
    required this.comment,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          CircleAvatar(radius: 22, backgroundImage: AssetImage(image)),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  name,

                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(comment, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
