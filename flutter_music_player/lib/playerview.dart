import 'dart:io';
import 'package:flutter/material.dart';

import 'main.dart';

class PlayerView extends StatefulWidget {
  @override
  _PlayerViewState createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: ClipOval(
                child: (mp.nowPlaying != null &&
                        mp.nowPlaying.albumArtwork != null)
                    ? Image(
                        height: MediaQuery.of(context).size.width * 0.75,
                        width: MediaQuery.of(context).size.width * 0.75,
                        image: FileImage(File(mp.nowPlaying.albumArtwork)),
                      )
                    : Container(
                        color: Colors.black,
                        height: MediaQuery.of(context).size.width * 0.75,
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Icon(Icons.music_note)),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width,
              child: InkWell(
                child: Icon(
                  (mp.player.playing) ? Icons.pause : Icons.play_arrow,
                  size: MediaQuery.of(context).size.height * 0.1,
                ),
                onTap: () {
                  print("Play/Pause Button Pressed");
                  setState(() {});
                  (mp.player.playing) ? mp.player.pause() : mp.player.play();
                },
              ),
            ),
            Seekbar(),
          ],
        ),
      ),
    ));
  }
}

class Seekbar extends StatefulWidget {
  @override
  _SeekbarState createState() => _SeekbarState();
}

class _SeekbarState extends State<Seekbar> {
  @override
  void initState() {
    super.initState();
    mp.player.positionStream.listen((event) async {
      if (event.inMilliseconds >= double.parse(mp.nowPlaying.duration)) {
        if (mounted)
          setState(() {
            mp.seekPos = 0;
          });

        mp.player.pause();
        mp.player.seek(Duration.zero);
        mp.playNext();
        if (mounted) setState(() {});
      } else
        setState(() {
          mp.seekPos = (event.inMilliseconds * 200) /
              double.parse(mp.nowPlaying.duration);
        });
    });
  }

  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
