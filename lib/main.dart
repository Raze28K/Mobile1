import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Приложение для Ромы',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainMenuPage(),
    );
  }
}

class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  int balance = 0;
  int clickPower = 1;
  int autoClickers = 0;
  Timer? autoClickTimer;
}

class ConfettiParticle {
  double x = Random().nextDouble();
  double y = Random().nextDouble() * -1;
  double speed = Random().nextDouble() * 0.02 + 0.005;
  Color color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
  double size = Random().nextDouble() * 6 + 4;
}
class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final GameState _state = GameState();
  final List<ConfettiParticle> _menuConfetti = List.generate(30, (index) => ConfettiParticle());
  Timer? _menuConfettiTimer;

  @override
  void initState() {
    super.initState();
    _state.autoClickTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.autoClickers > 0) {
        setState(() { _state.balance += _state.autoClickers; });
      }
    });

    _menuConfettiTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          for (var p in _menuConfetti) {
            p.y += p.speed;
            if (p.y > 1.1) {
              p.y = -0.1;
              p.x = Random().nextDouble();
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _menuConfettiTimer?.cancel();
    super.dispose();
  }

  void _refresh() { setState(() {}); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Приложение для Ромы', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          // Задний фон: Теперь здесь отображается ваша скачанная картинка
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.png'),
                fit: BoxFit.cover, // Растягивает картинку под размер любого экрана
              ),
            ),
          ),

          // Слой с падающими конфетти
          CustomPaint(size: Size.infinite, painter: ConfettiPainter(particles: _menuConfetti)),

          // Кнопки интерфейса поверх фона
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Text(
                    '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton.icon(
                  icon: const Icon(Icons.touch_app),
                  label: const Text('Играть в Кликер', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.purple, foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const ClickerPage()));
                    _refresh();
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.casino),
                  label: const Text('Колесо Фортуны', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const FortuneWheelPage()));
                    _refresh();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class ClickerPage extends StatefulWidget {
  const ClickerPage({super.key});

  @override
  State<ClickerPage> createState() => _ClickerPageState();
}

class _ClickerPageState extends State<ClickerPage> {
  final GameState _state = GameState();
  Timer? _localTimer;

  @override
  void initState() {
    super.initState();
    _localTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _localTimer?.cancel();
    super.dispose();
  }

