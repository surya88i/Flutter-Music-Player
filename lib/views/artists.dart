import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:music/database/database_client.dart';
import 'package:music/pages/card_detail.dart';

class Artists extends StatefulWidget {
  final DatabaseClient db;
  Artists(this.db);
  @override
  State<StatefulWidget> createState() {
    return new _StateArtist();
  }
}

class _StateArtist extends State<Artists> {
  List<Song> songs;
  var f;
  bool isLoading = true;

  @override
  initState() {
    super.initState();
    initArtists();
  }

  void initArtists() async {
    songs = await widget.db.fetchArtist();
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
              Hero(
                tag: song.artist,
                child: AspectRatio(
                  aspectRatio: 18 / 16,
                  child: new Image.asset(
                    "assets/artist.png",
                    height: 120.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4.0, 8.0, 0.0, 0.0),
                  child: Center(
                    child: Text(
                      song.artist,
                      textAlign: TextAlign.center,
                      style: new TextStyle(fontSize: 18.0),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (context) {
                return new CardDetail(widget.db, song, 1);
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
            ? new Center(child: new CircularProgressIndicator())
            : new GridView.count(
                crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
                children: _buildGridCards(context),
                padding: EdgeInsets.all(2.0),
                childAspectRatio: 8.0 / 10.0,
              ));
  }
  
}
