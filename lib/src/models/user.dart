class USER {
  final String email;
  final String password;

  USER({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory USER.fromJson(Map<String, dynamic> json) {
    return USER(
      email: json['email'],
      password: json['password'],
    );
  }
}
