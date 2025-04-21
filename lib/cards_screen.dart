import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'user_model.dart';

class CardDetailsPage extends StatefulWidget {
  const CardDetailsPage({super.key, required this.user});
  final User user;

  @override
  _CardDetailsPageState createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  bool isLocked = false; // Tracks if the card is locked or not
  bool isCardNumberVisible = false; // Controls visibility of the card number

  String formatAccountNo(String accountNo) {
    return accountNo.replaceAllMapped(RegExp(r".{1,4}"), (match) => "${match.group(0)} ").trim();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD), // Light Blue
              Color(0xFFFFEBEE), // Light Pink
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
                const Text(
                  'Card Details',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF37474F),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your saved card details',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7C8C8D),
                  ),
                ),
                const SizedBox(height: 30),

                // Card Image
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.blue,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Number
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isCardNumberVisible
                                  ? formatAccountNo(widget.user.accountNo)
                                  : '**** **** ****', // Masked until visible
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isCardNumberVisible
                                    ? CupertinoIcons.eye_slash
                                    : CupertinoIcons.eye,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  isCardNumberVisible = !isCardNumberVisible;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Expiry Date: 12/25', // Expiry Date
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Card Holder: ${widget.user.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // // Lock/Unlock Button
                // CupertinoButton.filled(
                //   padding: const EdgeInsets.symmetric(vertical: 15),
                //   borderRadius: BorderRadius.circular(10),
                //   child: Text(
                //     isLocked ? 'Unlock Card' : 'Lock Card', // Toggle text
                //     style: const TextStyle(
                //       fontSize: 24,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.white,
                //     ),
                //   ),
                //   onPressed: () {
                //     setState(() {
                //       isLocked = !isLocked; // Toggle lock state
                //     });
                //   },
                // ),

                const SizedBox(height: 20),


              ],
            ),
          ),
        ),
      ),
    );
  }
}
