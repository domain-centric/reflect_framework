import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reflect_framework/reflect_gui_tab.dart' as ReflectTabs;
import 'package:reflect_framework/reflect_gui_tab.dart';
import 'package:reflect_framework/reflect_localizations.dart';
import 'package:reflect_framework/reflect_meta_temp.dart';
import 'package:reflect_framework/reflect_application.dart';

const kTabletBreakpoint = 720.0;
const kDesktopBreakpoint = 1200.0;
const kSideMenuWidth = 250.0;

abstract class ReflectGuiApplication extends StatelessWidget
    implements ReflectApplication {
  ReflectGuiApplication({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => Tabs()),
      Provider(create: (_) => ReflectFramework()),
    ], child: ReflectMaterialApp(reflectGuiApplication: this));
  }

  /// Can be overridden so you can style your application light theme
  ThemeData get lightTheme {
    return ThemeData.light()
        .copyWith(visualDensity: VisualDensity.adaptivePlatformDensity);
  }

  /// Can be overridden so you can style your application dark theme
  ThemeData get darkTheme {
    return ThemeData.dark()
        .copyWith(visualDensity: VisualDensity.adaptivePlatformDensity);
  }
}

class ReflectMaterialApp extends StatelessWidget {
  final ReflectGuiApplication reflectGuiApplication;

  ReflectMaterialApp({Key key, @required this.reflectGuiApplication})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: Provider.of<ReflectFramework>(context)
          .reflection
          .applicationInfo
          .title,
      theme: reflectGuiApplication.lightTheme,
      darkTheme: reflectGuiApplication.darkTheme,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget implements ReflectApplication {
  Home({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, dimens) {
      if (dimens.maxWidth >= kDesktopBreakpoint) {
        return WideScaffold();
      } else {
        return NarrowScaffold();
      }
    });
  }
}

class ApplicationTitle extends StatelessWidget {
  ApplicationTitle({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Tabs tabs = Provider.of<Tabs>(context);
    String appTitle =
        Provider.of<ReflectFramework>(context).reflection.applicationInfo.title;
    return LayoutBuilder(builder: (_, dimens) {
      if (tabs.isEmpty) {
        return Text(appTitle);
      } else if (dimens.maxWidth < kTabletBreakpoint) {
        return Text(tabs.selected.title);
      } else {
        return Text('$appTitle - ${tabs.selected.title}');
      }
    });
  }
}

class NarrowScaffold extends StatelessWidget {
  NarrowScaffold({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Tabs tabs = Provider.of<Tabs>(context);
    return Scaffold(
        appBar: AppBar(
          title: ApplicationTitle(),
          //Text(ReflectFramework().reflection.applicationInfo.title),
          actions: [
            if (tabs.length > 1) TabsIcon(),
          ],
        ),
        drawer: Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the drawer if there isn't enough vertical
            // space to fit everything.
            child: MainMenu(
          isDrawerMenu: true,
        )),
        body: Container(
          constraints: BoxConstraints.expand(),
          child: TabContainer(),
        ));
  }
}

class WideScaffold extends StatelessWidget {
  WideScaffold({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Tabs tabs = Provider.of<Tabs>(context);
    return Scaffold(
        appBar: AppBar(
          title: ApplicationTitle(),
          //Text(ReflectFramework().reflection.applicationInfo.title),
          leading: InkWell(
            onTap: () {}, //TODO add
            child: Icon(
              Icons.menu, // add custom icons also
            ),
          ),
          actions: [
            if (tabs.length > 1) TabsIcon(),
          ],
        ),
        body: Center(
          child: Row(
            children: [
              Container(
                width: kSideMenuWidth,
                child: MainMenu(
                  isDrawerMenu: false,
                ),
              ),
              VerticalDivider(thickness: 3),
              Expanded(
                child: TabContainer(),
              ),
            ],
          ),
        ));
  }
}

class TabsIcon extends StatelessWidget {
  TabsIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          showTabSelectionDialog(context);
        },
        child: AspectRatio(
            aspectRatio: 1,
            child: Container(
                margin: const EdgeInsets.all(13.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        color:
                            Theme.of(context).primaryTextTheme.bodyText1.color,
                        width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Align(
                    alignment: Alignment.center,
                    child: Text('${Provider.of<Tabs>(context).length}')))));
  }

  showTabSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          var tabs = Provider.of<Tabs>(context);
          return AlertDialog(
            title: Text(AppLocalizations.of(context).tabs),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tabs.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    selected: tabs.selected == tabs[index],
                    title: Text(tabs[index].title),
                    leading: Icon(tabs[index].iconData),
                    trailing: InkWell(
                      child: Icon(Icons.close),
                      onTap: () {
                        tabs.close(tabs[index]);
                        Navigator.pop(context);
                      },
                    ),
                    onTap: () {
                      tabs.selected = tabs[index];
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            actions: [
              if (tabs.length >= 3)
                RaisedButton(
                    child: Text(AppLocalizations.of(context).closeOthers),
                    onPressed: () {
                      tabs.closeOthers(tabs.selected);
                      Navigator.pop(context);
                    }),
              if (tabs.length >= 2)
                RaisedButton(
                    child: Text(AppLocalizations.of(context).closeAll),
                    onPressed: () {
                      tabs.closeAll();
                      Navigator.pop(context);
                    })
            ],
          );
        });
  }
}

class MainMenu extends StatelessWidget {
  final bool isDrawerMenu;

  const MainMenu({Key key, this.isDrawerMenu}) : super(key: key);

  onTab(BuildContext context, ActionMethodInfo actionMethodInfo) {
    actionMethodInfo.execute(context, actionMethodInfo.title);
    if (isDrawerMenu) {
      Navigator.pop(context); //Hide Drawer
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: createChildren(context),
    );
  }

  List<Widget> createChildren(BuildContext context) {
    Reflection reflection = Provider.of<ReflectFramework>(context).reflection;

    List<Widget> children = List();

    if (isDrawerMenu) {
      children.add(createDrawerHeader(reflection, context));
    }

    for (ServiceObjectInfo serviceObjectInfo in reflection.serviveObjectInfos) {
      children.add(createServiceObjectTile(serviceObjectInfo));
      for (ActionMethodInfo actionMethodInfo
          in serviceObjectInfo.mainMenuItems) {
        children.add(createActionMethodTile(actionMethodInfo, context));
      }
    }
    return children;
  }

  Container createDrawerHeader(Reflection reflection, BuildContext context) {
    return Container(
      height: 88.0, //TODO get from AppBar
      child: DrawerHeader(
        child: Text(reflection.applicationInfo.title,
            style: Theme.of(context).primaryTextTheme.headline6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Container createServiceObjectTile(ServiceObjectInfo serviceObjectInfo) {
    return Container(
        height: 35,
        child: ListTile(
            title: Text(serviceObjectInfo.title.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold))));
  }

  ListTile createActionMethodTile(
      ActionMethodInfo actionMethodInfo, BuildContext context) {
    return ListTile(
      leading: Icon(actionMethodInfo.icon),
      //TODO of actionMethodInfo.icon=null then
      // Container(
      //   width: 18,
      //   height: 18,
      // ),
      title: Transform(
          //remove extra space between leading and title
          transform: Matrix4.translationValues(-20, 0.0, 0.0),
          child: Text(
            actionMethodInfo.title,
          )),
      onTap: () => {onTab(context, actionMethodInfo)},
    );
  }
}

class TabContainer extends StatelessWidget {
  TabContainer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReflectTabs.Tabs tabs = Provider.of<ReflectTabs.Tabs>(context);
    if (tabs.isEmpty) {
      return ApplicationTitleTab();
    } else {
      return IndexedStack(
        children: [
          for (ReflectTabs.Tab tab in tabs) tab,
        ],
        index: tabs.selectedIndex,
      );
    }
  }
}

class ApplicationTitleTab extends StatelessWidget {
  ApplicationTitleTab({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ApplicationInfo applicationInfo =
        Provider.of<ReflectFramework>(context).reflection.applicationInfo;
    var titleImagePath = applicationInfo.titleImagePath;
    if (titleImagePath != null) {
      return Center(child: Image.asset(titleImagePath));
    } else {
      return Center(
          child: Text(
        '${applicationInfo.title}',
        style: Theme.of(context).textTheme.headline3,
      ));
    }
  }
}
