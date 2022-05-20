import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_demo/shared/firebase_authentication.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String _message = '';
  bool _isLogin = true;
  final TextEditingController txtUserName = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  FirebaseAuthentication? auth;

  @override
  void initState() {
    Firebase.initializeApp().whenComplete(() {
      auth = FirebaseAuthentication();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
        actions: [
          IconButton(
              onPressed: () {
                auth!.logOut().then((value) {
                  if (value) {
                    setState(() {
                      _message = 'User Logged Out';
                    });
                  } else {
                    _message = 'Unable to Log Out';
                  }
                });
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(36),
        child: ListView(
          children: [
            userInput(),
            passwordInput(),
            btnMain(),
            btnSecondary(),
            txtMessage(),
          ],
        ),
      ),
    );
  }

  Widget userInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 128),
      child: TextFormField(
        controller: txtUserName,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: 'User Name',
          icon: Icon(Icons.verified_user),
        ),
        validator: (text) => text!.isEmpty ? 'User Name is required' : '',
      ),
    );
  }

  Widget passwordInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: TextFormField(
        controller: txtPassword,
        keyboardType: TextInputType.emailAddress,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'password',
          icon: Icon(Icons.enhanced_encryption),
        ),
        validator: (text) => text!.isEmpty ? 'Password is required' : '',
      ),
    );
  }

  Widget btnMain() {
    String btnText = _isLogin ? 'Log in' : 'Sign Up';
    return Padding(
      padding: const EdgeInsets.only(top: 125),
      child: Container(
        height: 60,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              Theme.of(context).primaryColorLight,
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          child: Text(
            btnText,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          onPressed: () {
            String userId = '';
            if (_isLogin) {
              auth!.login(txtUserName.text, txtPassword.text).then((value) {
                if (value == null) {
                  setState(() {
                    _message = 'Login Error';
                  });
                } else {
                  userId = value;
                  setState(() {
                    _message = 'User $userId successfully logged in';
                  });
                }
              });
            } else {
              auth!
                  .createUser(
                txtUserName.text,
                txtPassword.text,
              )
                  .then((value) {
                if (value == null) {
                  setState(() {
                    _message = 'Registration Error';
                  });
                } else {
                  userId = value;
                  setState(() {
                    _message = 'User $userId successfully signed in';
                  });
                }
              });
            }
          },
        ),
      ),
    );
  }

  Widget btnSecondary() {
    String buttonText = _isLogin ? 'Sign up' : 'Log in';
    return TextButton(
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
        });
      },
      child: Text(buttonText),
    );
  }

  Widget txtMessage() {
    return Text(
      _message,
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).primaryColorDark,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
