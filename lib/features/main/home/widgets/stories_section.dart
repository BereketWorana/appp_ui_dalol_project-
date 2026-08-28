import 'package:flutter/material.dart';
import '../../../../data/dummy/story_dummy.dart';
import '../screens/story_viewer_screen.dart';

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Filter out expired stories just to be safe
    final activeStories = stories.where((s) => !s.isExpired).toList();

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: activeStories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // "Add Story" button
            return GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Story creation coming soon')),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38, width: 2),
                        color: Colors.white12,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Your Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final story = activeStories[index - 1];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryViewerScreen(
                    stories: activeStories,
                    initialIndex: index - 1,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.pink, Colors.orange],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black, // Inner border to separate gradient from image
                      ),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(story.userAvatar),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 64,
                    child: Text(
                      story.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
