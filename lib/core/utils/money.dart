abstract class Money {
  static int cents(double value) => (value * 100).round();
  static double round(double value) => cents(value) / 100;
}
