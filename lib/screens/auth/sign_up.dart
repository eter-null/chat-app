import 'dart:developer';

import 'package:chat_application_iub_cse464/const_config/color_config.dart';
import 'package:chat_application_iub_cse464/const_config/text_config.dart';
import 'package:chat_application_iub_cse464/services/user_management_services.dart';
import 'package:chat_application_iub_cse464/services/utils/helper_functions.dart';
import 'package:chat_application_iub_cse464/services/utils/validators.dart';
import 'package:chat_application_iub_cse464/widgets/custom_buttons/Rouded_Action_Button.dart';
import 'package:chat_application_iub_cse464/widgets/input_widgets/password_input_field.dart';
import 'package:chat_application_iub_cse464/widgets/input_widgets/simple_input_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

import '../chat/dashboard.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final List<Widget> randomAvatar = <Widget>[];

  final auth = FirebaseAuth.instance;


  void onUserNameChange() {
    randomAvatar.add(RandomAvatar(
      usernameController.text,
      trBackground: false,
      height: 100,
      width: 100,
    ));
    setState(() {});
  }


  @override
  void initState() {
    // TODO: implement initState
    usernameController.text = "IUB CSE464";
    onUserNameChange();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: MyColor.scaffoldColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Text("Welcome to", style: TextDesign().dashboardWidgetTitle),
                Text("End Chat", style: TextDesign().popHead.copyWith(color: MyColor.black, fontSize: 22)),
                const SizedBox(height: 10),
                Container(
                    height: size.height * 0.25,
                    width: double.infinity,
                    decoration: BoxDecoration(color: MyColor.white, borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.all(20),
                    child: randomAvatar.last
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: MyColor.white, borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SimpleInputField(
                        controller: usernameController,
                        backgroundColor: MyColor.scaffoldColor,
                        hintText: "Enter your user name",
                        needValidation: true,
                        errorMessage: "Please enter an user name",
                        fieldTitle: "User name",
                        validatorClass: ValidatorClass().validateUserName,
                        onValueChange: (value) {
                          onUserNameChange();
                        },
                      ),
                      const SizedBox(height: 5),
                      SimpleInputField(
                        controller: emailController,
                        backgroundColor: MyColor.scaffoldColor,
                        hintText: "Enter email",
                        needValidation: true,
                        errorMessage: "",
                        validatorClass: ValidatorClass().validateEmail,
                        fieldTitle: "Email",
                      ),
                      const SizedBox(height: 5),
                      PasswordInputField(
                        password: passwordController,
                        backgroundColor: MyColor.scaffoldColor,
                        fieldTitle: "Password",
                        hintText: "*******",
                      ),

                      const SizedBox(height: 35),

                      /// Sign up --------------------------------------------------------------
                      /// Sign up --------------------------------------------------------------
                      /// Sign up --------------------------------------------------------------
                      RoundedActionButton(
                          onClick: () async{
                            FocusScope.of(context).unfocus();
                            if(formKey.currentState!.validate())
                              {
                                await auth.createUserWithEmailAndPassword(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim()
                                ).then((value) async {
                                  UserManage().createUserProfile(userName: usernameController.text, userEmail: emailController.text.trim(),userID: auth.currentUser!.uid);
                                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const Dashboard()), (route) => false);
                                  if(value.user != null)
                                    {
                                      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).update({
                                        'last_active': DateTime.now(),
                                      });
                                      showSnackBar(
                                          context: context,
                                          title: "Successful",
                                          height: 200,
                                          message: "Welcome to END Chat",
                                          failureMessage: false
                                      );
                                    }
                                  else
                                    {
                                      showSnackBar(
                                          context: context,
                                          title: "Error",
                                          height: 200,
                                          message: "Please try again later",
                                          failureMessage: true
                                      );
                                    }
                                });

                              }
                          },
                          width: size.width * 0.8,
                          label: "Sign Up"
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextDesign().bodyTextSmall.copyWith(color: MyColor.disabled),
                          ),
                          InkWell(
                              onTap: () {
                                // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const LoginPage()), (route) => false);
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const LoginPage()));
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child:Text("Login Now!",
                                    style: TextDesign().pageTitle.copyWith(color: MyColor.primary, fontSize: 13)),
                              ))
                        ],
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
