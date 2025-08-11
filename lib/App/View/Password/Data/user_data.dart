// class PasswordsModel {
//   final int? passwordId;
//   final String? passwordTitle;
//   final String? passwordContent;
//   final String? password; // Field for the actual password
//   final String createdAt;
//   final int? priority; // Change to int for priority

//   PasswordsModel({
//     this.passwordId,
//     required this.passwordTitle,
//     required this.passwordContent,
//     required this.password,
//     required this.createdAt,
//     this.priority,
//   });

//   factory PasswordsModel.fromMap(Map<String, dynamic> json, String id) => PasswordsModel(
//         passwordId: json["passwordId"],
//         passwordTitle: json["passwordTitle"],
//         passwordContent: json["passwordContent"],
//         password: json["password"],
//         createdAt: json["createdAt"],
//         priority: json["priority"] != null 
//             ? (json["priority"] is String 
//                 ? int.tryParse(json["priority"]) 
//                 : json["priority"] as int) 
//             : null,
//       );

//   Map<String, dynamic> toMap() => {
//         "passwordId": passwordId,
//         "passwordTitle": passwordTitle,
//         "passwordContent": passwordContent,
//         "password": password,
//         "createdAt": createdAt,
//         "priority": priority,
//       };
// }
class PasswordsModel {
  final String? passwordId; // Change to String
  final String? passwordTitle;
  final String? passwordContent;
  final String? password; // Field for the actual password
  final String createdAt;
  final int? priority; // Keep as int for priority

  PasswordsModel({
    this.passwordId,
    required this.passwordTitle,
    required this.passwordContent,
    required this.password,
    required this.createdAt,
    this.priority,
  });

  factory PasswordsModel.fromMap(Map<String, dynamic> json) => PasswordsModel(
        passwordId: json["passwordId"],
        passwordTitle: json["passwordTitle"],
        passwordContent: json["passwordContent"],
        password: json["password"],
        createdAt: json["createdAt"],
        priority: json["priority"] != null 
            ? (json["priority"] is String 
                ? int.tryParse(json["priority"]) 
                : json["priority"] as int) 
            : null,
      );

  Map<String, dynamic> toMap() => {
        "passwordId": passwordId, // Ensure this is String
        "passwordTitle": passwordTitle,
        "passwordContent": passwordContent,
        "password": password,
        "createdAt": createdAt,
        "priority": priority,
      };

  PasswordsModel copyWith({
    String? passwordId, // Change to String
    String? passwordTitle,
    String? passwordContent,
    String? password,
    String? createdAt,
    int? priority,
  }) {
    return PasswordsModel(
      passwordId: passwordId ?? this.passwordId,
      passwordTitle: passwordTitle ?? this.passwordTitle,
      passwordContent: passwordContent ?? this.passwordContent,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
    );
  }
}