import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'editor.dart';
import 'item.dart';

class Menu extends StatefulWidget{
  @override
  _Menu createState()=> _Menu();
}

class _Menu extends State<Menu>{
  List<Item> _notes;
  int _genKey = -1;

  @override
  initState() {
    super.initState();
    _notes = List();
    _init();
  }

  _init() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    _genKey = pref.getInt('_genKey') ?? -1;
    List<String> listItems = pref.getStringList('listItems') ?? List();
    if(listItems.length != 0) {
      listItems.forEach((item){
        _notes.add(Item(int.parse(item)));
      });
      setState(() {});
    }
  }

  _onReorder(int oldIndex, int newIndex) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (oldIndex < newIndex){newIndex -= 1;}
    Future.delayed(Duration(milliseconds: 100), (){
      final Widget item = _notes.removeAt(oldIndex);
      _notes.insert(newIndex, item);
      setState((){});
      List<String> list = List();
      _notes.forEach((item){
        list.add(item.getKey().toString());
      });
      pref.setStringList('listItems', list);
    });
  }

  removeItem(Item item) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> list = pref.getStringList('listItems') ?? List();
    list.remove(item.getKey().toString());
    pref.setStringList('listItems', list);
    _notes.remove(item);
    setState((){});
  }

  _goToEditor(){
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation, secAnimation){
              return Editor(_genKey);
            },
            transitionsBuilder: (context, animation, secAnimation, child){
              return SlideTransition(
                position: Tween(
                    begin: Offset(10.0, 0.0),
                    end: Offset.zero
                ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.fastOutSlowIn
                )),
                child: SlideTransition(
                  position: Tween(
                      begin: Offset.zero,
                      end: Offset(10.0, 0.0)
                  ).animate(secAnimation),
                  child: child,
                ),
              );
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(245, 245, 245, 1.0),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color.fromRGBO(245, 245, 245, 1.0),
          body: MenuInheritedWidget(
            this,
            ReorderableListView(
              children: _notes,
              onReorder: _onReorder,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: SizedBox(
            width: 60.0,
            child: FloatingActionButton(
              heroTag: 'plus',
              elevation: 1.0,
              backgroundColor: Color.fromRGBO(251, 190, 4, 1.0),
              onPressed: () async{
                _genKey++;
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.setInt('_genKey', _genKey);
                List<String> list = pref.getStringList('listItems') ?? List();
                list.add(_genKey.toString());
                pref.setStringList('listItems', list);
                _goToEditor();
              },
              child: Icon(Icons.add, color: Colors.black54, size: 30.0),
            ),
          ),
        ),
      ),
    );
  }
}


class MenuInheritedWidget extends InheritedWidget{
  final _Menu state;

  MenuInheritedWidget(this.state, child): super(child: child);

  static MenuInheritedWidget of (BuildContext context){
    return context.inheritFromWidgetOfExactType(MenuInheritedWidget);
  }

  @override
  bool updateShouldNotify(MenuInheritedWidget old) => false;
}
