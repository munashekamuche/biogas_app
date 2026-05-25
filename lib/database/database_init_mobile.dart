import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'isar_service.dart';
import '../models/isar_models.dart';

Future<void> initLocalDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [IsarUserSchema, IsarApplicationSchema, IsarReportSchema],
    directory: dir.path,
  );
  IsarService.instance = IsarService(isar);
}
