import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:music/database/database_client.dart';
import 'package:music/pages/card_detail.dart';
import 'package:music/util/utility.dart';

class Album extends StatefulWidget {
  final DatabaseClient db;
  Album(this.db);
  @override
  State<StatefulWidget> createState() {
    return new _StateAlbum();
  }
}

class _StateAlbum extends State<Album> {
  List<Song> songs;
  var f;
  bool isLoading = true;
  @override
  initState() {
    super.initState();
    initAlbum();
  }

  void initAlbum() async {
    // songs=await widget.db.fetchSongs();
    songs = await widget.db.fetchAlbum();
    setState(() {
      isLoading = false;
    });
  }

  List<Card> _buildGridCards(BuildContext context) {
    return songs.map((song) {
      return Card(
        child: new InkResponse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Hero(
                tag: song.album,
                child: AspectRatio(
                  aspectRatio: 18 / 16,
                  child: getImage(song) != null
                      ? new Image.file(
                          getImage(song),
                          height: 120.0,
                          fit: BoxFit.cover,
                        )
                      : new Image.asset(
                          "assets/back.jpg",
                          height: 120.0,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  // padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                  padding: EdgeInsets.fromLTRB(4.0, 8.0, 0.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Center(
                          child: Text(
                            song.album,
                            style: new TextStyle(fontSize: 18.0),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
              Navigator.push(context, new MaterialPageRoute(builder: (context) {
              return new CardDetail(widget.db, song, 0);
              }));
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return new Container(
        child: isLoading
            ? new Center(
                child: new CircularProgressIndicator(),
              )
            : new GridView.count(
                crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
                children: _buildGridCards(context),
                padding: EdgeInsets.all(2.0),
                childAspectRatio: 8.0 / 10.0,
              ));
  }
}
