import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_model.dart';
import 'dashboard_screen.dart';

class BillsPaymentPage extends StatelessWidget {
  const BillsPaymentPage(
      {super.key, required this.user, required void Function(int index) onFeatureTap});

  final User user;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.shade50,
              Colors.red.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Pay Bills',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                      decoration: TextDecoration.none, // Ensure no underline
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildBillerList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillerList(BuildContext context) {
    final List<Map<String, dynamic>> billers = [
      {
        "name": "Internet",
        "icon": CupertinoIcons.wifi,
        "iconColor": Colors.teal.shade400,
      },
      {
        "name": "Electricity",
        "icon": CupertinoIcons.lightbulb_fill,
        "iconColor": Colors.yellow.shade600,
      },
      {
        "name": "Water",
        "icon": CupertinoIcons.drop_fill,
        "iconColor": Colors.blue.shade400,
      },
    ];

    return Column(
      children: billers.map((biller) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    BillPaymentFormPage(biller: biller['name'], user: user),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade100.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  biller['icon'],
                  size: 30,
                  color: biller['iconColor'],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    biller['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade800,
                      decoration: TextDecoration.none, // Ensure no underline
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: 20,
                  color: Colors.red.shade300,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class BillPaymentFormPage extends StatefulWidget {
  final String biller;
  final User user;

  const BillPaymentFormPage({
    super.key,
    required this.biller,
    required this.user,
  });

  @override
  _BillPaymentFormPageState createState() => _BillPaymentFormPageState();
}

class _BillPaymentFormPageState extends State<BillPaymentFormPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;
  bool _showFieldErrors = false;

  Future<void> _submitPayment() async {
    final amount = _amountController.text.trim();
    final accNum = _accountNumberController.text.trim();

    _setMessage(null);
    _showFieldErrors = false;

    if (amount.isEmpty || accNum.isEmpty) {
      _setMessage("Please fill in all fields.", success: false);
      setState(() {
        _showFieldErrors = true;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
            'https://darksalmon-stork-710332.hostingersite.com/app/pay_bills.php'),
        body: {
          'user_id': widget.user.id.toString(),
          'biller': widget.biller,
          'amount': amount,
          'account_number': accNum,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          print("Server response: ${response.body}");

          _setMessage(
              "You have successfully paid ₱$amount for ${widget.biller}",
              success: true);
        } else {
          _setMessage("Payment failed: ${jsonResponse['message']}");
        }
      } else {
        _setMessage("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _setMessage("Error: ${e.toString()}");
    }

    setState(() => _isLoading = false);
  }

  void _setMessage(String? message, {bool success = false}) {
    setState(() {
      _message = message;
      _isSuccess = success;
      if (message != null && message != "Please fill in all fields.") {
        _showFieldErrors = false;
      } else if (message == null) {
        _showFieldErrors = false;
      }
    });

    if (success) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) =>
                ReceiptPage(
                  biller: widget.biller,
                  amount: _amountController.text,
                  accountNumber: _accountNumberController.text,
                  user: widget.user,
                ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.back, color: Color(0xFFB71C1C)),
                      SizedBox(width: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '${widget.biller}',
                    style: const TextStyle(
                      fontSize: 25,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB71C1C),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_message != null && _message != "Please fill in all fields.")
                        Container(
                          margin: const EdgeInsets.only(bottom: 7),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isSuccess ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isSuccess ? Icons.check_circle : Icons.error,
                                color: _isSuccess ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _message!,
                                  style: TextStyle(
                                    color: _isSuccess ? Colors.green[800] : Colors.red[800],
                                    fontSize: 12,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _accountNumberController,
                        label: 'Account Number',
                        placeholder: 'e.g. 1234567890',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        controller: _amountController,
                        label: 'Amount',
                        placeholder: 'e.g. 500.00',
                        keyboardType: TextInputType.number,
                      ),
                      if (_showFieldErrors && (_amountController.text.isEmpty || _accountNumberController.text.isEmpty))
                        Container(
                          padding: const EdgeInsets.only(top: 20.0, left: 8.0) ,
                          child: Text(
                            'Please fill in all fields.',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 13,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : GestureDetector(
                  onTap: _submitPayment,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFB71C1C),
                          Color(0xFFFF1744),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pay Now',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFB71C1C),
            decoration: TextDecoration.none, // Ensure no underline
          ),
        ),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          padding: const EdgeInsets.all(15),
          keyboardType: keyboardType,
          cursorColor: const Color(0xFFB71C1C),
          style: const TextStyle(
            color: Color(0xFF283593),
            fontSize: 16,
            decoration: TextDecoration.none,
          ),
          placeholderStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF9EBEB),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReceiptPage extends StatelessWidget {
  final String biller;
  final String amount;
  final String accountNumber;
  final User user;

  const ReceiptPage({
    super.key,
    required this.biller,
    required this.amount,
    required this.user,
    required this.accountNumber,
  });

  @override
  Widget build(BuildContext context) {
    final double amountValue = double.tryParse(amount) ?? 0;
    final double totalAmount = amountValue + 15;
    final String formattedDate = DateTime.now().toString().substring(
        0, 16);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE5E5FF),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF304FFE),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      spreadRadius: 3,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReceiptItem('Date:', formattedDate),
                      _buildReceiptItem('Bills:', biller),
                      _buildReceiptItem('Account No.:', accountNumber),
                      _buildReceiptItem(
                          'Amount Paid:', '₱$amount', isBold: true),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Payment Successful',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A237E),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildReceiptItem('Transaction Fee:', '₱15.00'),
                      const Divider(
                        color: Color(0xFFB3B9D9),
                        thickness: 1.5,
                        height: 40,
                      ),
                      _buildReceiptItem(
                        'Total Amount:',
                        '₱${totalAmount.toStringAsFixed(2)}',
                        isBold: true,
                        color: const Color(0xFF1A237E),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => DashboardScaffold(user: user),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3F51B5),
                        Color(0xFF283593),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF304FFE).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Go to Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Thank you for your payment!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF9FA8DA),
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptItem(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black87, decoration: TextDecoration.none,),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
