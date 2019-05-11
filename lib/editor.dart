import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu.dart';
import 'storage.dart';

class Editor extends StatefulWidget{
  final int _key;
  Editor(this._key);
  @override
  _Editor createState()=> _Editor(_key);
}

class _Editor extends State<Editor> with WidgetsBindingObserver{
  final int _key;
  Storage _storage;
  TextEditingController _textController;
  TextEditingController _textControllerHeader;

  _Editor(this._key);

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _storage = Storage(_key);
    _textController = TextEditingController();
    _textControllerHeader = TextEditingController();
    _readFile();
    _getHeader();
  }

  _readFile() async{
    _storage.readFile().then((text){
      setState(() {
        _textController.text = text;
      });
    });
  }

  _getHeader() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    _textControllerHeader.text = pref.getString('_textHeader-$_key') ?? '';
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.paused) _save();
  }

  @override
  dispose(){
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _textControllerHeader.dispose();
  }

  _save() async{
    _storage.writeFile(_textController.text);
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('_textHeader-$_key', _textControllerHeader.text);
  }

  _goToMenu(){
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation, secAnimation){
              return Menu();
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
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              child: ScrollConfiguration(
                behavior: Behavior(),
                child: SingleChildScrollView(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            TextField(
                              controller: _textControllerHeader,
                              cursorColor: Color.fromRGBO(251, 190, 4, 1.0),
                              style: TextStyle(color: Colors.black87, fontSize: 25.0),
                              decoration: InputDecoration.collapsed(
                                  hintText: 'Header'
                              ),
                            ),
                            SizedBox(height: 20.0,),
                            TextField(
                              controller: _textController,
                              cursorColor: Color.fromRGBO(251, 190, 4, 1.0),
                              style: TextStyle(color: Colors.black87, fontSize: 18.0),
                              decoration: InputDecoration.collapsed(hintText: null),
                              keyboardType: TextInputType.multiline,
                              maxLength: null,
                              maxLines: null,
                              autofocus: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: SizedBox(
            width: 60.0,
            child: FloatingActionButton(
              heroTag: 'back',
              elevation: 1.0,
              backgroundColor: Color.fromRGBO(251, 190, 4, 1.0),
              onPressed: (){
                _save();
                _goToMenu();
              },
              child: Icon(Icons.arrow_back, color: Colors.black54, size: 30.0),
            ),
          ),
        ),
      ),
    );
  }
}

class Behavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection){
    return child;
  }
}