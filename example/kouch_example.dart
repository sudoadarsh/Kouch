import 'package:kouch/kouch.dart';

void main() async {
  final Kouch kouch = Kouch();
  // Initialize [Kouch].
  kouch.init(host: "http://127.0.0.1:5984");
}