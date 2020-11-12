import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TimerWidget extends StatefulWidget {
  TimerWidget({Key key, this.duration, this.tik, this.onTik}) : super(key: key);
  final Duration duration;
  final Duration tik;
  final Function onTik;
  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  static final TextStyle _timeTextStyle =
      TextStyle(color: Colors.white, fontSize: 30);
  static final SnackBar _breakMessage = SnackBar(content: Text('Süre Bitti!'));

  Timer _timer;
  Duration _duration;
  Duration _tik;
  Function _onTik;
  Duration _countdown;
  DateTime _bitis;
  String _buttonText;
  String _displayTime;
  VideoPlayerController _playerController;

  @override
  void initState() {
    setState(() {
      _duration = widget.duration ?? Duration(minutes: 25);
      _tik = widget.tik ?? Duration(milliseconds: 100);
      _onTik = widget.onTik ?? (String displayTime) => {};
      _playerController = VideoPlayerController.asset('assets/audio/ring.ogg')
        ..setLooping(false)
        ..initialize();
      resetTimer();
    });
    super.initState();
  }

  String getDisplayTime(Duration time) {
    int minutes = time.inMinutes;
    int seconds = (time.inSeconds - (time.inMinutes * 60));
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void startTimer(BuildContext context) {
    setState(() {
      _bitis = DateTime.now().add(_duration);
      _displayTime = getDisplayTime(_duration - _tik);
      _onTik(_displayTime);
      _buttonText = 'Dur';
      _timer = Timer.periodic(_tik, (Timer timer) {
        setState(() {
          _countdown = _bitis.difference(DateTime.now());
          _displayTime = getDisplayTime(_countdown);
          _onTik(_displayTime);
          if (DateTime.now().isAfter(_bitis)) {
            stopTimer();
            alarmRing();
            Scaffold.of(context).showSnackBar(_breakMessage);
          }
        });
      });
    });
  }

  void stopTimer() => setState(() {
        _countdown = _duration;
        _buttonText = 'reset ';
        _timer.cancel();
      });

  void resetTimer() => setState(() {
        _countdown = _duration;
        _displayTime = getDisplayTime(_countdown);
        _buttonText = 'Başla';
      });

  void alarmRing() => _playerController
      .seekTo(Duration.zero)
      .then((_) => _playerController.play());

  void buttonPress(BuildContext context) {
    if (_timer?.isActive ?? false) {
      stopTimer();
    } else {
      if (_countdown == _duration) {
        startTimer(context);
      } else {
        stopTimer();
        _onTik(_displayTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        SizedBox(
          height: 200,
          width: 200,
          child: CircularProgressIndicator(
            value: _countdown.inMilliseconds / _duration.inMilliseconds,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[100]),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _displayTime,
                  style: _timeTextStyle,
                ),
              ],
            ),
            FlatButton(
              color: Colors.green,
              textColor: Colors.white,
              child: Text(_buttonText),
              shape: StadiumBorder(),
              onPressed: () => buttonPress(context),
            ),
          ],
        ),
      ],
    );
  }
}
