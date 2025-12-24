import 'Network.dart';

class Asset {
  // تحميل صفحة واحدة
  Future<List<dynamic>> getfetch(int page) async {
    final response = await Network.get(
      'https://api.alquran.cloud/v1/page/$page/quran-simple',
    );
    return response['data']['ayahs'];
  }

  // ✅ تحميل القرآن كامل (للبحث)
  Future<List<dynamic>> getAllQuran() async {
    final response = await Network.get(
      'https://api.alquran.cloud/v1/quran/quran-simple',
    );
    return response['data']['ayahs'];
  }
}
