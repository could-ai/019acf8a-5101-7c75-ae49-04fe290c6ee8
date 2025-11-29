import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

// Main App Entry Point
void main() {
  runApp(const BubbleCashApp());
}

class BubbleCashApp extends StatelessWidget {
  const BubbleCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble Cash - العب واربح',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue.shade900,
        scaffoldBackgroundColor: const Color(0xFF0A192F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlueAccent,
          brightness: Brightness.dark,
          background: const Color(0xFF0A192F),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF172A46),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/game': (context) => const GameScreen(),
        '/rewards': (context) => const RewardsScreen(),
        '/missions': (context) => const MissionsScreen(),
        '/ships': (context) => const ShipSelectionScreen(),
        '/redeem': (context) => const RedeemScreen(),
        '/admin': (context) => const AdminPanelScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/store': (context) => const StoreScreen(),
      },
    );
  }
}

// --- Screens ---

// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bubble Cash - القائمة الرئيسية'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildMenuCard(context, Icons.play_circle_fill, 'ابدأ اللعب', '/game'),
          _buildMenuCard(context, Icons.store, 'المتجر', '/store'),
          _buildMenuCard(context, Icons.card_giftcard, 'المكافآت اليومية', '/rewards'),
          _buildMenuCard(context, Icons.assignment, 'المهام والتحديات', '/missions'),
          _buildMenuCard(context, Icons.rocket_launch, 'اختر سفينتك', '/ships'),
          _buildMenuCard(context, Icons.emoji_events, 'الإنجازات', '/achievements'),
          _buildMenuCard(context, Icons.leaderboard, 'لوحة الصدارة', '/leaderboard'),
          _buildMenuCard(context, Icons.redeem, 'استرداد المكافآت', '/redeem'),
          _buildMenuCard(context, Icons.admin_panel_settings, 'لوحة الإدارة', '/admin'),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, IconData icon, String title, String route) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.lightBlueAccent),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// Game Screen
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _score = 0;
  int _level = 1;
  final List<Bubble> _bubbles = [];
  Timer? _timer;
  final double _gameWidth = 300;
  final double _gameHeight = 500;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _level = 1;
    _generateBubbles();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        for (var bubble in _bubbles) {
          bubble.y -= bubble.speed;
          if (bubble.y < -20) {
            bubble.y = _gameHeight + 20;
          }
        }
      });
    });
  }

  void _generateBubbles() {
    final random = Random();
    _bubbles.clear();
    for (int i = 0; i < 15; i++) {
      _bubbles.add(Bubble(
        x: random.nextDouble() * _gameWidth,
        y: random.nextDouble() * _gameHeight,
        color: Colors.primaries[random.nextInt(Colors.primaries.length)],
        speed: 1 + random.nextDouble() * 2,
      ));
    }
  }

  void _popBubble(int index) {
    setState(() {
      _bubbles.removeAt(index);
      _score += 10;
      if (_bubbles.isEmpty) {
        _level++;
        _generateBubbles();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تهانينا! لقد وصلت للمستوى $_level')),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المستوى: $_level - النقاط: $_score'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Container(
          width: _gameWidth,
          height: _gameHeight,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.lightBlueAccent),
          ),
          child: GestureDetector(
            onTapDown: (details) {
              final tapX = details.localPosition.dx;
              final tapY = details.localPosition.dy;
              for (int i = _bubbles.length - 1; i >= 0; i--) {
                final bubble = _bubbles[i];
                if (sqrt(pow(tapX - bubble.x, 2) + pow(tapY - bubble.y, 2)) < 20) {
                  _popBubble(i);
                  break;
                }
              }
            },
            child: CustomPaint(
              painter: BubblePainter(bubbles: _bubbles),
              child: Container(),
            ),
          ),
        ),
      ),
    );
  }
}

