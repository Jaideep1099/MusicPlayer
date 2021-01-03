import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(MusicApp());
}

final player = AudioPlayer();
//https://sounds-mp3.com/mp3/0012839.mp3

class MusicApp extends StatefulWidget {
  @override
  _MusicAppState createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      home: SafeArea(
          child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.music_note),
          title: Text("Music App"),
        ),
        body: Container(
          child: Column(
            children: [PlayView(), SongListView()],
          ),
        ),
      )),
      theme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}

class SongListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      height: MediaQuery.of(context).size.height * 0.795,
    );
  }
}

class PlayView extends StatefulWidget {
  @override
  _PlayViewState createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      height: MediaQuery.of(context).size.height * 0.10,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              child: Icon(Icons.play_arrow),
              onTap: () async {
                var duration = await player
                    .setUrl('https://sounds-mp3.com/mp3/0012839.mp3');
                player.play();
              },
            ),
          )
        ],
      ),
    );
  }
}
