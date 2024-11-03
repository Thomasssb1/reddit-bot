import 'package:reddit_2_video/command/command.dart';
import 'package:args/args.dart';
import 'package:reddit_2_video/config/end_card.dart';
import 'dart:io';
import 'package:reddit_2_video/exceptions/exceptions.dart';
import 'package:reddit_2_video/ffmpeg/file_type.dart';
import 'package:reddit_2_video/post/reddit_comment_sort_type.dart';
import 'package:reddit_2_video/post/reddit_post_sort_type.dart';
import 'package:reddit_2_video/post/reddit_video_type.dart';
import 'package:reddit_2_video/subtitles/alternate.dart';
import 'package:reddit_2_video/utils/substation_alpha_subtitle_color.dart';
import 'package:reddit_2_video/config/voice.dart';
import 'package:reddit_2_video/config/music.dart';
import 'package:reddit_2_video/ffmpeg/fps.dart';
export 'package:reddit_2_video/command/command.dart';
import 'package:reddit_2_video/utils/boolean_conversion.dart';

class ParsedCommand {
  final Command? _command;
  final ArgResults? _args;
  final Directory _prePath;
  final ArgParser? _parser;

  ParsedCommand({
    required Command? command,
    required ArgResults args,
  })  : _command = command,
        _args = args,
        _prePath = _determinePath(args),
        _parser = null;

  ParsedCommand.defaultCommand({
    required ArgResults args,
  })  : _command = Command.defaultCommand,
        _args = args,
        _prePath = _determinePath(args),
        _parser = null;

  ParsedCommand.noArgs({
    required Command command,
    required ArgParser parser,
  })  : _command = command,
        _args = null,
        _prePath = Directory.current,
        _parser = parser;

  ParsedCommand.none()
      : _command = null,
        _args = null,
        _prePath = Directory.current,
        _parser = null;

