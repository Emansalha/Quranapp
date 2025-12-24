import 'package:flutter/material.dart';
import 'asset.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Asset _asset = Asset();

  int _page = 1;
  List<dynamic> _ayahs = [];
  List<dynamic> _allAyahs = [];

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};

  @override
  void initState() {
    super.initState();
    _loadPage();
    _loadAllQuran();
  }

  // تحميل صفحة واحدة
  Future<void> _loadPage() async {
    _ayahs = await _asset.getfetch(_page);
    _ayahKeys.clear();
    setState(() {});
  }

  // تحميل القرآن كامل (للبحث)
  Future<void> _loadAllQuran() async {
    _allAyahs = await _asset.getAllQuran();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final String suraName = _ayahs.isNotEmpty
        ? (_ayahs.first['surah']?['name']?['arab'] ?? '')
        : '';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.orange[50],
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            if (suraName.isNotEmpty) _buildSuraTitle(suraName, isDark),
            const SizedBox(height: 8),
            if (suraName.isNotEmpty && suraName != 'الفاتحة')
              _buildBasmala(isDark),
            const SizedBox(height: 12),
            Expanded(child: _buildAyahsList(isDark)),
            _buildPageNumber(isDark),
          ],
        ),
      ),
    );
  }

  // ================= APP BAR =================

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 2,
      backgroundColor: Colors.orange[100],
      title: const Text(
        'القرآن الكريم',
        style: TextStyle(
          fontFamily: 'UthmanicHafs',
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () async {
            if (_allAyahs.isEmpty) return;

            final result = await showSearch(
              context: context,
              delegate: QuranSearchDelegate(_allAyahs),
            );

            if (result != null) {
              _page = result['page'];
              await _loadPage();

              Future.delayed(const Duration(milliseconds: 300), () {
                final index = _ayahs.indexWhere(
                  (a) => a['number'] == result['number'],
                );

                if (index != -1 && _ayahKeys[index]?.currentContext != null) {
                  Scrollable.ensureVisible(
                    _ayahKeys[index]!.currentContext!,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                  );
                }
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSuraTitle(String name, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.orange.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 28,
          fontFamily: 'UthmanicHafs',
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.brown[900],
        ),
      ),
    );
  }

  Widget _buildBasmala(bool isDark) {
    return Text(
      'بسم الله الرحمن الرحيم',
      style: TextStyle(
        fontSize: 22,
        fontFamily: 'UthmanicHafs',
        color: isDark ? Colors.white70 : Colors.brown[800],
      ),
    );
  }

  Widget _buildAyahsList(bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _ayahs.length,
      itemBuilder: (context, i) {
        _ayahKeys.putIfAbsent(i, () => GlobalKey());

        final String ayahText = _ayahs[i]['text']?['arab'] ?? '';

        final int ayahNumber = _ayahs[i]['number'] ?? 0;

        return Container(
          key: _ayahKeys[i],
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  ayahText,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.7,
                    fontFamily: 'UthmanicHafs',
                    color: isDark ? Colors.white : Colors.brown[900],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildAyahNumber(ayahNumber),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAyahNumber(int number) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: Colors.orange.shade200,
      child: Text(
        number.toString(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPageNumber(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        _page.toString(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : Colors.brown,
        ),
      ),
    );
  }
}

// ================= SEARCH =================

class QuranSearchDelegate extends SearchDelegate<dynamic> {
  final List<dynamic> ayahs;

  QuranSearchDelegate(this.ayahs);

  @override
  String get searchFieldLabel => 'ابحث في القرآن الكريم';

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    final results = ayahs
        .where((a) {
          final text = a['text']?['arab'] ?? '';
          return text.contains(query);
        })
        .take(50)
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final ayah = results[i];

        final String text = ayah['text']?['arab'] ?? '';
        final String sura = ayah['surah']?['name']?['arab'] ?? '';
        final page = ayah['page'] ?? '';

        return ListTile(
          title: Text(
            text,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'UthmanicHafs',
              fontSize: 22,
            ),
          ),
          subtitle: Text('$sura • صفحة $page'),
          onTap: () => close(context, ayah),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);
}
