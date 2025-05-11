// ignore_for_file: always_put_required_named_parameters_first

class User {
  /// Creates a new User instance with basic and health information
  ///
  /// Required fields for initial registration: [name], [surname], [email], [password]
  /// Optional health profile fields: [weight], [height], [age], [gender], [allergies]
  User({
    this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.password,
    this.weight,
    this.height,
    this.age,
    this.gender,
    this.allergies,
  });

  /// Create a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['name'] as String,
      surname: json['surname'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      weight: json['weight'] != null
          ? double.parse(json['weight'].toString())
          : null,
      height: json['height'] != null
          ? double.parse(json['height'].toString())
          : null,
      age: json['age'] != null ? int.parse(json['age'].toString()) : null,
      gender: json['gender']?.toString(),
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'] as List<dynamic>)
          : null,
    );
  }
  final String? id;
  final String name;
  final String surname;
  final String email;
  final String password;
  final double? weight;
  final double? height;
  final int? age;
  final String? gender;
  final List<String>? allergies;

  /// Convert User to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'password': password,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'allergies': allergies,
    };
  }

  /// Create a copy of this User with modified fields
  User copyWith({
    String? id,
    String? name,
    String? surname,
    String? email,
    String? password,
    double? weight,
    double? height,
    int? age,
    String? gender,
    List<String>? allergies,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      password: password ?? this.password,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      allergies: allergies ?? this.allergies,
    );
  }
}
