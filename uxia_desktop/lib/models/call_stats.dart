class CallStats {
  final int totalCalls;
  final int activeCalls;
  final int failedCalls;
  final double averageDuration;
  final double successRate;
  final DateTime lastUpdate;

  CallStats({
    required this.totalCalls,
    required this.activeCalls,
    required this.failedCalls,
    required this.averageDuration,
    required this.successRate,
    required this.lastUpdate,
  });

  factory CallStats.empty() {
    return CallStats(
      totalCalls: 0,
      activeCalls: 0,
      failedCalls: 0,
      averageDuration: 0,
      successRate: 0,
      lastUpdate: DateTime.now(),
    );
  }
}
