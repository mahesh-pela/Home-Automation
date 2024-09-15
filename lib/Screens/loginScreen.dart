import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_automation/Screens/signupScreen.dart';
import '../constants/textFieldDecoration.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  TextEditingController txtEmailController = TextEditingController();
  TextEditingController txtPassController = TextEditingController();
  var _obscureText = true;

  void showHidePassword(){
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(backgroundColor: CupertinoColors.white,),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30,),
            Text('Login', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w600),),
            SizedBox(height: 20,),

            ///---email address textfield---///
            TextField(
              controller: txtEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                )
              ),
            ),
            SizedBox(height: 10,),

            ///---password textfield----///
            TextField(
              keyboardType: TextInputType.visiblePassword,
              controller: txtPassController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.password),
                  suffixIcon: IconButton(
                    onPressed: showHidePassword,
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility)
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
              ),
            ),
            SizedBox(height: 5,),

            ///----forgot password---///
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Forgot Password?', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),)
              ],
            ),
            SizedBox(height: 15,),

            ///----Login Button-----///
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  onPressed: (){
                  },
                  child: Text('Login', style: TextStyle(color: CupertinoColors.white, fontSize: 21, fontWeight: FontWeight.w600),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CupertinoColors.activeBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  )
                ),
              ),
            ),
            SizedBox(height: 15,),

            Center(child: Text("Don't Have an Account? Create Now")),
            SizedBox(height: 15,),

            Center(child: Text('Or Sign in With', style: TextStyle(color: Colors.grey.shade600),)),
            SizedBox(height: 15,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 160,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        width: 1.5,
                        color: Colors.grey.shade300
                    ),
                  ),
                  child: IconButton(
                    onPressed: (){},
                    icon: Image.asset('assets/icons/google logo.png'),
                  ),
                ),

                // Container(
                //   width: 155,
                //   height: 55,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(15),
                //     border: Border.all(
                //         width: 1,
                //       color: Colors.grey.shade500
                //     )
                //   ),
                //
                //   child: IconButton(
                //     onPressed: (){},
                //     icon: Image.asset('assets/icons/facebook logo.png'),
                //   ),
                // )
              ],
            )
          ],
        ),
      ),
    );
  }
}
