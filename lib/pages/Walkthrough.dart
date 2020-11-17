import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:music/database/database_client.dart';
import 'package:music/musichome.dart';
import 'package:music/pages/NoMusicFound.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SplashState();
  }
}

class SplashState extends State<SplashScreen>{
  var db;
  var isLoading = false;
  
  @override
  void initState() { 
    super.initState();
    loadSongs();
  }
  @override
  void dispose() { 
    super.dispose();
  }
 

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: SafeArea(
          child: new Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset("assets/kids.gif", 
                    height: 300, width: 300,
                      fit: BoxFit.cover),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 5),
                  child: Text(
                    "Music player",
                    style: TextStyle(
                      color: Color(0xFF333945),
                      fontSize: 40,
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: isLoading ? CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ) : Container(),
                ),
                ),
                Text("Setting up...",
                    style: TextStyle(color: Color(0xFF333945), fontSize: 20))
               
              ],
            ),
          ),
        ));
  }

  loadSongs() async {
    setState(() {
      isLoading = true;
    });
    var db = new DatabaseClient();
    await db.create();
    if (await db.alreadyLoaded()) {
      Navigator.of(context).pop();
      Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
        return new MusicHome();
      }));
    } else {
      var songs;
      try {
        songs = await MusicFinder.allSongs();
        List<Song> list = new List.from(songs);

        if (list == null || list.length == 0) {
         // print("List-> $list");
          Navigator.of(context).pop(true);
          Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
            return new NoMusicFound();
          }));
        }
        else {
          for (Song song in list)
            db.updateInsertSongs(song);
          if (!mounted) {
            return;
          }
          Navigator.of(context).pop(true);
          Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
            return new MusicHome();
          }));
        }
      } catch (e) {
        print("failed to get songs");
      }
    }
  }
}
