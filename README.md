# THIS REPO IS DEPRECATED
This repo is replaced with the official Flutter [plugin](https://pub.dev/packages/banuba_sdk). 

## Banuba Face AR SDK - Flutter integration sample

[Banuba Face AR SDK](https://www.banuba.com/facear-sdk/face-filters) allows you to build amazing augmented reality apps with 3D filters, animation, and beauty effects.
Banuba AR technologies empower developers to create face filters, virtual makeup try on, animated avatars, and other face augmenting features, and build video-sharing apps with a Tiktok-like experience.
<br></br>
:exclamation: <ins>Support for Flutter plugin is under development at the moment and scheduled for __end Q4__. Please, reach out to [support team](https://www.banuba.com/faq/kb-tickets/new) to help you with your own Flutter integration.<ins>

<ins>Keep in mind that main part of integration and customization should be implemented in **android**, **ios** directories using native Android and iOS development process.<ins>

This sample demonstrates how to run Face AR SDK with [Flutter](https://flutter.dev/).


## Dependencies
|       | Version | 
| --------- |:-------:| 
| Dart      | 2.18.0  | 
| Flutter   |  3.3.0  |
| Android      |  6.0+   |
| iOS          |  12.0+  |

## Prerequisites
### Token
We offer а free 14-days trial for you could thoroughly test and assess Face AR SDK functionality in your app.</br>
To get access to your trial, please, get in touch with us by [filling a form](https://www.banuba.com/facear-sdk/face-filters) on our website. Our sales managers will send you the trial token.

:exclamation: __The token **IS REQUIRED** to run sample and an integration in your app.__</br>

## Installation and Usage
Run ```flutter pub get``` in terminal to update dependencies.

### Android
1. Set Banuba token in the sample app [resources](https://github.com/Banuba/face-ar-flutter-sample/blob/master/android/app/src/main/res/values/strings.xml#L3).
2. Run ```flutter run``` in terminal to launch the sample app on a device or launch the app in IDE i.e. Intellij, VC, etc.

### iOS
1. Install CocoaPods dependencies. Open **ios** directory and run ```pod install``` in terminal.
2. Open **Signing & Capabilities** tab in Target settings and select your Development Team.
3. Set Banuba token in the sample app [AppDelegate](https://github.com/Banuba/face-ar-flutter-sample/blob/master/ios/Runner/AppDelegate.swift#L17) .
4. Run ```flutter run``` in terminal to launch the sample on a device or launch the app in IDE i.e. XCode, Intellij, VC, etc.
