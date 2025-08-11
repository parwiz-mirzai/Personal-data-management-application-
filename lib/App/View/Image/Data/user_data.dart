class PhotoModel {
  final int? photoId;
  final String photoName;
  final String photoTitle;
  final String createdAt;
  final String importanceLevel; // new

  PhotoModel({
    this.photoId,
    required this.photoName,
    required this.photoTitle,
    required this.createdAt,
    required this.importanceLevel,
  });

  Map<String, dynamic> toMap() => {
        "photoId": photoId,
        "photoName": photoName,
        "photoTitle": photoTitle,
        "createdAt": createdAt,
        "importanceLevel": importanceLevel, // include here
      };

  factory PhotoModel.fromMap(Map<String, dynamic> map) => PhotoModel(
        photoId: map['photoId'],
        photoName: map['photoName'],
        photoTitle: map['photoTitle'],
        createdAt: map['createdAt'],
        importanceLevel: map['importanceLevel'], // read this too
      );
}
