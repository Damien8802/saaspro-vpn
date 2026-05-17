import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';

void main() {
  runApp(const SaaSProApp());
}

class SaaSProApp extends StatelessWidget {
  const SaaSProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaaSPro VPN',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF4361EE),
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnected = false;
  double _downloadSpeed = 0.0;
  double _uploadSpeed = 0.0;
  int _connectionSeconds = 0;
  int _selectedIndex = 0;
  int _selectedServer = 0;
  
  bool _stealthMode = true;
  bool _splitTunneling = false;
  bool _killSwitch = true;
  bool _perAppProxy = false;
  bool _localDNS = false;
  List<String> _selectedApps = [];
  List<String> _excludedRoutes = [];
  TextEditingController _routeController = TextEditingController();
  
  final List<Map<String, dynamic>> _servers = [
    {'emoji': '🚀', 'name': 'Авто', 'ping': 'Лучший', 'ip': 'auto'},
    {'emoji': '🇷🇺', 'name': 'Россия', 'ping': '5 ms', 'ip': '185.159.157.1'},
    {'emoji': '🇳🇱', 'name': 'Нидерланды', 'ping': '35 ms', 'ip': '185.159.158.1'},
    {'emoji': '🇺🇸', 'name': 'США', 'ping': '120 ms', 'ip': '185.159.159.1'},
    {'emoji': '🇩🇪', 'name': 'Германия', 'ping': '40 ms', 'ip': '185.159.160.1'},
    {'emoji': '🇸🇬', 'name': 'Сингапур', 'ping': '150 ms', 'ip': '185.159.161.1'},
  ];

  Timer? _speedTimer;
  Timer? _connectionTimer;

  @override
  void dispose() {
    _speedTimer?.cancel();
    _connectionTimer?.cancel();
    _routeController.dispose();
    super.dispose();
  }

  void _toggleVPN() {
    setState(() {
      _isConnected = !_isConnected;
      if (_isConnected) {
        _startVPN();
      } else {
        _stopVPN();
      }
    });
  }

