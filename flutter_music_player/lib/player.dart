import 'package:just_audio/just_audio.dart';

class SongData {
  String albumId;
  String artistId;
  String artist;
  String album;
  String title;
  String composer;
  String year;
  String track;
  String duration; //in ms
  String bookmark; //last stopped position
  String filePath;
  String uri;

  /// String with the size, in bytes, of this audio file.
  String fileSize;
  String albumArtwork;
  bool isMusic;
  bool isPodcast;
  bool isRingtone;
  bool isAlarm;
  bool isNotification;

  SongData(
      {this.album,
      this.albumArtwork,
      this.albumId,
      this.artist,
      this.artistId,
      this.bookmark,
      this.composer,
      this.duration,
      this.filePath,
      this.fileSize,
      this.isAlarm,
      this.isMusic,
      this.isNotification,
      this.isPodcast,
      this.isRingtone,
      this.title,
      this.track,
      this.uri,
      this.year});

  Map<String, dynamic> toMap() {
    return {
      'filePath': filePath,
      'title': title,
      'albumId': albumId,
      'album': album,
      'artistId': artistId,
      'artist': artist,
      'albumArtwork': albumArtwork,
      'bookmark': bookmark,
      'composer': composer,
      'duration': duration,
      'fileSize': fileSize,
      'isAlarm': isAlarm.toString(),
      'isMusic': isMusic.toString(),
      'isNotification': isNotification.toString(),
      'isPodcast': isPodcast.toString(),
      'isRingtone': isRingtone.toString(),
      'track': track,
      'uri': uri,
      'year': year
    };
  }
}

class MusicPlayer {
  SongData nowPlaying;
  int nowPlayingIndex;
  AudioPlayer player;
  List<SongData> playQueue;

  List<SongData> library;

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
