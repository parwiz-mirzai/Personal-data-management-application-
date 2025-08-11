class LinkModel {
  final String? linkId; // Ensure this is a String
  final String linkTitle;
  final String linkContent;   
  final String linkDescription;  
  final String createdAt;
  final String? priority;

  LinkModel({
    this.linkId,
    required this.linkTitle,
    required this.linkContent,
    required this.linkDescription,
    required this.createdAt,
    this.priority,
  });

  factory LinkModel.fromMap(Map<String, dynamic> json) => LinkModel(
        linkId: json["linkId"],
        linkTitle: json["linkTitle"],
        linkContent: json["linkContent"],
        linkDescription: json["linkDescription"],
        createdAt: json["createdAt"],
        priority: json["priority"],
  );

  Map<String, dynamic> toMap() => {
        "linkId": linkId,
        "linkTitle": linkTitle,
        "linkContent": linkContent,
        "linkDescription": linkDescription,
        "createdAt": createdAt,
        "priority": priority,
  };
}