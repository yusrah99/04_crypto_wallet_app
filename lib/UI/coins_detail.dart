
import 'package:flutter/material.dart';
import '../models/coin_list.dart';


class CoinsDetail extends StatefulWidget {
  const CoinsDetail({super.key, required this.coin});
  
  // passing the coin list details into coin 
  final CoinList coin;


  @override
  State<CoinsDetail> createState() => _CoinsDetailState();
}

class _CoinsDetailState extends State<CoinsDetail> {
  @override
  Widget build(BuildContext context) {
    //accessing coin 
    final coin = widget.coin;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coins Detail'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height:20),

          // first containeer for overall coin details 
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(20),
              
              
              child: Container(
                width: 250,
                height: 100,
                color: Colors. amber,
                   child: Row(
                    children: [
                      // Coin image
                      Image.network(
                        coin.imageurl,
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 16),

                      // Coin info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coin.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              coin.symbol.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Price: \$${coin.currentprice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
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
          
          // Chart goes here
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 300 ,
              color: Colors.pink
            ),
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 300, 
              color:Colors.blue
            ),
          )
        ],
      )
      );
    
  }
}