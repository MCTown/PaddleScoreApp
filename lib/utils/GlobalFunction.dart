import 'package:path_provider/path_provider.dart';

Future<String> getFilePath(String fileName) async {
final directory = await getApplicationDocumentsDirectory();
return '${directory.path}/$fileName';
}