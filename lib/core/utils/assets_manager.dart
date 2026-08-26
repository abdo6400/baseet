abstract class AssetsManager {
  static const String translationsPath = 'assets/translations';
  static const String iconsPath = 'assets/icons';
  static const String imagesPath = 'assets/images';
  static const String appIconDark = '$iconsPath/app_icon.png';
  static const String appIconLight = '$iconsPath/app_icon_light.png';
  static const String appIcon = appIconDark;

  static String getAppIcon({required bool isDark}) {
    return isDark ? appIconDark : appIconLight;
  }
}
