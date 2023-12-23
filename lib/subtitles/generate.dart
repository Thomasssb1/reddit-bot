import 'dart:convert';
import 'dart:io';
import 'package:reddit_2_video/utils/prepath.dart';
import 'package:reddit_2_video/subtitles/time.dart';
import 'package:mp3_info/mp3_info.dart';

/// [Remember] ffmpeg uses `HBBGGRR`
String animation(colour) => r"{\an5}";
//r"{\an5\1c&H000000&\t(0, 150, \1c&" +
//colour +
//r"& \frz0\frscx0\frscy0\t(0, 150, \fscx100, \fscy100))}{\fad(150,150)}";

Future<Duration> generateSubtitles(
    String id,
    String ttsID,
    bool alternateColour,
    bool isTitle,
    bool addDelay,
    String currentColour,
    Duration prevFileTime,
    IOSink sinkComments) async {
  final String highlightColour =
      alternateColour | isTitle ? 'HFFFFFF' : 'H00FFFF';
  final int maxCharacterCount = 30;

  Duration time = Duration.zero;

  String jsonData =
      await File("$prePath/.temp/$id/config/tts-$ttsID.mp3.words.json")
          .readAsString();
  var json = jsonDecode(jsonData);

  MP3Info ttsFile =
      MP3Processor.fromFile(File("$prePath/.temp/$id//tts/tts-$ttsID.mp3"));

  for (final segment in json['segments']) {
    List<dynamic> wordSet = [];
    num characterCount = 0;
    // whisper_timestamped sometimes hallucinates you
    int segmentCount = json['segments'].length;
    if (segment['words'][0]['text'] != 'you') {
      var words = segment['words'];
      int lineCount = words.length;
      //final word in segment['words']
      int position = 0;
      for (int i = 0; i < words.length; i++) {
        if (characterCount + words[i]['text'].length > maxCharacterCount) {
          karaokeEffect(
              wordSet,
              sinkComments,
              prevFileTime,
              highlightColour,
              currentColour,
              position,
              lineCount,
              segmentCount,
              ttsFile.duration);
          wordSet = [
            {
              "text": words[i]['text'],
              "end": (words[i]['end'] * 1000).toInt(),
              "start": (words[i]['start'] * 1000).toInt(),
              "segmentID": segment['id']
            }
          ];
          characterCount = 0;
          position = i;
        } else {
          wordSet.add({
            "text": words[i]['text'],
            "end": (words[i]['end'] * 1000).toInt(),
            "start": (words[i]['start'] * 1000).toInt(),
            "segmentID": segment['id']
          });
          characterCount += words[i]['text'].length;
        }
        /*time = Duration(
            milliseconds:
                (words[i]['end'] * 1000).toInt() + prevFileTime.inMilliseconds);*/
      }
      if (wordSet.isNotEmpty) {
        karaokeEffect(wordSet, sinkComments, prevFileTime, highlightColour,
            currentColour, position, lineCount, segmentCount, ttsFile.duration);
      }
    }
  }
  print("space");
  return Duration(
      milliseconds:
          ttsFile.duration.inMilliseconds + prevFileTime.inMilliseconds);
}

karaokeEffect(
    List<dynamic> line,
    IOSink sinkComments,
    Duration prevFileTime,
    String highlightColour,
    String textColour,
    int position,
    int lineCount,
    int segmentCount,
    Duration ttsFileDuration) {
  for (int i = 0; i < line.length; i++) {
    // start: ${(position == 0 && i == 0)}
    print(line[i]['segmentID']);
    print("segend: ${segmentCount - 1}");
    print(
        "end: ${position + i == lineCount - 1 && i == line.length - 1 && line[i]['segmentID'] == segmentCount - 1}");
    sinkComments.writeln(
        "Dialogue: 0,${getNewTime(Duration(milliseconds: line[i]['start'] + prevFileTime.inMilliseconds))},${getNewTime(Duration(milliseconds: (position + i == lineCount - 1 && i == line.length - 1 && line[i]['segmentID'] == segmentCount - 1) ? ttsFileDuration.inMilliseconds : line[i]['end'] + prevFileTime.inMilliseconds))},Default,,0,0,0,," +
            r"{\c&" +
            "$textColour}" +
            r"{\an5\frz0}" +
            line
                .sublist(0, i + 1)
                .map((e) => (line.indexOf(e) == i)
                    ? r"{\c&" + "$highlightColour}" + e['text']
                    : e['text'])
                .join(' '));
  }
}
