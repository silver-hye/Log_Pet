class ActivityLog {
  String logId;
  DateTime timestamp;
  String action;
  String content;

  ActivityLog({
    required this.action,
    required this.content,
    String? logId,
    DateTime? timestamp,
  })  : logId = logId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'content': content,
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      logId: map['logId'],
      timestamp: DateTime.parse(map['timestamp']),
      action: map['action'],
      content: map['content'],
    );
  }
}