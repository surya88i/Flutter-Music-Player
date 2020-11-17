import 'package:flutter/material.dart';
import 'package:music/database/database_client.dart';
import 'package:music/pages/list_songs.dart';


class PlayList extends StatefulWidget {
  final DatabaseClient db;
  final int selectedDrawerIndex;
  /* final List<Song> songs; */
  PlayList(this.db,this.selectedDrawerIndex);

  @override
  State<StatefulWidget> createState() {
    return new _StatePlaylist();
  }
}

class _StatePlaylist extends State<PlayList> {
  var mode;
  var selected;
  int selectedDrawerIndex;

  @override
  void initState() {
    mode = 1;
    selected = 1;
    selectedDrawerIndex=widget.selectedDrawerIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: selectedDrawerIndex==4?null:AppBar(
        title:Text("PlayList"),
        actions: [
          /* IconButton(icon: Icon(Icons.search), onPressed: (){
            setState(() {
              showSearch(context: context, delegate: DataSearch(widget.db, widget.songs));
            });
          }), */
        ],
      ),
      body: portrait(),
    );
  }

  Widget portrait() {
    return new ListView(
      children: <Widget>[
        new ListTile(
          leading: new Icon(Icons.call_received,
              color: Theme.of(context).accentColor),
          title: new Text("Recently played"),
          subtitle: new Text("songs"),
          onTap: () {
            Navigator.of(context)
                .push(new MaterialPageRoute(builder: (context) {
              return new ListSongs(widget.db, 1);
            }));
          },
        ),
        new Divider(),
        new ListTile(
          leading:
              new Icon(Icons.show_chart, color: Theme.of(context).accentColor),
          title: new Text("Top tracks"),
          subtitle: new Text("songs"),
          onTap: () {
            Navigator.of(context)
                .push(new MaterialPageRoute(builder: (context) {
              return new ListSongs(widget.db, 2);
            }));
          },
        ),
        new Divider(),
        new ListTile(
          leading:
              new Icon(Icons.favorite, color: Theme.of(context).accentColor),
          title: new Text("Favourites"),
          subtitle: new Text("Songs"),
          onTap: () {
            Navigator.of(context)
                .push(new MaterialPageRoute(builder: (context) {
              return new ListSongs(widget.db, 3);
            }));
          },
        ),
        new Divider(),
      ],
    );
  }
}
