import 'package:flutter/material.dart';
import 'package:hng4_cryptowallet_app/Service/api_service.dart';
import 'package:hng4_cryptowallet_app/models/coin_list.dart';
import 'package:hive/hive.dart';
import 'coins_detail.dart'; 

class AllCoins extends StatefulWidget {
  const AllCoins({super.key});

  @override
  State<AllCoins> createState() => _AllCoinsState();
}

class _AllCoinsState extends State<AllCoins> {
  final TextEditingController _searchController = TextEditingController();
  List<CoinList> _allCoins = [];
  List<CoinList> _filteredCoins = [];
  bool isLoading = true;
  bool isError = false;

  static const String coinBox = 'coinsBox';

  @override
  void initState() {
    super.initState();
    loadCoins();

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

  Future<void> loadCoins() async {
    var box = Hive.box(coinBox);

    //  Load cached coins first
    if (box.isNotEmpty) {
      setState(() {
        _allCoins = box.values.map((map) => CoinList.fromMap(map)).toList();
        _filteredCoins = _allCoins;
        isLoading = false;
      });
    }

    // Fetch fresh coins from API
    try {
      List<CoinList> coins = await CoinListApiService().fetchCoinListWithCache();

      // Update Hive
      await box.clear();
      for (var coin in coins) {
        await box.put(coin.id, coin.toMap());
      }

      // Update UI
      setState(() {
        _allCoins = coins;
        _filteredCoins = _allCoins;
        isLoading = false;
        isError = false;
      });
    } catch (e) {
      print('API fetch failed, using Hive data if available: $e');
      if (_allCoins.isEmpty) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : isError
                        ? const Center(child: Text('Failed to load coins'))
                        : ListView.builder(
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
                                      blurRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: coin.imageurl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  subtitle: Text(coin.symbol),
                                  trailing: Text(
                                      '\$${coin.currentprice.toStringAsFixed(2)}'),
                                  onTap: () {
                                    // Navigate to coin details page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CoinsDetail(coin: coin),
                                      ),
                                    );
                                  },
                                ),
                              );
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

