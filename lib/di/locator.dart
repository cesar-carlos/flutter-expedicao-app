import 'package:get_it/get_it.dart';

import 'package:data7_expedicao/di/modules/app_update_module.dart';
import 'package:data7_expedicao/di/modules/auth_module.dart';
import 'package:data7_expedicao/di/modules/cart_module.dart';
import 'package:data7_expedicao/di/modules/config_module.dart';
import 'package:data7_expedicao/di/modules/core_module.dart';
import 'package:data7_expedicao/di/modules/picking_module.dart';
import 'package:data7_expedicao/di/modules/printing_module.dart';
import 'package:data7_expedicao/di/modules/separation_module.dart';
import 'package:data7_expedicao/di/modules/socket_module.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  registerCoreModule(locator);
  registerConfigModule(locator);
  registerPrintingModule(locator);
  registerAppUpdateModule(locator);
  registerSocketModule(locator);
  registerAuthModule(locator);
  registerSeparationModule(locator);
  registerCartModule(locator);
  registerPickingModule(locator);
}
