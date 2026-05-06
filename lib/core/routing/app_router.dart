import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/ui/screens/login_screen.dart';
import 'package:data7_expedicao/ui/screens/splash_screen.dart';
import 'package:data7_expedicao/ui/screens/profile_screen.dart';
import 'package:data7_expedicao/ui/screens/register_screen.dart';
import 'package:data7_expedicao/ui/screens/qrcode_login_screen.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/ui/screens/counter_delivery_screen.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/viewmodels/separation_viewmodel.dart';
import 'package:data7_expedicao/ui/screens/separate_consultation_screen.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/viewmodels/separation_items_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/separate_consultation_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/profile_viewmodel.dart';
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
import 'package:data7_expedicao/ui/screens/home_screen.dart';
import 'package:data7_expedicao/ui/screens/shelf_scanning_screen.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/ui/screens/card_picking_screen.dart';
import 'package:data7_expedicao/ui/screens/picking_products_list_screen.dart';
import 'package:data7_expedicao/ui/screens/add_cart_screen.dart';
import 'package:data7_expedicao/presentation/viewmodels/add_cart_viewmodel.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String qrcodeLogin = '/qrcode-login';
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

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: splash,
      debugLogDiagnostics: true,
      // Bug AAAAAAAAAAA: usar refreshListenable para que o router
      // re-avalie o redirect quando authViewModel notificar — sem
      // precisar recriar o router inteiro a cada rebuild da MyApp
      // (o que era CARO: perdia state de navegacao + criava nova
      // instancia de GoRouter completa). Combinar com cache do router
      // em main.dart (campo do State em vez de criar no build()).
      refreshListenable: authViewModel,

      redirect: (BuildContext context, GoRouterState state) {
        return resolveRedirect(authStatus: authViewModel.status, currentLocation: state.uri.path);
      },

      routes: [
        GoRoute(path: splash, name: 'splash', builder: (context, state) => const SplashScreen()),

        GoRoute(path: login, name: 'login', builder: (context, state) => const LoginScreen()),

        GoRoute(path: register, name: 'register', builder: (context, state) => const RegisterScreen()),

        GoRoute(path: qrcodeLogin, name: 'qrcode-login', builder: (context, state) => const QRCodeLoginScreen()),

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
                // Bug AAAAAAAA: antes era `state.extra as Map<String, dynamic>?`
                // direto. Se a navegacao fosse feita com extra de tipo diferente
                // (ex.: passar SeparateConsultationModel direto por engano), o
                // cast lancava TypeError em vez do friendly fallback abaixo.
                // Agora validamos com `is` antes do cast.
                final extra = state.extra;
                if (extra is! Map<String, dynamic>) {
                  return const Scaffold(body: Center(child: Text('Dados da separação não encontrados')));
                }

                final SeparateConsultationModel separation;
                try {
                  separation = SeparateConsultationModel.fromJson(extra);
                } catch (_) {
                  return const Scaffold(body: Center(child: Text('Dados da separação inválidos')));
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
                // Bug AAAAAAAA: validacao defensiva de tipo (mesma motivacao
                // da rota separate-items acima).
                final extra = state.extra;
                if (extra is! Map<String, dynamic>) {
                  return const Scaffold(body: Center(child: Text('Dados do carrinho não encontrados')));
                }

                final cart = extra['cart'];
                if (cart is! ExpeditionCartRouteInternshipConsultationModel) {
                  return const Scaffold(body: Center(child: Text('Dados do carrinho inválidos')));
                }
                final userModel = extra['userModel'] is UserSystemModel ? extra['userModel'] as UserSystemModel : null;

                return ChangeNotifierProvider(
                  create: (_) => CardPickingViewModel(),
                  child: CardPickingScreen(cart: cart, userModel: userModel),
                );
              },
            ),

            GoRoute(
              path: 'picking-products-list',
              name: 'picking-products-list',
              builder: (context, state) {
                final extra = state.extra;
                if (extra is! Map<String, dynamic>) {
                  return const Scaffold(body: Center(child: Text('Dados não encontrados')));
                }

                final filterType = extra['filterType'];
                final viewModel = extra['viewModel'];
                final cart = extra['cart'];
                if (filterType is! String || cart is! ExpeditionCartRouteInternshipConsultationModel) {
                  return const Scaffold(body: Center(child: Text('Dados invalidos para picking-products-list')));
                }

                final parsedViewModel = viewModel is CardPickingViewModel ? viewModel : null;
                if (filterType == 'pending' && parsedViewModel == null) {
                  return const Scaffold(body: Center(child: Text('Dados invalidos para picking-products-list')));
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
                final extra = state.extra;
                if (extra is! Map<String, dynamic>) {
                  return const Scaffold(body: Center(child: Text('Dados não encontrados')));
                }

                final codEmpresa = extra['codEmpresa'];
                final codSepararEstoque = extra['codSepararEstoque'];
                if (codEmpresa is! int || codSepararEstoque is! int) {
                  return const Scaffold(body: Center(child: Text('Codigos invalidos para add-cart')));
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
            final extra = state.extra;
            if (extra is! Map<String, dynamic>) {
              return const Scaffold(body: Center(child: Text('Dados não encontrados')));
            }
            final expectedAddress = extra['expectedAddress'];
            final expectedAddressDescription = extra['expectedAddressDescription'];
            final viewModel = extra['viewModel'];
            if (expectedAddress is! String ||
                expectedAddressDescription is! String ||
                viewModel is! CardPickingViewModel) {
              return const Scaffold(body: Center(child: Text('Dados invalidos para shelf-scanning')));
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

      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Erro na navegação', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Rota não encontrada: ${state.uri.path}'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.go(home), child: const Text('Voltar ao Início')),
            ],
          ),
        ),
      ),
    );
  }
}
