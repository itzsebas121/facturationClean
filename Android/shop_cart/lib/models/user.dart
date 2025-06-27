enum UserRole { admin, user }

class User {
  final String id;
  final String username;
  final String passwordHash;
  final UserRole role;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
  });
}
