class Log{
  final String APP_NAME = "CRYB";
  String class_name;

  Log(this.class_name);

  debug(message) {
    print(APP_NAME + ":: " + class_name + ": " + message);
  }

  error(message) {
    print(APP_NAME + ":: " + class_name + ": " + message);
  }
}