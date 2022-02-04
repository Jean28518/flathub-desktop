import 'dart:convert';
import 'package:flatpak_manager/flatpak_list_view_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<ApplicationList> fetchAllApplications() async {
  final response =
      await http.get(Uri.parse("http://localhost:5000/flatpak/all"));
  if (response.statusCode == 200) {
    return ApplicationList.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load flatpak list.');
  }
}

installApplication(application_id) async {
  final response = await http
      .get(Uri.parse("http://localhost:5000/flatpak/install/$application_id"));
  if (response.statusCode == 200) {
    return;
  } else {
    print(response.statusCode);
  }
}

removeApplication(application_id) async {
  final response = await http
      .get(Uri.parse("http://localhost:5000/flatpak/remove/$application_id"));
  if (response.statusCode == 200) {
    return;
  } else {
    print(response.statusCode);
  }
}

startApplication(application_id) async {
  final response = await http
      .get(Uri.parse("http://localhost:5000/flatpak/start/$application_id"));
  if (response.statusCode == 200) {
    return;
  } else {
    print(response.statusCode);
  }
}

class AllFlatpaksView extends StatefulWidget {
  late bool showOnlyOnstalled;
  AllFlatpaksView(bool showOnlyOnstalled) {
    this.showOnlyOnstalled = showOnlyOnstalled;
  }

  @override
  _AllFlatpaksViewState createState() =>
      _AllFlatpaksViewState(showOnlyOnstalled);
}

class _AllFlatpaksViewState extends State<AllFlatpaksView> {
  late Future<ApplicationList> futureApplicationList;

  late bool showOnlyOnstalled;
  _AllFlatpaksViewState(bool showOnlyOnstalled) {
    this.showOnlyOnstalled = showOnlyOnstalled;
  }

  @override
  Widget build(BuildContext context) {
    futureApplicationList = fetchAllApplications();
    return FutureBuilder<ApplicationList>(
      future: futureApplicationList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FlatpakListViewWithSearch(snapshot.data, showOnlyOnstalled);
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Fetching latest data from flathub...",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                child: CircularProgressIndicator(),
                height: 80,
                width: 80,
              )
            ],
          ));
        }
      },
    );
  }
}

class ApplicationList {
  List<Application> entries = List.empty(growable: true);

  ApplicationList({required this.entries});

  factory ApplicationList.fromJson(List<dynamic> json) {
    List<Application> entries = List.empty(growable: true);
    json.forEach((element) {
      String id = element["id"];
      String name = element["name"];
      String description = element["summary"];
      String iconUrl = "";
      if (element["iconUrl"] != null) {
        iconUrl = element["iconUrl"];
      }
      bool installed = element["installed"].toString().toLowerCase() == "true";
      bool installing =
          element["installing"].toString().toLowerCase() == "true";
      bool removing = element["removing"].toString().toLowerCase() == "true";
      List<String> categories = [];
      for (dynamic category in element["categories"]) {
        categories.add(category);
      }
      // String name = element["name"];
      // String description = element["summary"];
      // String iconUrl = element["iconUrl"];
      // bool installed = element["installed"].toString().toLowerCase() == "true";
      entries.add(Application(id, name, description, iconUrl, installed,
          installing, removing, categories));
    });
    return ApplicationList(entries: entries);
  }
}

class Application {
  String id = "";
  String name = "";
  String descripion = "";
  String iconUrl = "";
  bool installed = false;
  bool installing = false;
  bool removing = false;
  late List<String> categories;

  Application(String id, String name, String description, String iconUrl,
      bool installed, bool installing, bool removing, List<String> categories) {
    this.id = id;
    this.name = name;
    this.descripion = description;
    this.iconUrl = iconUrl;
    this.installed = installed;
    this.installing = installing;
    this.removing = removing;
    this.categories = categories;
  }
}
