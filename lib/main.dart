import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:updat/updat_window_manager.dart';

import 'package:updat/theme/chips/floating_with_silent_download.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Updat Demo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xff1890ff),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var show = true;
  var elevated = false;

  TextEditingController titleController =
      TextEditingController(text: "Update Available");
  TextEditingController subtitleController =
      TextEditingController(text: "New version available");
  Color color = const Color(0xff1890ff);

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    titleController.addListener(() {
      setState(() {});
    });
    subtitleController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UpdatWindowManager(
      getLatestVersion: () async {
        // Github gives us a super useful latest endpoint, and we can use it to get the latest stable release
        final data = await http.get(Uri.parse(
          "https://api.github.com/repos/fluttertools/sidekick/releases/latest",
        ));

        // Return the tag name, which is always a semantically versioned string.
        return jsonDecode(data.body)["tag_name"];
      },
      getBinaryUrl: (version) async {
        // Github also gives us a great way to download the binary for a certain release (as long as we use a consistent naming scheme)

        // Make sure that this link includes the platform extension with which to save your binary.
        // If you use https://exapmle.com/latest/macos for instance then you need to create your own file using `getDownloadFileLocation`
        return "https://github.com/fluttertools/sidekick/releases/download/$version/sidekick-${Platform.operatingSystem}-$version.$platformExt";
      },
      appName: "Updat Example", // This is used to name the downloaded files.
      getChangelog: (_, __) async {
        // That same latest endpoint gives us access to a markdown-flavored release body. Perfect!
        final data = await http.get(Uri.parse(
          "https://api.github.com/repos/fluttertools/sidekick/releases/latest",
        ));
        return jsonDecode(data.body)["body"];
      },
      updateChipBuilder: floatingExtendedChipWithSilentDownload,
      currentVersion: '1.0.0',
      callback: (status) {},
      child: Scaffold(
        body: Center(
          child: Container(
            padding: const EdgeInsets.only(left: 50, right: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Updat Flutter Demo",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                    "Current Version: 1.0.0"),
                const Divider(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String get platformExt {
  switch (Platform.operatingSystem) {
    case 'windows':
      {
        return 'msix';
      }

    case 'macos':
      {
        return 'dmg';
      }

    case 'linux':
      {
        return 'AppImage';
      }
    default:
      {
        return 'zip';
      }
  }
}