  void _startVPN() {
    _speedTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isConnected) {
        setState(() {
          _downloadSpeed = (50 + Random().nextInt(100)).toDouble();
          _uploadSpeed = (20 + Random().nextInt(50)).toDouble();
        });
      } else {
        timer.cancel();
      }
    });
    
    _connectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isConnected) {
        setState(() {
          _connectionSeconds++;
        });
      } else {
        timer.cancel();
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔒 VPN подключен - Обход блокировок активен')),
    );
  }

  void _stopVPN() {
    _connectionSeconds = 0;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔓 VPN отключен')),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1A1A3E), Color(0xFF2D1B4E)],
          ),
        ),
        child: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomePage(),
              _buildServersPage(),
              _buildAppsPage(),
              _buildProfilePage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(),
          _buildBrand(),
          _buildVPNButton(),
          if (_isConnected) _buildStats(),
          const SizedBox(height: 20),
          _buildBypassModes(),
          const SizedBox(height: 20),
          _buildExcludedRoutes(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(
          builder: (context) => Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4361EE), Color(0xFF7209B7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('👤', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SaaSPro', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Премиум', style: TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4361EE), Color(0xFF7209B7)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4361EE).withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Center(child: Icon(Icons.shield, size: 50, color: Colors.white)),
        ),
        const SizedBox(height: 20),
        const Text(
          'SaaSPro',
          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Обход блокировок • Ваша цифровая крепость',
          style: TextStyle(fontSize: 12, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildVPNButton() {
    return GestureDetector(
      onTap: _toggleVPN,
      child: Container(
        margin: const EdgeInsets.all(30),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
                boxShadow: _isConnected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00F2FE).withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ]
                    : [],
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 140,
                height: 140,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _isConnected
                      ? const LinearGradient(
                          colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF4361EE), Color(0xFF7209B7)],
                        ),
                ),
                child: const Center(
                  child: Icon(Icons.shield, size: 60, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isConnected ? 'ЗАЩИЩЕН' : 'ОТКЛЮЧЕН',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isConnected ? const Color(0xFF00F2FE) : Colors.white70,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isConnected ? _servers[_selectedServer]['name'] : 'Нажмите для защиты',
              style: const TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.download, '${_downloadSpeed.toInt()}', 'Мбит/с'),
          _buildStatItem(Icons.upload, '${_uploadSpeed.toInt()}', 'Мбит/с'),
          _buildStatItem(Icons.timer, _formatTime(_connectionSeconds), ''),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String unit) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4361EE), size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (unit.isNotEmpty)
          Text(unit, style: const TextStyle(fontSize: 11, color: Colors.white54)),
      ],
    );
  }

  Widget _buildBypassModes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.shield, size: 20, color: Color(0xFF4361EE)),
              SizedBox(width: 8),
              Text('Технологии обхода', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          _buildModeToggle('Стелс-режим', 'Маскировка под HTTPS', _stealthMode, (val) {
            setState(() => _stealthMode = val);
          }),
          _buildModeToggle('Split Tunneling', 'Только заблокированные сайты', _splitTunneling, (val) {
            setState(() => _splitTunneling = val);
          }),
          _buildModeToggle('Kill Switch', 'Блокировка интернета при отключении', _killSwitch, (val) {
            setState(() => _killSwitch = val);
          }),
          _buildModeToggle('Per App Proxy', 'Прокси только для выбранных приложений', _perAppProxy, (val) {
            setState(() => _perAppProxy = val);
          }),
          _buildModeToggle('Локальный DNS', 'Использовать свой DNS сервер', _localDNS, (val) {
            setState(() => _localDNS = val);
          }),
        ],
      ),
    );
  }

  Widget _buildModeToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4361EE),
          ),
        ],
      ),
    );
  }

  Widget _buildExcludedRoutes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.route, size: 20, color: Color(0xFF4361EE)),
              SizedBox(width: 8),
              Text('Исключенные маршруты', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _routeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'IP адрес или диапазон',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (_routeController.text.isNotEmpty) {
                    setState(() {
                      _excludedRoutes.add(_routeController.text);
                      _routeController.clear();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4361EE),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _excludedRoutes.map((route) => Chip(
              label: Text(route),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() => _excludedRoutes.remove(route)),
              backgroundColor: Colors.white.withOpacity(0.1),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServersPage() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _servers.length,
      itemBuilder: (context, index) {
        final server = _servers[index];
        return Card(
          color: _selectedServer == index
              ? const Color(0xFF4361EE).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Text(server['emoji'], style: const TextStyle(fontSize: 30)),
            title: Text(server['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${server['ping']} • ${server['ip']}', style: const TextStyle(fontSize: 12)),
            trailing: _selectedServer == index
                ? const Icon(Icons.check_circle, color: Color(0xFF4361EE))
                : null,
            onTap: () {
              setState(() {
                _selectedServer = index;
                _selectedIndex = 0;
              });
              if (_isConnected) {
                _stopVPN();
                Future.delayed(const Duration(seconds: 1), () => _startVPN());
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildAppsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.apps, size: 80, color: Color(0xFF4361EE)),
          const SizedBox(height: 20),
          const Text(
            'Per App Proxy',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _selectedApps.isEmpty 
                ? 'Все приложения через VPN' 
                : '${_selectedApps.length} приложений в исключении',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          if (_selectedApps.isNotEmpty)
            Container(
              height: 200,
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: _selectedApps.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_selectedApps[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedApps.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Выбор приложений будет в следующей версии')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text('Выбрать приложения'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4361EE), Color(0xFF7209B7)],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Center(child: Text('👤', style: TextStyle(fontSize: 50))),
          ),
          const SizedBox(height: 20),
          const Text('SaaSPro Пользователь', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Премиум подписка', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 30),
          Card(
            color: Colors.white.withOpacity(0.05),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Действует до: 31.12.2025'),
                  SizedBox(height: 10),
                  Text('Тариф: Безлимитный'),
                  SizedBox(height: 10),
                  Text('Скорость: До 1 Гбит/с'),
                  SizedBox(height: 10),
                  Text('Обход DPI: Активен'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Главная', 0),
          _buildNavItem(Icons.public, 'Серверы', 1),
          _buildNavItem(Icons.apps, 'Приложения', 2),
          _buildNavItem(Icons.person, 'Профиль', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF4361EE) : Colors.white54, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: isSelected ? const Color(0xFF4361EE) : Colors.white54)),
        ],
      ),
    );
  }
}
