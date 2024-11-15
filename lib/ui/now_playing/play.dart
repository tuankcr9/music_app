import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/model/song.dart';
import 'audio_playing.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({
    super.key,
    required this.playingSong,
    required this.songs,
  });

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      playingSong: playingSong,
      songs: songs,
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    super.key,
    required this.playingSong,
    required this.songs,
  });

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late AudioManager audioManager;
  late int selectedItemIndex;
  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 12000));
    super.initState();
    audioManager = AudioManager(songUrl: widget.playingSong.source);
    audioManager.init();
    selectedItemIndex = widget.songs.indexOf(widget.playingSong);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.orange[50],
        // leading: IconButton(
        //     onPressed: () => {},
        //     icon: const Icon(Icons.arrow_back_ios_new)),
        middle: const Text('Now Playing'),
        trailing:
            IconButton(onPressed: () => {}, icon: const Icon(Icons.more_vert)),
      ),
      child: Scaffold(
          body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.playingSong.album} Album',
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              width: 48,
              height: 48,
            ),
            RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(animationController),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/image.jpg',
                    image: widget.playingSong.image,
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/image.jpg',
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                        fit: BoxFit.cover,
                      );
                    },
                  )),
            ),
            Container(
              margin: const EdgeInsets.all(30),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black26,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
                  const SizedBox(
                    width: 25,
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        Text(
                          widget.playingSong.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          widget.playingSong.artist,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 32, left: 24, right: 24, bottom: 16),
              child: progressBar(),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MediaButton(
                    function: null,
                    icon: Icons.shuffle,
                    size: 28,
                    color: null),
                const SizedBox(
                  width: 32,
                ),
                const MediaButton(
                    function: null,
                    icon: Icons.skip_previous,
                    size: 48,
                    color: null),
                playButton(),
                const MediaButton(
                    function: null,
                    icon: Icons.skip_next,
                    size: 48,
                    color: null),
                const SizedBox(
                  width: 32,
                ),
                const MediaButton(
                    function: null,
                    icon: Icons.repeat,
                    size: 28,
                    color: Colors.black26),
              ],
            ),
          ],
        ),
      )),
    );
  }


  StreamBuilder<PlayerState> playButton() {
    return StreamBuilder(
      stream: audioManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final play = playState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(),
          );
        } else if (play != true) {
          return MediaButton(
              function: () {
                audioManager.player.play();
              },
              icon: Icons.play_arrow,
              size: 48,
              color: null);
        } else if (processingState != ProcessingState.completed) {
          return MediaButton(
              function: () {
                audioManager.player.pause();
              },
              icon: Icons.pause,
              size: 48,
              color: null);
        } else {
          return MediaButton(
              function: () {
                audioManager.player.seek(Duration.zero);
              },
              icon: Icons.replay,
              size: 48,
              color: null);
        }
      },
    );
  }

  StreamBuilder<DurationState> progressBar() {
    return StreamBuilder<DurationState>(
        stream: audioManager.durationState,
        builder: (context, snapshot) {
          final duration = snapshot.data;
          final progress = duration?.progress ?? Duration.zero;
          final buffered = duration?.buffered ?? Duration.zero;
          final total = duration?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffered,
            onSeek: audioManager.player.seek,
          );
        });
  }

// Widget mediaButton() {
//   return const SizedBox(
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         MediaButton(
//             function: null,
//             icon: Icons.shuffle,
//             size: 16,
//             color: Colors.black26),
//         MediaButton(
//             function: null,
//             icon: Icons.skip_previous,
//             size: 16,
//             color: Colors.black),
//         MediaButton(
//             function: null,
//             icon: Icons.play_arrow,
//             size: 16,
//             color: Colors.black),
//         MediaButton(
//             function: null,
//             icon: Icons.skip_next,
//             size: 16,
//             color: Colors.black),
//         MediaButton(
//             function: null,
//             icon: Icons.repeat,
//             size: 16,
//             color: Colors.black26),
//       ],
//     ),
//   );
// }
}

class MediaButton extends StatefulWidget {
  const MediaButton({
    super.key,
    required this.function,
    required this.icon,
    required this.size,
    required this.color,
  });

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<MediaButton> createState() => _MediaButtonState();
}

class _MediaButtonState extends State<MediaButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color,
    );
  }
}
