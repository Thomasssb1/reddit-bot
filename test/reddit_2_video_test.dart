import 'package:args/args.dart';
import 'package:reddit_2_video/cmd.dart';
import 'package:reddit_2_video/utils.dart';
import 'package:test/test.dart';

void main() {
  group("reddit-2-video", () {
    group("CLI parsing", () {
      test("Run reddit-2-video command with subreddit arg only", () {
        var results = parse(['--subreddit', 'AskReddit']);
        ArgResults args = results['args'];

        List<String?> command = [(args.command == null) ? null : args.command.toString(), ...args.arguments];

        expect([null, '--subreddit', 'AskReddit'], command);
      });
      test("Run reddit-2-video command with url as a subreddit arg", () {
        var results =
            parse(['--subreddit', 'https://www.reddit.com/r/AskReddit/comments/15lfece/why_did_you_get_fired/']);

        ArgResults args = results['args'];

        List<String?> command = [(args.command == null) ? null : args.command.toString(), ...args.arguments];

        expect([null, '--subreddit', 'https://www.reddit.com/r/AskReddit/comments/15lfece/why_did_you_get_fired/'],
            command);
      });
    });
    group("Link validation", () {
      test("Reddit link directly to a post", () {
        bool isValidLink = validateLink('https://www.reddit.com/r/AskReddit/comments/15lfece/why_did_you_get_fired/');
        expect(true, isValidLink);
      });
      test("Reddit link to homepage", () {
        bool isValidLink = validateLink('https://www.reddit.com/');
        expect(false, isValidLink);
      });
      test("Reddit link to subreddit", () {
        bool isValidLink = validateLink('https://www.reddit.com/AskReddit');
        expect(false, isValidLink);
      });
      test("Link to a non-reddit site", () {
        bool isValidLink = validateLink('https://www.google.com/');
        expect(false, isValidLink);
      });
      test("Use a string instead of a link", () {
        bool isValidLink = validateLink('reddit-2-video');
        expect(false, isValidLink);
      });
    });
  });
}
