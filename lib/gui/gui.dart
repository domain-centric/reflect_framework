import 'package:flutter/material.dart';
import 'package:flutter_shine/flutter_shine.dart';
import 'package:provider/provider.dart';

import '../core/action_method_info.dart';
import '../core/annotations.dart' as reflectAnnotation;
import '../core/reflect_framework.dart';
import '../core/service_class_info.dart';
import '../generated.dart';
import '../gui/gui_tab.dart' as reflectTabs;
import '../localization/localizations.dart';

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
      ChangeNotifierProvider(create: (_) => reflectTabs.Tabs()),
      Provider(create: (_) => ReflectApplicationInfo()),
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
      title: Provider.of<ReflectApplicationInfo>(context).name,
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
    reflectTabs.Tabs tabs = Provider.of<reflectTabs.Tabs>(context);
    String appTitle = Provider.of<ReflectApplicationInfo>(context).name;
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
    reflectTabs.Tabs tabs = Provider.of<reflectTabs.Tabs>(context);
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
    reflectTabs.Tabs tabs = Provider.of<reflectTabs.Tabs>(context);
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
                    child: Text(
                        '${Provider.of<reflectTabs.Tabs>(context).length}')))));
  }

  @reflectAnnotation.Translation(keySuffix: 'title', englishText: 'Tabs:')
  @reflectAnnotation.Translation(
      keySuffix: 'buttonCloseOthers', englishText: 'Close others')
  @reflectAnnotation.Translation(
      keySuffix: 'buttonCloseAll', englishText: 'Close all')
  showTabSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          var tabs = Provider.of<reflectTabs.Tabs>(context);
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
                ElevatedButton(
                    child: Text(AppLocalizations.of(context).closeOthers),
                    onPressed: () {
                      tabs.closeOthers(tabs.selected);
                      Navigator.pop(context);
                    }),
              if (tabs.length >= 2)
                ElevatedButton(
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
    if (actionMethodInfo is StartWithoutParameter) {
      actionMethodInfo.start(context);
      if (isDrawerMenu) {
        Navigator.pop(context); //Hide Drawer
      }
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
    List<ServiceClassInfo> serviceClassInfo =
        Provider.of<ReflectApplicationInfo>(context).serviceClassInfos;

    List<Widget> children = [];

    if (isDrawerMenu) {
      children.add(createDrawerHeader(context));
    }

    for (ServiceClassInfo serviceObjectClassInfo in serviceClassInfo) {
      children.add(createServiceObjectTile(serviceObjectClassInfo));
      for (ActionMethodInfo actionMethodInfo
          in serviceObjectClassInfo.actionMethodInfosForMainMenu) {
        children.add(createActionMethodTile(actionMethodInfo, context));
      }
    }
    return children;
  }

  Container createDrawerHeader(BuildContext context) {
    return Container(
      height: 88.0, //TODO get from AppBar
      child: DrawerHeader(
        child: Text(Provider.of<ReflectApplicationInfo>(context).name,
            style: Theme.of(context).primaryTextTheme.headline6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Container createServiceObjectTile(ServiceClassInfo serviceClassInfo) {
    return Container(
        height: 35,
        child: ListTile(
            title: Text(serviceClassInfo.name.toUpperCase(),
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
            actionMethodInfo.name,
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
    final reflectTabs.Tabs tabs = Provider.of<reflectTabs.Tabs>(context);
    if (tabs.isEmpty) {
      return ApplicationTitleTab();
    } else {
      return IndexedStack(
        children: [
          for (reflectTabs.Tab tab in tabs) tab,
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
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.2,
            vertical: MediaQuery.of(context).size.height * 0.2),
        child: ApplicationTitleWidget());
  }
}

class ApplicationTitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Provider.of<ReflectApplicationInfo>(context).titleImage == null) {
      return ApplicationTitleText();
    } else {
      return ApplicationTitleImage();
    }
  }
}

class ApplicationTitleImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(Provider.of<ReflectApplicationInfo>(context).titleImage);
  }
}

class ApplicationTitleText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
        fit: BoxFit.fitWidth,
        child: FlutterShine(
          config: Config(offset: 0.05),
          builder: (BuildContext context, ShineShadow shineShadow) {
            return Opacity(
                opacity: 0.7,
                child: Text(
                  '${Provider.of<ReflectApplicationInfo>(context).name}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      shadows: shineShadow.shadows),
                ));
          },
        ));
  }
}
