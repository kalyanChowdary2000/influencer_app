// ignore_for_file: unused_local_variable, prefer_const_constructors, prefer_const_literals_to_create_immutables, no_leading_underscores_for_local_identifiers, prefer_is_empty
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:influ_app/provider/AuthProvider.dart';
import 'package:influ_app/utils/app_constants.dart';
import 'package:influ_app/utils/app_preferences.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with SingleTickerProviderStateMixin {
  var walletAmount = 0; // Replace with actual wallet amount
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;
  var transactions = [];
  bool isLogin = false;
  void isLoginCheck() async {
    var resp = PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
    if (resp != "") {
      // var userData=resp.decode(resp)
      var token =
          await PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
      await AuthProvider.fetchWallet(token: token);
      var transactionData = await AuthProvider.fetchTransaction(token: token);
      var resp = PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);
      var userData = jsonDecode(resp);
      // print(
      //     "--------user Data ${userData}   tranaction data ${transactionData["data"]}");

      setState(() {
        print(transactionData["data"]);
        transactions = transactionData["data"];
        walletAmount = userData["walletMoney"];
        isLogin = true;
      });
    }
    print("login Data ${resp} ---->> ${isLogin}");
  }

  void _showDepositDialog() {}

  void _showWithdrawDialog() {
    TextEditingController _amountController = TextEditingController();
    TextEditingController _accountNumberController = TextEditingController();
    TextEditingController _ifscCodeController = TextEditingController();
    TextEditingController _branchController = TextEditingController();
    TextEditingController _bankNameController = TextEditingController();
    TextEditingController _accountHolderController = TextEditingController();
    var resp = PreferenceUtils.getString(AppPreferenceConstants.LOGIN_KEY);

    if (resp != "") {
      setState(() {
        Map<dynamic, dynamic>? loginData = json.decode(resp);
        _accountNumberController.text = loginData?["accountNumber"] ?? '';
        _ifscCodeController.text = loginData?["ifscCode"] ?? '';
        _branchController.text = loginData?["branch"] ?? '';
        _bankNameController.text = loginData?["bankName"] ?? '';
        _accountHolderController.text = loginData?["accountHolderName"] ?? '';
      });
    }

    String errorMessage = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Withdraw Amount'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Enter amount'),
                    ),
                    TextField(
                      controller: _accountHolderController,
                      keyboardType: TextInputType.text,
                      decoration:
                          InputDecoration(labelText: 'Account Holder Name'),
                    ),
                    TextField(
                      controller: _accountNumberController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'Account Number'),
                    ),
                    TextField(
                      controller: _ifscCodeController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'IFSC Code'),
                    ),
                    TextField(
                      controller: _branchController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'Branch'),
                    ),
                    TextField(
                      controller: _bankNameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'Bank Name'),
                    ),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    double withdrawAmount =
                        double.tryParse(_amountController.text) ?? 0.0;
                    String accountHolderName = _accountHolderController.text;
                    String accountNumber = _accountNumberController.text;
                    String ifscCode = _ifscCodeController.text;
                    String branch = _branchController.text;
                    String bankName = _bankNameController.text;

                    if (withdrawAmount < 50 ||
                        accountHolderName.isEmpty ||
                        accountNumber.isEmpty ||
                        ifscCode.isEmpty ||
                        branch.isEmpty ||
                        bankName.isEmpty) {
                      setState(() {
                        if (withdrawAmount < 50) {
                          errorMessage = 'Minimum withdrawal amount is 50';
                        }
                        //errorMessage = 'Please fill in all fields correctly.';
                      });
                    } else if (walletAmount - withdrawAmount < 0) {
                      setState(() {
                        errorMessage =
                            'Withdrawal amount exceeds wallet balance';
                      });
                    } else {
                      Navigator.pop(context); // Close the dialog
                      var token = await PreferenceUtils.getString(
                          AppPreferenceConstants.TOKEN_KEY);
                      await AuthProvider.addTransaction(
                        token: token,
                        amount: withdrawAmount,
                        isDeposit: false,
                        accountHolderName: accountHolderName,
                        accountNumber: accountNumber,
                        ifscCode: ifscCode,
                        branch: branch,
                        bankName: bankName,
                      );
                      _refreshWallet();
                    }
                  },
                  child: Text('Withdraw'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _refreshWallet() async {
    _refreshController.forward(from: 0.0);
    var token =
        await PreferenceUtils.getString(AppPreferenceConstants.TOKEN_KEY);
    await AuthProvider.fetchWallet(token: token);
    isLoginCheck();
  }

  @override
  void initState() {
    super.initState();
    isLoginCheck();
    _refreshController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _refreshAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //SizedBox(width: 8),
            Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon(
                  //   Icons.account_balance_wallet,
                  //   color: Colors.white,
                  //   size: 24.0,
                  // ),
                  SizedBox(width: 8),
                  Text(
                    'Wallet Page',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
            // SizedBox(
            //   width: 8,
            // ),
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet, // Wallet symbol
                  color: Colors.white, // Customize the color as needed
                ),
                Text(
                  '${walletAmount}', // Replace with the actual currency amount
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                GestureDetector(
                  onTap: _refreshWallet,
                  child: RotationTransition(
                    turns: _refreshAnimation,
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 28.0,
                    ),
                  ),
                ),
              ],
            ),
            //SizedBox(width: 4),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Container(
          //   padding: EdgeInsets.all(16.0),
          //   color: Theme.of(context).primaryColor,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Icon(
          //         Icons.account_balance_wallet,
          //         color: Colors.white,
          //         size: 48.0,
          //       ),
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.end,
          //         children: [
          //           Row(
          //             children: [
          //               Text(
          //                 '₹${walletAmount}',
          //                 style: TextStyle(
          //                   color: Colors.white,
          //                   fontSize: 32.0,
          //                   fontWeight: FontWeight.bold,
          //                 ),
          //               ),
          //               SizedBox(width: 16.0),
          //               GestureDetector(
          //                 onTap: _refreshWallet,
          //                 child: RotationTransition(
          //                   turns: _refreshAnimation,
          //                   child: Icon(
          //                     Icons.refresh,
          //                     color: Colors.white,
          //                     size: 28.0,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),

          transactions.length > 0
              ? Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      print(transaction);
                      final isDeposit = transaction["isDeposit"];
                      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                          int.parse(transaction["createTime"]));

                      final transactionType =
                          "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";

                      final transactionColor =
                          isDeposit ? Colors.green : Colors.red;
                      final transactionStatus = transaction["status"]
                          ? 'Completed'
                          : 'Pending'; // Example logic for status
                      var transactionAmount = transaction["amount"];
                      var descriptionText = "";

                      // DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                      //     int.parse(transaction["createTime"]));

                      // descriptionText =
                      //     "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
                      if (transaction["isDeposit"]) {
                        descriptionText = "Deposit";
                      } else {
                        descriptionText = "Withdrawal";
                        transactionAmount = transaction["netWithDrawal"];
                      }
                      return GestureDetector(
                        onTap: () {
                          if (!transaction["isDeposit"]) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: Center(
                                    child: Text(
                                  'Withdrawal Summary',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 17, 84, 167)),
                                )),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: Text(
                                    'Withdrawal Amount = (total withdrawal)-(30% x net winings)\n Withdrawal Amount = ${transaction["amount"]}-(30% x ${transaction["netWinings"]})\n Withdrawal Amount = ${transaction["netWithDrawal"]}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      shadows: [
                                        Shadow(
                                          color: Color(0xFFFFFFFF),
                                          blurRadius: 1,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.orange,
                                        textStyle: const TextStyle(
                                            fontSize: 20, color: Colors.white)),
                                    child: Center(child: Text('  Close   ')),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: ListTile(
                          leading: Icon(Icons.payment, color: transactionColor),
                          title: Text('Transaction #${transaction["_id"]}'),
                          subtitle: Text(descriptionText),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isDeposit
                                    ? '+₹${transaction["amount"]}'
                                    : '-₹${transaction["amount"]}',
                                style: TextStyle(
                                  color: transactionColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                transactionType,
                                style: TextStyle(
                                  color: transactionColor,
                                  fontSize: 14.0,
                                ),
                              ),
                              Text(
                                'Status: $transactionStatus',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    const Center(
                        child: Text(
                      "You have not posted any ads yet",
                      style: TextStyle(fontSize: 20),
                    )),
                  ],
                ),
          SizedBox(height: 10.0), // Adjust spacing as needed
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _showWithdrawDialog,
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
              child: Text(
                'Claim Cashback',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 60,
          )
        ],
      ),
    );
  }
}