  factory ParsedCommand.parse(List<String> args) {
    // init parser
    var parser = ArgParser();
    // add parser options
    parser.addOption('subreddit');
    parser.addOption('sort',
        defaultsTo: 'hot', abbr: 's', allowed: ['hot', 'new', 'top', 'rising']);
    parser.addOption('comment-sort',
        defaultsTo: 'top',
        allowed: ['top', 'best', 'new', 'controversial', 'old', 'q&a']);
    parser.addOption('count',
        defaultsTo: '8', help: 'Minimum number of comments.');
    parser.addOption('type', defaultsTo: 'post', allowed: [
      'comments',
      'post',
      'multi'
    ], allowedHelp: {
      'comments':
          'Creates a video that contains a post title, body and a set number of comments for that post.',
      'post':
          'Creates a video that only contains a single post with the title and body.',
      'multi':
          'Creates a video that contains multiple posts from a single subreddit, not including comments.'
    });
    // TODO: Look into getting info from text such as female/male when assigning voices in future
    parser.addMultiOption('alternate',
        valueHelp:
            'alternate-tts(on/off),alternate-colour(on/off),title-colour(hex)',
        help:
            'tts - alternate TTS voice for each comment/post (defaults to off)\ncolour - alternate text colour for each comment/post (defaults to off)\ntitle-colour - determine title colour for post (defaults to #FF0000).',
        defaultsTo: ['off', 'off', '#0000FF']);
    parser.addFlag('post-confirmation', defaultsTo: false);
    parser
      ..addFlag('nsfw', defaultsTo: true)
      ..addFlag('spoiler',
          defaultsTo: false,
          help:
              'Add a spoiler to the video which hides the image/text before showing for 3s.');
    parser.addFlag('ntts',
        defaultsTo: true,
        help:
            'Determines whether to use neural tts or normal tts. (This will only affect usage if aws polly is active).');
    parser.addFlag('aws',
        defaultsTo: true,
        help:
            'Whether or not to use AWS Polly, but this requires setup of aws cli as well as correct details.');

    // not implemented
    parser.addFlag('gtts',
        defaultsTo: false,
        hide: true,
        help:
            'Uses googles tts to generae tts which has no cost and is generated online. (not implemented)');
    parser.addOption(
      'accent',
      defaultsTo: 'com.mx',
      hide: true,
      allowed: [
        'com.mx',
        'co.uk',
        'com.au',
        'us',
        'ca',
        'co.in',
        'ie',
        'co.za'
      ],
      help:
          'The accent to be used when not using aws tts.\nUse a top-level-domain from google such as com.mx or co.uk. (not implemented)',
    );

    parser.addOption('voice',
        defaultsTo: 'Matthew', help: 'The voice to use for AWS Polly tts.');

    parser.addOption('repeat',
        help:
            'How many times the program should repeat - does not work for links but works for subreddits.',
        valueHelp: 'integer',
        defaultsTo: '1');
    parser.addOption('video',
        defaultsTo: 'defaults/video1.mp4',
        abbr: 'p',
        valueHelp: 'path-to-video');
    parser.addMultiOption('music', valueHelp: 'path,volume');
    parser.addFlag('youtube-short',
        help:
            'Whether or not to produce the final long form video with several videos split by a minute length as well as the full video.',
        defaultsTo: false);
    parser.addFlag('horror',
        help: 'Lowers the pitch from TTS for creepy stories.',
        defaultsTo: false);
    parser.addOption('output',
        abbr: 'o',
        defaultsTo: 'final',
        help: 'Location where the generated file will be stored.');
    parser.addOption('file-type',
        defaultsTo: 'mp4', allowed: ['mp4', 'avi', 'mov', 'flv']);
    parser.addOption('framerate',
        defaultsTo: '45',
        allowed: ['15', '30', '45', '60', '75', '120', '144'],
        help:
            'The framerate used when generating the video - using a higher framerate will take longer and produce a larger file.');
    parser.addFlag('censor',
        defaultsTo: false,
        help:
            'Censors any innapropriate words. This will only work when using AWS and you need to upload the defaults/lexicons/lexeme.xml file as a lexicon in AWS console.');
    parser.addOption('end-card',
        help: 'Path to a gif & audio that will play at the end of the video.',
        valueHelp: 'path-to-gif');
    parser
      ..addFlag('verbose', abbr: 'v', defaultsTo: false)
      ..addFlag('override', abbr: 'y', defaultsTo: false)
      ..addFlag('dev', abbr: 'd', hide: true, defaultsTo: false);
    parser.addFlag('help', abbr: 'h', hide: true);

    // create a new command
    var flush = parser.addCommand('flush');
    // add a command specific option
    flush.addOption('post',
        abbr: 'p', help: 'Remove a specific reddit post from the visited log.');
    flush.addFlag('dev', abbr: 'd', hide: true, defaultsTo: false);

    var install = parser.addCommand('install');
    install.addFlag('dev', abbr: 'd', hide: true, defaultsTo: false);

    // parse the cli for arguments
    var results = parser.parse(args);

    // if the command was the default generation command
    if (results.command == null) {
      // if the cli contained help argument
      if (results.wasParsed('help')) {
        // output the help message
        return ParsedCommand.noArgs(command: Command.help, parser: parser);
        // if the cli did not contain a subreddit/link
      } else if (!results.wasParsed('subreddit')) {
        throw ArgumentMissingException(
            'Argument <subreddit> is required. \nUse -help to get more information about usage.');
      } else if (results['alternate'].length != 3) {
        throw ArgumentMissingException(
            'The option --alternate needs 3 options each split by a comma. Check --help to see the syntax.');
      } else if (results.wasParsed('gtts')) {
        throw ArgumentNotImplementedException(
            'GTTS does not currently work, in order to get tts you will need to use AWS-Polly which can be enabled by the -aws flag');
      } else if (results.wasParsed('aws') && results.wasParsed('gtts')) {
        throw ArgumentConflictException(
            'Both tts options --aws and --gtts cannot be active at the same time.',
            'aws',
            'gtts');
      } else if (int.tryParse(results['repeat']) == null) {
        throw FormatException(
            'The value provided for --repeat must be an integer.');
      } else if (results.wasParsed('ntts') && results.wasParsed('gtts')) {
        Warning.warn(
            'The flag -ntts does not affect local-tts but only aws tts. Using both flags at the same time will not affect the voice used for local-tts.');
      } else if (results.wasParsed('gtts') && results.wasParsed('censor')) {
        Warning.warn(
            'The flag --censor does not affect local-tts but only aws tts.');
      } else if (results.wasParsed('count') &&
          Uri.tryParse(results['subreddit']) != null) {
        Warning.warn(
            'The option --count does not work with a link, generation will continue but the --count option will be omitted.');
      }
      // return map of command and args
      return ParsedCommand.defaultCommand(args: results);
      // if the command is flush
    } else if (results.command!.name == 'flush') {
      return ParsedCommand(command: Command.flush, args: flush.parse(args));
      // if the command is install
    } else if (results.command!.name == 'install') {
      return ParsedCommand(command: Command.install, args: install.parse(args));
    }
    throw NoCommandException(
        'There is no such command ${results.command?.name}');
  }

