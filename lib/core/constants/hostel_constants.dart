class HostelConstants {
  // Boys Hostels
  static const String bh1 = 'BH1';
  static const String bh2 = 'BH2';
  static const String bh3 = 'BH3';
  static const String bh4 = 'BH4';
  static const String mbh = 'MBH';

  // Girls Hostels
  static const String gh1 = 'GH1';
  static const String gh2 = 'GH2';
  static const String gh3 = 'GH3';
  static const String mgh = 'MGH';

  // Lists for dropdowns
  static const List<String> boysHostels = [bh1, bh2, bh3, bh4, mbh];
  static const List<String> girlsHostels = [gh1, gh2, gh3, mgh];
  static const List<String> allHostels = [...boysHostels, ...girlsHostels];
}
