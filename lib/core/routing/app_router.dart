import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/ui/screens/login_screen.dart';
import 'package:data7_expedicao/ui/screens/splash_screen.dart';
import 'package:data7_expedicao/ui/screens/profile_screen.dart';
import 'package:data7_expedicao/ui/screens/register_screen.dart';
import 'package:data7_expedicao/ui/screens/qrcode_login_screen.dart';
import 'package:data7_expedicao/ui/screens/camera_barcode_scanner_screen.dart';
import 'package:data7_expedicao/presentation/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/ui/screens/counter_delivery_screen.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/presentation/viewmodels/separation_viewmodel.dart';
import 'package:data7_expedicao/domain/usecases/user/register_via_qrcode_usecase.dart';
import 'package:data7_expedicao/ui/screens/separate_consultation_screen.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/separation_items_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/separate_consultation_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/user_selection_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/profile_viewmodel.dart';
import 'package:data7_expedicao/ui/screens/separation_items_screen.dart';
import 'package:data7_expedicao/ui/wrappers/user_selection_wrapper.dart';
import 'package:data7_expedicao/ui/screens/separation_screen.dart';
import 'package:data7_expedicao/ui/screens/conference_screen.dart';
import 'package:data7_expedicao/ui/screens/collection_screen.dart';
import 'package:data7_expedicao/ui/screens/packaging_screen.dart';
import 'package:data7_expedicao/ui/screens/storage_screen.dart';
import 'package:data7_expedicao/ui/screens/scanner_screen.dart';
import 'package:data7_expedicao/ui/screens/config_screen.dart';
import 'package:data7_expedicao/ui/screens/scanner_config_screen.dart';
import 'package:data7_expedicao/ui/screens/printer_config_screen.dart';
import 'package:data7_expedicao/ui/services/camera_barcode_scan_service.dart';
import 'package:data7_expedicao/ui/screens/home_screen.dart';
import 'package:data7_expedicao/ui/screens/shelf_scanning_screen.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/ui/screens/card_picking_screen.dart';
import 'package:data7_expedicao/ui/screens/picking_products_list_screen.dart';
import 'package:data7_expedicao/ui/screens/add_cart_screen.dart';
import 'package:data7_expedicao/presentation/viewmodels/add_cart_viewmodel.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/core/routing/route_extra.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/ui/routing/app_route_extra_codec.dart';
import 'package:data7_expedicao/ui/widgets/common/navigation_error_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String qrcodeLogin = '/qrcode-login';
  static const String cameraBarcodeScanner = '/camera-barcode-scanner';
  static const String config = '/config';
  static const String scannerConfig = '/scanner-config';
  static const String printerConfig = '/printer-config';
  static const String home = '/home';
  static const String scanner = '/home/scanner';
  static const String userSelection = '/user-selection';
  static const String profile = '/profile';
  static const String shipmentSeparateConsultation = '/shipment-separate-consultation';
  static const String separation = '/home/separation';
  static const String separateItems = '/home/separate-items';
  static const String conference = '/home/conference';
  static const String counterDelivery = '/home/counter-delivery';
  static const String packaging = '/home/packaging';
  static const String storage = '/home/storage';
  static const String collection = '/home/collection';
  static const String shelfScanning = '/shelf-scanning';
  static const String cardPicking = '/home/card-picking';
  static const String pickingProductsList = '/home/picking-products-list';
  static const String addCart = '/home/add-cart';

  static String? resolveRedirect({required AuthStatus authStatus, required String currentLocation}) {
    final isAuthenticatedRoute =
        currentLocation.startsWith(home) ||
        currentLocation == profile ||
        currentLocation == shipmentSeparateConsultation ||
        currentLocation == shelfScanning ||
        currentLocation == cardPicking ||
        currentLocation == pickingProductsList ||
        currentLocation == addCart;

    if (authStatus == AuthStatus.initial || authStatus == AuthStatus.loading) {
      if (currentLocation != splash) {
        return splash;
      }
      return null;
    }

    if (authStatus == AuthStatus.unauthenticated || authStatus == AuthStatus.error) {
      if (isAuthenticatedRoute) {
        return login;
      }

      if (currentLocation != login &&
          currentLocation != register &&
          currentLocation != qrcodeLogin &&
          currentLocation != cameraBarcodeScanner &&
          currentLocation != config) {
        return login;
      }
      return null;
    }

    if (authStatus == AuthStatus.needsUserSelection) {
      if (currentLocation != userSelection) {
        return userSelection;
      }
      return null;
    }

    if (authStatus == AuthStatus.authenticated) {
      if (currentLocation == splash ||
          currentLocation == login ||
          currentLocation == register ||
          currentLocation == userSelection) {
        return home;
      }
      return null;
    }

    return null;
  }

  static GoRouter createRouter(AuthViewModel authViewModel, {GlobalKey<NavigatorState>? navigatorKey}) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: splash,
      debugLogDiagnostics: true,
      extraCodec: const AppRouteExtraCodec(),
      refreshListenable: authViewModel,

      redirect: (BuildContext context, GoRouterState state) {
        return resolveRedirect(authStatus: authViewModel.status, currentLocation: state.uri.path);
      },

      routes: [
        GoRoute(path: splash, name: 'splash', builder: (context, state) => const SplashScreen()),

        GoRoute(path: login, name: 'login', builder: (context, state) => const LoginScreen()),

        GoRoute(path: register, name: 'register', builder: (context, state) => const RegisterScreen()),

        GoRoute(
          path: qrcodeLogin,
          name: 'qrcode-login',
          builder: (context, state) => QRCodeLoginScreen(
            scanService: locator<CameraBarcodeScanService>(),
            registerViaQRCodeUseCase: locator<RegisterViaQRCodeUseCase>(),
          ),
        ),

        GoRoute(
          path: cameraBarcodeScanner,
          name: 'camera-barcode-scanner',
          builder: (context, state) => const CameraBarcodeScannerScreen(),
        ),

        GoRoute(path: config, name: 'config', builder: (context, state) => const ConfigScreen()),

        GoRoute(path: scannerConfig, name: 'scanner-config', builder: (context, state) => const ScannerConfigScreen()),

        GoRoute(path: printerConfig, name: 'printer-config', builder: (context, state) => const PrinterConfigScreen()),

        GoRoute(
          path: userSelection,
          name: 'user-selection',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => locator<UserSelectionViewModel>(),
            child: const UserSelectionWrapper(),
          ),
        ),

        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(path: 'scanner', name: 'scanner', builder: (context, state) => const ScannerScreen()),

            GoRoute(
              path: 'separation',
              name: 'separation',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => locator<SeparationViewModel>(),
                child: const SeparationScreen(),
              ),
            ),

            GoRoute(
              path: 'separate-items',
              name: 'separate-items',
              builder: (context, state) {
                final extra = routeExtraMap(state.extra);
                if (extra == null) {
                  return _invalidArguments(
                    state,
                    'Dados da separação não encontrados. Volte ao início e reabra a operação.',
                  );
                }

                final SeparateConsultationModel separation;
                try {
                  separation = SeparateConsultationModel.fromJson(extra);
                } catch (error, stackTrace) {
                  return _invalidArguments(
                    state,
                    'Dados da separação inválidos. Volte ao início e reabra a operação.',
                    error: error,
                    stackTrace: stackTrace,
                  );
                }

                return ChangeNotifierProvider(
                  create: (_) => locator<SeparationItemsViewModel>(),
                  child: SeparationItemsScreen(separation: separation),
                );
              },
            ),

            GoRoute(path: 'conference', name: 'conference', builder: (context, state) => const ConferenceScreen()),

            GoRoute(
              path: 'counter-delivery',
              name: 'counter-delivery',
              builder: (context, state) => const CounterDeliveryScreen(),
            ),

            GoRoute(path: 'packaging', name: 'packaging', builder: (context, state) => const PackagingScreen()),

            GoRoute(path: 'storage', name: 'storage', builder: (context, state) => const StorageScreen()),

            GoRoute(path: 'collection', name: 'collection', builder: (context, state) => const CollectionScreen()),

            GoRoute(
              path: 'card-picking',
              name: 'card-picking',
              builder: (context, state) {
                final extra = routeExtraMap(state.extra);
                if (extra == null) {
                  return _invalidArguments(
                    state,
                    'Dados do carrinho não encontrados. Volte ao início e reabra a operação.',
                  );
                }

                final cart = extra['cart'];
                if (cart is! ExpeditionCartRouteInternshipConsultationModel) {
                  return _invalidArguments(state, 'Dados do carrinho inválidos. Volte ao início e reabra a operação.');
                }
                final userModel = extra['userModel'];
                if (userModel != null && userModel is! UserSystemModel) {
                  return _invalidArguments(state, 'Dados do usuário inválidos. Volte ao início e reabra a operação.');
                }

                return ChangeNotifierProvider(
                  create: (_) => locator<CardPickingViewModel>(),
                  child: CardPickingScreen(cart: cart, userModel: userModel as UserSystemModel?),
                );
              },
            ),

            GoRoute(
              path: 'picking-products-list',
              name: 'picking-products-list',
              builder: (context, state) {
                final extra = routeExtraMap(state.extra);
                if (extra == null) {
                  return _invalidArguments(state, 'Dados não encontrados. Volte ao início e reabra a operação.');
                }

                final filterType = extra['filterType'];
                final viewModel = extra['viewModel'];
                final cart = extra['cart'];
                if (filterType is! String || cart is! ExpeditionCartRouteInternshipConsultationModel) {
                  return _invalidArguments(
                    state,
                    'Dados invalidos para picking-products-list. Volte ao início e reabra a operação.',
                  );
                }

                final parsedViewModel = viewModel is CardPickingViewModel ? viewModel : null;
                if (filterType == 'pending' && parsedViewModel == null) {
                  return _invalidArguments(
                    state,
                    'Dados invalidos para picking-products-list. Volte ao início e reabra a operação.',
                  );
                }
                final isReadOnly = extra['isReadOnly'] is bool ? extra['isReadOnly'] as bool : false;
                final screen = PickingProductsListScreen(
                  filterType: filterType,
                  viewModel: parsedViewModel,
                  cart: cart,
                  isReadOnly: isReadOnly,
                );

                if (parsedViewModel == null) {
                  return screen;
                }

                return ChangeNotifierProvider.value(value: parsedViewModel, child: screen);
              },
            ),

            GoRoute(
              path: 'add-cart',
              name: 'add-cart',
              builder: (context, state) {
                final extra = routeExtraMap(state.extra);
                if (extra == null) {
                  return _invalidArguments(state, 'Dados não encontrados. Volte ao início e reabra a operação.');
                }

                final codEmpresa = extra['codEmpresa'];
                final codSepararEstoque = extra['codSepararEstoque'];
                if (codEmpresa is! int || codSepararEstoque is! int) {
                  return _invalidArguments(
                    state,
                    'Codigos invalidos para add-cart. Volte ao início e reabra a operação.',
                  );
                }

                return ChangeNotifierProvider(
                  create: (_) => AddCartViewModel(codEmpresa: codEmpresa, codSepararEstoque: codSepararEstoque),
                  child: AddCartScreen(codEmpresa: codEmpresa, codSepararEstoque: codSepararEstoque),
                );
              },
            ),
          ],
        ),

        GoRoute(
          path: shelfScanning,
          name: 'shelf-scanning',
          builder: (context, state) {
            final extra = routeExtraMap(state.extra);
            if (extra == null) {
              return _invalidArguments(state, 'Dados não encontrados. Volte ao início e reabra a operação.');
            }
            final expectedAddress = extra['expectedAddress'];
            final expectedAddressDescription = extra['expectedAddressDescription'];
            final viewModel = extra['viewModel'];
            if (expectedAddress is! String ||
                expectedAddressDescription is! String ||
                viewModel is! CardPickingViewModel) {
              return _invalidArguments(
                state,
                'Dados invalidos para shelf-scanning. Volte ao início e reabra a operação.',
              );
            }
            final returnRoute = extra['returnRoute'] is String ? extra['returnRoute'] as String : null;
            return ShelfScanningScreen(
              expectedAddress: expectedAddress,
              expectedAddressDescription: expectedAddressDescription,
              viewModel: viewModel,
              returnRoute: returnRoute,
            );
          },
        ),

        GoRoute(
          path: profile,
          name: 'profile',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) =>
                ProfileViewModel(locator<UserRepository>(), Provider.of<AuthViewModel>(context, listen: false)),
            child: const ProfileScreen(),
          ),
        ),

        GoRoute(
          path: shipmentSeparateConsultation,
          name: 'shipment-separate-consultation',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => ShipmentSeparateConsultationViewModel(),
            child: const SeparateConsultationScreen(),
          ),
        ),
      ],

      errorBuilder: (context, state) => _invalidArguments(
        state,
        'Não foi possível abrir esta tela. Volte ao início e tente novamente.',
        error: state.error,
      ),
    );
  }

  static Widget _invalidArguments(GoRouterState state, String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.error(
      'Falha na navegacao para ${state.uri.path}',
      tag: 'AppRouter',
      error: error ?? StateError(message),
      stackTrace: stackTrace ?? StackTrace.current,
    );
    final extra = state.extra;
    return NavigationErrorScreen(message: extra is RouteExtraFailure ? extra.message : message);
  }
}
