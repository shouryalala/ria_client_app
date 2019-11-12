import 'package:flutter_app/base_util.dart';
import 'package:flutter_app/core/ops/cache_ops.dart';
import 'package:flutter_app/core/fcm_handler.dart';
import 'package:flutter_app/core/fcm_listener.dart';
import 'package:flutter_app/core/ops/lcl_db_ops.dart';
import 'package:flutter_app/core/service/api.dart';
import 'package:flutter_app/core/service/cache_api.dart';
import 'package:flutter_app/core/service/lcl_db_api.dart';
import 'package:get_it/get_it.dart';

import '../core/ops/db_ops.dart';

GetIt locator = GetIt();

void setupLocator() {
  locator.registerLazySingleton(() => Api());
  locator.registerLazySingleton(() => DBModel());
  locator.registerLazySingleton(() => LocalApi());
  locator.registerLazySingleton(() => LocalDBModel());
  locator.registerLazySingleton(() => CacheApi());
  locator.registerLazySingleton(() => CacheModel());
  locator.registerLazySingleton(() => BaseUtil());
  locator.registerLazySingleton(() => FcmListener());
  locator.registerLazySingleton(() => FcmHandler());
}