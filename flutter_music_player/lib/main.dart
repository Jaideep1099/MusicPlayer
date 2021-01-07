import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_audio_query/flutter_audio_query.dart';

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

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  child: PlayPreview(),
                  height: MediaQuery.of(context).size.height * 0.14,
                  color: Colors.red,
                ),
              ),
              Flexible(
                flex: 7,
                child: Container(
                  child: SongList(),
                  color: Colors.blueGrey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PlayPreview extends StatefulWidget {
  SongInfo song;
  PlayPreview({@required this.song});
  @override
  _PlayPreviewState createState() => _PlayPreviewState(song: this.song);
}

class _PlayPreviewState extends State<PlayPreview> {
  SongInfo song;
  _PlayPreviewState({@required this.song});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          child: ClipOval(
            child: (song != null && song.albumArtwork != null)
                ? Image(
                    height: 80,
                    width: 80,
                    image: FileImage(File(song.albumArtwork)),
                  )
                : Container(
                    color: Colors.black,
                    height: 80,
                    width: 80,
                    child: Icon(Icons.music_note)),
          ),
        ),
        Container(
            child: (song != null) ? Text(song.title) : Text("Play Something")),
        Container(
          height: 80,
          width: 80,
          child: Icon(Icons.play_arrow),
        ),
      ],
    ));
  }
}

class SongList extends StatelessWidget {
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
                      return SongTile(song: songList[index]);
                    });
              else
                return CircularProgressIndicator();
            }));
  }
}

class SongTile extends StatelessWidget {
  SongInfo song;
  SongTile({@required this.song});
  @override
  Widget build(BuildContext context) {
    return Container(
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
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  (song.title.length < 45)
                      ? song.title
                      : song.title.substring(0, 41) + "...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }
}
