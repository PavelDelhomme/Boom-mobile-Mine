class User {
  final String name;
  final String role;
  final String date;
  final String? avatar;
  final String email;
  final bool isActive = true;

  User({required this.name, required this.role, required this.date, this.avatar, required this.email});
}