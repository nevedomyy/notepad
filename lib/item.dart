import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu.dart';
import 'editor.dart';
import 'storage.dart';

class Item extends StatefulWidget{
  Key key;
  int _key;
  Item(int key){
    this.key = Key(key.toString());
    this._key = key;
  }
  int getKey() => _key;
  @override
  ItemState createState() => ItemState(_key, this);
}

class ItemState extends State<Item> {
  int _key;
  Item _item;
  Storage _storage;
  String _text = '';
  String _textHeader = '';
  final List<Color> _color = [
    Colors.white,
    Color.fromRGBO(218, 236, 248, 1),
    Color.fromRGBO(219, 247, 231, 1),
    Color.fromRGBO(239, 239, 222, 1),
    Color.fromRGBO(254, 242, 224, 1),
    Color.fromRGBO(252, 231, 228, 1),
    Color.fromRGBO(241, 232, 247, 1),
  ];
  int _colorNumber = 0;
  bool _delItem = false;
  double _width;

  ItemState(int key, Item item){
    this._key = key;
    this._item = item;
  }

  @override
  initState(){
    super.initState();
    _storage = Storage(_key);
    _readFile();
    _getHeaderAndColor();
  }

  _readFile() async{
    _storage.readFile().then((text){
      setState(() {
        _text = text;
      });
    });
  }

  _getHeaderAndColor() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    _textHeader = pref.getString('_textHeader-$_key') ?? '';
    _colorNumber = pref.getInt('_colorNumber-$_key') ?? 0;
    setState(() {});
  }

  _saveColor() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt('_colorNumber-$_key', _colorNumber);
  }

  _removeItem(){
    MenuInheritedWidget.of(context).state.removeItem(_item);
  }

  _goToEditor(){
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation, secAnimation){
              return Editor(_key);
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

  Widget w(){
    if(_delItem){
      return Stack(
        alignment: AlignmentDirectional.topCenter,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
                'Delete ?'
            ),
          ),
          Positioned(
            bottom: 0.0,
            child: Row(
              children: <Widget>[
                FlatButton(
                  child: Text('YES', style: TextStyle(color: Color.fromRGBO(235, 65, 52, 1.0), fontSize: 18.0, fontWeight: FontWeight.normal)),
                  onPressed: (){
                    _removeItem();
                    _storage.deleteFile();
                  },
                ),
                FlatButton(
                  child: Text('NO', style: TextStyle(color: Color.fromRGBO(52, 170, 81, 1.0), fontSize: 18.0, fontWeight: FontWeight.normal)),
                  onPressed: (){
                    setState(() {
                      _delItem = !_delItem;
                    });
                  },
                )
              ],
            ),
          )
        ],
      );
    }
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0, right: 18.0, left: 18.0, bottom: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: _width-40.0-50.0-30.0,
                child: Text(
                  _textHeader,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
              Divider(),
              Container(
                width: _width-40.0,
                child: Text(
                  _text,
                  overflow: TextOverflow.fade,
                  softWrap: true,
                  maxLines: 3,
                )
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: (){_goToEditor();}
        ),
        Positioned(
          right: 0.0,
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: (){
                  _colorNumber++;
                  if (_colorNumber == 7) _colorNumber = 0;
                  _saveColor();
                  setState(() {});
                },
                padding: EdgeInsets.all(0.0),
                iconSize: 24.0,
                icon: Icon(Icons.radio_button_unchecked, color: Color.fromRGBO(52, 170, 81, 1.0)),
              ),
              IconButton(
                onPressed: (){
                  setState(() {
                    _delItem = !_delItem;
                  });
                },
                padding: EdgeInsets.all(0.0),
                iconSize: 24.0,
                icon: Icon(Icons.close, color: Color.fromRGBO(235, 65, 52, 1.0)),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width - 50.0;
    return Card(
      elevation: 1.0,
      color: _color[_colorNumber],
      margin: EdgeInsets.all(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0.0))),
      child: SizedBox(
          width: _width,
          height: 130.0,
          child: w()
      ),
    );
  }
}