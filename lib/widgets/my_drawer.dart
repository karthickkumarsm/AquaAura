import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:water_reminder_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "AquaAura",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "An AppVista Product",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const Padding(padding: EdgeInsets.all(20)),
            SizedBox(
              width: 175,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Settings(),
                      ),
                    );
                  },
                   style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  ),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            SizedBox(
              width: 175,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const About(),
                      ),
                    );
                  },
                   style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                     backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                   child: Text(
                    "About",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  ),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            SizedBox(
              width: 175,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Info(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                     backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),  
                  child: Text(
                    "How to use",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  ),
            ),
            const Padding(padding: EdgeInsets.only(top: 100)),
            const Text(
              "copyright ©️ 2024",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Settings"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Dark/Light Mode",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            CupertinoSwitch(
                value: Provider.of<ThemeProvider>(context).isDarkMode,
                onChanged: (value) {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                })
          ],
        ),
      ),
    );
  }
}

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("About"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: const Text(
          "Version : 1.0.0\n\nContact us : appvista2024@gmail.com\n\nCompany : AppVista\n\nDeveloper : Karthick Kumar SM\n\nCopyRight : 2024\n\nDisclaimer : This app doesn't misuse any personal data of the user. It is just a reminder app to remind you to drink water. You can also delete your data by clicking on 'Delete Account' in the settings.\n\nP.S. We setted the amount of water you enter as 150 ml by default for now.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("How to use"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: const Text(
            "1.Enter your entry of drinking by pressing '+' icon.\n\n2.Delete your entry of drinking by pressing '-' icon.\n\n3.Click on 'History' icon to view your drinking time log.\n\n4.Click on 'Alarm' icon to set timer for notification to remember you to have some water.\n\n5.You can set reminder upto 3 hours to remember you to drink water.\n\n6.You can also turn off the reminder notification when you are going to sleep or in a busy situation.\n\n7.Once you turn on the reminder notification, the previous schedule will be resumed.\n\n8.Click on 'user' icon to view Accounts settings.\n\n9.Click on 'Hamburger' icon to see menu.\n\n10.Click on 'Settings' to access settings option.\n\n11.Click on 'About' to know about the app.\n\n12.Click on your profile picture to change your profile picture.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}