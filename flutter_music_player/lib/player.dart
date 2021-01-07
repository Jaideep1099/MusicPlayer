import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayer {
  SongInfo nowPlaying;
  AudioPlayer player;

  MusicPlayer() {
    this.player = AudioPlayer();
  }
}
