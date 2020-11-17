import 'dart:async';
import 'dart:io';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_notification/media_notification.dart';
import 'package:music/database/database_client.dart';
import 'package:music/sc_model/model.dart';
import 'package:music/util/lastplay.dart';
import 'package:music/views/playlists.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume/volume.dart';
import 'dart:math' as math;

// ignore: must_be_immutable
class NowPlaying extends StatefulWidget {
  final List<Song> songs;
  int index;
  int mode;
  final DatabaseClient db;
  NowPlaying(this.db, this.songs, this.index,this.mode);
  @override
  _NowPlayingState createState() => _NowPlayingState();
}

enum PlayerState { stopped, playing, paused }

class _NowPlayingState extends State<NowPlaying>
    with TickerProviderStateMixin {
  AudioManager audioManager;

  bool loading;
  Song song;
  bool isPlayings = false;
  Animation animation;
  AnimationController animationController;
  Duration duration=Duration();
  Duration position=Duration();
  PlayerState playerState = PlayerState.stopped;
  bool isMuted;

  int maxVol, currentVol;
  List<Song> songs;
  final saved = new Set<Song>();

  List<BoxShadow> shadowList = [
    BoxShadow(
      blurRadius: 3.0,
      color: Colors.grey[300],
      offset: Offset(3, 3),
    ),
  ];

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;
  IconData one;
  Color ones;
  double value = 0.0;
  int playerId;
  int quantity = 0;
  MusicFinder player;

  @override
  void initState() {
    super.initState();
    isMuted = false;
    initAnim();
    initPlayer();
    initPlatformState();
    MediaNotification.setListener('pause', () {
      setState((){
        playpause();
      });
    });

    MediaNotification.setListener('play', () {
      setState((){
        playpause();
      });
    });

    MediaNotification.setListener('next', () {
     setState((){
        next();
      });
    });

    MediaNotification.setListener('prev', () {
      setState((){
        prev();
      });
    });
    updatePage(widget.index);
    //widget.index++;
    animationController = AnimationController(
        vsync: this,
        animationBehavior: AnimationBehavior.preserve,
        duration: Duration(seconds: 10))..addListener(() {
          setState(() {
            
          });
        });
    animation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
        CurvedAnimation(parent: animationController.view, curve: Curves.linear));
    loading = false;
    animationController.repeat();
    initPlatformState();
  }

  initAnim(){
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
        ..addListener(() {
          setState(() {
            
          });
        });
    animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    animateColor = ColorTween(
      begin: Colors.deepOrange,
      end: Colors.deepOrangeAccent,
    ).animate(CurvedAnimation(
      parent: _animationController.view,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
  }

  animateForward() {
    _animationController.forward();
  }

  animateReverse() {
    _animationController.reverse();
  }

  Future<void> hide() async {
    try {
      await MediaNotification.hide();
      setState(() => status = 'hidden');
    } on PlatformException {}
  }

  Future<void> show(title, author) async {
    try {
      await MediaNotification.show(title: title, author: author,play: isPlayings);
      setState(() =>status = 'play');
    } on PlatformException {}
  }

  void onComplete() {
    setState(() {
      next();
    });
  }

  void initPlayer() async {
    if (player == null) {
      player = MusicFinder();
      MyQueue.player = player;
      var pref = await SharedPreferences.getInstance();
      pref.setBool("played", true);
    }
    setState(() {
       if (widget.mode == 0) {
        player.stop();
      }
      updatePage(widget.index);
      isPlayings = true;
    });
    player.setDurationHandler((d) => setState(() {
          duration = d;
        }));
    player.setPositionHandler((p) => setState(() {
          position = p;
        }));
    player.setCompletionHandler(() {
      onComplete();
      setState(() {
        position = duration;
      });
    });
    player.setErrorHandler((msg) {
      setState(() {
        playerState = PlayerState.stopped;
        player.stop();
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
    player.durationHandler.call(duration);
    player.positionHandler.call(position);
  }

  void updatePage(int index) {
    MyQueue.index = index;
    song = widget.songs[index];
    widget.index=index;
    song.timestamp = new DateTime.now().millisecondsSinceEpoch;
    if (song.count == null) {
      song.count = 0;
    } else {
      song.count++;
    }
    if (widget.db != null && song.id != 9999)
      widget.db.updateSong(song);
    isFavourite = song.isFav;
    player.play(song.uri);
    animateReverse();
    setState(() {
      isPlayings = true;
      isFavourite = song.isFav;
      status = 'play';
    });

    show(song.title, song.album);
    ScopedModel.of<SongModel>(context).updateUI(song, widget.db);

    animateReverse();
  }

  void playpause() {
    if (isPlayings) {
      player.pause();
      animateForward();
      animationController.reset();
      setState(() {
        status = 'pause';
        isPlayings = false;
        MediaNotification.show(title:song.title,author: song.album,play: isPlayings);
        //hide();
      });
    } else {
     
      player.play(song.uri);
      show(song.title, song.artist);
      animateReverse();
       animationController.repeat();
      setState(() {
        status = 'play';
        isPlayings = true;
        MediaNotification.show(title:song.title,author:song.album,play: isPlayings);
      });
    }

  }

  Future next() async {
    player.stop();
    animationController.repeat();
    setState(() {
      int i = ++widget.index;
      if (i >= widget.songs.length) {
        widget.index = 0;
        i = widget.index;
      }
      updatePage(i);
    });
  }

  Future prev() async {
    player.stop();
    animationController.repeat();
    //   int i=await  widget.db.isfav(song);
    setState(() {
      int i = --widget.index;
      if (i < 0) {
        widget.index = 0;
        i = widget.index;
      }

      updatePage(i);
    });
  }

  @override
  void dispose(){
    animationController.stop();
    _animationController.stop();
    super.dispose(); 
  }

  

  Future showBottomSheet() async {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            height: MediaQuery.of(context).size.height / 1.8,
            child: Column(
              children: <Widget>[
                SizedBox(height: 4),
                Container(
                  height: 60,
                  child: Card(
                    elevation: 10.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(width: 10),
                        Icon(
                          Icons.list,
                          size: 20,
                        ),
                        Text(
                          "Playing Queue",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        Expanded(
                            child: Text(
                          "${widget.index + 1}/${widget.songs.length} song(s)\t\t",
                          textAlign: TextAlign.right,
                        ))
                      ],
                    ),
                  ),
                ),
                Divider(),
                new Expanded(
                    child: new ListView.builder(
                  itemCount: widget.songs.length,
                  itemBuilder: (context, i) => new Column(
                    children: <Widget>[
                      new ListTile(
                        leading: CircleAvatar(
                          backgroundImage: FileImage(File.fromUri(
                              Uri.parse(widget.songs[i].albumArt))),
                        ),
                        title: new Text(widget.songs[i].title,
                            maxLines: 1, style: new TextStyle(fontSize: 18.0)),
                        subtitle: new Text(
                          widget.songs[i].artist,
                          maxLines: 1,
                          style:
                              new TextStyle(fontSize: 12.0, color: Colors.grey),
                        ),
                        trailing: song.id == widget.songs[i].id
                            ? new Icon(
                                Icons.play_circle_filled,
                                color: Colors.deepPurple,
                              )
                            : new Text(
                                (i + 1).toString(),
                                style: new TextStyle(
                                    fontSize: 12.0, color: Colors.grey),
                              ),
                        onTap: () {
                          setState(() {
                            player.stop();
                            updatePage(i);
                            Navigator.pop(context);
                          });
                        },
                      ),
                      new Divider(
                        height: 8.0,
                      ),
                    ],
                  ),
                )),
              ],
            ),
          );
        });
  }

  Future<void> initPlatformState() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  adjustQuantity(press) {
    switch (press) {
      case 'MINUS':
        setState(() {
          setVol(quantity--);
        });
        return;
      case 'PLUS':
        setState(() {
          setVol(quantity += 1);
        });
        return;
    }
  }

  updateVolumes() async {
    maxVol = await Volume.getMaxVol;
    currentVol = await Volume.getVol;
  }

  setVol(int i) async {
    await Volume.setVol(i, showVolumeUI: ShowVolumeUI.SHOW);
  }

  Future mute(bool muted) async {
    final result = await player.mute(muted);
    if (result == 1)
      setState(() {
        isMuted = muted;
      });
  }
 Future<void> setFav(song) async {
    var i = await widget.db.favSong(song);
    return i;
  }
  int isFavourite;
  AnimationController _animationController;
  Animation<Color> animateColor;
  bool isOpened = true;
  String status = 'hidden';
  Animation<double> animateIcon;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
            setState(() {
              player.stop();
              MediaNotification.hide();
              Navigator.pop(context);
            });
          }),
          title: Text("Now Playing"),
          actions: [
            IconButton(icon: Icon(Icons.playlist_add), onPressed: (){
              setState(() {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>new PlayList(widget.db,widget.index)));
              });
            }),
          ],
        ),
        body: orientation==Orientation.portrait?portrait():landScape(),
    );
  }
  Widget portrait(){
    final isFav = saved.contains(song);
    return ListView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      children: <Widget>[
        SizedBox(height:30),
        Hero(
          tag: widget.index,
          child: Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: shadowList,
                    shape: BoxShape.circle,
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: animation.value,
                        child:song==null?CircleAvatar(
                            radius: 200,
                            backgroundImage: AssetImage('assets/back.jpg')):CircleAvatar(
                          radius: 200,
                          backgroundImage: FileImage(File.fromUri(Uri.parse(song.albumArt))),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      boxShadow: shadowList,
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: IconButton(
                          icon: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                              isFav ? Colors.red : Colors.deepOrange),
                          onPressed: () {
                            setState(() {
                              setFav(song);
                              isFav ? saved.remove(song) : saved.add(song);
                              final SnackBar snackBar = SnackBar(
                                  content: Text(
                                    isFav
                                        ? "${song.title} is unselected favourite song"
                                        : "${song.title} is selected favourite song",
                                    style: TextStyle(fontFamily: "Bitter"),
                                  ));
                              scaffoldKey.currentState.showSnackBar(snackBar);

                            });
                          }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(song.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text(song.artist,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        SizedBox(height:20),
        Slider(
            value: position?.inSeconds?.toDouble(),
            min: 0.0,
            inactiveColor: Color(0xFF333945),
            max: duration?.inSeconds?.toDouble() ?? 0.0,
            activeColor: Colors.deepOrange,
            onChanged: (double value) {
              setState(() {
                player.seek(value.roundToDouble());
              });
            }),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                Duration(seconds: position?.inSeconds?.toInt() ?? 0)
                    .toString()
                    .split('.')[0],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  Duration(seconds: duration?.inSeconds?.toInt() ?? 0)
                      .toString()
                      .split('.')[0]),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ScopedModelDescendant<SongModel>(
              builder: (context, child, model) {
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    child: new IconButton(
                        icon: new Icon(Icons.keyboard_arrow_left,
                            color: Colors.deepOrange),
                        onPressed: () {
                          prev();
                          model.updateUI(song, widget.db);
                        }),
                  ),
                );
              },
            ),
            //fab,
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                child: IconButton(
                    icon: Icon(Icons.volume_off),
                    onPressed: () {
                      setState(() {
                        adjustQuantity('MINUS');
                      });
                    },
                    color: Colors.deepOrange),
              ),
            ),
            new FloatingActionButton(
              backgroundColor: animateColor.value,
              child: new AnimatedIcon(
                  icon: AnimatedIcons.pause_play, progress: animateIcon),
              onPressed: (){
                setState(() {
                  playpause();
                });
              },
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                child: IconButton(
                    icon: Icon(Icons.volume_up),
                    onPressed: () {
                      setState(() {
                        adjustQuantity('PLUS');
                      });
                    },
                    color: Colors.deepOrange),
              ),
            ),
            ScopedModelDescendant<SongModel>(
              builder: (context, child, model) {
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    child: new IconButton(
                        icon: new Icon(Icons.keyboard_arrow_right,
                            color: Colors.deepOrange),
                        onPressed: () {
                          next();
                          model.updateUI(song, widget.db);
                        }),
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(
          height:40,
        ),
        SizedBox(
          child: GestureDetector(
            child: Center(child: Text('UP NEXT')),
            onTap: ()=>showBottomSheet(),
          ),
        ),
        SizedBox(
          height:20,
        ),
      ],
    );
  }
  Widget landScape(){
    final isFav = saved.contains(song);
    return Row(
     mainAxisAlignment: MainAxisAlignment.spaceAround, 
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width:20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: widget.index,
              child: Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: shadowList,
                        shape: BoxShape.circle,
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(200),
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: animation.value,
                            child:song==null?CircleAvatar(
                                radius: 200,
                                backgroundImage: AssetImage('assets/back.jpg')):CircleAvatar(
                              radius: 200,
                              backgroundImage: FileImage(File.fromUri(Uri.parse(song.albumArt))),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          boxShadow: shadowList,
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          child: IconButton(
                              icon: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                  isFav ? Colors.red : Colors.deepOrange),
                              onPressed: () {
                                setState(() {
                                  setFav(song);
                                  isFav ? saved.remove(song) : saved.add(song);
                                  final SnackBar snackBar = SnackBar(
                                      content: Text(
                                        isFav
                                            ? "${song.title} is unselected favourite song"
                                            : "${song.title} is selected favourite song",
                                        style: TextStyle(fontFamily: "Bitter"),
                                      ));
                                  scaffoldKey.currentState.showSnackBar(snackBar);

                                });
                              }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height:20),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(song.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text(song.artist,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height:10),
            Container(
              width: 300,
                  child: Slider(
                  value: position?.inSeconds?.toDouble(),
                  min: 0.0,
                  inactiveColor: Color(0xFF333945),
                  max: duration?.inSeconds?.toDouble() ?? 0.0,
                  activeColor: Colors.deepOrange,
                  onChanged: (double value) {
                    setState(() {
                      player.seek(value.roundToDouble());
                    });
                  }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    Duration(seconds: position?.inSeconds?.toInt() ?? 0)
                        .toString()
                        .split('.')[0],
                  ),
                ),
                SizedBox(width:200),
                Center(
                  child: Text(
                      Duration(seconds: duration?.inSeconds?.toInt() ?? 0)
                          .toString()
                          .split('.')[0]),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ScopedModelDescendant<SongModel>(
                  builder: (context, child, model) {
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        child: new IconButton(
                            icon: new Icon(Icons.keyboard_arrow_left,
                                color: Colors.deepOrange),
                            onPressed: () {
                              prev();
                              model.updateUI(song, widget.db);
                            }),
                      ),
                    );
                  },
                ),
                //fab,
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    child: IconButton(
                        icon: Icon(Icons.volume_off),
                        onPressed: () {
                          setState(() {
                            adjustQuantity('MINUS');
                          });
                        },
                        color: Colors.deepOrange),
                  ),
                ),
                new FloatingActionButton(
                  backgroundColor: animateColor.value,
                  child: new AnimatedIcon(
                      icon: AnimatedIcons.pause_play, progress: animateIcon),
                  onPressed: (){
                    setState(() {
                      playpause();
                    });
                  },
                ),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    child: IconButton(
                        icon: Icon(Icons.volume_up),
                        onPressed: () {
                          setState(() {
                            adjustQuantity('PLUS');
                          });
                        },
                        color: Colors.deepOrange),
                  ),
                ),
                ScopedModelDescendant<SongModel>(
                  builder: (context, child, model) {
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        child: new IconButton(
                            icon: new Icon(Icons.keyboard_arrow_right,
                                color: Colors.deepOrange),
                            onPressed: () {
                              next();
                              model.updateUI(song, widget.db);
                            }),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height:10,
            ),
            SizedBox(
              child: GestureDetector(
                child: Center(child: Text('UP NEXT')),
                onTap: ()=>showBottomSheet(),
              ),
            ),
            SizedBox(
              height:10,
            ),
          ],
        ),
      ],
    );
  }
}
