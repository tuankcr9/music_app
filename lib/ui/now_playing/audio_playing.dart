import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioManager {
  AudioManager({
    required this.songUrl
  });

  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  String songUrl;

  void init() {
    player.stop();
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        player.positionStream,
        player.playbackEventStream,
            (position, play) =>
            DurationState(
                progress: position,
                buffered: play.bufferedPosition,
                total: play.duration
            )
    );
    player.setUrl(songUrl);
    player.play();
  }

  void updateSong(String Url){
    songUrl = Url;
    init();
  }

  void disposed() {
    player.dispose();
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });

  final Duration progress;
  final Duration buffered;
  final Duration? total;
}