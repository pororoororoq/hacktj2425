class CustomBadge {
  final int id;
  final String name;
  final String description;
  final String imagePath;

  CustomBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
    };
  }

  factory CustomBadge.fromMap(Map<String, dynamic> map) {
    return CustomBadge(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imagePath: map['imagePath'],
    );
  }

  @override
  String toString() {
    return 'CustomBadge{id: $id, name: $name, description: $description, imagePath: $imagePath}';
  }
}
