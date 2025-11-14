import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hng4_cryptowallet_app/models/coin_graph_data.dart';
import 'package:hng4_cryptowallet_app/models/coin_list.dart';
import 'package:http/http.dart' as http;

class CoinsDetail extends StatefulWidget {
  const CoinsDetail({super.key, required this.coin});

  final CoinList coin;

  @override
  State<CoinsDetail> createState() => _CoinsDetailState();
}

class _CoinsDetailState extends State<CoinsDetail> {
  List<GraphData> ohlcData = [];
  bool isLoading = true;
  bool isError = false;

  double minY = 0;
  double maxY = 0;

  String selectedRange = '7';
  final dataranges = {
    '24h': '1',
    '7d': '7',
    '1m': '30',
    '6m': '180',
    '1y': '365',
  };

  static const String graphBox = 'graphBox';

  @override
  void initState() {
    super.initState();
    fetchGraphDataWithCache(selectedRange);
  }

  Future<void> fetchGraphDataWithCache(String days) async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final box = Hive.box(graphBox);
    final key = '${widget.coin.id}-$days';

    try {
      final url =
          'https://api.coingecko.com/api/v3/coins/${widget.coin.id}/ohlc?vs_currency=usd&days=$days';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        ohlcData = data.map((item) => GraphData.fromList(item)).toList();

        final List<Map<String, dynamic>> mapList =
            ohlcData.map((e) => e.toMap()).toList();
        await box.put(key, mapList);
      } else {
        throw Exception('Failed to load chart from API');
      }
    } catch (e) {
      print('API failed, loading from Hive: $e');
      List<dynamic> mapList = box.get(key, defaultValue: []);
      ohlcData = mapList.map((map) => GraphData.fromMap(map)).toList();
      if (ohlcData.isEmpty) {
        setState(() {
          isError = true;
          isLoading = false;
        });
        return;
      }
    }

    if (ohlcData.isNotEmpty) {
      minY = ohlcData.map((e) => e.low).reduce((a, b) => a < b ? a : b);
      maxY = ohlcData.map((e) => e.high).reduce((a, b) => a > b ? a : b);
      double padding = (maxY - minY) * 0.1;
      minY -= padding;
      maxY += padding;
    }

    setState(() {
      isLoading = false;
    });
  }

  List<FlSpot> getChartSpots() {
    return ohlcData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.close))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final coin = widget.coin;

    return Scaffold(
      appBar: AppBar(
        title: Text(coin.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Coin info card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.teal[700],
                  child: Row(
                    children: [
                      Image.network(
                        coin.imageurl,
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              coin.name,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              coin.symbol.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Price: \$${coin.currentprice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Range selector
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: dataranges.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  String key = dataranges.keys.elementAt(index);
                  bool isSelected = selectedRange == dataranges[key];
                  return ElevatedButton(
                    onPressed: () async {
                      selectedRange = dataranges[key]!;
                      await fetchGraphDataWithCache(selectedRange);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.teal[700] : Colors.grey.shade300,
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                    ),
                    child: Text(key),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Chart
            Container(
              height: 350,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : isError
                      ? const Center(child: Text('Failed to load chart'))
                      : LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: (ohlcData.length - 1).toDouble(),
                            minY: minY,
                            maxY: maxY,
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: true,
                              drawVerticalLine: true,
                              horizontalInterval: (maxY - minY) / 5,
                              verticalInterval:
                                  (ohlcData.length / 6).ceilToDouble(),
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey.shade300,
                                strokeWidth: 1,
                              ),
                              getDrawingVerticalLine: (value) => FlLine(
                                color: Colors.grey.shade300,
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: (ohlcData.length / 6).ceilToDouble(),
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index < 0 || index >= ohlcData.length)
                                      return Container();
                                    final date = ohlcData[index].time;
                                    return Text(
                                      "${date.month}/${date.day}",
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: (maxY - minY) / 5,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      "\$${value.toStringAsFixed(0)}",
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              rightTitles:
                                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles:
                                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                left: BorderSide(color: Colors.black26),
                                bottom: BorderSide(color: Colors.black26),
                                top: BorderSide(color: Colors.transparent),
                                right: BorderSide(color: Colors.transparent),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: getChartSpots(),
                                isCurved: true,
                                color: Colors.orangeAccent,
                                barWidth: 2,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
            ),

            const SizedBox(height: 16),

            // Additional Coin Info container 
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Coin Info',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Market Cap:', '\$${coin.marketCap.toStringAsFixed(2)}'),
                      _buildInfoRow('24h High:', '\$${coin.high24h.toStringAsFixed(2)}'),
                      _buildInfoRow('24h Low:', '\$${coin.low24h.toStringAsFixed(2)}'),
                      _buildInfoRow('Total Volume:', '\$${coin.totalVolume.toStringAsFixed(2)}'),
                      _buildInfoRow('Circulating Supply:', '${coin.circulatingSupply.toStringAsFixed(0)}'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // method to build a row with label and value
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.black, fontSize: 16)),
        ],
      ),
    );
  }
}
