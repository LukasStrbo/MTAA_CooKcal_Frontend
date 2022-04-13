import 'package:cookcal/Screens/home_screen.dart';
import 'package:cookcal/Screens/Login_register/register_screen.dart';
import 'package:cookcal/Utils/constants.dart';
import 'package:cookcal/Utils/custom_functions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../HTTP/login_register.dart';
import '../../model/users.dart';
import '../MainNavigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passController = TextEditingController();

  var user_auth = Userauth();

  /*
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose(); } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(builder: (context, constraints){
        return Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Column(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              color: COLOR_GREEN,

                            ),
                            Image.asset("assets/images/fast-food.png"),
                            Padding(padding: const EdgeInsets.all(10)),
                          ],
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.fromLTRB(10,5,10,5),
                          width: constraints.maxWidth,
                          color: COLOR_WHITE,
                          height: constraints.maxHeight * 0.65,

                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  border: Border.all(
                                      color: COLOR_ORANGE,// set border color
                                      width: 3.0),   // set border width
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0)), // set rounded corner radius
                                ),
                                child: TextField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    icon: Icon(
                                      Icons.local_post_office_outlined,
                                      color: COLOR_GREEN,
                                    ),
                                    hintText: 'E-mail',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  border: Border.all(
                                      color: COLOR_GREEN,// set border color
                                      width: 3.0),   // set border width
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0)), // set rounded corner radius
                                ),
                                child: TextField(
                                  controller: passController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    icon: Icon(
                                      Icons.key_outlined,
                                      color: COLOR_ORANGE,
                                    ),
                                    hintText: 'Password',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              addVerticalSpace(constraints.maxHeight * 0.1),
                              ButtonTheme(
                                minWidth: 500,
                                height: 200,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(200,80),
                                      primary: COLOR_GREEN,
                                      shadowColor: Colors.grey.shade50,
                                      textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50)
                                      )
                                  ),
                                  onPressed: () async {
                                    var response = await user_auth.login(UserLogin(username: emailController.text, password: passController.text));
                                    if (response != null){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                                      );
                                    }
                                    else{
                                      showDialog(
                                          context: context,
                                          builder: (context){
                                            return AlertDialog(
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                              backgroundColor: COLOR_WHITE,
                                              content: Container(
                                                width: constraints.maxWidth * 0.8,
                                                height: constraints.maxHeight * 0.12,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    children: [
                                                      const Text(
                                                        "Invalid E-mail or Password",
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            color: COLOR_BLACK,
                                                            fontSize: 20
                                                        ),
                                                      ),
                                                      addVerticalSpace(constraints.maxHeight * 0.01),
                                                      SizedBox(
                                                        width: 50,
                                                        height: 50,
                                                        child: FloatingActionButton(
                                                          backgroundColor: COLOR_ORANGE,
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          child: const Icon(Icons.arrow_back),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                      );
                                    }
                                  },
                                  child: Text('Login'),
                                ),
                              ),
                              TextButton(
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all<Color>(COLOR_DARKGREEN),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                  );
                                },
                                child: Text('or register HERE!'),
                              )
                            ],
                          )
                      ),
                    ]
                )
        );
      }),
    );
  }
}