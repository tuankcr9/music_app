import 'package:music_app/data/source/source.dart';

import '../model/song.dart';

abstract interface class Reponsitory{
  Future<List<Song>?> loadData();
}

class DefaultReponsitory implements Reponsitory{
  final _localDataSoure = LocalDataSoure();
  final _remoteDataSoure = RemoteDataSoure();

  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];
    await _remoteDataSoure.loadData().then((remoteSongs) async {
      if(remoteSongs == null){
        await _localDataSoure.loadData().then((localSongs){
          if(localSongs != null){
            songs.addAll(localSongs);
            return songs;
          }
        });
      }
      else{
        songs.addAll(remoteSongs);
      }
    });
    return songs;
  }
}