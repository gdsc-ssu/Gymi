/// [DropInfo] is a data structure designed to collect and organize
/// various information from the drop event stream.
class DropInfo {
  late final int timestamp;

  DropInfo(Map<dynamic, dynamic> event) {
    timestamp = event[DropEventKey.timestamp.name] ?? -1;
  }
}

/// Enum representing the different keys used in the drop event.
enum DropEventKey { timestamp }
