
/*import 'package:flutter/material.dart';
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
}*/

/*import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hng4_cryptowallet_app/Service/api_service.dart';
import 'package:hng4_cryptowallet_app/models/coin_list.dart';

class AllCoins extends StatefulWidget {
  const AllCoins({super.key});

  @override
  State<AllCoins> createState() => _AllCoinsState();
}

class _AllCoinsState extends State<AllCoins> {

  late Future<List<CoinList>> _futureCoins;

  //text editing controller for search field
  final TextEditingController _searchController = TextEditingController();
  List<CoinList> _allCoins = [];
  List<CoinList> _filteredCoins = [];

  @override
  void initState() {
    super.initState();
    _futureCoins = CoinListApiService().fetchCoinList();

    _searchController.addListener((){
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredCoins = (_allCoins as List<CoinList>).where((coin) {
          final nameLower = coin.name.toLowerCase();
          final symbolLower = coin.symbol.toLowerCase();
          return nameLower.contains(query) || symbolLower.contains(query);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: const Text(
          'All Coins',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          //building the list view with future builder
          child: Column(
            children: [
              // search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search coins...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),

              SizedBox(height: 20),
             
              // coin list
              Expanded(
                child: FutureBuilder<List<CoinList>>(
                  future: _futureCoins,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No coins found.'));
                    } else {
                      final coins = snapshot.data!.take(100).toList();
                      // If search query is not empty, filter the coins
                      final displayCoins = _searchController.text.isEmpty
                          ? coins
                          : _filteredCoins;


                      return ListView.builder(
                        itemCount: coins.length,
                        itemBuilder: (context, index) {
                          final coin = _filteredCoins[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: coin.imageurl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        coin.imageurl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.image_not_supported,
                                      size: 40, color: Colors.grey),
                              title: Text(
                                coin.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(coin.symbol),
                              trailing: Text(
                                  '\$${coin.currentprice.toStringAsFixed(2)}'),
                              // You can add onTap to navigate to coin details page
                              onTap: () {
                                // TODO: navigate to coin details page
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:hng4_cryptowallet_app/Service/api_service.dart';
import 'package:hng4_cryptowallet_app/models/coin_list.dart';

class AllCoins extends StatefulWidget {
  const AllCoins({super.key});

  @override
  State<AllCoins> createState() => _AllCoinsState();
}

class _AllCoinsState extends State<AllCoins> {
  late Future<List<CoinList>> _futureCoins;

  final TextEditingController _searchController = TextEditingController();
  List<CoinList> _allCoins = [];
  List<CoinList> _filteredCoins = [];

  @override
  void initState() {
    super.initState();
    _futureCoins = CoinListApiService().fetchCoinList();

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredCoins = _allCoins
            .where((coin) =>
                coin.name.toLowerCase().contains(query) ||
                coin.symbol.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: const Text(
          'All Coins',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search coins...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
              // Coin list
              Expanded(
                child: FutureBuilder<List<CoinList>>(
                  future: _futureCoins,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No coins found.'));
                    } else {
                      // Load first 100 coins only once
                      if (_allCoins.isEmpty) {
                        _allCoins = snapshot.data!.take(100).toList();
                        _filteredCoins = _allCoins;
                      }

                      return ListView.builder(
                        itemCount: _filteredCoins.length,
                        itemBuilder: (context, index) {
                          final coin = _filteredCoins[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: coin.imageurl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        coin.imageurl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.image_not_supported,
                                      size: 40, color: Colors.grey),
                              title: Text(
                                coin.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(coin.symbol),
                              trailing: Text(
                                  '\$${coin.currentprice.toStringAsFixed(2)}'),
                              onTap: () {
                                // TODO: navigate to coin details page
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