// Rewards Screen
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المكافآت اليومية'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('قم بتسجيل الدخول يوميًا لجمع المكافآت المذهلة!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            _buildRewardDay(1, '100 Coins', true),
            _buildRewardDay(2, '150 Coins + 5 Gems', true),
            _buildRewardDay(3, '200 Coins', false),
            _buildRewardDay(4, '250 Coins + 10 Gems', false),
            _buildRewardDay(5, '300 Coins + 15 Gems', false),
            _buildRewardDay(6, '400 Coins + 20 Gems', false),
            _buildRewardDay(7, '500 Coins + 50 Gems', false, isSpecial: true),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('نصائح المكافأة', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 10),
                    const Text('• قم بتسجيل الدخول يوميًا للحفاظ على سلسلة انتصاراتك.'),
                    const Text('• إذا فاتك يوم واحد، فسيتم إعادة تعيين سلسلتك إلى اليوم الأول.'),
                    const Text('• مكافآت اليوم السابع مميزة للغاية!'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardDay(int day, String reward, bool claimed, {bool isSpecial = false}) {
    return Card(
      color: claimed ? Colors.grey.shade800 : (isSpecial ? Colors.amber.shade900 : null),
      child: ListTile(
        leading: CircleAvatar(child: Text('$day')),
        title: Text('اليوم $day'),
        subtitle: Text(reward),
        trailing: claimed ? const Icon(Icons.check_circle, color: Colors.green) : ElevatedButton(onPressed: () {}, child: const Text('اجمع')),
      ),
    );
  }
}

// Missions Screen
class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المهام والتحديات'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildMissionCard('ماستر النتيجة', 'الوصول إلى نتيجة 5000 في لعبة واحدة', '0 / 5000', '+500 Coins, +10 Gems'),
          _buildMissionCard('صياد الأعداء', 'تدمير 50 عدوًا', '0 / 50', '+300 Coins, +5 Gems'),
          _buildMissionCard('الناجي', 'البقاء على قيد الحياة لمدة 5 دقائق', '0 / 300s', '+400 Coins, +8 Gems'),
          _buildMissionCard('تشغيل مثالي', 'إكمال المستوى دون تلقي أي ضرر', '0 / 1', '+1000 Coins, +20 Gems'),
          _buildMissionCard('قاتل الزعماء', 'هزيمة 3 زعماء', '0 / 3', '+2000 Coins, +50 Gems', isAchievement: true),
          _buildMissionCard('بطل المستوى', 'الوصول إلى المستوى 20', '0 / 20', '+3000 Coins, +80 Gems', isAchievement: true),
        ],
      ),
    );
  }

  Widget _buildMissionCard(String title, String description, String progress, String reward, {bool isAchievement = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent)),
            const SizedBox(height: 5),
            Text(description),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: 0.3, backgroundColor: Colors.grey.shade700),
            const SizedBox(height: 5),
            Text('التقدم: $progress'),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 5),
                Text(reward),
                const Spacer(),
                ElevatedButton(onPressed: () {}, child: const Text('ابدأ')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Ship Selection Screen
class ShipSelectionScreen extends StatelessWidget {
  const ShipSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر سفينتك'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildShipCard(
            context,
            'مقاتل',
            'سفينة متوازنة ذات سرعة وقوة نيران جيدة',
            {'سرعة': 8, 'القوة النارية': 6, 'الدفاع': 4},
            'خاص: انفجار ناري سريع',
          ),
          _buildShipCard(
            context,
            'صهريج',
            'دروع ثقيلة بأسلحة قوية',
            {'سرعة': 4, 'القوة النارية': 7, 'الدفاع': 9},
            'خاص: تجديد الدرع',
          ),
          _buildShipCard(
            context,
            'المعترض',
            'سريع للغاية مع استهداف دقيق',
            {'سرعة': 10, 'القوة النارية': 5, 'الدفاع': 3},
            'خاص: لوحة القيادة Afterburner',
          ),
        ],
      ),
    );
  }

  Widget _buildShipCard(BuildContext context, String name, String description, Map<String, int> stats, String special) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            ...stats.entries.map((e) => _buildStatBar(e.key, e.value)),
            const SizedBox(height: 16),
            Text(special, style: const TextStyle(color: Colors.amber, fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('اختر'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 10.0,
              minHeight: 10,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
            ),
          ),
          SizedBox(width: 40, child: Text('$value/10', textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

// Redeem Screen
class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استرداد المكافآت'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
                  const SizedBox(height: 20),
                  Text(
                    'تم إرسال طلب الاسترداد!',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'سيتم معالجة الدفع خلال ٢٤ ساعة.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                   const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('العودة'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Admin Panel Screen
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildChargePlayerCard(context),
            const SizedBox(height: 20),
            _buildBulkRewardCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChargePlayerCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('شحن العملة للاعب', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'اسم المستخدم', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: 'كمية العملات', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: 'كمية الجواهر', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('شحن العملة')),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkRewardCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('مكافأة مجمعة لجميع اللاعبين', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'كمية العملات', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: 'كمية الجواهر', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('إرسال إلى جميع اللاعبين')),
          ],
        ),
      ),
    );
  }
}

