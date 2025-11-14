
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hng4_cryptowallet_app/UI/all_coins.dart';
import 'package:hng4_cryptowallet_app/UI/coins_detail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import '../models/coin_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// button actions
final actions = [
  {'icon': Icons.arrow_outward, 'text': 'Send'},
  {'icon': Icons.call_received, 'text': 'Receive'},
  {'icon': Icons.add, 'text': 'Add'},
];

class _HomePageState extends State<HomePage> {
  List<CoinList> topCoins = [];
  bool isLoading = true;
  bool isError = false;

  static const String coinBox = 'coinsBox';

  @override
  void initState() {
    super.initState();
    fetchTopCoins();
  }

  Future<void> fetchTopCoins() async {
    final String apiKey = dotenv.env['API_KEY'] ?? '';
    const String baseUrl = 'https://api.coingecko.com/api/v3';
    final headers = {'x-cg-demo-api-key': apiKey};

    //  Load cached coins first
    var box = Hive.box(coinBox);
    if (box.isNotEmpty) {
      setState(() {
        topCoins = box.values.map((map) => CoinList.fromMap(map)).take(10).toList();
        isLoading = false;
      });
    }

    // Fetch fresh top coins from API
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=true'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<CoinList> coins = data.map((json) => CoinList.fromJson(json)).toList();

        // Update Hive
        await box.clear();
        for (var coin in coins) {
          await box.put(coin.id, coin.toMap());
        }

        // Update UI
        setState(() {
          topCoins = coins;
          isLoading = false;
          isError = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('API fetch failed, using Hive data if available: $e');
      if (topCoins.isEmpty) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Text(
                'CryptoPal',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[700],
                ),
              ),
            ),

            // Balance container
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Available Balance',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '\$0.00',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      // Buttons for Send, Receive, Add
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 3.0,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(
                            3,
                            (index) {
                              return ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 4),
                                ),
                                onPressed: () {
                                  print('${actions[index]} clicked');
                                },
                                icon: Icon(
                                  actions[index]['icon'] as IconData,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                label: Text(
                                  actions[index]['text'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Top Movers container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : isError
                            ? const Center(
                                child: Text('Failed to load top coins'),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Top Movers',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                              builder: (context) {
                                                return const AllCoins();
                                              },
                                            ));
                                          },
                                          child: const Text('See All'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // List of coins
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: topCoins.length,
                                      itemBuilder: (context, index) {
                                        final coin = topCoins[index];
                                        final sparkline = coin.sparkline_in_7d;

                                        double minY, maxY;

                                        if (sparkline != null &&
                                            sparkline.isNotEmpty) {
                                          minY = sparkline
                                              .reduce((a, b) => a < b ? a : b)
                                              .toDouble();
                                          maxY = sparkline
                                              .reduce((a, b) => a > b ? a : b)
                                              .toDouble();
                                        } else {
                                          minY = 0;
                                          maxY = 0;
                                        }

                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CoinsDetail(coin: coin),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 12),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Image.network(
                                                  coin.imageurl,
                                                  width: 40,
                                                  height: 40,
                                                ),
                                                const SizedBox(width: 10),

                                                // coin name and symbol
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        coin.name,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      Text(
                                                        coin.symbol.toUpperCase(),
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // price
                                                Column(
                                                  children: [
                                                    Text(
                                                      "\$${coin.currentprice.toStringAsFixed(2)}",
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 8),

                                                // sparkline chart
                                                sparkline != null &&
                                                        sparkline.isNotEmpty
                                                    ? SizedBox(
                                                        height: 50,
                                                        width: 100,
                                                        child: LineChart(
                                                          LineChartData(
                                                            minY: minY,
                                                            maxY: maxY,
                                                            minX: 0,
                                                            maxX: (sparkline
                                                                        .length -
                                                                    1)
                                                                .toDouble(),
                                                            lineTouchData:
                                                                LineTouchData(
                                                                    enabled:
                                                                        false),
                                                            gridData: FlGridData(
                                                                show: false),
                                                            borderData:
                                                                FlBorderData(
                                                                    show: false),
                                                            titlesData:
                                                                FlTitlesData(
                                                                    show: false),
                                                            lineBarsData: [
                                                              LineChartBarData(
                                                                spots: sparkline
                                                                    .asMap()
                                                                    .entries
                                                                    .map((e) => FlSpot(
                                                                        e.key
                                                                            .toDouble(),
                                                                        (e.value
                                                                                as num)
                                                                            .toDouble()))
                                                                    .toList(),
                                                                isCurved: true,
                                                                color: Colors.orangeAccent,
                                                                barWidth: 1,
                                                                dotData: FlDotData(
                                                                    show: false),
                                                                belowBarData:
                                                                    BarAreaData(
                                                                        show:
                                                                            false),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox.shrink(),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
