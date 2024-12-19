import 'package:firebase_learn/services/auth/firebase_auth_service.dart';
import 'package:firebase_learn/widgets/custom_elevated_button.dart';
import 'package:firebase_learn/widgets/custom_input_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  final void Function()? ontap;
  const SignupPage({super.key,required this.ontap});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
    final TextEditingController _userName = TextEditingController();

  final FirebaseAuthService _auth = FirebaseAuthService();
  @override
  void dispose() {
    _email.dispose;
    _password.dispose;
    _confirmPassword.dispose;
    super.dispose();
  }
 bool validateInput(BuildContext context, String email, String password,String confirmPassword,String userName) {
    if (email.isEmpty || password.isEmpty || userName.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All fields required'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    else if(password!=confirmPassword){
            ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Passwords don't match"),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    else{return true;}
  }
  void signUp() async {
    // ignore: unused_local_variable
    if (validateInput(context, _email.text, _password.text, _confirmPassword.text,_userName.text)) {
    _auth.signUpWithEmailAndPassword(_email.text, _password.text,_userName.text, context);
    }
    else{if (kDebugMode) {
      print('Unknown Error');
    }}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('images/image_bag.jpg'),
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
                  colors: [Colors.blueGrey, Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 45,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                CustomInputField(
                  inputController: _userName,
                  labelText: const Text('Username'),
                  hint: 'Create a username',
                  textInputType: TextInputType.text,
                ),
                CustomInputField(
                  inputController: _email,
                  labelText: const Text('Email'),
                  hint: 'Enter you email',
                  textInputType: TextInputType.text,
                ),
                CustomInputField(
                  inputController: _password,
                  labelText: const Text('Password'),
                  hint: 'Create a strong Password',
                  textInputType: TextInputType.emailAddress,
                ),
                CustomInputField(
                  inputController: _confirmPassword,
                  labelText: const Text('Confirm Password'),
                  hint: '',
                  textInputType: TextInputType.text,
                ),
                CustomElevatedButton(
                  label: const Text('Create Account'),
                  buttonIcon: const Icon(Icons.create),
                  onPressed: signUp,
                ),
                SizedBox(
                  height: 10,
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.white)),
                      TextSpan(
                        text: "Log in",
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.ontap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
