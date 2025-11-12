
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hng4_cryptowallet_app/models/coin_graph_data.dart';
import 'package:http/http.dart' as http;
import '../models/coin_list.dart';

class CoinsDetail extends StatefulWidget {
  const CoinsDetail({super.key, required this.coin});

  // Passing the coin list details into coin
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
  // default range of one week
  String selectedRange = '7';

  final dataranges = {
    '24h': '1',
    '7d': '7',
    '1m': '30',
    '6m': '180',
    '1y': '365',
  };

  @override
  void initState() {
    super.initState();
    fetchGraphData(selectedRange);
  }

  // Method to fetch graph data
  Future<void> fetchGraphData(String days) async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final url =
        'https://api.coingecko.com/api/v3/coins/${widget.coin.id}/ohlc?vs_currency=usd&days=$days';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          ohlcData = data.map((item) => GraphData.fromList(item)).toList();
          if (ohlcData.isNotEmpty) {
            minY =
                ohlcData.map((e) => e.low).reduce((a, b) => a < b ? a : b);
            maxY =
                ohlcData.map((e) => e.high).reduce((a, b) => a > b ? a : b);
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  // Preparing data for fl_chart
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
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Coin details container
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                
                child: Container(
                  width: double.infinity,
                  height: 130,
                  color: Colors.teal[700],
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Image.network(
                        coin.imageurl,
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              coin.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              coin.symbol.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white70),
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

            const SizedBox(height: 10),

            // Chart container
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Range buttons
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: dataranges.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        String key = dataranges.keys.elementAt(index);
                        bool isSelected = selectedRange == dataranges[key];
                        return ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              selectedRange = dataranges[key]!;
                              isLoading = true;
                              isError = false;
                            });
                            try {
                              await fetchGraphData(selectedRange);
                            } catch (_) {
                              setState(() {
                                isError = true;
                                isLoading = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? Colors.teal[700]
                                : Colors.grey.shade300,
                            foregroundColor:
                                isSelected ? Colors.white : Colors.black,
                          ),
                          child: Text(key),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Line chart
                  Container(
                    height: 350,
                    width: double.infinity,
                    color: Colors.transparent,
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

                                  // Grid lines
                                  gridData: FlGridData(
                                    show: true,
                                    drawHorizontalLine: true,
                                    drawVerticalLine: true,
                                    horizontalInterval: (maxY - minY) / 5,
                                    verticalInterval:
                                        (ohlcData.length / 6).floorToDouble(),
                                    getDrawingHorizontalLine: (value) =>
                                        FlLine(
                                            color: Colors.grey.shade300,
                                            strokeWidth: 1),
                                    getDrawingVerticalLine: (value) => FlLine(
                                        color: Colors.grey.shade300,
                                        strokeWidth: 1),
                                  ),

                                  // Border
                                  borderData: FlBorderData(
                                    show: true,
                                    border: const Border(
                                      left: BorderSide(color: Colors.black26),
                                      bottom: BorderSide(color: Colors.black26),
                                      top: BorderSide(color: Colors.transparent),
                                      right:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                  ),

                                  // Axis titles
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval:
                                            (ohlcData.length / 6).floorToDouble(),
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
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return Text("\$${value.toStringAsFixed(0)}",
                                              style: const TextStyle(fontSize: 10));
                                        },
                                      ),
                                    ),
                                    rightTitles:
                                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles:
                                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),

                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: ohlcData
                                          .asMap()
                                          .entries
                                          .map((e) => FlSpot(
                                              e.key.toDouble(), e.value.close))
                                          .toList(),
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

                  const SizedBox(height: 20),

                  // Additional container
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(12),
                      child: Container(
                        width: double.infinity,
                        color: Colors.transparent,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Coin Info',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Market Cap:', style: TextStyle(color: Colors.black,fontSize: 16,)),
                                    Text('\$${coin.marketCap.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black,fontSize: 16,)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('24h High:', style: TextStyle(color: Colors.black,fontSize: 16,)),
                                    Text('\$${coin.high24h.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 16,)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('24h Low:', style: TextStyle(color: Colors.black, fontSize: 16,)),
                                    Text('\$${coin.low24h.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 16,)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total Volume:', style: TextStyle(color: Colors.black, fontSize: 16,)),
                                    Text('\$${coin.totalVolume.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 16,)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Circulating Supply:', style: TextStyle(color: Colors.black, fontSize: 16,)),
                                    Text('${coin.circulatingSupply.toStringAsFixed(0)}', style: const TextStyle(color: Colors.black, fontSize: 16,)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ),
                    ),
                                          
                                        

                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
