import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'dashboard_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('savedAccounts');
  runApp(const BankingApp());
}

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Nunito',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 16, color: Colors.white70),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _successMessage;
  final FocusNode _pinFocusNode = FocusNode();

  final BoxDecoration _backgroundGradient = const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFFB71C1C),
        Color(0xFFD32F2F),
        Color(0xFFF44336),
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ),
  );

  final BoxDecoration _buttonGradient = BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    gradient: const LinearGradient(
      colors: [
        Color(0xFFFF3D00),
        Color(0xFFD50000),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.red.shade700.withOpacity(0.6),
        blurRadius: 12,
        spreadRadius: 2,
        offset: const Offset(0, 6),
      ),
    ],
  );

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String pin = _passwordController.text.trim();

    if (username.isEmpty || pin.isEmpty) {
      setState(() {
        _errorMessage = "Please fill in all fields.";
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final url = Uri.parse("https://darksalmon-stork-710332.hostingersite.com/app/login.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "pin": pin}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse["status"] == "success") {
          setState(() {
            _successMessage = "Login Successful!";
          });
          final user = User.fromJson(jsonResponse["data"]);

          Future.delayed(const Duration(milliseconds: 800), () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (_) => DashboardScaffold(user: user)),
            );
          });
        } else {
          setState(() {
            _errorMessage = jsonResponse["message"];
          });
        }
      } else {
        setState(() {
          _errorMessage = "Unexpected error occurred. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Could not connect to server. Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.07;

    return Container(
      decoration: _backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.topRight,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) => CupertinoActionSheet(
                            title: const Text('Meet Our Team', style: TextStyle(fontSize: 20)),
                            actions: const [
                              DeveloperTile(name: "Artienda, Mary Joyce"),
                              DeveloperTile(name: "Avendano, Aaron Jireh"),
                              DeveloperTile(name: "Basilio, Joseph Lee"),
                              DeveloperTile(name: "Dizon, Joel"),
                              DeveloperTile(name: "Macalino, Rachelle Anne"),
                              DeveloperTile(name: "Simbillo, Jomel"),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: const Text('Close', style: TextStyle(color: CupertinoColors.destructiveRed)),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                      child: const Icon(
                        CupertinoIcons.question_circle_fill,
                        color: Colors.white70,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade300.withOpacity(0.15),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.building_2_fill,
                      size: 70,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Welcome to ATM",
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Login into your account",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _buildInputField(
                    controller: _usernameController,
                    placeholder: "*****@gmail.com",
                    icon: CupertinoIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).requestFocus(_pinFocusNode),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      _buildInputField(
                        controller: _passwordController,
                        placeholder: "PIN",
                        obscureText: _obscurePassword,
                        icon: CupertinoIcons.lock,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        focusNode: _pinFocusNode,
                        onSubmitted: (_) => _login(),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Icon(
                          _obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                          color: Colors.red.shade400,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 90),
                  Container(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: _buttonGradient,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _login,
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    _buildMessageBox(_errorMessage!, CupertinoColors.systemRed, CupertinoColors.white),
                  if (_successMessage != null)
                    _buildMessageBox(_successMessage!, CupertinoColors.systemGreen, CupertinoColors.white),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    IconData? icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
  }) {
    return CupertinoTextField(
      controller: controller,
      obscureText: obscureText,
      placeholder: placeholder,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      placeholderStyle: TextStyle(
        color: CupertinoColors.secondaryLabel.withOpacity(0.7),
        fontSize: 16,
      ),
      style: const TextStyle(
        color: CupertinoColors.label,
        fontSize: 16,
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      prefix: icon != null
          ? Padding(
        padding: const EdgeInsets.only(left: 10, right: 8),
        child: Icon(
          icon,
          color: CupertinoColors.inactiveGray,
          size: 20,
        ),
      )
          : null,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CupertinoColors.lightBackgroundGray.withOpacity(0.8)),
      ),
    );
  }

  Widget _buildMessageBox(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            bgColor == CupertinoColors.systemRed
                ? CupertinoIcons.exclamationmark_circle_fill
                : CupertinoIcons.checkmark_circle_fill,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeveloperTile extends StatelessWidget {
  final String name;

  const DeveloperTile({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheetAction(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 16,
          color: CupertinoColors.activeBlue,
        ),
      ),
    );
  }
}