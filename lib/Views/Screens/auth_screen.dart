import 'package:chat_app/Models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AuthState { Phone, OTP }

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  AuthState _authState = AuthState.Phone;
  var _phoneController = TextEditingController();
  var _otpController = TextEditingController();
  String? verificationId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.cyan, Colors.lightBlue]),
        ),
        child: Center(
          child: AnimatedSize(
            duration: Duration(milliseconds: 300),
            vsync: this,
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // if (_authState == AuthState.SignUp) InkWell(onTap: _pickImageFile ,child: CircleAvatar()),
                  if (_authState == AuthState.Phone)
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'enter your phone number',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1.0),
                        ),
                      ),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                  if (_authState == AuthState.OTP)
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'enter your phone number',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 1.0),
                        ),
                      ),
                      controller: _otpController,
                      keyboardType: TextInputType.phone,
                    ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_authState == AuthState.Phone) {
                        await FirebaseAuth.instance.verifyPhoneNumber(
                            phoneNumber: _phoneController.text.trim(),
                            verificationCompleted: (phoneCredentials) =>
                                signIn(phoneCredentials, context),
                            verificationFailed: (error) =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.message!))),
                            codeSent: (verificationId, resendToken) {
                              setState(() {
                                this.verificationId = verificationId;
                                _authState = AuthState.OTP;
                              });
                            },
                            codeAutoRetrievalTimeout: (verificationId) => null);
                      } else {
                        var cred = PhoneAuthProvider.credential(
                            verificationId: verificationId!,
                            smsCode: _otpController.text.trim());
                        await signIn(cred, context);
                      }
                    },
                    icon: Icon(Icons.done),
                    label: Text(
                        _authState == AuthState.Phone ? 'Send SMS' : 'Verify'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signIn(PhoneAuthCredential cred, BuildContext context) async {
    final result = await FirebaseAuth.instance.signInWithCredential(cred);
    print(FirebaseAuth.instance.currentUser!.uid);
    Provider.of<UserManager>(context, listen: false).createUser(
        result.user!.phoneNumber!,
        result.user!.uid,
        result.user!.displayName ?? '',
        result.user!.photoURL ?? ''
        );
  }
}
