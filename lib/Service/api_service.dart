import 'package:hng4_cryptowallet_app/models/coin_graph_data.dart';
import 'package:hng4_cryptowallet_app/models/coin_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';

final String apiKey = dotenv.env['API_KEY'] ?? '';

class CoinListApiService {
  final String _baseUrl = 'https://api.coingecko.com/api/v3';
  final headers = {
    'x-cg-demo-api-key': apiKey,
  };

  static const String coinBox = 'coinsBox';
  static const String graphBox = 'graphBox';

  //  Fetch full coin list with Hive caching
  Future<List<CoinList>> fetchCoinListWithCache() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<CoinList> coins = data.map((json) => CoinList.fromJson(json)).toList();
        
        // Save to Hive
        var box = Hive.box(coinBox);
        await box.clear();
        for (var coin in coins) {
          await box.put(coin.id, coin.toMap());
        }

        return coins;
      } else {
        throw Exception('Failed to load coin list');
      }
    } catch (e) {
      print('Failed to fetch API, loading from Hive: $e');
      var box = Hive.box(coinBox);
      return box.values.map((map) => CoinList.fromMap(map)).toList();
    }
  }

  // Fetch top coins with Hive caching 
  Future<List<CoinList>> fetchTopCoinsWithCache() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=true'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<CoinList> coins = data.map((json) => CoinList.fromJson(json)).toList();

        // Save to Hive (optional: overwrite only top 10 or full list)
        var box = Hive.box(coinBox);
        for (var coin in coins) {
          await box.put(coin.id, coin.toMap());
        }

        return coins;
      } else {
        throw Exception('Failed to load top coins');
      }
    } catch (e) {
      print('Failed to fetch API, loading from Hive: $e');
      var box = Hive.box(coinBox);
      return box.values.map((map) => CoinList.fromMap(map)).take(10).toList();
    }
  }

  // Fetch GraphData with Hive caching
  Future<List<GraphData>> fetchGraphDataWithCache(String coinId, String days) async {
    try {
      final url = '$_baseUrl/coins/$coinId/ohlc?vs_currency=usd&days=$days';
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<GraphData> graphData = data.map((item) => GraphData.fromList(item)).toList();

        // Save to Hive
        var box = Hive.box(graphBox);
        List<Map<String, dynamic>> mapList = graphData.map((e) => e.toMap()).toList();
        await box.put('$coinId-$days', mapList);

        return graphData;
      } else {
        throw Exception('Failed to load OHLC data');
      }
    } catch (e) {
      print('Failed to fetch API, loading from Hive: $e');
      var box = Hive.box(graphBox);
      List<dynamic> mapList = box.get('$coinId-$days', defaultValue: []);
      return mapList.map((map) => GraphData.fromMap(map)).toList();
    }
  }
}
