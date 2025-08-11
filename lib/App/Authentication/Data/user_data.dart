class Users {
  final String name;
  final String password;

  Users({required this.name, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'usrPassword': password,
    };
  }

  static Users fromMap(Map<String, dynamic> map) {
    return Users(
      name: map['name'],
      password: map['usrPassword'],
    );
  }
}