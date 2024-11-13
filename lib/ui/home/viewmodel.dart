import 'dart:async';

import 'package:music_app/data/repository/reponsitory.dart';

import '../../data/model/song.dart';

class MusicAppViewModel{
  StreamController<List<Song>> songStream = StreamController();

  void loadSong(){
    final reponsitory = DefaultReponsitory();
    reponsitory.loadData().then((a) => songStream.add(a!));
  }
}