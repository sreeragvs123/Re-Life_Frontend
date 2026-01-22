import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/user_home.dart';
import 'pages/admin_home.dart';
import 'pages/volunteer_home.dart';
import 'models/volunteer.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();


  await Hive.openBox('authBox');
  await Hive.openBox('volunteersBox');
  await Hive.openBox('bloodBox');


  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Re-Life",
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const SplashScreen(),
    );
  }
}



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();

}




class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { // ifecycle method of a StatefulWidget.It is called exactly once when the widget is inserted into the widget treeuse it to do one-time setup, like: Start animations , Initialize variables , Fetch data

    super.initState(); // becoz we override the parent's initState so we again call the parents's initState using super keyword

    Future.delayed(const Duration(seconds: 3), () {// Delay for 3 seconds before moving ahead
      _navigateNext();
    });
  }

  void _navigateNext() {

    var authBox = Hive.box('authBox'); // opens the box in the Hive and tries to take the key:value pair from the box 
    bool isLoggedIn = authBox.get('isLoggedIn', defaultValue: false); // if there is no value to the key "isLogged" set default
    String role = authBox.get('role', defaultValue: "USER"); // if there is no value to the key "role" set default


    Widget nextPage;
    if (isLoggedIn && role == "ADMIN") {
      nextPage = const AdminHome();
    } 
    
    else if (isLoggedIn && role == "VOLUNTEER") {
      final email = authBox.get('email');
      final vBox = Hive.box('volunteersBox');
      final data = vBox.get(email);
      nextPage = VolunteerHome(
        volunteer: Volunteer(
          name: data['name'],
          place: data['place'],
          email: data['email'],
          password: data['password'],
        ),
      );
    } 
    else {
      nextPage = const UserHome();
    }




    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );

  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.blueAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.png", height: 300),
              const SizedBox(height: 20),
              const Text(
                "RE-LIFE",
                style: TextStyle(
                  fontFamily: 'Impact', // Impact font
                  fontSize: 36,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),


      ),
    );
  }
}
