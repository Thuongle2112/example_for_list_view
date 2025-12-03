# PicList - AI Image Gallery App 🎨

A feature-rich Flutter application for browsing images, reading news, and generating AI images with SDXL model.

## ✨ Features

### 🖼️ Image Gallery
- Browse images from Picsum API with pagination
- **Hero Animation** for smooth image transitions
- **Shimmer Loading** effects
- **Pull-to-Refresh** functionality
- Grid and List view options
- Image detail view with zoom capabilities

### 📰 News Reader
- Fetch and display news articles
- Beautiful card-based UI
- Read full articles in WebView

### 🤖 AI Image Generator
- Generate images using Replicate's SDXL model
- Preset prompts for quick generation
- Chat-like interface with Hive local storage
- View and manage generated images
- Lottie animations for enhanced UX

### 📤 Share Features
- Share images with other apps
- Copy image URLs to clipboard
- Download images
- Share image information

### 🔍 QR Code Features
- Scan QR codes with camera
- Generate QR codes for albums
- Pick QR from gallery
- Test QR functionality

### 📱 Platform Support
- Android ✅
- iOS ✅
- Web ✅
- macOS ✅
- Windows ✅
- Linux ✅

## 🏗️ Architecture

This project follows **Clean Architecture** principles with **BLoC** pattern:

```
lib/
├── core/
│   ├── di/              # Dependency Injection (GetIt)
│   └── router/          # Navigation (GoRouter)
├── data/
│   ├── datasources/     # API calls
│   ├── models/          # Data models
│   ├── repositories/    # Repository implementations
│   └── services/        # AI & other services
├── domain/
│   ├── entities/        # Business entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic
└── presentation/
    ├── bloc/            # BLoC state management
    ├── pages/           # UI screens
    └── widgets/         # Reusable widgets
```

## 📦 Dependencies

### Core
- `flutter_bloc: ^8.1.3` - State management
- `get_it: ^7.6.4` - Dependency injection
- `go_router: ^14.6.2` - Navigation

### Networking
- `dio: ^5.4.0` - HTTP client
- `equatable: ^2.0.5` - Value equality

### UI & Animation
- `shimmer: ^3.0.0` - Shimmer loading effect
- `lottie: ^3.1.2` - Lottie animations
- `pull_to_refresh: ^2.0.0` - Pull to refresh
- `photo_view: ^0.14.0` - Image zoom

### Features
- `qr_flutter: ^4.1.0` - QR generation
- `mobile_scanner: ^5.2.3` - QR scanning
- `share_plus: ^10.1.3` - Share functionality
- `url_launcher: ^6.3.1` - Open URLs
- `image_picker: ^1.1.2` - Pick images
- `hive: ^2.2.3` - Local storage
- `google_mobile_ads: ^5.2.0` - AdMob integration

### Environment
- `flutter_dotenv: ^5.1.0` - Environment variables

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.5.4)
- Dart SDK (>=3.5.4)
- Android Studio / VS Code
- iOS development tools (for macOS)

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd example_for_list_view
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Set up environment variables**

Create a `.env` file in the root directory:
```env
REPLICATE_API_KEY=your_replicate_api_key_here
NEWS_API_KEY=your_news_api_key_here
```

4. **Run the app**
```bash
flutter run
```

## 🔑 API Keys

### Replicate API (for AI Image Generation)
1. Sign up at [replicate.com](https://replicate.com)
2. Get your API token
3. Add to `.env` file

### News API (for News Feed)
1. Sign up at [newsapi.org](https://newsapi.org)
2. Get your API key
3. Add to `.env` file

## 📱 App Structure

### Main Pages
- **Home** (`/home`) - Image gallery with Column/ListView switcher
- **News** (`/news`) - News articles feed
- **AI Chat** (`/ai-chat`) - AI image generation interface
- **QR Scanner** (`/qr-scan`) - QR code scanner
- **Image Detail** (`/detail/:id`) - Detailed image view

### Navigation Flow
```
SplashPage → MainScaffold (Home/News) → Detail Pages
                ↓
            AI Features (Chat, Gallery)
            QR Features (Scan, Generate)
```

## 🎨 Animations & Effects

- **Shimmer Loading**: Replace CircularProgressIndicator
- **Hero Animation**: Smooth image transitions
- **Favorite Animation**: Heart animation on tap
- **Slide Animation**: Bottom sheet transitions
- **Lottie Animations**: Custom vector animations
- **Pull-to-Refresh**: WaterDropHeader effect

See [`ANIMATION_FEATURES.md`](ANIMATION_FEATURES.md) for details.

## 📤 Share Features

- Share images with platform share sheet
- Copy image URLs
- Download images to device
- Share image information

See [`SHARE_FEATURES.md`](SHARE_FEATURES.md) for details.

## 🛠️ Development

### Run tests
```bash
flutter test
```

### Build for production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 📝 Project Status

- ✅ Image Gallery with Clean Architecture
- ✅ News Feed Integration
- ✅ AI Image Generation (SDXL)
- ✅ QR Code Features
- ✅ Share Functionality
- ✅ Multiple Platform Support
- ✅ Animations & Effects
- ✅ Local Storage (Hive)
- ⏳ AdMob Integration (In Progress)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

Pham Le Thuong

## 🙏 Acknowledgments

- [Picsum Photos](https://picsum.photos) - Image API
- [NewsAPI](https://newsapi.org) - News API
- [Replicate](https://replicate.com) - AI Model API
- Flutter Team - Amazing framework