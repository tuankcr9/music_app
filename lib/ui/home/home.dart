import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/discovery/discovery.dart';
import 'package:music_app/ui/home/viewmodel.dart';
import 'package:music_app/ui/now_playing/play.dart';
import 'package:music_app/ui/settings/settings.dart';
import 'package:music_app/ui/user/user.dart';

import '../../data/model/song.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const Hometab(),
    const DiscoveryTab(),
    const SettingsTab(),
    const AccountTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Music App'),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.album), label: 'Discovery'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

class Hometab extends StatelessWidget {
  const Hometab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModel musicAppViewModel;

  @override
  void initState() {
    musicAppViewModel = MusicAppViewModel();
    musicAppViewModel.loadSong();
    musicAppViewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    musicAppViewModel.songStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.separated(
      itemBuilder: (context, position) {
        return songItem(songs[position]);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.deepOrange,
          thickness: 1,
          indent: 5,
          endIndent: 5,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  Widget songItem(Song song) {
    return ListTile(
      onTap: () {
        navigate(song);
      },
      contentPadding: const EdgeInsets.only(
        left: 8,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/image.jpg',
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/image.jpg',
              width: 48,
              height: 48,
            );
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
          onPressed: () {
            showBottomSheet();
          },
          icon: const Icon(Icons.more_vert)),
    );
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 400,
              color: Colors.black12,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text('Modal bottom'),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Bottom'))
                ],
              ),
            ),
          );
        });
  }

  void navigate(Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(playingSong: song, songs: songs);
    }));
  }
}

// class SongItemSection extends StatelessWidget {
//   const SongItemSection({
//     super.key,
//     required this.parent,
//     required this.song,
//   });
//
//   final _HomeTabPageState parent;
//   final Song song;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       contentPadding: const EdgeInsets.only(
//         left: 8,
//       ),
//       leading: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: FadeInImage.assetNetwork(
//           placeholder: 'assets/image.jpg',
//           image: song.image,
//           width: 48,
//           height: 48,
//           imageErrorBuilder: (context,error,strackTrace){
//             return Image.asset(
//               'assets/image.jpg',
//               width: 48,
//               height: 48,
//             );
//           },
//         ),
//       ),
//       title: Text(song.title),
//       subtitle: Text(song.artist),
//       trailing: IconButton(
//           onPressed: (){
//
//           },
//           icon: Icon(Icons.more_vert)),
//     );
//   }
// }
