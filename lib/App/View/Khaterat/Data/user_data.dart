class KhateratModel {
  int? khaterahId;
  String? khaterahTitle;
  String? khaterahContent;
  String level;
  String createdAt;
  String? videoPath;
  String? filePath;

  KhateratModel({
    this.khaterahId,
    this.khaterahTitle,
    this.khaterahContent,
    required this.level,
    required this.createdAt,
    this.videoPath,
    this.filePath,
  });

  factory KhateratModel.fromMap(Map<String, dynamic> json) => KhateratModel(
        khaterahId: json['khaterahId'],
        khaterahTitle: json['khaterahTitle'],
        khaterahContent: json['khaterahContent'],
        level: json['level'],
        createdAt: json['createdAt'],
        videoPath: json['videoPath'],  // make sure DB column exists
        filePath: json['filePath'],    // make sure DB column exists
      );

  Map<String, dynamic> toMap() => {
        'khaterahId': khaterahId,
        'khaterahTitle': khaterahTitle,
        'khaterahContent': khaterahContent,
        'level': level,
        'createdAt': createdAt,
        'videoPath': videoPath,
        'filePath': filePath,
      };
}
