import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sep_module_razzaq/firebase_options.dart';
import 'package:sep_module_razzaq/screens/manage_report/report_page.dart';
import 'package:sep_module_razzaq/screens/manage_user/login_form.dart';
import 'package:sep_module_razzaq/screens/manage_user/profile_view_page.dart';
import 'package:sep_module_razzaq/screens/rating_screen.dart';
import 'package:sep_module_razzaq/seeders/reports_seeder.dart';
import 'package:sep_module_razzaq/seeders/users_seeder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await seedReports(); // Call your seeder here
  await seedUsers();  

  // Request location permission before starting the app
  await requestLocationPermission();
  runApp(MyApp());
}

Future<void> requestLocationPermission() async{
  //check the current permission status
  var status = await Permission.location.request();

  if (status.isGranted){
    print("Location permission granted"); // dont use print in production code
  } else if (status.isDenied) {
    print("Location permission denied");
  } else if (status.isPermanentlyDenied) {
    print("Location permission permanently denied. Open settings to enable");
    await openAppSettings();
  }
}

class MyApp extends StatelessWidget {
  
 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<int?>(
        future: getUserSession(),  // Fetch user session from SharedPreferences
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const LoginForm();  // If no user session found, show LoginForm
          }
          int userId = snapshot.data!;
          return DrawerMenu(userId: userId);  // If user session exists, show DrawerMenu
        },
      ),
      routes: {
        '/profile': (context) => ProfileViewPage(userId: getUserSession() as int),
      },
    );
  }

  Future<int?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}

class ScheduleScreenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScheduleScreen(),
    );
  }
}

class DrawerMenu extends StatefulWidget {
 final int userId;  // Accept userId as a parameter

  // Constructor to receive userId
  DrawerMenu({required this.userId});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  late int userId;  // Declare userId but do not initialize here

  @override
  void initState() {
    super.initState();
    userId = widget.userId;  // Initialize userId after the widget is built
  }

  final List<MenuItem> menuItems = [
    MenuItem(
        title: "Profile", icon: Icons.person, destination: ProfileViewPage(userId: 1)), // Example, replace with dynamic value
    MenuItem(
        title: "Schedule",
        icon: Icons.schedule,
        destination: ScheduleScreen()),
    MenuItem(
        title: "Activity", icon: Icons.group, destination: ActivityScreen()),
    MenuItem(
        title: "Report", icon: Icons.bar_chart, destination: ReportPage()),
    MenuItem(
        title: "Rating/Complaint",
        icon: Icons.feedback,
        destination: RatingScreen()),
    MenuItem(
        title: "Payment",
        icon: Icons.attach_money,
        destination: PaymentScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: const Text('CCS', style: TextStyle(color: Colors.black)),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.yellow[600],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.yellow[600]),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cleaning_services,
                        size: 50, color: Colors.black),
                    SizedBox(height: 10),
                    Text(
                      'CCS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              DrawerItem(
                title: 'Home',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              DrawerItem(
                title: 'About Us',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUsScreen()),
                  );
                },
              ),
              DrawerItem(
                title: 'Activity',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ActivityScreen()),
                  );
                },
              ),
              DrawerItem(
                title: 'Schedule',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScheduleScreen()),
                  );
                },
              ),
              DrawerItem(
                title: 'Complaint/Rating',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RatingScreen()),
                  );
                },
              ),
              DrawerItem(
                title: 'Logout',
                onTap: () async {
                  // Clear all shared preferences data
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();  // Clears all stored data

                  // Navigate back to the login screen after logout
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginForm()),
                    (route) => false,  // Removes all previous routes, so user can't navigate back
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return GestureDetector(
              onTap: () {
                // Make sure userId is passed dynamically to the destination page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      if (item.title == 'Profile') {
                        return ProfileViewPage(userId: userId);
                      } else if (item.title == 'Schedule') {
                        return ScheduleScreen();
                      } else if (item.title == 'Activity') {
                        return ActivityScreen();
                      } else if (item.title == 'Report') {
                        return ReportPage();
                      } else if (item.title == 'Rating/Complaint') {
                        return RatingScreen();
                      } else if (item.title == 'Payment') {
                        return PaymentScreen();
                      }
                      return const SizedBox(); // Default fallback (not reachable)
                    },
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.yellow[600],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 50, color: Colors.black),
                    const SizedBox(height: 8.0),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        ],
        selectedItemColor: Colors.yellow[700],
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  DrawerItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
      onTap: onTap,
    );
  }
}

class DashboardPage extends StatelessWidget {
  final List<MenuItem> menuItems = [
    MenuItem(
        title: "Profile", icon: Icons.person, destination: ProfileScreen()),
    MenuItem(
        title: "Schedule", icon: Icons.schedule, destination: ScheduleScreen()),
    MenuItem(
        title: "Activity", icon: Icons.group, destination: ActivityScreen()),
    MenuItem(
        title: "Report", icon: Icons.bar_chart, destination: ReportPage()),
    MenuItem(
        title: "Rating/Complaint",
        icon: Icons.feedback,
        destination: RatingScreen()),
    MenuItem(
        title: "Payment",
        icon: Icons.attach_money,
        destination: PaymentScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: const Text("Dashboard"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Back to Drawer Menu
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item.destination),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.yellow[600],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 50, color: Colors.black),
                    const SizedBox(height: 8.0),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final Widget destination;

  MenuItem(
      {required this.title, required this.icon, required this.destination});
}

// Placeholder screens
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: const Center(child: Text("Profile Screen")),
    );
  }
}

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Us")),
      body: const Center(child: Text("About Us Screen")),
    );
  }
}

class ActivityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activity")),
      body: const Center(child: Text("Activity Screen")),
    );
  }
}

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activity")),
      body: const Center(child: Text("Activity Screen")),
    );
  }
}

/*class RatingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rating/Complaint")),
      body: const Center(child: Text("Rating/Complaint Screen")),
    );
  }
}
*/
class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: const Center(child: Text("Payment Screen")),
    );
  }
}

class ReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report")),
      body: const Center(child: Text("Report Screen")),
    );
  }
}