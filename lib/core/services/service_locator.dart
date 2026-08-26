
import 'package:logger/logger.dart';

class ServiceLocator {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  static Future<void> initialize() async {
    try {
      // await dotenv.load(fileName: ".env");
    } catch (e) {
      logger.e("Failed to load environment variables: $e");
    }
  }
}