// Achievements Screen
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإنجازات'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAchievement('مبتدئ الفقاعات', Icons.star, true),
          _buildAchievement('مدمر 1000 فقاعة', Icons.whatshot, true),
          _buildAchievement('الفوز 10 مرات', Icons.military_tech, true),
          _buildAchievement('سلسلة 7 أيام', Icons.date_range, false),
          _buildAchievement('قاتل الزعماء', Icons.shield, false),
          _buildAchievement('جامع السفن', Icons.rocket, false),
        ],
      ),
    );
  }

  Widget _buildAchievement(String title, IconData icon, bool unlocked) {
    return Card(
      color: unlocked ? Colors.amber.shade900 : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: unlocked ? Colors.white : Colors.grey),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: unlocked ? Colors.white : Colors.grey)),
        ],
      ),
    );
  }
}

// Leaderboard Screen
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الصدارة'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: [
          _buildLeaderboardEntry(1, 'PlayerOne', 150230, isPlayer: false),
          _buildLeaderboardEntry(2, 'ProGamer', 145800, isPlayer: false),
          _buildLeaderboardEntry(3, 'BubbleMaster', 130100, isPlayer: false),
          _buildLeaderboardEntry(15, 'You', 80560, isPlayer: true),
        ],
      ),
    );
  }

  Widget _buildLeaderboardEntry(int rank, String name, int score, {required bool isPlayer}) {
    return Card(
      color: isPlayer ? Colors.blue.shade900 : null,
      child: ListTile(
        leading: Text('#$rank', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        title: Text(name),
        trailing: Text('$score', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// Store Screen
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المتجر'),
          backgroundColor: Theme.of(context).primaryColor,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'السفن'),
              Tab(text: 'الأسلحة'),
              Tab(text: 'المظاهر'),
              Tab(text: 'المعززات'),
              Tab(text: 'الترقيات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStoreCategory([
              _buildStoreItem('Tank Ship', '5000 Coins', Icons.shield),
              _buildStoreItem('Interceptor', '3000 Coins', Icons.flash_on),
              _buildStoreItem('Stealth Ship', '500 Gems', Icons.visibility_off),
            ]),
            _buildStoreCategory([
              _buildStoreItem('Laser Cannon', '2000 Coins', Icons.filter_tilt_shift),
              _buildStoreItem('Plasma Gun', '4000 Coins', Icons.album),
              _buildStoreItem('Rocket Launcher', '300 Gems', Icons.rocket_launch),
            ]),
            _buildStoreCategory([
              _buildStoreItem('Gold Skin', '5000 Coins', Icons.color_lens),
              _buildStoreItem('Galaxy Skin', '500 Gems', Icons.flare),
            ]),
             _buildStoreCategory([
              _buildStoreItem('Score Booster', '200 Coins', Icons.arrow_upward),
              _buildStoreItem('Shield Booster', '400 Coins', Icons.security),
            ]),
             _buildStoreCategory([
              _buildStoreItem('Damage Upgrade', '1000 Coins', Icons.add_circle),
              _buildStoreItem('Health Upgrade', '1000 Coins', Icons.favorite),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCategory(List<Widget> items) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: items,
    );
  }

  Widget _buildStoreItem(String name, String price, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(name),
        subtitle: Text(price, style: const TextStyle(color: Colors.amber)),
        trailing: ElevatedButton(onPressed: () {}, child: const Text('شراء')),
      ),
    );
  }
}


// --- Game Logic and Models ---

class Bubble {
  double x;
  double y;
  Color color;
  double speed;

  Bubble({required this.x, required this.y, required this.color, required this.speed});
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;

  BubblePainter({required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var bubble in bubbles) {
      paint.color = bubble.color;
      canvas.drawCircle(Offset(bubble.x, bubble.y), 20, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
