import 'package:flutter_app/base_util.dart';
import 'package:flutter_app/core/model/local_db_model.dart';
import 'package:flutter_app/core/service/api.dart';
import 'package:flutter_app/core/service/local_api.dart';
import 'package:get_it/get_it.dart';

import '../core/model/db_model.dart';

GetIt locator = GetIt();

void setupLocator() {
  locator.registerLazySingleton(() => Api());
  locator.registerLazySingleton(() => DBModel());
  locator.registerLazySingleton(() => LocalApi());
  locator.registerLazySingleton(() => LocalDBModel());
  locator.registerLazySingleton(() => BaseUtil());
}