import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayer {
  SongInfo nowPlaying;
  AudioPlayer player;
  double seekPos;

  MusicPlayer() {
    this.player = AudioPlayer();
  }
}
