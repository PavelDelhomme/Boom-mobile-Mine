class Account {
  final String name;
  final String detail;

  Account({required this.name, required this.detail});

  factory Account.fromMap(Map<String, String> map) {
    return Account(
        name: map['name'] ?? '',
        detail: map['detail'] ?? ''
    );
  }
}