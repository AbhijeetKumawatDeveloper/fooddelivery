# FoodGo 🍔 — Multi-Role Clean Architecture Food Delivery Platform

[![FoodGo Flutter CI](https://github.com/AbhijeetKumawatDeveloper/fooddelivery/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/AbhijeetKumawatDeveloper/fooddelivery/actions)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20BLoC%2FCubit-red.svg)](https://bloclibrary.dev)
[![Tests](https://img.shields.io/badge/Tests-119%20Passed-brightgreen.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

FoodGo is a production-engineered, company-grade food delivery application built with **Flutter**, **Clean Architecture**, **BLoC/Cubit**, **Modular GetIt Dependency Injection**, and **Firebase (Auth & Cloud Firestore)** with a built-in offline mock fallback engine.

The platform integrates four distinct user roles into a single coherent reactive ecosystem:
1. **Customer Mobile Experience** — Restaurant browsing, food menu exploration, persistent shopping cart, checkout calculation, Razorpay integration, and live order tracking.
2. **Restaurant Partner POS** — Kitchen operations dashboard, real-time incoming order pipeline, preparation staging, and menu item catalog management.
3. **Delivery Partner App** — Assigned delivery task queue, step-by-step dispatch workflow (Accepted &rarr; Picked Up &rarr; On The Way &rarr; Delivered), and real-time GPS telemetry beaconing.
4. **Platform Admin Console** — High-level platform KPIs, revenue analytics, fulfillment health monitoring, restaurant approval toggles, and user account governance.

---

## 🏛️ System Architecture

FoodGo strictly follows Uncle Bob's **Clean Architecture** combined with **Feature-Driven Design**, decoupling business rules from external dependencies and UI frameworks:

```
lib/
├── core/
│   ├── di/                             # Modular GetIt Service Locator & Dependency Graph
│   │   ├── injection.dart              # Core DI orchestrator & provider
│   │   └── modules/                    # Feature-scoped DI sub-modules
│   ├── errors/                         # Sealed Result<T> union type & Failure hierarchy
│   ├── logger/                         # AppLogger contract & AppBlocObserver telemetry
│   └── theme/app_theme.dart            # Design system, palette, typography & widget themes
└── features/
    ├── auth/                           # Authentication & session gatekeeping
    ├── restaurants/                    # Restaurant catalog, discovery, filters & search
    ├── foods/                          # Restaurant menu catalog & category browsing
    ├── cart/                           # Persistent cart backed by SharedPreferences
    ├── checkout/                       # Multi-address manager, fee calculations & Razorpay gateway
    ├── orders/                         # Customer order history & real-time tracking stepper
    ├── restaurant_partner/             # Restaurant POS dashboard & kitchen status queue
    ├── delivery_partner/               # Delivery Partner App, GPS simulation & route stepper
    └── admin/                          # Admin Console, KPI analytics & governance toggles
```

### Layer Separation per Feature

```
feature_module/
├── domain/
│   ├── entities/          # Pure Dart models (Equatable, immutable business objects)
│   ├── repositories/      # Abstract interfaces defining data contracts
│   └── usecases/          # Granular, single-responsibility business interactors
├── data/
│   ├── models/            # JSON/Firestore serialization wrappers over entities
│   ├── datasources/       # Remote (Cloud Firestore / Auth) + Local fallback sources
│   └── repositories/      # Concrete implementations coordinating datasources
└── presentation/
    ├── cubit/             # BLoC/Cubit state management classes & immutable states
    └── screens/           # Modular Flutter UI widgets & responsive views
```

---

## 🔄 End-to-End Order Lifecycle State Machine

```
[Customer]
    │
    ▼ Place Order
[Pending]
    │
    ▼ Restaurant Partner: Accept
[Accepted]
    │
    ▼ Restaurant Partner: Start Cooking
[Preparing]
    │
    ▼ Restaurant Partner: Mark Ready
[Ready for Pickup]
    │
    ▼ Delivery Partner: Confirm Kitchen Pickup
[Picked Up]
    │
    ▼ Delivery Partner: Start Transit & Ping GPS
[On The Way]
    │
    ▼ Delivery Partner: Handover to Customer
[Delivered]  ──▶  Platform Admin: Included in Gross Revenue & Completed Metrics
```

---

## 🚀 Key Engineering Highlights

- **Dual-Mode Data Source Strategy**: Every feature's remote data source is engineered with an uninitialized-safe fallback. The app runs out-of-the-box in offline demo mode and automatically switches to live Firebase Cloud Firestore and Firebase Auth when credentials are supplied.
- **Cart Persistence**: State is persisted across app restarts using `SharedPreferences`, with serialization safeguarding against corrupted state.
- **Atomic Checkout Logic**: `CalculateCheckout` usecase implements validated mathematics ($Total = Subtotal + Delivery - Discount + Tax$), ensuring non-negative figures and discount thresholds.
- **Real-Time Stream Subscriptions**: Order queues utilize Firestore snapshot streams combined with lifecycle-aware stream subscriptions inside Cubits to prevent memory leaks.
- **Role-Based Firestore Security Rules**: [`firestore.rules`](file:///D:/Food_Delivery/firestore.rules) enforces strict multi-tenant authorization rules preventing cross-restaurant data leakage and unauthorized status tampering.

---

## 🧪 Automated Testing & Code Quality

FoodGo includes comprehensive automated test coverage spanning unit tests, Cubit state machines, repository mocks, and widget tests.

```bash
# Run static analysis
flutter analyze

# Run complete test suite with coverage
flutter test --coverage

# Verify code formatting
dart format --output=none --set-exit-if-changed .
```

### Test Suite Summary:
- **119 Tests Passing** across all domain features & core architecture:
  - `result_test.dart` — Functional `Result<T>` sealed class & `Failure` hierarchy
  - `logger_test.dart` — `ConsoleAppLogger` and `AppBlocObserver` lifecycle telemetry
  - `di_modules_test.dart` — Modular feature DI registrations & locator contracts
  - `auth_test.dart` — Auth flow, user entity, state transitions
  - `cart_calculations_test.dart` & `cart_persistence_test.dart` — Cart totals & disk storage
  - `calculate_checkout_test.dart` — Pricing calculations, discount limits, address management
  - `food_test.dart` — Menu catalog, availability, pricing queries
  - `restaurant_loading_test.dart` — Restaurant pagination, rating filters, model mapping
  - `order_test.dart` — Order creation, order streams, live tracking state
  - `restaurant_partner_test.dart` — POS queue transitions, restaurant revenue & menu editing
  - `delivery_partner_test.dart` — Delivery status pipeline, earnings formulas, GPS beaconing
  - `admin_test.dart` — Governance KPIs, restaurant approval switches, user suspensions

---

## 🛡️ Phase 12: Production Architecture & Maintainability

FoodGo incorporates enterprise Flutter maintainability standards:
- **Modular Dependency Injection**: Decomposed into 10 domain-isolated modules under `lib/core/di/modules/` (`AuthModule`, `RestaurantModule`, `FoodModule`, `CartModule`, `CheckoutModule`, `OrderModule`, `PartnerModule`, `DeliveryModule`, `AdminModule`, `CoreModule`), avoiding giant service locator files.
- **Enterprise Observability**: `AppLogger` and `AppBlocObserver` provide structured logging with debug toggle safeguards based on flavor environments (`AppConfig.instance.enableDebugLogs`).
- **Functional Error Handling**: `Result<T>` sealed class with `Success<T>` and `FailureResult<T>` enabling exhaustive pattern matching and eliminating unhandled runtime exceptions.
- **Strict Lint Rules**: Hardened `analysis_options.yaml` enforcing `avoid_print`, `unawaited_futures`, `prefer_const_constructors`, `always_declare_return_types`, and `directives_ordering` with **0 static analysis warnings**.

---

## ⚙️ CI/CD Pipeline

FoodGo includes a production-grade GitHub Actions CI workflow in [`.github/workflows/flutter-ci.yml`](file:///D:/Food_Delivery/.github/workflows/flutter-ci.yml):

- **Trigger**: Runs automatically on pushes and pull requests to `main` and `develop`.
- **Environment**: `ubuntu-latest` with Flutter Stable.
- **Steps**:
  1. Checks formatting (`dart format --output=none --set-exit-if-changed .`).
  2. Runs static analysis with strict linting (`flutter analyze`).
  3. Executes all 119 unit & widget tests and generates coverage reports (`flutter test --coverage`).

---

## 💻 Getting Started Locally

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.13.0)
- Android Studio / VS Code with Flutter extension
- Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/AbhijeetKumawatDeveloper/fooddelivery.git
   cd fooddelivery
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```
   *Note: By default, the app initializes in offline demo mode with mock restaurants, menus, orders, delivery partners, and admin stats.*

4. **(Optional) Connect Live Firebase Backend:**
   ```bash
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

---

## ⚡ Performance Engineering

FoodGo implements key production optimizations to guarantee smooth 60fps scrolling and optimal memory usage:
- **Selective BLoC Rebuilds**: Utilizes `BlocSelector` in app bars and badges (`HomeScreen`, `FoodMenuScreen`) to avoid full screen re-renders when cart counts or individual item quantities change.
- **Image Decode Optimization**: Constrains GPU decoding overhead with `cacheHeight: 360` for restaurant banners and `cacheWidth: 160, cacheHeight: 160` for food thumbnails, minimizing rasterizer jank.
- **Paint Boundary Isolation**: Employs `RepaintBoundary` on list items to decouple scrolling repaint cycles.
- **Lazy Item Construction**: Uses `ListView.builder` with on-demand item construction.

---

## 🏷️ Build Flavors & Environment Configuration

FoodGo uses clean configuration objects via `AppConfig` with dedicated entrypoints for each lifecycle stage:

```bash
# Run Development Flavor (Mock fallback, verbose logs, debug banner)
flutter run -t lib/main_dev.dart

# Run Staging Flavor (Pre-production endpoints, integration testing)
flutter run -t lib/main_staging.dart

# Run Production Flavor (Optimized, live API endpoints)
flutter run -t lib/main.dart
```

---

## 📦 Release Engineering & Android Signing

### 1. Release Keystore Signing
For secure deployment without committing credentials into version control:
1. Copy the template: `cp android/key.properties.example android/key.properties`
2. Populate `storePassword`, `keyPassword`, `keyAlias`, and `storeFile` with your release keystore details.
3. Gradle automatically picks up `key.properties` in `android/app/build.gradle.kts`. If absent, it safely falls back to debug signing for testing.

### 2. ProGuard & R8 Bytecode Optimization
Release builds automatically apply code shrinking and obfuscation via `android/app/proguard-rules.pro`, keeping necessary Flutter engine, Firebase, and location sensor bindings intact.

### 3. Building Release Artifacts
```bash
# Build universal release APK
flutter build apk --release -t lib/main.dart

# Build Google Play App Bundle (AAB)
flutter build appbundle --release -t lib/main.dart
```

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
