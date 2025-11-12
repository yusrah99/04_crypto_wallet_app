import 'package:http/http.dart' as http;
import 'package:hng4_cryptowallet_app/models/coin_list.dart';
import 'dart:convert'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';


final String apiKey = dotenv.env['API_KEY'] ?? '';

class CoinListApiService {
  final String _baseUrl = 'https://api.coingecko.com/api/v3';
  final headers = {
    'x-cg-demo-api-key': apiKey,

  };
  // List for search featrue this will fetch the coin list of 100 from coingecko API

  Future<List<CoinList>> fetchCoinList() async {
    //fetching the coin list from coingecko API endpoint 
    //converting the string url to Uri object for dart 
    final response = await http.get(Uri.parse('$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false'),
    headers:headers,
    );

    // responce 
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => CoinList.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load coin list');
    }
  }


  // List for home page to fetch top 10 coins by market cap
  Future<List<CoinList>> fetchTopCoins() async {
    final response = await http.get(Uri.parse('$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=true'),
    headers:headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => CoinList.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top coins');
    }
  }
}