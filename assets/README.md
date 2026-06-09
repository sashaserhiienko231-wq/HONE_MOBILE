# Assets Directory

This directory contains all the static assets used by Hone Mobile.

## Structure

```
assets/
├── fonts/           # Custom fonts
├── images/          # Images and icons
├── animations/      # Lottie animations
└── games/          # Game icons and assets
```

## Fonts

The app uses the Inter font family for optimal readability:

- **Inter-Regular.ttf** - Regular weight
- **Inter-Medium.ttf** - Medium weight
- **Inter-SemiBold.ttf** - Semi-bold weight
- **Inter-Bold.ttf** - Bold weight

### Download Inter Font

You can download the Inter font family from:
https://github.com/rsms/inter/releases

Download the following files and place them in the `assets/fonts/` directory:

1. Inter-Regular.ttf
2. Inter-Medium.ttf
3. Inter-SemiBold.ttf
4. Inter-Bold.ttf

## Images

### App Icons
- `logo.png` - Main app logo (512x512px)
- `icon.png` - App icon (192x192px)
- `splash.png` - Splash screen image

### UI Icons
- Various icons used throughout the app
- Neon green and orange themed icons
- Optimized for dark theme

## Animations

Lottie animations for:
- Loading states
- Success animations
- Performance indicators
- Game launch animations

## Game Assets

Icons and banners for detected games:
- Game category icons
- Default game placeholder
- Performance overlays

## Usage

All assets are referenced in `pubspec.yaml` under the `flutter.assets` section.

Make sure to run `flutter pub get` after adding new assets to update the asset bundle.
