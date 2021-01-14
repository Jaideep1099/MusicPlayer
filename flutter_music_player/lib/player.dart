import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayer {
  SongInfo nowPlaying;
  int nowPlayingIndex;
  AudioPlayer player;
  List<SongInfo> playQueue;

  MusicPlayer() {
    this.player = AudioPlayer();
  }

  void playNext() async {
    if (++this.nowPlayingIndex < this.playQueue.length) {
      try {
        this.nowPlaying = this.playQueue[this.nowPlayingIndex];
        await this.player.setFilePath(this.nowPlaying.filePath);
        this.player.play();
      } on PlayerException catch (e) {
        print("Error Code: ${e.code}");
      }
    } else {
      this.nowPlayingIndex = 0;
      this.nowPlaying = this.playQueue[this.nowPlayingIndex];
      await this.player.setFilePath(this.nowPlaying.filePath);
    }
  }

  void playPrev() async {
    if (this.nowPlayingIndex > 0) {
      try {
        this.nowPlaying = this.playQueue[--this.nowPlayingIndex];
        await this.player.setFilePath(this.nowPlaying.filePath);
        this.player.play();
      } on PlayerException catch (e) {
        print("Error Code: ${e.code}");
      }
    }
  }
}
