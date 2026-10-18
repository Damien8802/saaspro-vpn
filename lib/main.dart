import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const VPNApp());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
}

class VPNApp extends StatelessWidget {
  const VPNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Stack VPN',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C5CE7),
        scaffoldBackgroundColor: const Color(0xFF0F0F1F),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==================== SPLASH ====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _controller.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      if (token != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F1F), Color(0xFF1A1A3E), Color(0xFF2D1B4E)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 140, height: 140, fit: BoxFit.contain),
              const SizedBox(height: 30),
              const Text('Business Stack VPN', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Ваша цифровая крепость', style: TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== LOGIN ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://businessstack.ru/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': _emailController.text, 'password': _passwordController.text}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'] ?? data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Неверный email или пароль')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F0F1F), Color(0xFF1A1A3E)]),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ БЕЛЫЙ КВАДРАТ С ЛОГОТИПОМ (вместо фиолетового круга)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('VPN', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF6C5CE7))),
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF6C5CE7)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF6C5CE7))),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF6C5CE7)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Войти', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    child: const Text('Зарегистрироваться', style: TextStyle(color: Color(0xFF6C5CE7), fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== REGISTER (НОВЫЙ ЭКРАН) ====================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return;
    }
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пароль должен быть не менее 6 символов')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://businessstack.ru/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyEmailScreen(email: _emailController.text),
            ),
          );
        }
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['error'] ?? 'Ошибка регистрации')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Регистрация'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F0F1F), Color(0xFF1A1A3E)]),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Создать аккаунт', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Имя',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF6C5CE7))),
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF6C5CE7)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF6C5CE7))),
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF6C5CE7)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF6C5CE7))),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF6C5CE7)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Зарегистрироваться', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Уже есть аккаунт? Войти', style: TextStyle(color: Color(0xFF6C5CE7), fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== VERIFY EMAIL (НОВЫЙ ЭКРАН) ====================
class VerifyEmailScreen extends StatelessWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F0F1F), Color(0xFF1A1A3E)]),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mark_email_unread, size: 80, color: Color(0xFF6C5CE7)),
                  const SizedBox(height: 30),
                  const Text('Проверьте почту', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text(
                    'Мы отправили ссылку для подтверждения на\n$email',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Перейдите по ссылке в письме, чтобы активировать аккаунт. После этого вы сможете войти в приложение.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white54),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Вернуться к входу', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== HOME (БЕЗ ИЗМЕНЕНИЙ) ====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FlutterV2ray _flutterV2Ray;
  bool _isConnected = false;
  bool _wasConnected = false;
  bool _isConnecting = false;
  String _userEmail = '';
  String _userName = '';
  bool _isOwner = false;
  int _selectedServer = 0;
  String _vlessUrl = '';

  List<Map<String, dynamic>> _servers = [];

  @override
  void initState() {
    super.initState();
    _flutterV2Ray = FlutterV2ray(onStatusChanged: (status) {
      print('VPN status: ${status.state}');
      if (mounted) {
        setState(() {
          _isConnected = (status.state == 'CONNECTED');
          if (status.state == 'DISCONNECTED' && _wasConnected) {
            _showDisconnectedSnack();
            _wasConnected = false;
          }
          if (status.state == 'CONNECTED') {
            _wasConnected = true;
          }
        });
      }
    });
    _loadUserData();
    _loadCountries();
    _loadVlessConfig();
  }

  Future<void> _loadVlessConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://businessstack.ru/api/vpn/stealth/config/vless'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _vlessUrl = data['vless_url'] ?? '';
        });
        print('VLESS config loaded: ${_vlessUrl.isNotEmpty}');
      } else {
        print('Error loading VLESS config: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading VLESS config: $e');
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('https://businessstack.ru/api/user/profile'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final user = data['user'] ?? {};
          setState(() {
            _userEmail = user['email'] ?? '';
            _userName = user['name'] ?? _userEmail.split('@')[0];
            _isOwner = _userEmail == 'dev@businessstack.ru' || user['role'] == 'owner';
          });
        }
      } catch (e) {
        print('Error loading user: $e');
      }
    }
  }

  Future<void> _loadCountries() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://businessstack.ru/api/vpn/countries'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final countries = data['countries'] as List;

        setState(() {
          _servers = countries.map((c) => {
            'emoji': c['flag'] ?? '🌍',
            'name': c['name'] ?? 'Unknown',
            'ping': '${c['ping'] ?? 0} ms',
            'code': c['code'] ?? '',
            'servers': c['servers'] ?? 0,
          }).toList();
        });

        print('Загружено стран: ${_servers.length}');
      }
    } catch (e) {
      print('Error loading countries: $e');
    }
  }

  void _showDisconnectedSnack() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('VPN отключён. Нажмите «Подключить» снова.'),
        backgroundColor: Colors.red.withOpacity(0.9),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Переподключить',
          textColor: Colors.white,
          onPressed: () {
            if (!_isConnected && !_isConnecting) {
              _toggleVPN();
            }
          },
        ),
      ),
    );
  }

  Future<void> _toggleVPN() async {
    if (_isConnecting) return;

    setState(() => _isConnecting = true);

    try {
      if (_isConnected) {
        await _flutterV2Ray.stopV2Ray();
        setState(() => _isConnected = false);
      } else {
        if (_vlessUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Конфиг VPN не загружен. Обновите страницу.')),
          );
          setState(() => _isConnecting = false);
          return;
        }

        final parser = FlutterV2ray.parseFromURL(_vlessUrl);
        final config = parser.getFullConfiguration();

        final allowed = await _flutterV2Ray.requestPermission();
        if (!allowed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Разрешите VPN в настройках телефона')),
          );
          setState(() => _isConnecting = false);
          return;
        }

        await _flutterV2Ray.initializeV2Ray();

        await _flutterV2Ray.startV2Ray(
          remark: parser.remark,
          config: config,
        );

        setState(() {
          _isConnected = true;
          _wasConnected = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка VPN: $e')),
      );
      print('VPN error: $e');
    }

    setState(() => _isConnecting = false);
  }

  Future<void> _logout() async {
    if (_isConnected) {
      await _flutterV2Ray.stopV2Ray();
      setState(() => _isConnected = false);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F1F), Color(0xFF1A1A3E), Color(0xFF2D1B4E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(),
                if (_isOwner) _buildOwnerBadge(),
                const SizedBox(height: 30),
                _buildVPNButton(),
                _buildServersList(),
                const SizedBox(height: 20),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A3E),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA367F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : '👤',
                    style: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _userName.isNotEmpty ? _userName : 'Пользователь',
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  _userEmail.isNotEmpty ? _userEmail : '',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Профиль', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _openProfile();
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.white),
            title: const Text('Помощь', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _openTelegramHelp();
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Выйти', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }

  void _openProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3E),
        title: const Text('Профиль', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Имя: ${_userName.isNotEmpty ? _userName : "Пользователь"}',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Email: ${_userEmail.isNotEmpty ? _userEmail : "—"}',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Статус: ${_isOwner ? "👑 Владелец" : "Premium"}',
                style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть', style: TextStyle(color: Color(0xFF6C5CE7))),
          ),
        ],
      ),
    );
  }

  Future<void> _openTelegramHelp() async {
    final Uri url = Uri.parse('https://t.me/Business_Stack_Bot');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1A1A3E),
              title: const Text('Помощь', style: TextStyle(color: Colors.white)),
              content: const SelectableText(
                'Telegram-канал: https://t.me/Business_Stack_Bot\n\nСкопируйте ссылку и откройте вручную.',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрыть', style: TextStyle(color: Color(0xFF6C5CE7))),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('Error opening Telegram: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ссылка: https://t.me/Business_Stack_Bot'),
            duration: Duration(seconds: 10),
          ),
        );
      }
    }
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA367F0)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : '👤',
                        style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_userName.isNotEmpty ? _userName : 'Пользователь',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const Text('Premium', style: TextStyle(fontSize: 10, color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFBBF24)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 18, color: Color(0xFFFBBF24)),
          SizedBox(width: 8),
          Text('👑 ВЛАДЕЛЕЦ ПЛАТФОРМЫ',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24))),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // ✅ БЕЛЫЙ КВАДРАТ С ЛОГОТИПОМ
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('VPN', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6C5CE7).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('ОБХОД БЛОКИРОВОК',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildVPNButton() {
    return GestureDetector(
      onTap: _isConnecting ? null : _toggleVPN,
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
                            spreadRadius: 10)
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
                          colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)])
                      : const LinearGradient(
                          colors: [Color(0xFF6C5CE7), Color(0xFFA367F0)]),
                ),
                child: Center(
                  child: _isConnecting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.power_settings_new,
                          size: 60, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isConnecting
                  ? 'ПОДКЛЮЧЕНИЕ...'
                  : (_isConnected ? 'ЗАЩИЩЕН' : 'ОТКЛЮЧЕН'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isConnected ? const Color(0xFF00F2FE) : Colors.white70,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('🌍 Доступные серверы',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        ..._servers.asMap().entries.map((entry) {
          final index = entry.key;
          final server = entry.value;
          return Card(
            color: _selectedServer == index
                ? const Color(0xFF6C5CE7).withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Text(server['emoji'], style: const TextStyle(fontSize: 28)),
              title: Text(server['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${server['ping']} • ${server['servers']} серверов',
                  style: const TextStyle(fontSize: 11)),
              trailing: _selectedServer == index
                  ? const Icon(Icons.check_circle, color: Color(0xFF6C5CE7))
                  : null,
              onTap: () => setState(() => _selectedServer = index),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: _logout,
      icon: const Icon(Icons.logout),
      label: const Text('Выйти'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.withOpacity(0.2),
        foregroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}