class UserEntity {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = 'user',
  });
}
