import 'package:flutter/material.dart';
import 'package:hng4_cryptowallet_app/Service/api_service.dart';
import 'package:hng4_cryptowallet_app/UI/all_coins.dart';
import 'package:hng4_cryptowallet_app/UI/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

 Future <void> main() async {
  // load env file
  await dotenv.load(fileName: "key.env");
  runApp(const MyApp());
// see if api service works
  final apiService = CoinListApiService();
  try {
    final coinList = await apiService.fetchCoinList();
    print('Fetched ${coinList.length} coins');
  } catch (e) {
    print('Error fetching coin list: $e');
    
    
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AllCoins(),
    );
  }
}

