import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordContoller = TextEditingController();
  final String loginUrl = "http://feeds.ppu.edu/api/login";

  Future<void> _login() async {
    http.Response response = await http.post(Uri.parse(loginUrl),
        body: json.encode({
          "email": _emailController.text,
          "password": _passwordContoller.text
        }));

    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      dynamic jsonObject = jsonDecode(response.body);
      print(jsonObject['status']);
      if (jsonObject['status'] == 'success') {
        String token = jsonObject['session_token'];
        // Store the token to be used later by any request
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        Navigator.pushReplacementNamed(context, "/home");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Form(
              child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    labelText: "Email", border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _passwordContoller,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Password", border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    _login();
                  },
                  child: Text("Login"))
            ],
          )),
        ),
      ),
    );
  }
}
