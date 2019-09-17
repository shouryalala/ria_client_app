import 'package:flutter_app/user_details.dart';
import 'package:get_it/get_it.dart';

import 'api.dart';
import 'db_model.dart';

GetIt locator = GetIt();

void setupLocator() {
  locator.registerLazySingleton(() => Api());
  locator.registerLazySingleton(() => DBModel());
  locator.registerLazySingleton(() => UserDetails());
}