import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_model.dart';
import 'transfer_receipt.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TransferPage extends StatelessWidget {
  final User user;
  final void Function(int index) onFeatureTap;
  const TransferPage({super.key, required this.user, required this.onFeatureTap});

  @override
  Widget build(BuildContext context) {
    final Box savedAccountsBox = Hive.box('savedAccounts');
    final List<Map<String, String>> savedAccounts = savedAccountsBox.values
        .map<Map<String, String>>((value) {
      if (value is Map) {
        try {
          return value.cast<String, String>();
        } catch (e) {
          print("Error casting Hive value: $e, value: $value");
          return {};
        }
      } else {
        print("Unexpected value type in Hive: ${value.runtimeType}, value: $value");
        return {};
      }
    }).toList();

    final List<String> partnerBanks = [
      "BDO", "China Bank", "Landbank", "METRO"
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFB71C1C),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Transfer Funds',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ) ??
                      const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Accounts:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.red.shade600,
                      ) ??
                          const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB71C1C),
                          ),
                    ),
                    const SizedBox(height: 16),
                    savedAccounts.isEmpty
                        ? const Text(
                      "No saved accounts yet.",
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                        : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: savedAccounts.map((acc) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => TransferFormPage(
                                    bankOrAccount: acc['bank'] ?? 'Unknown Bank',
                                    accountId: user.id.toString(),
                                    initialName: acc['name'] ?? 'Unknown Name',
                                    initialAccount: acc['account'] ?? 'Unknown Account',
                                    user: user,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 170,
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.shade200.withOpacity(0.5),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.shade200.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    acc['name'] ?? 'No Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.red.shade800,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${acc['bank'] ?? ' '} • ${acc['account'] ?? ' '}",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Select Banks',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ) ??
                            const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB71C1C),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 25),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: partnerBanks.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final bank = partnerBanks[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => TransferFormPage(
                                    bankOrAccount: bank,
                                    accountId: user.id.toString(),
                                    user: user,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      bank,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red.shade800,
                                      ),
                                    ),
                                  ),
                                  Icon(CupertinoIcons.chevron_forward,
                                      size: 20, color: Colors.red.shade400),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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



class TransferFormPage extends StatefulWidget {
  final String bankOrAccount;
  final String accountId;
  final String? initialName;
  final String? initialAccount;
  final User user;

  const TransferFormPage({
    super.key,
    required this.bankOrAccount,
    required this.accountId,
    required this.user,
    this.initialName,
    this.initialAccount,
  });

  @override
  TransferFormPageState createState() => TransferFormPageState();
}

class TransferFormPageState extends State<TransferFormPage> {
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _message;
  bool _isSuccess = false;

  final String _transferApiUrl = "https://darksalmon-stork-710332.hostingersite.com/app/transfer.php";

  Future<void> _submitTransfer() async {
    final name = _recipientNameController.text.trim();
    final account = _accountNumberController.text.trim();
    final amount = _amountController.text.trim();
    final bank = widget.bankOrAccount;
    final accountId = widget.accountId;

    if (name.isEmpty || account.isEmpty || amount.isEmpty) {
      _showMessage("Please fill out all fields.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_transferApiUrl),
        body: {
          "accountId": accountId,
          "recipientBankName": bank,
          "recipientAccountNumber": account,
          "amount": amount,
        },
      );

      if (response.statusCode != 200) {
        _showMessage("Server error: ${response.statusCode}");
        return;
      }
      final json = jsonDecode(response.body);
      if (json.containsKey('success')) {
        _showMessage(json['success'], success: true);
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) =>
                  TransferReceiptPage(
                    recipientName: name,
                    bank: bank,
                    accountNumber: account,
                    amount: amount,
                    user: widget.user,
                  ),
            ),
          );
        });
      } else if (json.containsKey('error')) {
        _showMessage(json['error']);
      } else {
        _showMessage('Transfer failed.');
      }
    } catch (e) {
      _showMessage("Failed to connect to server: $e");
    }
  }

  void _showMessage(String message, {bool success = false}) {
    setState(() {
      _message = message;
      _isSuccess = success;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _message = null);
    });
  }

  Future<void> _saveAccountToHive() async {
    final name = _recipientNameController.text.trim();
    final bank = widget.bankOrAccount;
    final account = _accountNumberController.text.trim();

    if (name.isEmpty || account.isEmpty) {
      _showMessage("Please fill out recipient name and account number.");
      return;
    }

    final box = Hive.box('savedAccounts');

    bool accountExists = false;
    for (var savedAccount in box.values) {
      if (savedAccount is Map &&
          savedAccount['account'] == account &&
          savedAccount['bank'] == bank) {
        accountExists = true;
        break;
      } else if (savedAccount is! Map) {
        print("Skipping non-map value: $savedAccount");
      }
    }

    if (accountExists) {
      _showMessage("This account is already saved.");
      return;
    }

    try {
      await box.add({
        'name': name,
        'bank': bank,
        'account': account,
      });
      _showMessage("Account saved successfully!", success: true);
    } catch (e) {
      _showMessage("Error saving account: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _recipientNameController.text = widget.initialName ?? '';
    _accountNumberController.text = widget.initialAccount ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: CupertinoNavigationBar(
        middle: Text(
          'Transfer to ${widget.bankOrAccount}',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.red.shade800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_message != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isSuccess ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isSuccess ? Colors.green.shade700 : Colors.red.shade300,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle : Icons.error,
                        color: _isSuccess ? Colors.green.shade700 : Colors.red.shade400,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _message!,
                          style: TextStyle(
                            color: _isSuccess ? Colors.green.shade900 : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Center(
                child: Text(
                  'Transfer Funds',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _recipientNameController,
                label: 'Recipient Name',
                placeholder: 'e.g. John Doe',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _accountNumberController,
                label: 'Bank Number',
                placeholder: 'e.g. 123456789',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _amountController,
                label: 'Amount',
                placeholder: 'e.g. 1000',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 30),


              Align(
                alignment: Alignment.centerLeft,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _saveAccountToHive,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade200.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.bookmark_fill, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Save Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // <<< TRANSFER BUTTON >>>
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _submitTransfer,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [Colors.red.shade700, Colors.red.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade200.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 12),
                      Text(
                        'Transfer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 150),
            ],
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.red.shade800,
          ),
        ),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          cursorColor: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          placeholderStyle: TextStyle(fontSize: 15, color: Colors.red.shade300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.red.shade100),
          ),
        ),
      ],
    );
  }
}

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
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Light blue
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  children: [
                    const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      size: 80,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Transfer Successful!',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ) ??
                          const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00897B),
                          ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildReceiptRow(label: 'Recipient Name', value: recipientName),
                        _buildReceiptRow(label: 'Bank', value: bank),
                        _buildReceiptRow(label: 'Account Number', value: accountNumber),
                        _buildReceiptRow(label: 'Amount', value: '₱$amount'),
                        _buildReceiptRow(label: 'Transaction Date', value: DateTime.now().toString()), //Added Transaction Date
                        _buildReceiptRow(label: 'Sender Name', value: user.name), // Added Sender's Name
                        _buildReceiptRow(label: 'Sender ID', value: user.id.toString()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              CupertinoButton( // Changed to CupertinoButton
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade800, // Darker blue
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}