  void printHelp({
    String defaultsColourCode = "\x1b[33m",
    String optionsColourCode = "\x1b[35m",
    String flagsColourCode = "\x1b[32m",
  }) {
    if (_parser == null) {
      throw ArgumentMissingException(
          "No parser was provided. Unable to print help message.");
    }

    var usage = _parser.usage;

    var bracketsRegex = RegExp(r'\((defaults.+)\)');
    var sqBracketsRegex = RegExp(r'\[(.*?)\]');
    var dashRegex = RegExp(r'(?!-level|-colour|-domain)(\-\S+)');

    for (final match in bracketsRegex.allMatches(usage)) {
      usage =
          usage.replaceAll(match[0]!, '$defaultsColourCode${match[0]}\x1b[0m');
    }
    for (final match in sqBracketsRegex.allMatches(usage)) {
      if (match[0] != '[no-]') {
        usage =
            usage.replaceAll(match[0]!, '$optionsColourCode${match[0]}\x1b[0m');
      }
    }
    for (final match in dashRegex.allMatches(usage)) {
      usage = usage.replaceAll(match[0]!, '$flagsColourCode${match[0]}\x1b[0m');
    }
    print(usage);
  }

  Command? get name => _command;
  ArgResults? get args => _args;
  String get prePath => _prePath.path;

  // individual argument getters and setters
  String get subreddit => _args!['subreddit'];
  RedditPostSortType get sort => RedditPostSortType.called(args!['sort'])!;
  RedditCommentSortType get commentSort =>
      RedditCommentSortType.called(args!['comment-sort'])!;
  int get commentCount => int.parse(args!['count']);
  RedditVideoType get type => RedditVideoType.called(args!['type'])!;
  Alternate get alternate => Alternate(
        tts: BooleanConversion(args!['alternate'][0]).parseBool(),
        color: BooleanConversion(args!['alternate'][1]).parseBool(),
        titleColour: SubstationAlphaSubtitleColor(args!['alternate'][2]),
      );
  bool get postConfirmation => args!['post-confirmation'];
  bool get nsfw => args!['nsfw'];
  bool get spoiler => args!['spoiler'];
  bool get ntts => args!['ntts'];
  bool get aws => args!['aws'];
  Voice get voice => Voice.called(args!['voice']);
  int get repeat => subredditIsLink ? 1 : int.parse(args!['repeat']);
  // need to figure out what to do with video
  String get videoPath => args!['video'];
  Music? get music => args!['music'].length > 0
      ? Music(
          path: args!['music'][0],
          prePath: prePath,
          volume: args!['music'].length == 2 ? args!['music'][1] : "1.0",
        )
      : null;
  bool get youtubeShort => args!['youtube-short'];
  bool get horror => args!['horror'];
  String get output => args!['output'];
  FileType get fileType => FileType.called(args!['file-type'])!;
  FPS get framerate => FPS.fpsValue(int.parse(args!['framerate']));
  bool get censor => args!['censor'];
  EndCard? get endCard => args!['end-card'] != null
      ? EndCard(
          path: args!['end-card'],
          prePath: prePath,
        )
      : null;
  bool get verbose => args!['verbose'];
  bool get override => args!['override'];

  String? get post => args!['post'];

  T getArg<T>(String key) => _args![key] as T;

  bool get isDefault => _command == Command.defaultCommand;
  bool get isDev => _args?['dev'] ?? false;
  bool get isHelp => _args?['help'] ?? false;
  bool get subredditIsLink =>
      Uri.tryParse(_args!['subreddit'])?.hasAbsolutePath ?? false;

  static Directory _determinePath(ArgResults args) {
    return args['dev']
        ? Directory.current
        : File(Platform.resolvedExecutable).parent.parent;
  }
}
