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

