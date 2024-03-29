import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:spotify/spotify.dart' as Spotify hide User;
import 'package:tracksfer/screens/spotify/spotify_search.dart';
import 'package:tracksfer/services/spotify.dart';

import '../../models/Track.dart';
import '../../models/Group.dart';
import '../../services/auth.dart';
import '../../services/requests.dart';
import '../../widgets/error.dart';
import '../../widgets/loading.dart';

class GroupDetailScreen extends StatelessWidget {
  final Group group;

  GroupDetailScreen(this.group);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GroupDetailWidget(group),
    );
  }
}

class GroupDetailWidget extends StatefulWidget {
  final Group group;

  GroupDetailWidget(this.group);

  @override
  _GroupDetailWidgetState createState() => _GroupDetailWidgetState();
}

class _GroupDetailWidgetState extends State<GroupDetailWidget> {
  List<Track> _tracks;
  bool _error = false;
  bool _loading = true;
  int _page = 1;

  void _getTracks() async {
    try {
      final response = await Request.get('groups/${widget.group.id}/tracks/');
      if (response.statusCode == 200) {
        final Iterable tracksJson = response.data['results'];
        final List<Track> tracks =
            tracksJson.map((model) => Track.fromJson(model)).toList();
        populateSpotifyDetails(tracks);
        setState(() {
          _tracks = tracks;
          _loading = false;
        });
      } else if (response.statusCode == 403) {
        logout(context);
      } else {
        _setError();
      }
    } catch (e) {
      print(e);
      _setError();
    }
  }

  void _refresh() {
    setState(() {
      _error = false;
      _getTracks();
    });
  }

  void _setError() {
    setState(() {
      this._error = true;
      this._loading = false;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final errorWidget = LoadErrorWidget(
      errorMessage: 'Failed to load group.',
      function: _refresh,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.group.groupName),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SpotifySearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: _error
          ? errorWidget
          : _loading
              ? LoadingWidget()
              : _tracks.isEmpty
                  ? Center(
                      child: Text(
                        'No tracks have been added to this group yet! Why not add one now?',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tracks.length,
                      itemBuilder: (context, index) {
                        final Track track = _tracks[index];
                        return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: track.getAlbumThumbnail(),
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          title: Text(track.spotifyTrack.name),
                          subtitle: Text(track.getArtistNames()),
                          onTap: () {
                            showCupertinoModalBottomSheet(
                              context: context,
                              builder: (context) => TrackModelWidget(track),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}

class TrackModelWidget extends StatefulWidget {
  final Track track;

  TrackModelWidget(this.track);

  @override
  _TrackModelWidgetState createState() => _TrackModelWidgetState();
}

class _TrackModelWidgetState extends State<TrackModelWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(widget.track.spotifyTrack.name),
          Text(widget.track.getArtistNames()),
        ],
      ),
    );
  }
}
