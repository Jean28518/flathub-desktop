import 'package:flatpak_manager/networking.dart';
import 'package:flutter/material.dart';

class FlatpakListViewWithSearch extends StatefulWidget {
  late ApplicationList appList;
  late bool show_only_installed;

  FlatpakListViewWithSearch(
      ApplicationList? appList, bool show_only_installed) {
    if (appList != null) {
      this.appList = appList;
      this.show_only_installed = show_only_installed;
    }
  }

  @override
  _FlatpakListViewWithSearchState createState() =>
      _FlatpakListViewWithSearchState(appList, show_only_installed);
}

class _FlatpakListViewWithSearchState extends State<FlatpakListViewWithSearch> {
  late ApplicationList appList;
  late bool show_only_installed;

  final List<String> categories = [
    "All",
    "Popular",
    "AudioVideo",
    "Development",
    "Education",
    "Game",
    "Graphics",
    "Network",
    "Office",
    "Science",
    "System",
    "Utility",
    "Installed",
  ];

  String selected_category = "All";

  String _lastKeyword = "";

  ApplicationList _foundApps = ApplicationList(entries: []);

  _FlatpakListViewWithSearchState(
      ApplicationList appList, bool show_only_installed) {
    this.appList = appList;
    this.show_only_installed = show_only_installed;
  }

  @override
  initState() {
    _foundApps.entries = List<Application>.from(appList.entries);
    if (show_only_installed) {
      _foundApps.entries =
          _foundApps.entries.where((app) => app.installed).toList();
    }
    super.initState();
  }

  void _runFilter(String keyword, {bool runSetState = true}) {
    _lastKeyword = keyword;
    keyword = keyword.toLowerCase();
    List<Application> results = [];
    if (keyword.isEmpty) {
      results = List<Application>.from(appList.entries);
    } else {
      results = appList.entries.where((app) {
        return app.id.toLowerCase().contains(keyword) ||
            app.name.toLowerCase().contains(keyword) ||
            app.descripion.toLowerCase().contains(keyword);
      }).toList();
    }

    if (show_only_installed || selected_category == "Installed") {
      results = results.where((app) => app.installed).toList();
    }

    if (selected_category != "All" && selected_category != "Installed") {
      results = results
          .where((app) => app.categories.contains(selected_category))
          .toList();
    }
    _foundApps.entries = results;
    if (runSetState) {
      setState(() {});
    }
  }

  // void _update() {
  void _update(Application app) {
    // setState(() {
    // appList.entries[appList.entries.indexOf(app)] = app;
    // _foundApps.entries[_foundApps.entries.indexOf(app)] = app;
    _runFilter(_lastKeyword);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Card(
            child: ListView(
              primary: false,
              children: List.generate(categories.length, (index) {
                return ListTile(
                    title: Text(categories[index]),
                    key: UniqueKey(),
                    selected: categories[index] == selected_category,
                    onTap: () {
                      selected_category = categories[index];
                      _runFilter(_lastKeyword);
                    });
              }),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        onChanged: (value) => _runFilter(value),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter a search term',
                            suffixIcon: Icon(Icons.search)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.extent(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  maxCrossAxisExtent: 800,
                  childAspectRatio: 6,
                  children: List.generate(_foundApps.entries.length, (index) {
                    Application app = _foundApps.entries[index];
                    return Card(
                      elevation: 3,
                      child: Center(
                        child: ListTile(
                          key: UniqueKey(),
                          hoverColor: Colors.grey,
                          leading: Image.network(
                            app.iconUrl,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Icon(
                                Icons.error,
                                size: 48,
                              );
                            },
                          ),
                          title: Text(
                            app.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            app.descripion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: InstallButton(app, this),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InstallButton extends StatefulWidget {
  late Application app;
  late dynamic reference;

  InstallButton(Application app, dynamic reference) {
    this.app = app;
    this.reference = reference;
    createState();
  }

  @override
  _InstallButtonState createState() => _InstallButtonState(app, reference);
}

class _InstallButtonState extends State<InstallButton> {
  late Application app;
  late dynamic reference;

  _InstallButtonState(Application app, reference) {
    this.app = app;
    this.reference = reference;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (app.removing) {
      return Padding(
        padding: EdgeInsets.only(right: 45),
        child: const SizedBox(
            child: CircularProgressIndicator(color: Colors.red),
            width: 15,
            height: 15),
      );
      ;
    } else if (app.installing) {
      return Padding(
        padding: EdgeInsets.only(right: 40),
        child: const SizedBox(
            child: CircularProgressIndicator(color: Colors.green),
            width: 15,
            height: 15),
      );
      ;
    } else if (app.installed) {
      return SizedBox(
        width: 120,
        child: Row(
          children: [
            ElevatedButton(
              child: Icon(Icons.play_arrow),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green)),
              onPressed: () async {
                await startApplication(app.id);
              },
            ),
            SizedBox(
              width: 5,
            ),
            ElevatedButton(
              child: Icon(Icons.delete_forever),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red)),
              onPressed: () async {
                app.removing = true;
                setState(() {});
                await removeApplication(app.id);
                app.removing = false;
                app.installed = false;
                reference._update(app);
                setState(() {
                  this.app = app;
                });
              },
            ),
          ],
        ),
      );
    } else {
      return ElevatedButton(
        child: Icon(Icons.arrow_downward),
        onPressed: () async {
          app.installing = true;
          setState(() {});
          await installApplication(app.id);
          app.installing = false;
          app.installed = true;
          reference._update(app);
          setState(() {
            this.app = app;
          });
        },
      );
    }
  }
}
