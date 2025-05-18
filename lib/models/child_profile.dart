class ChildProfile {
  final String name;
  final String? imagePath;

  ChildProfile({
    required this.name,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imagePath': imagePath,
    };
  }

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      name: json['name'],
      imagePath: json['imagePath'],
    );
  }
}
