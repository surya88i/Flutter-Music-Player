import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class NoMusicFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
          appBar: AppBar(
            title: Text("Music player"),
            automaticallyImplyLeading: false,
          ),
          body: new Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      "assets/sad.png",
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Sorry ",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Text(
                    " No music found!!",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: RaisedButton.icon(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      elevation: 6.0,
                      label: Text("Exit"),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Future<bool> _onWillPop() {
    return SystemNavigator.pop();
  }
}
