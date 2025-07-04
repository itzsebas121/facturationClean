class Client {
  final int clientId;
  final String cedula;
  final String email;
  final String firstName;
  final String lastName;
  final String address;
  final String phone;
  final String? picture;

  Client({
    required this.clientId,
    required this.cedula,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.phone,
    this.picture,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      clientId: json['clientId'] ?? json['ClientId'] ?? 0,
      cedula: json['cedula'] ?? json['Cedula'] ?? '',
      email: json['email'] ?? json['Email'] ?? '',
      firstName: json['firstName'] ?? json['FirstName'] ?? '',
      lastName: json['lastName'] ?? json['LastName'] ?? '',
      address: json['address'] ?? json['Address'] ?? '',
      phone: json['phone'] ?? json['Phone'] ?? '',
      picture: json['picture'] ?? json['Picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'cedula': cedula,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'phone': phone,
      'picture': picture,
    };
  }

  Client copyWith({
    int? clientId,
    String? cedula,
    String? email,
    String? firstName,
    String? lastName,
    String? address,
    String? phone,
    String? picture,
  }) {
    return Client(
      clientId: clientId ?? this.clientId,
      cedula: cedula ?? this.cedula,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      picture: picture ?? this.picture,
    );
  }

  @override
  String toString() {
    return 'Client(clientId: $clientId, firstName: $firstName, lastName: $lastName, email: $email, picture: $picture)';
  }
}
