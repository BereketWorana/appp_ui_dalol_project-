class Hotel {
  final int id;
  final String name;
  final String image;
  final String video;

  // Explore Screen
  final String description;
  final String location;
  final double rating;
  final double price;

  // Feed Screen
  final int likes;
  final int comments;
  final int shares;

  const Hotel({
    required this.id,
    required this.name,
    required this.image,
    required this.video,

    required this.description,
    required this.location,
    required this.rating,
    required this.price,

    required this.likes,
    required this.comments,
    required this.shares,
  });
}
