import 'dart:async';

import 'package:flutter/material.dart';

import 'data/mood_repository.dart';
import 'models/mood_entry.dart';

const _forest = Color(0xFF286B5B);
const _mint = Color(0xFFE7F2EC);
const _paper = Color(0xFFF8F8F3);
const _ink = Color(0xFF263B35);
const _muted = Color(0xFF718079);
const _peach = Color(0xFFFFF0E2);

class MoodApp extends StatefulWidget {
  const MoodApp({super.key, required this.repository});

  final MoodRepository repository;

  @override
  State<MoodApp> createState() => _MoodAppState();
}

class _MoodAppState extends State<MoodApp> {
  String? _name;
  Object? _loadError;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final name = widget.repository.loadName();
      if (!mounted) return;
      setState(() {
        _name = name;
        _loadError = null;
        _ready = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _ready = true;
      });
    }
  }

  Future<void> _register(String name) async {
    await widget.repository.saveName(name);
    if (!mounted) return;
    setState(() => _name = name.trim());
  }

  Future<void> _signOut() async {
    await widget.repository.clearAll();
    if (!mounted) return;
    setState(() => _name = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _forest,
          primary: _forest,
          surface: _paper,
        ),
        scaffoldBackgroundColor: _paper,
        appBarTheme: const AppBarTheme(
          backgroundColor: _paper,
          foregroundColor: _ink,
          centerTitle: false,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: _muted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE6ECE8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _forest, width: 1.5),
          ),
        ),
      ),
      home: !_ready
          ? const _LoadingScreen()
          : _loadError != null
          ? _LoadErrorScreen(error: _loadError!, onRetry: _loadProfile)
          : _name == null
          ? WelcomeScreen(onContinue: _register)
          : MoodShell(
              key: ValueKey(_name),
              name: _name!,
              repository: widget.repository,
              onSignOut: _signOut,
            ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _LoadErrorScreen extends StatelessWidget {
  const _LoadErrorScreen({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: _forest, size: 40),
            const SizedBox(height: 12),
            Text(
              'No se pudieron cargar tus datos.\n$error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    ),
  );
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.onContinue});

  final Future<void> Function(String name) onContinue;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Escribe tu nombre para continuar.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onContinue(name);
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'No se pudo guardar tu perfil: $error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(26, 34, 26, 28),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: _mint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.spa_rounded,
                    color: _forest,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 38),
              Text(
                'Un momento para ti',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(color: _ink, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Conoce tus emociones, crea pequeños hábitos y avanza a tu ritmo.',
                style: TextStyle(color: _muted, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _mint,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Column(
                  children: [
                    Text('🌱', style: TextStyle(fontSize: 58)),
                    SizedBox(height: 10),
                    Text(
                      'Cuidarte también empieza por escucharte.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _forest,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                key: const Key('nameField'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _continue(),
                decoration: const InputDecoration(
                  labelText: '¿Cómo te llamas?',
                  hintText: 'Tu nombre',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                child: FilledButton(
                  key: const Key('startButton'),
                  onPressed: _saving ? null : _continue,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Comenzar'),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Tu perfil y tus registros se guardan en este dispositivo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class MoodShell extends StatefulWidget {
  const MoodShell({
    super.key,
    required this.name,
    required this.repository,
    required this.onSignOut,
  });

  final String name;
  final MoodRepository repository;
  final Future<void> Function() onSignOut;

  @override
  State<MoodShell> createState() => _MoodShellState();
}

class _MoodShellState extends State<MoodShell> {
  int _selectedIndex = 0;
  int _refreshVersion = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        name: widget.name,
        repository: widget.repository,
        onActivities: () => setState(() {
          _selectedIndex = 1;
          _refreshVersion++;
        }),
      ),
      ActivitiesScreen(
        repository: widget.repository,
        refreshVersion: _refreshVersion,
      ),
      HistoryScreen(
        repository: widget.repository,
        refreshVersion: _refreshVersion,
      ),
      ProfileScreen(name: widget.name, onSignOut: widget.onSignOut),
    ];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 680
                ? 680.0
                : constraints.maxWidth;
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: IndexedStack(index: _selectedIndex, children: pages),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                  _refreshVersion++;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.spa_outlined),
                  selectedIcon: Icon(Icons.spa_rounded),
                  label: 'Actividades',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Historial',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.name,
    required this.repository,
    required this.onActivities,
  });

  final String name;
  final MoodRepository repository;
  final VoidCallback onActivities;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _noteController = TextEditingController();
  Mood? _selectedMood;
  late Future<List<MoodEntry>> _entriesFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _entriesFuture = widget.repository.loadEntries();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    final mood = _selectedMood;
    if (mood == null || _saving) return;

    setState(() => _saving = true);
    try {
      await widget.repository.saveEntry(
        MoodEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          mood: mood,
          note: _noteController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _entriesFuture = widget.repository.loadEntries();
        _selectedMood = null;
        _noteController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu ánimo quedó registrado. Gracias por escucharte.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el registro: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<MoodEntry>>(
    future: _entriesFuture,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return _DataError(
          message: 'No se pudo cargar el historial: ${snapshot.error}',
        );
      }
      if (!snapshot.hasData) return const _PageLoading();

      final entries = snapshot.data!;
      final todaysEntry = entries.cast<MoodEntry?>().firstWhere(
        (entry) => _sameDay(entry!.createdAt, DateTime.now()),
        orElse: () => null,
      );

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TU ESPACIO SEGURO', style: _EyebrowStyle()),
                    const SizedBox(height: 5),
                    Text(
                      'Hola, ${widget.name}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: _ink, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 25,
                backgroundColor: _mint,
                child: Icon(Icons.spa_rounded, color: _forest),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _mint,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cada emoción merece un espacio.',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'No hay respuestas correctas o incorrectas.',
                        style: TextStyle(color: _muted, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text('🌿', style: TextStyle(fontSize: 42)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const _SectionHeading(
            title: '¿Cómo te sientes hoy?',
            subtitle: 'Tómate un momento para identificarlo.',
          ),
          const SizedBox(height: 13),
          Row(
            children: Mood.values.map((mood) {
              final selected = _selectedMood == mood;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _MoodChoice(
                    mood: mood,
                    selected: selected,
                    onTap: () => setState(() => _selectedMood = mood),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _noteController,
            minLines: 2,
            maxLines: 4,
            maxLength: 240,
            decoration: const InputDecoration(
              hintText: '¿Quieres contar algo más? (opcional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              key: const Key('saveMoodButton'),
              onPressed: _selectedMood == null || _saving ? null : _saveMood,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.favorite_border),
              label: Text(_saving ? 'Guardando...' : 'Registrar mi ánimo'),
            ),
          ),
          const SizedBox(height: 22),
          if (todaysEntry != null)
            _SurfaceCard(
              color: Colors.white,
              child: Row(
                children: [
                  Text(
                    todaysEntry.mood.emoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tu último registro de hoy',
                          style: _EyebrowStyle(),
                        ),
                        Text(
                          todaysEntry.mood.label,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTime(todaysEntry.createdAt),
                    style: const TextStyle(color: _muted),
                  ),
                ],
              ),
            )
          else
            _SurfaceCard(
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, color: _forest, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entries.isEmpty
                          ? 'Tu primer registro es un pequeño comienzo.'
                          : 'Aún no has registrado cómo te sientes hoy.',
                      style: const TextStyle(color: _ink, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const _SectionHeading(
            title: 'Un pequeño paso',
            subtitle: 'Elige una actividad para cuidarte.',
          ),
          const SizedBox(height: 12),
          _SurfaceCard(
            color: _peach,
            onTap: widget.onActivities,
            child: Row(
              children: [
                const Icon(Icons.air_rounded, color: _forest, size: 28),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Respira con calma',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Una pausa guiada de 3 minutos',
                        style: TextStyle(color: _muted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: _forest, size: 17),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: widget.onActivities,
            icon: const Icon(Icons.spa_outlined),
            label: const Text('Ver actividades'),
          ),
        ],
      );
    },
  );
}

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({
    super.key,
    required this.repository,
    required this.refreshVersion,
  });

  final MoodRepository repository;
  final int refreshVersion;

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  late Future<List<ActivityLog>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = widget.repository.loadActivities();
  }

  @override
  void didUpdateWidget(covariant ActivitiesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _activitiesFuture = widget.repository.loadActivities();
    }
  }

  Future<void> _refreshActivities() async {
    setState(() => _activitiesFuture = widget.repository.loadActivities());
    await _activitiesFuture;
  }

  Future<void> _complete(String title, {String note = ''}) async {
    try {
      await widget.repository.logActivity(title, note: note);
      if (!mounted) return;
      await _refreshActivities();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Bien hecho! "$title" quedó guardada.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la actividad: $error')),
      );
    }
  }

  Future<void> _openBreathing() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BreathingScreen(repository: widget.repository),
      ),
    );
    if (mounted) await _refreshActivities();
  }

  Future<void> _writeGratitude() async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tres cosas buenas'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 5,
          maxLength: 240,
          decoration: const InputDecoration(
            hintText: 'Escribe algo que agradezcas hoy...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note == null || note.isEmpty) return;
    await _complete('Diario de gratitud', note: note);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<ActivityLog>>(
    future: _activitiesFuture,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return _DataError(
          message: 'No se pudieron cargar las actividades: ${snapshot.error}',
        );
      }
      if (!snapshot.hasData) return const _PageLoading();

      final todayCount = snapshot.data!
          .where((activity) => _sameDay(activity.completedAt, DateTime.now()))
          .length;

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        children: [
          const Text('BIENESTAR A TU RITMO', style: _EyebrowStyle()),
          const SizedBox(height: 5),
          Text(
            'Cuida de ti',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: _ink, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pequeñas pausas también cuentan. Elige lo que te haga bien.',
            style: TextStyle(color: _muted, height: 1.45),
          ),
          const SizedBox(height: 18),
          _SurfaceCard(
            color: _mint,
            child: Row(
              children: [
                const Icon(Icons.self_improvement, color: _forest, size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    todayCount == 0
                        ? 'Hoy puedes empezar con una pausa de 3 minutos.'
                        : 'Hoy ya te has regalado $todayCount ${todayCount == 1 ? 'pausa' : 'pausas'}.',
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 21),
          _ActivityCard(
            icon: Icons.air_rounded,
            title: 'Respiración consciente',
            subtitle: 'Sigue un ritmo tranquilo durante 3 minutos.',
            duration: '3 min',
            onTap: _openBreathing,
          ),
          _ActivityCard(
            icon: Icons.edit_note_rounded,
            title: 'Diario de gratitud',
            subtitle: 'Anota algo que haya hecho bien tu día.',
            duration: '2 min',
            onTap: _writeGratitude,
          ),
          _ActivityCard(
            icon: Icons.directions_walk_rounded,
            title: 'Pausa sin pantalla',
            subtitle: 'Levántate, estira el cuerpo y mira a tu alrededor.',
            duration: '5 min',
            onTap: () => _complete('Pausa sin pantalla'),
          ),
          _ActivityCard(
            icon: Icons.water_drop_outlined,
            title: 'Un vaso de agua',
            subtitle: 'Haz una pausa para hidratarte con calma.',
            duration: '1 min',
            onTap: () => _complete('Un vaso de agua'),
          ),
          const SizedBox(height: 14),
          const _SectionHeading(title: 'Actividad reciente'),
          const SizedBox(height: 9),
          if (snapshot.data!.isEmpty)
            const _EmptyState(
              icon: Icons.spa_outlined,
              message: 'Cuando completes una actividad, aparecerá aquí.',
            )
          else
            ...snapshot.data!
                .take(3)
                .map((activity) => _RecentActivityTile(activity: activity)),
        ],
      );
    },
  );
}

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key, required this.repository});

  final MoodRepository repository;

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  static const _totalSeconds = 180;
  Timer? _timer;
  int _remainingSeconds = _totalSeconds;
  bool _isRunning = false;
  bool _isComplete = false;

  void _toggleTimer() {
    if (_isComplete) {
      setState(() {
        _remainingSeconds = _totalSeconds;
        _isComplete = false;
      });
    }
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }

    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
          _isComplete = true;
        });
        unawaited(_saveCompletion());
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _saveCompletion() async {
    try {
      await widget.repository.logActivity('Respiración consciente');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pausa completada. ¡Gracias por dedicarte este tiempo!',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la actividad: $error')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final phase = _isComplete
        ? 'Pausa completada'
        : !_isRunning
        ? 'Cuando estés listo, comienza.'
        : (_remainingSeconds ~/ 4) % 2 == 0
        ? 'Inhala suavemente'
        : 'Suelta el aire despacio';

    return Scaffold(
      appBar: AppBar(title: const Text('Respiración consciente')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Regálate este momento',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Busca una postura cómoda y acompaña tu respiración.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, height: 1.5),
                ),
                const SizedBox(height: 40),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 900),
                  width: _isRunning && (_remainingSeconds ~/ 4) % 2 == 0
                      ? 230
                      : 198,
                  height: _isRunning && (_remainingSeconds ~/ 4) % 2 == 0
                      ? 230
                      : 198,
                  decoration: BoxDecoration(
                    color: _mint,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC9E1D2),
                      width: 8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.air_rounded, color: _forest, size: 30),
                      const SizedBox(height: 8),
                      Text(
                        '$minutes:$seconds',
                        style: const TextStyle(
                          color: _forest,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          phase,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: _forest, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                SizedBox(
                  width: 220,
                  height: 52,
                  child: FilledButton(
                    onPressed: _toggleTimer,
                    child: Text(
                      _isComplete
                          ? 'Repetir'
                          : _isRunning
                          ? 'Pausar'
                          : _remainingSeconds == _totalSeconds
                          ? 'Iniciar'
                          : 'Continuar',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.repository,
    required this.refreshVersion,
  });

  final MoodRepository repository;
  final int refreshVersion;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<MoodEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = widget.repository.loadEntries();
  }

  @override
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _entriesFuture = widget.repository.loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<MoodEntry>>(
    future: _entriesFuture,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return _DataError(
          message: 'No se pudo cargar el historial: ${snapshot.error}',
        );
      }
      if (!snapshot.hasData) return const _PageLoading();

      final entries = snapshot.data!;
      final recent = entries.take(30).toList();
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        children: [
          const Text('MIRA TU CAMINO', style: _EyebrowStyle()),
          const SizedBox(height: 5),
          Text(
            'Tu historial',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: _ink, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cada registro te ayuda a conocerte un poquito más.',
            style: TextStyle(color: _muted, height: 1.45),
          ),
          const SizedBox(height: 18),
          _SectionHeading(
            title: 'Últimos 7 días',
            subtitle: entries.isEmpty
                ? 'Aún no hay registros para comparar.'
                : null,
          ),
          const SizedBox(height: 12),
          _WeeklyMoodChart(entries: entries),
          const SizedBox(height: 22),
          const _SectionHeading(title: 'Registros anteriores'),
          const SizedBox(height: 10),
          if (recent.isEmpty)
            const _EmptyState(
              icon: Icons.calendar_month_outlined,
              message: 'Tus registros de ánimo aparecerán aquí.',
            )
          else
            ...recent.map((entry) => _MoodHistoryTile(entry: entry)),
          if (entries.length > recent.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Mostrando los ${recent.length} registros más recientes.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ),
        ],
      );
    },
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.name, required this.onSignOut});

  final String name;
  final Future<void> Function() onSignOut;

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar datos de este dispositivo'),
        content: const Text(
          'Se eliminarán tu perfil, tus registros de ánimo y tus actividades. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Borrar datos'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await onSignOut();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron borrar los datos: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
    children: [
      const Text('TU CUENTA', style: _EyebrowStyle()),
      const SizedBox(height: 5),
      Text(
        'Perfil',
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(color: _ink, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 20),
      _SurfaceCard(
        color: _mint,
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Text(
                name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                style: const TextStyle(
                  color: _forest,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tu espacio personal', style: _EyebrowStyle()),
                  Text(
                    name,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      const _SectionHeading(title: 'Sobre tus datos'),
      const SizedBox(height: 8),
      const _SurfaceCard(
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline_rounded, color: _forest),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tu perfil, tus notas y tus registros se guardan localmente en este dispositivo. Esta versión no usa cuentas en línea.',
                style: TextStyle(color: _muted, height: 1.5),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      OutlinedButton.icon(
        onPressed: () => _confirmReset(context),
        icon: const Icon(Icons.delete_outline),
        label: const Text('Borrar datos y volver al inicio'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF9B4A3F),
          side: const BorderSide(color: Color(0xFFE9C9C4)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    ],
  );
}

class _WeeklyMoodChart extends StatelessWidget {
  const _WeeklyMoodChart({required this.entries});

  final List<MoodEntry> entries;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(
      7,
      (index) => DateTime(today.year, today.month, today.day - 6 + index),
    );
    final scores = days.map((day) {
      final dayEntries = entries.where(
        (entry) => _sameDay(entry.createdAt, day),
      );
      if (dayEntries.isEmpty) return 0.0;
      final total = dayEntries.fold<int>(
        0,
        (sum, entry) => sum + entry.mood.score,
      );
      return total / dayEntries.length;
    }).toList();

    return _SurfaceCard(
      color: Colors.white,
      child: SizedBox(
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(days.length, (index) {
            final score = scores[index];
            final barHeight = score == 0 ? 8.0 : 14 + (score / 5 * 72);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (score > 0)
                      Text(
                        score.toStringAsFixed(
                          score == score.roundToDouble() ? 0 : 1,
                        ),
                        style: const TextStyle(color: _muted, fontSize: 10),
                      ),
                    const SizedBox(height: 6),
                    Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: score == 0 ? const Color(0xFFE8ECE9) : _forest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _weekdayShort(days[index]),
                      style: const TextStyle(color: _muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _MoodChoice extends StatelessWidget {
  const _MoodChoice({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: mood.label,
    child: InkWell(
      key: Key('moodOption-${mood.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
        decoration: BoxDecoration(
          color: selected ? _mint : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _forest : const Color(0xFFE7ECE8),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 25)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                mood.label,
                style: TextStyle(
                  color: selected ? _forest : _muted,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: _SurfaceCard(
      color: Colors.white,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _mint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _forest),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    height: 1.35,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  duration,
                  style: const TextStyle(color: _forest, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: _forest, size: 16),
        ],
      ),
    ),
  );
}

class _MoodHistoryTile extends StatelessWidget {
  const _MoodHistoryTile({required this.entry});

  final MoodEntry entry;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(entry.mood.emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.mood.label,
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (entry.note.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  entry.note,
                  style: const TextStyle(color: _muted, height: 1.4),
                ),
              ],
              const SizedBox(height: 5),
              Text(
                '${_formatDate(entry.createdAt)} · ${_formatTime(entry.createdAt)}',
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RecentActivityTile extends StatelessWidget {
  const _RecentActivityTile({required this.activity});

  final ActivityLog activity;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        const Icon(Icons.check_circle_outline, color: _forest, size: 19),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            activity.title,
            style: const TextStyle(color: _ink, fontSize: 13),
          ),
        ),
        Text(
          _formatTime(activity.completedAt),
          style: const TextStyle(color: _muted, fontSize: 11),
        ),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: _ink,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(subtitle!, style: const TextStyle(color: _muted, fontSize: 12)),
      ],
    ],
  );
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.color,
    required this.child,
    this.onTap,
    this.margin,
  });

  final Color color;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) => Card(
    color: color,
    margin: margin,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    color: Colors.white,
    child: Row(
      children: [
        Icon(icon, color: _forest),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: _muted, height: 1.4),
          ),
        ),
      ],
    ),
  );
}

class _DataError extends StatelessWidget {
  const _DataError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

class _PageLoading extends StatelessWidget {
  const _PageLoading();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _EyebrowStyle extends TextStyle {
  const _EyebrowStyle()
    : super(
        color: _muted,
        fontSize: 10,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w700,
      );
}

bool _sameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

String _weekdayShort(DateTime date) =>
    const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'][date.weekday - 1];

String _formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

String _formatDate(DateTime date) {
  final today = DateTime.now();
  if (_sameDay(date, today)) return 'Hoy';
  if (_sameDay(date, today.subtract(const Duration(days: 1)))) return 'Ayer';
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  return '${_weekdayShort(date)} ${date.day} ${months[date.month - 1]}';
}
