import 'dart:io';
import 'package:flutter/material.dart';

import 'main.dart';

class PlayerView extends StatefulWidget {
  @override
  _PlayerViewState createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  @override
  void initState() {
    super.initState();

    mp.player.playerStateStream.listen((event) async {
      if (mounted) setState(() {});
      print("PV: ${mp.player.playerState} ${mp.player.processingState}");
    });
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: ClipOval(
                child: (mp.nowPlaying != null &&
                        mp.nowPlaying.albumArtwork != null)
                    ? Image(
                        height: MediaQuery.of(context).size.width * 0.85,
                        width: MediaQuery.of(context).size.width * 0.85,
                        image: FileImage(File(mp.nowPlaying.albumArtwork)),
                      )
                    : Container(
                        color: Colors.black,
                        height: MediaQuery.of(context).size.width * 0.85,
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Icon(
                          Icons.music_note,
                          size: MediaQuery.of(context).size.width * 0.75,
                        )),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Icon(
                      Icons.skip_previous,
                      size: MediaQuery.of(context).size.height * 0.1,
                    ),
                    onTap: () {
                      print("Prev Button Pressed");
                      if (mp.player.position.inSeconds == 0)
                        mp.playPrev();
                      else
                        mp.player.seek(Duration.zero);
                    },
                  ),
                  InkWell(
                    child: Icon(
                      (mp.player.playing) ? Icons.pause : Icons.play_arrow,
                      size: MediaQuery.of(context).size.height * 0.1,
                    ),
                    onTap: () {
                      print("Play/Pause Button Pressed");
                      (mp.player.playing)
                          ? mp.player.pause()
                          : mp.player.play();
                    },
                  ),
                  InkWell(
                    child: Icon(
                      Icons.skip_next,
                      size: MediaQuery.of(context).size.height * 0.1,
                    ),
                    onTap: () {
                      print("Play/Pause Button Pressed");
                      mp.playNext();
                    },
                  ),
                ],
              ),
            ),
            Seekbar(),
            Container(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    mp.nowPlaying.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.06),
                  ),
                  Text(
                    mp.nowPlaying.artist,
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: MediaQuery.of(context).size.width * 0.04),
                  ),
                  Text(
                    mp.nowPlaying.album,
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: MediaQuery.of(context).size.width * 0.04),
                  ),
                ],
              ),
            )
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
    mp.player.positionStream.listen((event) {
      if (mounted) setState(() {});
    });
  }

  Widget build(BuildContext context) {
    return Container(
      //PlayProgress bar
      margin: EdgeInsets.fromLTRB(0, 6, 0, 0),
      color: Colors.blueGrey,
      width: MediaQuery.of(context).size.width * 0.75,
      height: 1,
      child: Row(
        children: [
          Container(
            color: Colors.red,
            height: 1,
            width: (mp.player.position != null)
                ? (mp.player.position.inMilliseconds *
                        MediaQuery.of(context).size.width *
                        0.75) /
                    double.parse(mp.nowPlaying.duration)
                : 0,
          ),
        ],
      ),
    );
  }
}
