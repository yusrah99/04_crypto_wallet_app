# Flutter Crypto Wallet App

A mobile cryptocurrency wallet app built with Flutter that allows users to view crypto prices, track coins, and visualize coin trends with interactive charts.

## 📱 Demo Video
🎥 Watch App Walkthrough https://drive.google.com/file/d/1LnG8evywjOBy5XWM_1sWbjveoEt2knDM/view?usp=drive_link

This video demonstrates the full app flow: adding, viewing, editing, and deleting products.

---

## 📦 Download APK
📲 Download Release APK https://appetize.io/app/b_l2kajkg5xxalxofajfazcjszty

You can install and test the app directly on your Android device.

---

## 💻 GitHub Repository
🔗 [GitHub Repository] https://github.com/yusrah99/04_crypto_wallet_app

## Features

- View top and all cryptocurrencies
- Search for coins by name or symbol
- Detailed coin page with price, high/low, and historical graph
- Interactive graph with selectable ranges (24h, 7d, 1m, 6m, 1y)
- Light and Dark theme toggle
- Real-time updates from CoinGecko API

## How to Run
1. Clone the repository  
   ```bash
   git clone https://github.com/yusrah99/04_crypto_wallet_app
2. Clone the repository  
     cd 04_crypto_wallet_app

3.  Install flutter dependencies
    ```
      flutter pub get
5. Run the app on an emulator or connected device
   ```

   flutter run
6. Build a release APK
   flutter build apk --release
   
## Dependencies

flutter_dotenv
 - for environment variables

http
 - for API requests

fl_chart
 - for interactive line charts

flutter
 - for building cross-platform apps

## API

Data is fetched from CoinGecko API
:

/coins/markets - for top coins and all coins data

/coins/{id}/ohlc - for OHLC chart data


## 🧑‍💻 Developer

Yusrah Temitope Afiz- Ogun
Flutter Developer | 
📧yusraht.afiz99@gmail.com

🔗 LinkedIn




A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
