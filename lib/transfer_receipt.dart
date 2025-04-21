import 'package:finals_app/dashboard_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'user_model.dart';
class TransferReceiptPage extends StatelessWidget {
  final String recipientName;
  final String bank;
  final String accountNumber;
  final String amount;
  final User user;
  const TransferReceiptPage({
    super.key,
    required this.recipientName,
    required this.bank,
    required this.accountNumber,
    required this.amount,
    required this.user
  });

  @override
  Widget build(BuildContext context) {
    final double parsedAmount = double.tryParse(amount) ?? 0.0;
    final double fee = 15.0;
    final double total = parsedAmount + fee;

    final String formattedDate = DateFormat('MMMM d, y – h:mm a', 'en_US').format(DateTime.now());

    return SingleChildScrollView(
      child: CupertinoPageScaffold(
        backgroundColor: const Color(0xFFFDE0DC), // Light red background
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  CupertinoIcons.checkmark_shield_fill,
                  color: Color(0xFFD32F2F), // Red success icon
                  size: 100,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Transfer Successful',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB71C1C), // Dark red title
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  formattedDate,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFE57373), // Light red date
                  ),
                ),
                const SizedBox(height: 40),
                _buildDetailRow('Recipient Name', recipientName),
                _buildDetailRow('Bank', bank),
                _buildDetailRow('Account Number', accountNumber),
                _buildDetailRow('Transfer Amount', '₱${parsedAmount.toStringAsFixed(2)}', isBold: true, color: const Color(0xFFD32F2F)),
                _buildDetailRow('Transaction Fee', '₱${fee.toStringAsFixed(2)}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(color: Color(0xFFE57373), thickness: 1.2), // Red divider
                ),
                _buildDetailRow(
                  'Total Amount',
                  '₱${total.toStringAsFixed(2)}',
                  isBold: true,
                  color: const Color(0xFFB71C1C), // Dark red total
                  fontSize: 18,
                ),
                const SizedBox(height: 50),
                CupertinoButton(
                  borderRadius: BorderRadius.circular(15),
                  color: CupertinoColors.systemRed, // Red button
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => DashboardScaffold(user: user),
                      ),
                    );
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: CupertinoColors.white),
                  ),
                ),
                const SizedBox(height: 60),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color, double? fontSize}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: fontSize ?? 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
