import 'package:logger/src/logger.dart';
import 'package:logger/src/log_printer.dart';
import 'package:logger/src/ansi_color.dart';

/// A decorator for a [LogPrinter] that allows for the prepending of every
/// line in the log output with a string for the level of that log. For
/// example:
///
/// ```
/// PrefixPrinter(PrettyPrinter());
/// ```
///
/// Would prepend "DEBUG" to every line in a debug log. You can supply
/// parameters for a custom message for a specific log level.

class PrefixPrinter extends LogPrinter {
  final LogPrinter _realPrinter;
  late Map<Level, String> _prefixMap;

  PrefixPrinter(this._realPrinter,
      {debug, verbose, wtf, info, warning, error}) {
    _prefixMap = {
      Level.debug: debug ?? 'DEBUG',
      Level.verbose: verbose ?? 'VERBOSE',
      Level.wtf: wtf ?? 'WTF',
      Level.info: info ?? 'INFO',
      Level.warning: warning ?? 'WARNING',
      Level.error: error ?? 'ERROR',
    };

    var len = _longestPrefixLength();
    _prefixMap.forEach((k, v) => _prefixMap[k] = '${v.padLeft(len)} ');
  }

  @override
  List<String> log(LogEvent event) {
    var realLogs = _realPrinter.log(event);

    AnsiColor errorColor = _getLevelColor(event.level);
    return realLogs.map((item) {
      String prefix = _prefixMap[event.level] ?? '';
      String line = errorColor.resetForeground +
          errorColor(prefix) +
          errorColor.resetBackground +
          item;
      return line;
    }).toList();

    // return realLogs.map((s) => '${_prefixMap[event.level]}$s').toList();
  }

  int _longestPrefixLength() {
    var compFunc = (String a, String b) => a.length > b.length ? a : b;
    return _prefixMap.values.reduce(compFunc).length;
  }

  final levelColors = {
    Level.verbose: AnsiColor.fg(AnsiColor.grey(0.5)),
    Level.debug: AnsiColor.none(),
    Level.info: AnsiColor.fg(12),
    Level.warning: AnsiColor.fg(208),
    Level.error: AnsiColor.fg(196),
    Level.wtf: AnsiColor.fg(199),
  };

  AnsiColor _getLevelColor(Level level) {
    return levelColors[level]!;
  }
}
