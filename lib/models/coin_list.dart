// model class of coin list from coin gecko API 
class CoinList {
  final String id;
  final String name;
  final String symbol;
  final String imageurl;
  final double currentprice;
  final double pricechangepercentage24h;
  final List<double> sparkline_in_7d;
  final double marketCap;
  final double high24h;
  final double low24h;
  final double totalVolume;
  final double circulatingSupply;


// initializing the constructor named-parameter
  CoinList({
    required this.id,
    required this.name,
    required this.symbol,
    this.imageurl = '',
    this.currentprice = 0.0,
    this.pricechangepercentage24h = 0.0,
    this.sparkline_in_7d = const [],
    required this.marketCap,
    required this.high24h,
    required this.low24h,
    required this.totalVolume,
    required this.circulatingSupply,

    
  });


  factory CoinList.fromJson(Map<String, dynamic>json){
    return CoinList(
      id: json['id'] ?? '', 
      name: json['name'] ?? '', 
      symbol: json['symbol'] ?? '',
      imageurl: json['image'] ?? '',
      currentprice: (json['current_price'] != null) ? json['current_price'].toDouble() : 0.0,
      pricechangepercentage24h: (json['price_change_percentage_24h'] != null) 
      ? json['price_change_percentage_24h'].toDouble() : 0.0,
      sparkline_in_7d: json['sparkline_in_7d'] != null && json['sparkline_in_7d']['price'] != null
      ? List<double>.from(json['sparkline_in_7d']['price'].map((x) => x.toDouble())) : [],
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0,
      high24h: (json['high_24h'] as num?)?.toDouble() ?? 0,
      low24h: (json['low_24h'] as num?)?.toDouble() ?? 0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0,
      circulatingSupply: (json['circulating_supply'] as num?)?.toDouble() ?? 0,

      
      );

  }

}
