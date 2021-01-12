import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayer {
  SongInfo nowPlaying;
  int nowPlayingIndex;
  AudioPlayer player;
  double seekPos;
  List<SongInfo> songLibrary;

  MusicPlayer() {
    this.player = AudioPlayer();
  }

  void playNext() async {
    if (++this.nowPlayingIndex < this.songLibrary.length) {
      try {
        this.nowPlaying = this.songLibrary[this.nowPlayingIndex];
        await this.player.setFilePath(this.nowPlaying.filePath);
        this.player.play();
      } on PlayerException catch (e) {
        print("Error Code: ${e.code}");
      }
    } else {
      this.nowPlayingIndex = 0;
      this.nowPlaying = this.songLibrary[this.nowPlayingIndex];
      await this.player.setFilePath(this.nowPlaying.filePath);
    }
  }
}
