// model class of coin list from coin gecko API 
class CoinList {
  final String id;
  final String name;
  final String symbol;
  final String imageurl;
  final double currentprice;

// initializing the constructor named-parameter
  CoinList({
    required this.id,
    required this.name,
    required this.symbol,
    this.imageurl = '',
    this.currentprice = 0.0,
  });


  factory CoinList.fromJson(Map<String, dynamic>json){
    return CoinList(
      id: json['id'] ?? '', 
      name: json['name'] ?? '', 
      symbol: json['symbol'] ?? '',
      imageurl: json['image'] ?? '',
      currentprice: (json['current_price'] != null) ? json['current_price'].toDouble() : 0.0,
      );

  }

}