  void _buyUpgrade(String type, int cost) {
    if (_state.balance >= cost) {
      setState(() {
        _state.balance -= cost;
        if (type == 'click') _state.clickPower += 1;
        if (type == 'auto') _state.autoClickers += 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Недостаточно очков!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    int clickCost = _state.clickPower * 10;
    int autoCost = (_state.autoClickers + 1) * 25;

    return Scaffold(
      appBar: AppBar(title: const Text('Приложение Ромы: Кликер')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text('Очки: ${_state.balance}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              Text('Сила клика: +${_state.clickPower} | Автоклик: ${_state.autoClickers}/сек',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () { setState(() { _state.balance += _state.clickPower; }); },
                child: Container(
                  width: 160, height: 160,
                  decoration: const BoxDecoration(
                    color: Colors.purple, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: const Center(
                    child: Text('КЛИК!', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('🛒 МАГАЗИН УЛУЧШЕНИЙ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.add_moderator, color: Colors.blue),
                title: const Text('Прокачать клик (+1)'),
                subtitle: Text('Цена: $clickCost очков'),
                trailing: ElevatedButton(
                  onPressed: () => _buyUpgrade('click', clickCost),
                  child: const Text('Купить'),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.android, color: Colors.green),
                title: const Text('Нанять автокликера (+1/сек)'),
                subtitle: Text('Цена: $autoCost очков'),
                trailing: ElevatedButton(
                  onPressed: () => _buyUpgrade('auto', autoCost),
                  child: const Text('Купить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class FortuneWheelPage extends StatefulWidget {
  const FortuneWheelPage({super.key});

  @override
  State<FortuneWheelPage> createState() => _FortuneWheelPageState();
}

class _FortuneWheelPageState extends State<FortuneWheelPage> with SingleTickerProviderStateMixin {
  final GameState _state = GameState();
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _confettiTimer;

  double _currentAngle = 0.0;
  String _resultText = 'Попыток осталось: 4';
  bool _isSpinning = false;
  final List<ConfettiParticle> _confetti = List.generate(40, (index) => ConfettiParticle());
  int _spinCount = 0;

  final List<Map<String, dynamic>> _prizes = [
    {'text': '🍬 Конфеты', 'color': Colors.redAccent, 'id': 'candy'},
    {'text': '🎮 PSP!', 'color': Colors.purpleAccent, 'id': 'psp'},
    {'text': '📱 iPhone 9', 'color': Colors.greenAccent, 'id': 'iphone'},
    {'text': '🚲 Велик', 'color': Colors.orangeAccent, 'id': 'bike'},
    {'text': '💥 Ничего', 'color': Colors.blueAccent, 'id': 'nothing'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic);

    _confettiTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          for (var p in _confetti) {
            p.y += p.speed;
            if (p.y > 1.1) { p.y = -0.1; p.x = Random().nextDouble(); }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiTimer?.cancel();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning || _spinCount >= 4) return;

    setState(() {
      _isSpinning = true;
      _spinCount++;
      _resultText = 'Колесо крутится...';
    });

    int targetIdx = (_spinCount <= 3) ? 0 : 1;
    double sectorSize = (2 * pi) / _prizes.length;
    double targetAngle = (1.5 * pi) - (targetIdx * sectorSize) - (sectorSize / 2);
    double totalRotation = (4 * 2 * pi) + targetAngle;

    _animation = Tween<double>(begin: _currentAngle, end: totalRotation).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward(from: 0.0).then((_) {
      setState(() {
        _currentAngle = totalRotation % (2 * pi);
        final finalPrize = _prizes[targetIdx];

        int leftSpins = 4 - _spinCount;
        if (leftSpins > 0) {
          _resultText = 'Вы выиграли: ${finalPrize['text']}\nОсталось попыток: $leftSpins';
        } else {
          _resultText = 'Вы выиграли: ${finalPrize['text']}\nПопытки закончились!';
        }

        _isSpinning = false;
        if (finalPrize['id'] == 'psp') _showPSPDialog();
      });
    });
  }

  void _showPSPDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.gamepad, size: 120, color: Colors.white),
              const SizedBox(height: 20),
              const Text('🎮 МЕГА ВЫИГРЫШ! 🎮', style: TextStyle(color: Colors.yellow, fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text('РОМА ВЫИГРАЛ КРУТУЮ PSP!\nГЛАВНЫЙ СУПЕР-ПРИЗ!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, foregroundColor: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('ЗАБРАТЬ ПРИЗ И ВЫЙТИ!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canSpin = !_isSpinning && _spinCount < 4;

    return Scaffold(
      appBar: AppBar(title: const Text('Приложение Ромы'), centerTitle: true),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          CustomPaint(size: Size.infinite, painter: ConfettiPainter(particles: _confetti)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Колесо сдвинуто на 200 пикселей вниз
                Transform.translate(
                  offset: const Offset(3, -70),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _animation.value,
                            child: CustomPaint(size: const Size(280, 280), painter: WheelPainter(prizes: _prizes)),
                          );
                        },
                      ),
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 25, height: 25,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 22),
                        ),
                      ),
                      Container(
                        width: 35, height: 35,
                        decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                      ),
                    ],
                  ),
                ),

                // Создаем большой регулируемый зазор под колесом, чтобы открыть лицо
                const SizedBox(height: 60),

                // 2. ВСЯ ОСТАЛЬНАЯ ЧАСТЬ (Очки, табло, кнопка) теперь ТОЖЕ сдвинута на 200 пикселей вниз
                Transform.translate(
                  offset: const Offset(0,0),
                  child: Column(
                    children: [

                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.purple.shade300, width: 2),
                        ),
                        child: Text(_resultText, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canSpin ? Colors.purple : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                          elevation: canSpin ? 5 : 0,
                        ),
                        onPressed: canSpin ? _spinWheel : null,
                        child: Text(
                          _isSpinning ? 'Колесо крутится...' : (_spinCount >= 4 ? 'Попытки исчерпаны' : 'Крутить колесо!'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var p in particles) {
      paint.color = p.color;
      canvas.drawRect(Rect.fromLTWH(p.x * size.width, p.y * size.height, p.size, p.size), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> prizes;
  WheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = 0.0;
    double sweepAngle = (2 * pi) / prizes.length;

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3;

    for (int i = 0; i < prizes.length; i++) {
      paint.color = prizes[i]['color'] as Color;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + (sweepAngle / 2));

      const textStyle = TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold);
      final textSpan = TextSpan(text: prizes[i]['text'] as String, style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();

      textPainter.paint(canvas, Offset(radius * 0.35, -textPainter.height / 2));
      canvas.restore();
      startAngle += sweepAngle;
    }

    canvas.drawCircle(center, radius, Paint()..color = Colors.amber.shade600..style = PaintingStyle.stroke..strokeWidth = 6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
