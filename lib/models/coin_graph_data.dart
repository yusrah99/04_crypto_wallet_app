

class GraphData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;

  GraphData({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  // Convert list from API to GraphData 
  factory GraphData.fromList(List<dynamic> data) {
    return GraphData(
      time: DateTime.fromMicrosecondsSinceEpoch(data[0]),
      open: (data[1] as num).toDouble(),
      high: (data[2] as num).toDouble(),
      low: (data[3] as num).toDouble(),
      close: (data[4] as num).toDouble(),
    );
  }

  //  Convert GraphData to Map for Hive 
  Map<String, dynamic> toMap() {
    return {
      'time': time.microsecondsSinceEpoch,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
    };
  }

  //  Convert Map from Hive back to GraphData 
  factory GraphData.fromMap(Map<dynamic, dynamic> map) {
    return GraphData(
      time: DateTime.fromMicrosecondsSinceEpoch(map['time']),
      open: (map['open'] as num).toDouble(),
      high: (map['high'] as num).toDouble(),
      low: (map['low'] as num).toDouble(),
      close: (map['close'] as num).toDouble(),
    );
  }
}
