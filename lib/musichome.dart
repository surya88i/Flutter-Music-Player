import 'dart:async';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music/database/database_client.dart';
import 'package:music/pages/DataSearch.dart';
import 'package:music/pages/NowPlaying.dart';
import 'package:music/util/lastplay.dart';
import 'package:music/views/album.dart';
import 'package:music/views/artists.dart';
import 'package:music/views/home.dart';
import 'package:music/views/playlists.dart';
import 'package:music/views/songs.dart';

class MusicHome extends StatefulWidget {
  final bottomItems = [
    new BottomItem("Home", Icons.home),
    new BottomItem("Albums", Icons.album),
    new BottomItem("Songs", Icons.music_note),
    new BottomItem("Artists", Icons.person),
    new BottomItem("PlayList", Icons.playlist_add_check),
  ];
  @override
  State<StatefulWidget> createState() {
    return new _MusicState();
  }
}

class _MusicState extends State<MusicHome> {
  int _selectedDrawerIndex = 0;
  List<Song> songs;
  String title = "Music player";
  DatabaseClient db;
  bool isLoading = true;
  Song last;
  Color color = Colors.deepPurple;
 
  getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new Home(db);
      case 1:
        return new Album(db);
      case 2:
        return new Songs(db);
      case 3:
        return new Artists(db);
      case 4:
        return new PlayList(db,_selectedDrawerIndex);
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    getDrawerItemWidget(_selectedDrawerIndex);
    title = widget.bottomItems[index].title;
  }

  @override
  void initState() {
    super.initState();
    getLast();
  }

  @override
  void dispose(){
    super.dispose();
  }

  void getLast() async {
    db = new DatabaseClient();
    await db.create();
    last = await db.fetchLastSong();
    songs = await db.fetchSongs();
    setState(() {
      songs = songs;
      isLoading = false;
    });
  }

  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    var bottomOptions = <BottomNavigationBarItem>[];
    for (var i = 0; i < widget.bottomItems.length; i++) {
      var d = widget.bottomItems[i];
      bottomOptions.add(
        new BottomNavigationBarItem(
          icon: new Icon(
            d.icon,
          ),
          label: d.title,
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
    return new WillPopScope(
      child: new Scaffold(
        key: scaffoldState,
        appBar: _selectedDrawerIndex == 0
            ? null
            : new AppBar(
              
                title: new Text(title),
                actions: <Widget>[
                  new IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          showSearch(
                              context: context,
                              delegate: DataSearch(db, songs));
                        });
                      }),
                     
                ],
              ),
             
        floatingActionButton: new FloatingActionButton(
            child: new Icon(Icons.play_circle_filled),
            splashColor: Colors.white,
            tooltip: "Play",
            onPressed: () async{
                Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (context) {
                if (MyQueue.songs == null) {
                  List<Song> list = new List();
                  list.add(last);
                  MyQueue.songs = list;
                  return new NowPlaying(db, list, 0,0);
                } else{
                  return new NowPlaying(db, MyQueue.songs, MyQueue.index,1);
              }}));
            }),
            
        body: isLoading
            ? new Center(
                child: new CircularProgressIndicator(),
              )
            : getDrawerItemWidget(_selectedDrawerIndex),
        bottomNavigationBar: new BottomNavigationBar(
          items: bottomOptions,
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFF333945),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.shifting,
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Color(0xFF333945)),
          onTap: (index) => _onSelectItem(index),
          currentIndex: _selectedDrawerIndex,
        ),
      ),
      onWillPop: _onWillPop,
    );
  }

  Future<bool> _onWillPop() {
    if (_selectedDrawerIndex != 0) {
      setState(() {
        _selectedDrawerIndex = 0;
      });
    }
    return showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('music player will be stopped..'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  'No',
                ),
              ),
              new FlatButton(
                onPressed: () {
                  MyQueue.player.stop();
                  SystemNavigator.pop();
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class BottomItem {
  String title;
  IconData icon;
  BottomItem(this.title, this.icon);
}
