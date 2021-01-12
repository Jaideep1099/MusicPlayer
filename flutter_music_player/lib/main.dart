import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

import 'player.dart';

final mp = MusicPlayer();

void main() {
  runApp(MusicApp());
}

final FlutterAudioQuery audioQuery = FlutterAudioQuery();

class MusicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      home: Home(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      themeMode: ThemeMode.system,
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Music'),
        ),
        drawer: Drawer(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 7,
                fit: FlexFit.tight,
                child: Container(
                  child: SongList(onSelect: (SongInfo song) async {
                    setState(() {
                      mp.nowPlaying = song;
                      mp.player.play();
                      mp.player.createPositionStream(
                          steps: 200,
                          maxPeriod: Duration(
                              milliseconds: int.parse(mp.nowPlaying.duration)));
                    });
                    mp.player.positionStream.listen((event) async {
                      if (event.inMilliseconds >=
                          double.parse(mp.nowPlaying.duration)) {
                        mp.seekPos = 0;
                        mp.player.pause();
                        mp.player.seek(Duration.zero);
                        mp.playNext();
                        setState(() {});
                      } else
                        mp.seekPos = (event.inMilliseconds * 200) /
                            double.parse(mp.nowPlaying.duration);
                      setState(() {});
                    });
                  }),
                  color: Colors.blueGrey,
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  child: PlayPreview(),
                  height: MediaQuery.of(context).size.height * 0.14,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayPreview extends StatefulWidget {
  @override
  _PlayPreviewState createState() => _PlayPreviewState();
}

class _PlayPreviewState extends State<PlayPreview> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(2),
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: ClipOval(
                child: (mp.nowPlaying != null &&
                        mp.nowPlaying.albumArtwork != null)
                    ? Image(
                        height: 80,
                        width: 80,
                        image: FileImage(File(mp.nowPlaying.albumArtwork)),
                      )
                    : Container(
                        color: Colors.black,
                        height: 80,
                        width: 80,
                        child: Icon(Icons.music_note)),
              ),
            ),
            Container(
                child: (mp.nowPlaying != null)
                    ? Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              (mp.nowPlaying.title.length < 30)
                                  ? mp.nowPlaying.title
                                  : mp.nowPlaying.title.substring(0, 29),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Verdana',
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              (mp.nowPlaying.artist.length < 30)
                                  ? mp.nowPlaying.artist
                                  : mp.nowPlaying.artist.substring(0, 29),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Verdana',
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Container(
                              //PlayProgress bar
                              margin: EdgeInsets.fromLTRB(0, 6, 0, 0),
                              color: Colors.grey,
                              width: 200,
                              height: 1,
                              child: Row(
                                children: [
                                  Container(
                                    color: Colors.red,
                                    height: 1,
                                    width: mp.seekPos,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    : Text("Play Something")),
            Container(
              height: 80,
              width: 70,
              child: InkWell(
                child: Icon(
                  (mp.player.playing) ? Icons.pause : Icons.play_arrow,
                  size: 28,
                ),
                onTap: () {
                  print("Play/Pause Button Pressed");
                  setState(() {});
                  (mp.player.playing) ? mp.player.pause() : mp.player.play();
                },
              ),
            ),
          ],
        ));
  }
}

class SongList extends StatelessWidget {
  final void Function(SongInfo song) onSelect;
  SongList({@required this.onSelect});
  Future<List<SongInfo>> fetchSongs() async {
    return await audioQuery.getSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
            future: fetchSongs(),
            builder: (context, snapshot) {
              List<SongInfo> songList = snapshot.data;
              if (snapshot.hasData)
                return ListView.builder(
                    itemCount: songList.length,
                    itemBuilder: (context, index) {
                      return SongTile(
                        song: songList[index],
                        onSelect: (SongInfo song) {
                          mp.nowPlayingIndex = index;
                          print(index);
                          if (mp.songLibrary == null) mp.songLibrary = songList;
                          onSelect(song);
                        },
                      );
                    });
              else
                return Container(child: CircularProgressIndicator());
            }));
  }
}

class SongTile extends StatelessWidget {
  final SongInfo song;
  final void Function(SongInfo song) onSelect;
  SongTile({@required this.song, @required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          await mp.player.setFilePath(song.filePath);
        } on PlayerException catch (e) {
          print("Error Code: ${e.code}");
        }
        onSelect(this.song);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 1, 0, 1),
        color: Colors.black,
        padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              child: (song.albumArtwork != null)
                  ? Image(
                      height: 50,
                      width: 50,
                      image: FileImage(File(song.albumArtwork)),
                    )
                  : Container(
                      height: 50, width: 50, child: Icon(Icons.music_note)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      (song.title.length < 40)
                          ? song.title
                          : song.title.substring(0, 37) + "...",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: Text(
                      (song.artist.length < 55)
                          ? song.artist
                          : song.artist.substring(0, 51) + "...",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Container(
                    child: Text(
                      (song.album.length < 55)
                          ? song.album
                          : song.album.substring(0, 51) + "...",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
