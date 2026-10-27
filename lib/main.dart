import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
const String supabaseUrl = 'https://jmwyirjmybzzseupofln.supabase.co';
const String supabasePublishableKey =
    'sb_publishable_0kzQFOebUxsT7k9ishDwiA_ulDdb_8D';
const Color lime = Color(0xFFD5FF45);
const Color background = Color(0xFF10110F);
const Color panel = Color(0xFF1B1D19);
const Color muted = Color(0xFF9A9D91);
final supabase = Supabase.instance.client;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  runApp(const GoLiftApp());
}
class GoLiftApp extends StatelessWidget {
  const GoLiftApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoLift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: lime,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: panel,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lime,
            foregroundColor: background,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        return supabase.auth.currentSession != null
            ? const DashboardPage()
            : const WelcomePage();
      },
    );
  }
}
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}
class _WelcomePageState extends State<WelcomePage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isSignUp = false;
  bool loading = false;
  bool hidePassword = true;
  String message = '';
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.length < 6) {
      setState(() => message =
          'Enter your email and a password of at least 6 characters.');
      return;
    }
    setState(() {
      loading = true;
      message = '';
    });
    try {
      if (isSignUp) {
        final result = await supabase.auth.signUp(
          email: email,
          password: password,
        );
        if (result.session == null && mounted) {
          setState(() => message =
              'Account created! Check your email to confirm it, then sign in.');
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => message = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => message = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: lime,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: background,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'GOLIFT',
                    style: TextStyle(
                      color: lime,
                      letterSpacing: 5,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Become your\nstrongest self.',
                    style: TextStyle(
                      fontSize: 43,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Your journey. Your progress. Your rules.',
                    style: TextStyle(color: muted, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSignUp ? 'Create your account' : 'Welcome back',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSignUp
                              ? 'Start building your fitness history.'
                              : 'Sign in to continue your journey.',
                          style: const TextStyle(color: muted),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: passwordController,
                          obscureText: hidePassword,
                          autofillHints: [
                            isSignUp
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => hidePassword = !hidePassword,
                              ),
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                        if (message.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(message, style: const TextStyle(color: lime)),
                        ],
                        const SizedBox(height: 22),
                        ElevatedButton(
                          onPressed: loading ? null : submit,
                          child: loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN'),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() {
                              isSignUp = !isSignUp;
                              message = '';
                            }),
                            child: Text(
                              isSignUp
                                  ? 'Already have an account? Sign in'
                                  : 'New to GoLift? Create an account',
                              style: const TextStyle(color: lime),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'YOUR JOURNEY STARTS HERE',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
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
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}
class _DashboardPageState extends State<DashboardPage> {
  final nameController = TextEditingController();
  final heightController = TextEditingController();
  final birthYearController = TextEditingController();
  final weightController = TextEditingController();
  List<Map<String, dynamic>> weightEntries = [];
  List<String> photoPaths = [];
  List<Uint8List> photoBytes = [];
  bool loading = true;
  bool saving = false;
  bool uploadingPhoto = false;
  String message = '';
  String get userId => supabase.auth.currentUser!.id;
  String get email => supabase.auth.currentUser?.email ?? '';
  @override
  void initState() {
    super.initState();
    loadData();
  }
  @override
  void dispose() {
    nameController.dispose();
    heightController.dispose();
    birthYearController.dispose();
    weightController.dispose();
    super.dispose();
  }
  Future<void> loadData() async {
    try {
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (profile != null) {
        nameController.text = profile['display_name']?.toString() ?? '';
        heightController.text = profile['height_cm']?.toString() ?? '';
        birthYearController.text = profile['birth_year']?.toString() ?? '';
      }
      final entries = await supabase
          .from('weight_entries')
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: false);
      await loadPhotos();
      if (!mounted) return;
      setState(() {
        weightEntries = List<Map<String, dynamic>>.from(entries);
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        message = 'Could not load some data. Check your connection and tables.';
      });
    }
  }
  Future<void> loadPhotos() async {
    try {
      final files = await supabase.storage
          .from('progress-photos')
          .list(path: userId);
      final paths = <String>[];
      final bytesList = <Uint8List>[];
      for (final file in files) {
        if (file.name == '.emptyFolderPlaceholder') continue;
        final path = '$userId/${file.name}';
        final bytes = await supabase.storage
            .from('progress-photos')
            .download(path);
        paths.add(path);
        bytesList.add(bytes);
      }
      if (!mounted) return;
      setState(() {
        photoPaths = paths;
        photoBytes = bytesList;
      });
    } catch (_) {
      // An empty photo folder is normal for a new account.
    }
  }
  Future<void> addProgressPhoto() async {
    final picker = ImagePicker();
    try {
      final photo = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (photo == null || !mounted) return;
      setState(() {
        uploadingPhoto = true;
        message = '';
      });
      final bytes = await photo.readAsBytes();
      final extension = photo.name.contains('.')
          ? photo.name.split('.').last.toLowerCase()
          : 'jpg';
      final safeExtension = ['jpg', 'jpeg', 'png', 'webp'].contains(extension)
          ? extension
          : 'jpg';
      final path =
          '$userId/${DateTime.now().millisecondsSinceEpoch}.$safeExtension';
      await supabase.storage.from('progress-photos').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: safeExtension == 'png'
                  ? 'image/png'
                  : safeExtension == 'webp'
                      ? 'image/webp'
                      : 'image/jpeg',
              upsert: false,
            ),
          );
      await loadPhotos();
      if (mounted) {
        setState(() => message = 'Progress photo uploaded privately!');
      }
    } on StorageException catch (e) {
      if (mounted) {
        setState(() => message = 'Photo upload failed: ${e.message}');
      }
    } catch (_) {
      if (mounted) {
        setState(() => message = 'Could not upload photo. Please try again.');
      }
    } finally {
      if (mounted) setState(() => uploadingPhoto = false);
    }
  }
  Future<void> deleteProgressPhoto(String path) async {
    try {
      await supabase.storage.from('progress-photos').remove([path]);
      await loadPhotos();
      if (mounted) setState(() => message = 'Progress photo deleted.');
    } catch (_) {
      if (mounted) {
        setState(() => message = 'Could not delete photo. Check your policies.');
      }
    }
  }
  Future<void> saveProfile() async {
    final height = double.tryParse(heightController.text.trim());
    final yearText = birthYearController.text.trim();
    final year = yearText.isEmpty ? null : int.tryParse(yearText);
    if (heightController.text.trim().isNotEmpty &&
        (height == null || height <= 0 || height > 300)) {
      setState(() => message = 'Enter a valid height in centimetres.');
      return;
    }
    if (yearText.isNotEmpty &&
        (year == null || year < 1900 || year > DateTime.now().year)) {
      setState(() => message = 'Enter a valid birth year.');
      return;
    }
    setState(() {
      saving = true;
      message = '';
    });
    try {
      await supabase.from('profiles').upsert({
        'id': userId,
        'display_name': nameController.text.trim(),
        'height_cm': height,
        'birth_year': year,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      if (mounted) setState(() => message = 'Profile saved successfully!');
    } catch (_) {
      if (mounted) setState(() => message = 'Could not save profile.');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
  Future<void> addWeight() async {
    final weight = double.tryParse(weightController.text.trim());
    if (weight == null || weight <= 0 || weight >= 1000) {
      setState(() => message = 'Enter a valid weight in kilograms.');
      return;
    }
    setState(() {
      saving = true;
      message = '';
    });
    try {
      await supabase.from('weight_entries').insert({
        'user_id': userId,
        'weight_kg': weight,
      });
      weightController.clear();
      await loadData();
      if (mounted) setState(() => message = 'Weight entry saved!');
    } catch (_) {
      if (mounted) setState(() => message = 'Could not save weight.');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
  Widget sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: muted)),
        ],
      ),
    );
  }
  Widget statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: lime, size: 24),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    );
  }
  Widget buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(
          'Progress photos',
          'Private photos to help you track your journey.',
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lock_outline, color: lime),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only you should be able to access your photos.',
                      style: TextStyle(color: muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: uploadingPhoto ? null : addProgressPhoto,
                icon: uploadingPhoto
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_a_photo_outlined),
                label: Text(
                  uploadingPhoto ? 'UPLOADING...' : 'ADD PROGRESS PHOTO',
                ),
              ),
              if (photoBytes.isNotEmpty) ...[
                const SizedBox(height: 18),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: photoBytes.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            photoBytes[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const ColoredBox(
                              color: panel,
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: IconButton(
                              tooltip: 'Delete photo',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () =>
                                  deleteProgressPhoto(photoPaths[index]),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ] else ...[
                const SizedBox(height: 18),
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        color: muted,
                        size: 38,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your progress photos will appear here.',
                        style: TextStyle(color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    final latestWeight = weightEntries.isEmpty
        ? null
        : weightEntries.first['weight_kg'].toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
        title: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: lime, size: 28),
            SizedBox(width: 8),
            Text(
              'GOLIFT',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: lime))
          : RefreshIndicator(
              color: lime,
              onRefresh: loadData,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: lime,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'YOUR JOURNEY',
                              style: TextStyle(
                                color: background,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Welcome${nameController.text.trim().isEmpty ? '' : ', ${nameController.text.trim()}'}!',
                              style: const TextStyle(
                                color: background,
                                fontSize: 29,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Small steps. Strong habits. Real progress.',
                              style: TextStyle(color: background),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      sectionTitle('Your stats', 'Your latest saved measurements'),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = (constraints.maxWidth - 12) / 2;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: width,
                                child: statCard(
                                  'LATEST WEIGHT',
                                  latestWeight == null ? '-- kg' : '$latestWeight kg',
                                  Icons.monitor_weight_outlined,
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: statCard(
                                  'HEIGHT',
                                  heightController.text.isEmpty
                                      ? '-- cm'
                                      : '${heightController.text} cm',
                                  Icons.height_rounded,
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: statCard(
                                  'WEIGHT LOGS',
                                  '${weightEntries.length}',
                                  Icons.trending_up_rounded,
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: statCard(
                                  'ACCOUNT',
                                  'ACTIVE',
                                  Icons.verified_user_outlined,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      sectionTitle(
                        'Your profile',
                        'Saved privately to your account',
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: panel,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Display name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: heightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Height (cm)',
                                prefixIcon: Icon(Icons.height_rounded),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: birthYearController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Birth year (optional)',
                                prefixIcon: Icon(Icons.cake_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: saving ? null : saveProfile,
                              child: Text(saving ? 'SAVING...' : 'SAVE PROFILE'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      buildPhotoSection(),
                      const SizedBox(height: 30),
                      sectionTitle(
                        'Weight history',
                        'Record a measurement whenever you want.',
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: panel,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: weightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Weight in kilograms',
                                prefixIcon:
                                    Icon(Icons.monitor_weight_outlined),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: saving ? null : addWeight,
                              child: Text(
                                saving ? 'SAVING...' : 'ADD WEIGHT ENTRY',
                              ),
                            ),
                            if (weightEntries.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              for (final entry in weightEntries.take(10))
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFF303627),
                                    child: Icon(
                                      Icons.trending_up,
                                      color: lime,
                                    ),
                                  ),
                                  title: Text(
                                    '${entry['weight_kg']} kg',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    entry['recorded_at']
                                        .toString()
                                        .replaceFirst('T', ' ')
                                        .split('.')
                                        .first,
                                    style: const TextStyle(color: muted),
                                  ),
                                ),
                            ] else
                              const Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  'Your weight history will appear here.',
                                  style: TextStyle(color: muted),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (message.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          message,
                          style: const TextStyle(color: lime),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: muted),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}