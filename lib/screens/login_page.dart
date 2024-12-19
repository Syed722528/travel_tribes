import 'package:firebase_learn/services/auth/firebase_auth_service.dart';
import 'package:firebase_learn/widgets/custom_elevated_button.dart';
import 'package:firebase_learn/widgets/custom_input_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final void Function()? ontap;
  const LoginPage({super.key,required this.ontap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final FirebaseAuthService _auth = FirebaseAuthService();
  //----------------- Live User Input on Screen ---------------//
  @override
  // void initState() {
  //   super.initState();

  //   _email.addListener(() {
  //     setState(() {
  //       _email.text;
  //     });
  //   });
  //   _password.addListener(() {
  //     setState(() {
  //       _password.text;
  //     });
  //   });
  // }

  //----------------- Disposing the value ---------------//
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();

  }

  bool validateInput(BuildContext context, String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All fields required'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  void signIn() async {
    if(validateInput(context, _email.text, _password.text)){
      _auth.signInWithEmailAndPassword(_email.text, _password.text, context);
    }
    else{if (kDebugMode) {
      print('Unknow Error Occured');
    }}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('images/image_plane.jpg'),
          ),
        ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                height: 450,
                width: MediaQuery.of(context).size.width * 0.90,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: LinearGradient(
                        colors: [Colors.black, Colors.transparent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 45,
                          color: Colors.white
                          //fontFamily:
                          ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    //----------------- Using Custom Input Field---------------//
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: CustomInputField(
                        inputController: _email,
                        labelText: const Text('Email'),
                        hint: 'Email',
                        textInputType: TextInputType.emailAddress,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: CustomInputField(
                        inputController: _password,
                        labelText: const Text('Password'),
                        hint: 'Password',
                        textInputType: TextInputType.text,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomElevatedButton(
                      label: const Text('Continue'),
                      buttonIcon: const Icon(Icons.login),
                      onPressed: signIn,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    RichText(
                      text: TextSpan(
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: "Sign up",
                            style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap =widget.ontap,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}

// ignore: must_be_immutable

