import 'dart:io';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:music/database/database_client.dart';
import 'package:music/pages/NowPlaying.dart';
import 'package:music/util/lastplay.dart';

class DataSearch extends SearchDelegate{
  final DatabaseClient db;
  final List<Song> songs;
  DataSearch(this.db,this.songs);

  @override
  String get searchFieldLabel =>'Search song,artist or album';
  @override
  TextStyle get searchFieldStyle => TextStyle(fontSize: 16,fontFamily: "Bitter");

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: Colors.white,
      cursorColor: Color(0xFF333945),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
      return [
        IconButton(icon: Icon(Icons.highlight_off,color: Color(0xFF333945)), onPressed: (){
          query='';
          showSuggestions(context);
        })
      ];
    }
  
    @override
    Widget buildLeading(BuildContext context) {
      return IconButton(icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation), 
        color: Color(0xFF333945),
        onPressed: (){
          Navigator.pop(context);
        });
    }
   
    @override
    Widget buildResults(BuildContext context) {
      
    final suggestionList=query.isEmpty?songs:songs
                    .where((song) =>song.title.toLowerCase().startsWith(query) || song.artist.toLowerCase().startsWith(query) ||
                    song.album.toLowerCase().startsWith(query.toUpperCase()))
                    .toList();
      return suggestionList.isEmpty?Center(child: Text("No Music Found $query",style:TextStyle(fontSize: 20,fontFamily: "Bitter"))):ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context,index){
          return ListTile(
                  leading: new Hero(
                    tag: suggestionList[index].id,
                    child: CircleAvatar(backgroundImage:FileImage(File.fromUri(Uri.parse(suggestionList[index].albumArt)))),
                  ),
                  title: new Text(suggestionList[index].title,
                      maxLines: 1, style: new TextStyle(fontSize: 18.0)),
                  subtitle: new Text(
                    suggestionList[index].artist,
                    maxLines: 1,
                    style: new TextStyle(fontSize: 12.0),
                  ),
                  trailing: new Text(
                      new Duration(milliseconds: suggestionList[index].duration)
                          .toString()
                          .split('.')
                          .first,
                      style: new TextStyle(fontSize: 12.0)),
                  onTap: () {
                    MyQueue.songs = suggestionList;
                    Navigator.of(context).pop();
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) =>
                        new NowPlaying(db,suggestionList,index,0)));
                  },
                );
      },
    );
  }
  
 
    @override
    Widget buildSuggestions(BuildContext context) {
    
    final suggestionList=query.isEmpty?songs:songs
                    .where((song) =>song.title.toLowerCase().startsWith(query) || song.artist.toLowerCase().startsWith(query) ||
                    song.album.toLowerCase().startsWith(query))
                    .toList();
      return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context,index){
          return ListTile(
                  leading: new Hero(
                    tag: suggestionList[index].id,
                    child: CircleAvatar(backgroundImage:FileImage(File.fromUri(Uri.parse(suggestionList[index].albumArt)))),
                  ),
                  title: new Text(
                    suggestionList[index].title,
                    
                    style: new TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                  subtitle: new Text(
                    suggestionList[index].artist,
                    maxLines: 1,
                    style: new TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  trailing: new Text(
                      new Duration(milliseconds: suggestionList[index].duration)
                          .toString()
                          .split('.')
                          .first,
                      style: new TextStyle(fontSize: 12.0, color: Colors.grey)),
                  onTap: () {
                    showResults(context);
                    MyQueue.songs = suggestionList;
                    Navigator.of(context).pop();
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) =>
                        new NowPlaying(db,suggestionList,index,0)));
                  },
                );
      },
    );
  }
}