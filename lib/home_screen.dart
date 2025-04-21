import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onFeatureTap;
  final User user;

  const HomeScreen({super.key, required this.user, required this.onFeatureTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class BankTransaction {
  final String type;
  final double amount;
  final String date;

  BankTransaction({
    required this.type,
    required this.amount,
    required this.date,
  });

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    return BankTransaction(
      type: json['Type'],
      amount: double.tryParse(json['Amount'].toString()) ?? 0.0,
      date: json['Date'],
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late double _currentBalance;
  bool _showBalance = true;
  List<BankTransaction> _transactions = [];
  bool _isLoadingTransactions = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    _currentBalance = widget.user.balance;
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    try {
      final response = await http.post(
        Uri.parse('https://darksalmon-stork-710332.hostingersite.com/app/get_balance.php'),
        body: {'accountId': widget.user.id.toString()},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final newBalance = double.tryParse(data['balance'].toString()) ?? 0.0;
          setState(() {
            _currentBalance = newBalance;
          });
        }
      }
    } catch (e) {
      print("Exception in fetchBalance: $e");
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await http.post(
        Uri.parse('https://darksalmon-stork-710332.hostingersite.com/app/transaction.php'),
        body: {'accountId': widget.user.id.toString()},
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await fetchBalance();
        if (responseData['status'] == 'success') {
          List<dynamic> data = responseData['data'];
          setState(() {
            _transactions = data.map((t) => BankTransaction.fromJson(t)).toList();
            _isLoadingTransactions = false;
          });
        } else {
          setState(() {
            _isLoadingTransactions = false;
          });
        }
      }
    } catch (_) {
      setState(() {
        _isLoadingTransactions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.06;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "CHINABANK",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Current Balance",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showBalance = !_showBalance;
                            });
                          },
                          child: Icon(
                            _showBalance
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill,
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _showBalance ? "₱${_currentBalance.toStringAsFixed(2)}" : "••••••",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Transaction History",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingTransactions)
                      const Center(child: CupertinoActivityIndicator())
                    else if (_transactions.isEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Image.asset(
                            'assets/empty.png',
                            height: 100,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "No transactions found.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: _transactions
                            .map((tx) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TransactionTile(
                            type: tx.type,
                            amount: tx.amount,
                            date: tx.date,
                          ),
                        ))
                            .toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final String type;
  final double amount;
  final String date;

  const TransactionTile({
    super.key,
    required this.type,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type.toLowerCase().contains("deposit") || type.toLowerCase().contains("from");
    final formattedAmount = "${isIncome ? "+" : "-"} ₱${amount.toStringAsFixed(2)}";

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Row(
        children: [
          Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green[700] : Colors.red[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formattedAmount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green[700] : Colors.red[700],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
