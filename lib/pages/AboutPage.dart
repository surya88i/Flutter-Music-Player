import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          SizedBox(height: 40),
          Center(
            child: Container(
              width: 150,
              height: 150,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Card(
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Hero(
                          tag:'music',
                          child: CircleAvatar(
                          radius: 100,
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage('assets/music player.png')),
                    )),
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
              child: Text("Music Player",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Bitter",
                      fontWeight: FontWeight.w600))),
          SizedBox(height: 10),
          Center(
              child: Text("Version:1.0.0",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Bitter",
                      fontWeight: FontWeight.w600))),
          SizedBox(height: 10),
          Divider(),
          Card(
            child: ExpansionTile(
              leading: Icon(Icons.featured_play_list),
              title: Text('Features',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Bitter",
                      fontWeight: FontWeight.w600)),
                      
              children: [
                ListTile(
                  title:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max, children: <Widget>[
                    Text(
                    """Play local songs \n\n Beautiful Home screen \n\n Beautiful Now Playing \n\n Sqflite database support \n\n Search songs \n\n Songs suggestions \n\n Top tracks \n\n Recent songs \n\n Random song \n\n Album view \n\n Artist view \n\n Playlist \n\n Add to favourite \n\n Shuffle \n\n Playing queue \n\n Play/pause \n\n Next/prev \n\n Theme(dark/light) \n\n Animations \n\n Play from SD card \n\n landscape mode supported \n\n""",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        fontSize: 16,
                        
                        fontFamily: "Bitter",
                        fontWeight: FontWeight.w600),  
                    ),
                  ]),
                )
              ],
            ),
          ),
          Card(
            child: ExpansionTile(
              leading: Icon(Icons.contact_mail),
              title: Text("Contact",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Bitter",
                      fontWeight: FontWeight.w600)),
              children: [
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text("swarajya888@gmail.com",style:TextStyle(
                      fontSize: 16,
                      fontFamily: "Bitter",
                      fontWeight: FontWeight.w600)),
                ),
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text("Pune",style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Bitter",
                      fontWeight: FontWeight.w600)),
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text("+918668796251",style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Bitter",
                      fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
          Card(
            child: ExpansionTile(
              leading: Icon(Icons.info),
              title: Text("About",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Bitter",
                      fontWeight: FontWeight.w600)),
              expandedAlignment: Alignment.centerLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        """Flutter is an open source framework to create high quality, high performance mobile applications across mobile operating systems - Android and iOS. It provides a simple, powerful, efficient and easy to understand SDK to write mobile application in Google’s own language, Dart. This tutorial walks through the basics of Flutter framework, installation of Flutter SDK, setting up Android Studio to develop Flutter based application, architecture of Flutter framework and developing all type of mobile applications using Flutter framework.""",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Bitter",
                          fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
