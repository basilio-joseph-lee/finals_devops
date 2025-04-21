class User {
  final int id;
  final String name;
  final String email;
  final String bankName;
  final String pin;
  final String accountType;
  final String accountNo;
  double balance;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.bankName,
    required this.pin,
    required this.accountType,
    required this.accountNo,
    required this.balance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["Id"],
      name: json["Name"],
      email: json["Email"],
      bankName: json["BankName"],
      pin: json["Pin"],
      accountType: json["AccountType"],
      accountNo: json["AccountNo"],
      balance: double.tryParse(json["Balance"].toString()) ?? 0.0,
    );
  }
}
