import 'package:flutter/material.dart';
import 'package:fooddelivery/page/home_page.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fooddelivery/util/constant.dart'; 
import 'package:fooddelivery/util/storage.dart';

Future<Map<String, dynamic>> login(String email, String password) async {
  const String endpoint = 'api/login';
  try{
    final response = await http.post(Uri.http(baseIp, endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 20), onTimeout: () {
      return http.Response('Error', 408);
    },);
    if(response.statusCode == 200){
      var data = jsonDecode(response.body);
      print('Response Data: $data'); // Debugging
      return data;
    }else{
      print('Error: ${response.statusCode} - ${response.body}');
      return {};
    }
  }catch(e){
    return Future.error(e.toString());
  }
}
Future<Map<String, dynamic>> Register(String name, String email, String password, String noTelp) async {
  const String endpoint = 'api/register';
  try{
    final response = await http.post(Uri.http(baseIp, endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'no_telp': noTelp,
      }),
    ).timeout(const Duration(seconds: 20), onTimeout: () {
      return http.Response('Error', 408);
    },);
    if(response.statusCode == 200){
      var data = jsonDecode(response.body);
      print('Response Data: $data'); // Debugging
      return data;
    }else{
      print('Error: ${response.statusCode} - ${response.body}');
      return {};
    }
  }catch(e){
    return Future.error(e.toString());
  }
}
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    confirmPasswordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  void showCustomSnackBar(String title, String message, ContentType type) {
    
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 3), // Ensure snackbar is displayed
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Image(image: AssetImage('images/logo.png')),
              const SizedBox(height: 30),
              const Text(
                'Log IN',
                style: TextStyle(
                  fontFamily: 'Sen',
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(
                      fontFamily: "Sen",
                    ),
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(
                      fontFamily: "Sen",
                    ),
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (emailController.text.isEmpty) {
                    showCustomSnackBar("Email Can't be Empty", "Please fill the email to continue", ContentType.warning);
                  } else if (passwordController.text.isEmpty) {
                    showCustomSnackBar("Password Can't be Empty", "Please fill the password to continue", ContentType.warning);
                  } else {
                    try {
                      Map<String, dynamic>? data;
                      data = await login(emailController.text, passwordController.text);

                      if (data.isNotEmpty) {
                        print(data);  // Debugging to check if the response contains the token
                        if (data['message'] == 'email Not Found') {
                          showCustomSnackBar("Email Not Found", "Please check the email and try again", ContentType.warning);
                        } else if (data['message'] == "Request Timeout") {
                          showCustomSnackBar("Request Timeout", "Try again later", ContentType.failure);
                        } else if (data['message'] == 'Invalid Credentials') {
                          showCustomSnackBar("Invalid Credentials", "The credentials are invalid. Try again", ContentType.failure);
                        } else {
                          // Token check for debugging
                          if (data['token'] == null || data['token'].isEmpty) {
                            showCustomSnackBar("Missing Token", "The server did not return a token", ContentType.failure);
                          } else {
                            showCustomSnackBar("Login Successfully", "Thank you for using our app", ContentType.success);
                            
                            await Storage.writeSecureData('personalToken', data['token']);
                            await Storage.writeSecureData('id', data['detail']['id'].toString());
                            await Storage.writeSecureData('name', data['detail']['name']);
                            await Storage.writeSecureData('email', data['detail']['email']);

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const HomePage()),
                              (route) => false,
                            );
                          }
                        }
                      }

                    } catch (e) {
                      showCustomSnackBar(e.toString(), "Please try again later", ContentType.failure);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: const Color.fromARGB(255, 255, 116, 36),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Color.fromARGB(255, 32, 32, 32),
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context, 
                    builder: (BuildContext context) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 18, 18, 35),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 3 / 4,
                        
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                          const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'Sen',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: 350,
                            child: TextField(
                              controller: usernameController,
                              //change the color of text when user type
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Username',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Sen',
                                  color: Colors.white,
                                ),
                                

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: 350,
                            child: TextField(
                              controller: phoneController,
                              //change the color of text when user type
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Phone Number',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Sen',
                                  color: Colors.white,
                                ),
                                

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              validator: (value) {
                                final material = MaterialBanner(
                                  forceActionsBelow: true,
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  content: AwesomeSnackbarContent(
                                    title: "Email Can't be Empty", message: "Please Fill The Email to Continue", contentType: ContentType.warning, inMaterialBanner: true), 
                                    
                                  actions: const [SizedBox.shrink()]
                                );

                                if(value == null || value.isEmpty){
                                  material;
                                }

                                ScaffoldMessenger.of(context)..hideCurrentMaterialBanner()..showMaterialBanner(material);
                                return null;
                              },
                              controller: emailController,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Sen',
                                  color: Colors.white,
                                ),
                                
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              validator: (value) {
                                final material = SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  content: AwesomeSnackbarContent(
                                    title: "Passowrd Can't be Empty", message: "Please Fill The Password to Continue", contentType: ContentType.warning, inMaterialBanner: true), 
                                );

                                if(value == null || value.isEmpty){
                                  material;
                                }

                                ScaffoldMessenger.of(context)..hideCurrentSnackBar()
                                ..showSnackBar(material);
                                return null;
                              },
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              controller: passwordController,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Sen',
                                  color: Colors.white,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          SizedBox(
                            width: 350,
                            child: TextField(
                              controller: confirmPasswordController,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Sen',
                                  color: Colors.white,
                                ),
                                
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () async{
                              if(usernameController.text.isEmpty){
                                showCustomSnackBar("Username Can't be Empty", "Please fill the username to continue", ContentType.warning);
                              }
                              if(phoneController.text.isEmpty){
                                showCustomSnackBar("Phone Number Can't be Empty", "Please fill the phone number to continue", ContentType.warning);
                              }
                              if(emailController.text.isEmpty){
                                showCustomSnackBar("Email Can't be Empty", "Please fill the email to continue", ContentType.warning);
                              }
                              if(passwordController.text.isEmpty){
                                showCustomSnackBar("Password Can't be Empty", "Please fill the password to continue", ContentType.warning);
                              }
                              Map<String, dynamic>? data;
                              data = await Register(usernameController.text, emailController.text, passwordController.text, phoneController.text);
                              if(data.isNotEmpty){
                                if(data['message'] == 'Account Already Exist!'){
                                  showCustomSnackBar("Account Already Exist!", "Please use another email", ContentType.warning);
                                }else{
                                  showCustomSnackBar("Register Successfully", "Thank you for using our app", ContentType.success);
                                  Navigator.pop(context);
                                }
                              }else{
                                showCustomSnackBar("Error", "Please try again later", ContentType.failure);
                              }
                              
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 41, 41, 41),
                              ),
                            ),
                          ),
                        ],
                        ),
                      );
                    }
                    );
                },
                child: const Text(
                  "Don't Have an Account? Register",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

