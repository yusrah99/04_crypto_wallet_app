
class GraphData{
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

// takes the array and converts it to dart obkect 
// no need to incude the ID that is done in the api call 
factory GraphData.fromList(List<dynamic> data){
  return GraphData(
    time: DateTime.fromMicrosecondsSinceEpoch(data[0]), 
    open: (data[1] as num).toDouble(), 
    high: (data[2] as num).toDouble(), 
    low: (data[3] as num).toDouble(), 
    close: (data[4] as num).toDouble(),
    );

}
}

