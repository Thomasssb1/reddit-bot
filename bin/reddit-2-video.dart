import 'package:reddit_2_video/log.dart';
import 'package:reddit_2_video/reddit_2_video.dart' as reddit_2_video;
import 'package:reddit_2_video/utils.dart';
import '../lib/cmd.dart';
import 'dart:io';

// enable preview ffplay
// add styling to title and fade in etc using .ass
void main(List<String> arguments) async {
  if (await File('./.temp/tts/.gitkeep').exists()) {
    await File('./.temp/tts/.gitkeep').delete().catchError((error) {
      printError(
          "Something went wrong when trying to delete a temporary file. To fix this you can go to the ./reddit-2-video/.temp/tts folder and delete the .gitkeep file. Error: $error");
      exit(1);
    });
  }
  var results = parse(arguments);
  if (results == 'flush') {
    flushLog();
  } else if (results != null) {
    final List<dynamic> postData = await reddit_2_video.getPostData(
      results['subreddit'],
      results['sort'],
      results['nsfw'],
      int.parse(results['count']),
      results['comment-sort'],
      results['post-confirmation'],
      results['type'],
    );
    if (postData.isNotEmpty) {
      reddit_2_video.generateVideo(
        postData,
        results['output'],
        results['video-path'],
        results['music'],
        int.parse(results['framerate']),
        results['ntts'],
        results['file-type'],
        results['verbose'],
        results['override'],
        results['video-path'],
      );
    } else {
      printError("No post(s) found... Try again.");
    }
  }
}
