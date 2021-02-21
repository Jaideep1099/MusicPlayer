import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:marquee/marquee.dart';

import 'playerview.dart';
import 'player.dart';

dynamic mp;

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
  var _dbSet;
  var _dbPath;
  Database _database;

  Future<void> _fetchDB() async {
    _dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(_dbPath, 'musiclib.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE musicLib(filePath TEXT," +
              " title TEXT, albumId TEXT, album TEXT,artistId TEXT," +
              " artist TEXT,albumArtwork TEXT,bookmark TEXT, composer TEXT," +
              " duration TEXT, fileSize TEXT, isAlarm TEXT, isMusic TEXT," +
              " isNotification TEXT, isPodcast TEXT, isRingtone TEXT," +
              "  track TEXT, uri TEXT, year TEXT , PRIMARY KEY(title, album, artist, track) )",
        );
      },
      version: 1,
    );
  }

  Future<void> _insertSong(SongData song) async {
    final Database db = _database;

    await db.insert(
      'musicLib',
      song.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SongData>> _fetchSongs() async {
    print("_setLibrary()\n");
    // Get a reference to the database.
    final Database db = _database;
    print("db\n");
    // Query the table.
    final List<Map<String, dynamic>> maps = await db.query('musicLib');
    print("Query Complete ${maps.length}\n");
    // Convert the List<Map<String, dynamic> into a List<SongData>.
    return List.generate(maps.length, (i) {
      print("Adding song ${maps[i]['isAlarm']}\n");
      return SongData(
          album: maps[i]['album'],
          albumArtwork: maps[i]['albumArtwork'],
          albumId: maps[i]['albumId'],
          artist: maps[i]['artist'],
          artistId: maps[i]['artistId'],
          bookmark: maps[i]['bookmark'],
          composer: maps[i]['composer'],
          duration: maps[i]['duration'],
          filePath: maps[i]['filePath'],
          fileSize: maps[i]['fileSize'],
          isAlarm: (maps[i]['isAlarm'] == 'true'),
          isMusic: (maps[i]['isMusic'] == "true"),
          isNotification: (maps[i]['isNotification'] == "true"),
          isPodcast: (maps[i]['isPodcast'] == "true"),
          isRingtone: (maps[i]['isRingtone'] == "true"),
          title: maps[i]['title'],
          track: maps[i]['track'],
          uri: maps[i]['uri'],
          year: maps[i]['year']);
    });
  }

  Future<void> _setLibrary() async {
    print("_setLibrary()\n");
    mp.library = await _fetchSongs();
  }

  Future<void> _checkDBSet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _dbSet = (prefs.getInt('DBset') ?? 0);
  }

  Future<void> _setDB() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('DBset', 1);
  }

  void initiate() async {
    await _fetchDB();

    await _checkDBSet();

    if (_dbSet == 0) {
      print("DB not Set. Fetching SongLibrary");
      //Fetch SongLibrary
      audioQuery.getSongs().then((value) {
        List<SongData> library = [];
        for (var i = 0; i < value.length; ++i) {
          library.add(SongData(
              album: value[i].album,
              albumArtwork: value[i].albumArtwork,
              albumId: value[i].albumId,
              artist: value[i].artist,
              artistId: value[i].artistId,
              bookmark: value[i].bookmark,
              composer: value[i].composer,
              duration: value[i].duration,
              filePath: value[i].filePath,
              fileSize: value[i].fileSize,
              isAlarm: value[i].isAlarm,
              isMusic: value[i].isMusic,
              isNotification: value[i].isNotification,
              isPodcast: value[i].isPodcast,
              isRingtone: value[i].isRingtone,
              title: value[i].title,
              track: value[i].track,
              uri: value[i].uri,
              year: value[i].year));

          print("Addding Song :$i");
          _insertSong(library[i]);
        }
        mp.library = library;
        _setDB();
        setState(() {});
      });
    } else {
      print("Fetching Library from DB");
      await _setLibrary();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    mp = MusicPlayer();
    WidgetsFlutterBinding.ensureInitialized();

    initiate();
  }

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
                  child: SongList(onSelect: (SongData song) async {
                    setState(() {
                      mp.nowPlaying = song;
                      mp.player.play();
                      mp.player.createPositionStream(
                          steps: 200,
                          maxPeriod: Duration(
                              milliseconds: int.parse(mp.nowPlaying.duration)));
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
  StreamSubscription<PlayerState> _playerStateStream;
  @override
  void initState() {
    super.initState();

    _playerStateStream = mp.player.playerStateStream.listen((event) {
      if (mp.player.playing &&
          mp.player.processingState == ProcessingState.completed) {
        mp.player.pause();
        mp.player.seek(Duration.zero);
        mp.playNext();
      }
      setState(() {});
      print("S: ${mp.player.playerState} ${mp.player.processingState}");
    });
  }

  void dispose() {
    super.dispose();
    _playerStateStream.cancel();
  }

  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(2),
        color: Colors.black,
        child: InkWell(
          onTap: () {
            if (mp.nowPlaying != null)
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PlayerView();
              }));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                child: ClipOval(
                  //AlbumArt
                  child: (mp.nowPlaying != null &&
                          mp.nowPlaying.albumArtwork != null)
                      ? Image(
                          height: MediaQuery.of(context).size.width * 0.15,
                          width: MediaQuery.of(context).size.width * 0.15,
                          image: FileImage(File(mp.nowPlaying.albumArtwork)),
                        )
                      : Container(
                          color: Colors.black,
                          height: MediaQuery.of(context).size.width * 0.15,
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: Icon(Icons.music_note)),
                ),
              ),
              Container(
                  //Now Playing Song
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: (mp.nowPlaying != null)
                      ? Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                (mp.nowPlaying.title.length < 26)
                                    ? mp.nowPlaying.title
                                    : mp.nowPlaying.title.substring(0, 26),
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.042,
                                    fontFamily: 'Verdana',
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                (mp.nowPlaying.artist.length < 30)
                                    ? mp.nowPlaying.artist
                                    : mp.nowPlaying.artist.substring(0, 29),
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.034,
                                  fontFamily: 'Verdana',
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text("Play Something")),
              Container(
                //Play/Pause Button
                height: 80,
                width: MediaQuery.of(context).size.width * 0.15,
                child: InkWell(
                  child: Icon(
                    (mp.player.playing) ? Icons.pause : Icons.play_arrow,
                    size: MediaQuery.of(context).size.width * 0.10,
                  ),
                  onTap: () {
                    print("Play/Pause Button Pressed");
                    (mp.player.playing) ? mp.player.pause() : mp.player.play();
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class SongList extends StatelessWidget {
  final void Function(SongData song) onSelect;
  SongList({@required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: (mp.library == null)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              )
            : ListView.builder(
                itemCount: mp.library.length,
                itemBuilder: (context, index) {
                  return SongTile(
                      song: mp.library[index],
                      onSelect: (SongData song) {
                        mp.nowPlayingIndex = index;
                        if (mp.playQueue == null) mp.playQueue = mp.library;
                        print(index);
                        onSelect(song);
                      });
                }));
  }
}

class SongTile extends StatelessWidget {
  final SongData song;
  final void Function(SongData song) onSelect;
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
                      width: MediaQuery.of(context).size.width * 0.13,
                      image: FileImage(File(song.albumArtwork)),
                    )
                  : Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.13,
                      child: Icon(Icons.music_note)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      (song.title.length < 35)
                          ? song.title
                          : song.title.substring(0, 32) + "..",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.042,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: Text(
                      (song.artist.length < 49)
                          ? song.artist
                          : song.artist.substring(0, 46) + "..",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.032),
                    ),
                  ),
                  Container(
                    child: Text(
                      (song.album.length < 49)
                          ? song.album
                          : song.album.substring(0, 46) + "..",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.032),
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
