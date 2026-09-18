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
      title: 'Multi Game App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainMenuPage(),
    );
  }
}

// ХРАНИЛИЩЕ ДАННЫХ И ИГРОВОГО ПРОГРЕССА
class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  int balance = 0;       // Общий баланс игрока
  int clickPower = 1;    // Текущая сила клика
  int autoClickers = 0;  // Количество купленных автокликеров
  Timer? autoClickTimer; // Таймер для автоматического начисления очков
}
// --- ГЛАВНОЕ МЕНЮ ---
class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final GameState _state = GameState();

  @override
  void initState() {
    super.initState();
    // Запускаем постоянный цикл автокликера (срабатывает раз в секунду)
    _state.autoClickTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.autoClickers > 0) {
        setState(() {
          _state.balance += _state.autoClickers;
        });
      }
    });
  }

  // Функция для обновления меню, когда мы возвращаемся из игры назад
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главное меню'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Панель баланса
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal, width: 2),
              ),
              child: Text(
                '💰 Ваш баланс: ${_state.balance}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 50),
            // Кнопка перехода в Кликер
            ElevatedButton.icon(
              icon: const Icon(Icons.touch_app),
              label: const Text('Играть в Кликер', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const ClickerPage()));
                _refresh();
              },
            ),
            const SizedBox(height: 20),
            // Кнопка перехода в Колесо Фортуны
            ElevatedButton.icon(
              icon: const Icon(Icons.casino),
              label: const Text('Колесо Фортуны', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const FortuneWheelPage()));
                _refresh();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- ЭКРАН 1: КЛИКЕР + МАГАЗИН ---
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
    // Обновляем экран каждую секунду, чтобы видеть пассивный доход
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
        if (type == 'click') {
          _state.clickPower += 1;
        } else if (type == 'auto') {
          _state.autoClickers += 1;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Недостаточно очков для покупки!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int clickCost = _state.clickPower * 10;
    int autoCost = (_state.autoClickers + 1) * 25;

    return Scaffold(
      appBar: AppBar(title: const Text('Кликер Марсиков')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text('Марсиковские клики: ${_state.balance}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              Text('Сила клика: +${_state.clickPower} | Автоклик: ${_state.autoClickers}/сек',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  setState(() { _state.balance += _state.clickPower; });
                },
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: const BoxDecoration(
                    color: Colors.teal, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: const Center(
                    child: Text('МЯУ!', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
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

// --- ЭКРАН 2: КОЛЕСО ФОРТУНЫ С АНИМАЦИЕЙ ---
class FortuneWheelPage extends StatefulWidget {
  const FortuneWheelPage({super.key});

  @override
  State<FortuneWheelPage> createState() => _FortuneWheelPageState();
}

class _FortuneWheelPageState extends State<FortuneWheelPage> {
  final GameState _state = GameState();
  String _currentDisplay = 'Испытай удачу!';
  bool _isSpinning = false;

  final List<Map<String, dynamic>> _prizes = [
    {'text': '🍬 Конфета'},
    {'text': 'Секретный супер приз!'},
    {'text': 'Секретный супер приз!'},
    {'text': 'Ничего'},

  ];

  void _startSpinningAnimation() {
    if (_isSpinning) return;
    setState(() { _isSpinning = true; });

    int counter = 0;
    int totalTicks = 20;

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      counter++;
      setState(() {
        _currentDisplay = _prizes[Random().nextInt(_prizes.length)]['text'];
      });

      if (counter >= totalTicks) {
        timer.cancel();
        _determineFinalPrize();
      }
    });
  }

  void _determineFinalPrize() {
    final finalPrizeMap = _prizes[Random().nextInt(_prizes.length)];
    setState(() {
      _currentDisplay = 'Вы выиграли:\n${finalPrizeMap['text']}';
      _state.balance += finalPrizeMap['value'] as int;
      if (_state.balance < 0) _state.balance = 0;
      _isSpinning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Колесо фортуны')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💰 Баланс: ${_state.balance}', style: const TextStyle(fontSize: 22, color: Colors.teal)),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(25),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity, height: 150, alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _isSpinning ? Colors.amber.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amber, width: 3),
              ),
              child: Text(_currentDisplay, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSpinning ? Colors.grey : Colors.amber, foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              onPressed: _isSpinning ? null : _startSpinningAnimation,
              child: Text(_isSpinning ? 'Колесо крутится...' : 'Крутить колесо!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
