/// Web / non-IO platforms: no local Isar database.
Future<void> initLocalDatabase() async {
  // IsarService.instance stays null; SyncService web impl uses Firestore only.
}
