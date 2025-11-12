
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hng4_cryptowallet_app/Service/api_service.dart';
import 'package:hng4_cryptowallet_app/models/coin_list.dart';
import 'package:http/http.dart' as http;

class AllCoins extends StatefulWidget {
  const AllCoins({super.key});

  @override
  State<AllCoins> createState() => _AllCoinsState();
}

class _AllCoinsState extends State<AllCoins> {
  // initialize as an empty list to avoid null/late issues
  late Future<List<CoinList>> _futureCoins;
 
  
  @override
  void initState(){
    super.initState();
    _futureCoins = CoinListApiService().fetchCoinList();

    // TODO: load coins into the list, e.g. via network request
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Coins'),
      ),
      body: FutureBuilder<List<CoinList>>(
        future: _futureCoins,
        builder: (context, snapshot) {
          //error handling and data display
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
            
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No coins found.'));
          } else {
            // Display only the first 100 coins
             final coins = snapshot.data!.take(100).toList();
            return ListView.builder(
              itemCount: coins.length,
              itemBuilder: (context, index) {
                final coin = coins[index];
                return ListTile(
                  title: Text(coin.name),
                  subtitle: Text(coin.symbol),
                  leading: coin.imageurl.isNotEmpty
                      ? Image.network(coin.imageurl, width: 30, height: 30)
                      : null,
                  trailing: Text('\$${coin.currentprice.toStringAsFixed(2)}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}