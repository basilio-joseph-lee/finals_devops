import 'package:finals_app/pay_bills_screen.dart';
import 'package:finals_app/transfer_screen.dart';
import 'package:flutter/material.dart';
import 'user_model.dart';
import 'home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';

class DashboardScaffold extends StatefulWidget {
  final User user;

  const DashboardScaffold({super.key, required this.user});

  @override
  State<DashboardScaffold> createState() => _DashboardScaffoldState();
}

class _DashboardScaffoldState extends State<DashboardScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  static const Color redGradientStart = Color(0xFFB71C1C);
  static const Color redGradientEnd = Color(0xFFD32F2F);
  static const Color redAccent = Color(0xFFC62828);
  static const Color drawerBackgroundColor = Color(0xFFFFEBEE);

  void _onFeatureTap(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(user: widget.user, onFeatureTap: _onFeatureTap);
      case 1:
        return TransferPage(user: widget.user, onFeatureTap: _onFeatureTap);
      case 2:
        return BillsPaymentPage(user: widget.user, onFeatureTap: _onFeatureTap);
      case 3:
        return _buildSettingsContent();
      default:
        return Center(child: Text("Invalid Page Index: $_selectedIndex"));
    }
  }

  Widget _buildSettingsContent() {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFB71C1C), // Deep red like China Bank
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: [
                    const Text(
                      'Account Security',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemGroupedBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => ChangePinPage(user: widget.user)),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.padlock_solid, color: Color(0xFF303F9F), size: 26),
                            SizedBox(width: 16),
                            Text(
                              'Change PIN',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: CupertinoColors.black,
                              ),
                            ),
                            Spacer(),
                            Icon(CupertinoIcons.forward, color: CupertinoColors.systemGrey),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          _getPage(),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.menu,
                    size: 28,
                    color: redAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: drawerBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [redGradientStart, redGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "ATM Banking",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home_outlined, "Home", 0),
            _buildDrawerItem(Icons.swap_horiz, "Transfer Funds", 1),
            _buildDrawerItem(Icons.receipt_long_outlined, "Payment & Bills", 2),
            _buildDrawerItem(Icons.settings_outlined, "Settings", 3),
            const Spacer(),
            const Divider(height: 1, thickness: 1, color: Colors.black12),
            _buildDrawerItem(Icons.logout, "Logout", 99),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? redAccent : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? redAccent : Colors.black87,
        ),
      ),
      tileColor: isSelected ? redAccent.withOpacity(0.1) : null,
      onTap: () {
        if (index >= 0 && index <= 3) {
          _onFeatureTap(index);
        } else if (index == 99) {
          Navigator.pop(context);
          _logout(context);
        }
      },
    );
  }
}

class ChangePinPage extends StatefulWidget {
  final User user;
  const ChangePinPage({super.key, required this.user});

  @override
  _ChangePinPageState createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  void _showMessage(String message, {bool success = false}) {
    setState(() {
      _message = message;
      _isSuccess = success;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _message = null);
    });
  }

  Future<void> initiatePinChange() async {
    final accountId = widget.user.id;

    print('Initiating PIN change for accountId: $accountId');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://darksalmon-stork-710332.hostingersite.com/app/send_otp.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accountId': accountId}),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] != null) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => VerifyOtpPage(accountId: accountId.toString()),
            ),
          );
        } else {
          _showMessage(data['error'] ?? 'Failed to send OTP.');
        }
      } else {
        _showMessage('Server error. Please try again later.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Something went wrong. Please check your connection.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFB71C1C).withOpacity(0.95),
        border: null,
        middle: const Text(
          'Change PIN',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_message != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _isSuccess ? const Color(0xFFE0F7FA) : const Color(0xFFFDE0DC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isSuccess ? const Color(0xFF81D4FA) : const Color(0xFFFBCEDD),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isSuccess ? Icons.check_circle : Icons.error_outline,
                              color: _isSuccess ? const Color(0xFF0091EA) : const Color(0xFFE53935),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _message!,
                                style: TextStyle(
                                  color: _isSuccess ? const Color(0xFF00869e) : const Color(0xFFc62828),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.mail_solid,
                            color: Color(0xFFB71C1C),
                            size: 40,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Verify Your Identity",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.black,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "To change your PIN, we’ll send a One-Time Password (OTP) to your registered email.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF455A64),
                              height: 1.5,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              color: Color(0xFFB71C1C),
                              borderRadius: BorderRadius.circular(30),
                              onPressed: _isLoading ? null : initiatePinChange,
                              child: _isLoading
                                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                                  : const Text(
                                'Send OTP',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }




}

class VerifyOtpPage extends StatefulWidget {
  final String accountId;

  const VerifyOtpPage({super.key, required this.accountId});

  @override
  _VerifyOtpPageState createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;
  bool _obscurePin = true;

  void _showMessage(String message, {bool success = false}) {
    setState(() {
      _message = message;
      _isSuccess = success;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _message = null);
    });
  }

  Future<void> verifyOtpAndChangePin() async {
    final otp = _otpController.text.trim();
    final newPin = _newPinController.text.trim();

    if (otp.isEmpty || newPin.isEmpty) {
      _showMessage('Please enter both OTP and new PIN.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://darksalmon-stork-710332.hostingersite.com/app/change_pin.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accountId': widget.accountId,
          'otp': otp,
          'newPin': newPin,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != null) {
          _showMessage('PIN changed successfully!', success: true);
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
            );
          });
        } else {
          _showMessage(data['error'] ?? 'Failed to change PIN.');
        }
      } else {
        _showMessage('Server error. Please try again later.');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('An error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFB71C1C),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFB71C1C),
        border: null,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.left_chevron, color: CupertinoColors.white),
              SizedBox(width: 6),
              Text(
                '',
                style: TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          ),
        ),
        middle: const Text(
          'Secure Your PIN',
          style: TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.white, fontSize: 18,),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter OTP",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                        color:CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CupertinoTextField(
                      controller: _otpController,
                      placeholder: 'Note: 6-Digit OTP is required',
                      keyboardType: TextInputType.number,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEF9A9A)),
                      ),
                      style: const TextStyle(color: Color(0xFF424242)),
                      placeholderStyle: const TextStyle(color: Color(0xFFB71C1C)),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "New PIN",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                        color:CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        CupertinoTextField(
                          controller: _newPinController,
                          placeholder: 'Enter 4-Digit PIN',
                          keyboardType: TextInputType.number,
                          obscureText: _obscurePin,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEF9A9A)),
                          ),
                          style: const TextStyle(color: Color(0xFF424242)),
                          placeholderStyle: const TextStyle(color: Color(0xFFB71C1C)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePin = !_obscurePin;
                              });
                            },
                            child: Icon(
                              _obscurePin ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: CupertinoButton(
                        onPressed: _isLoading ? null : verifyOtpAndChangePin,
                        borderRadius: BorderRadius.circular(25),
                        color: const Color(0xFFB71C1C),
                        child: _isLoading
                            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                            : const Text(
                          'Change PIN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isSuccess ? const Color(0xFFE0F7FA) : const Color(0xFFFDE0DC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isSuccess ? const Color(0xFF81D4FA) : const Color(0xFFFBCEDD),
                            ),
                          ),
                          child: Text(
                            _message!,
                            style: TextStyle(
                              color: _isSuccess ? const Color(0xFF00869e) : const Color(0xFFd32f2f),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}