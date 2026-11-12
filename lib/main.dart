import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';

const _ink = Color(0xff17233c);
const _muted = Color(0xff72809a);
const _primary = Color(0xff1769aa);
const _canvas = Color(0xfff5f6fa);
const _line = Color(0xffe9ecf3);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    runApp(const UserAdminApp());
  } catch (error) {
    runApp(ConfigurationApp(message: error.toString()));
  }
}

class UserAdminApp extends StatelessWidget {
  const UserAdminApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'QLHocPhan · Quản trị giảng viên',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: _primary, surface: Colors.white),
          scaffoldBackgroundColor: _canvas,
          appBarTheme: const AppBarTheme(
              backgroundColor: _canvas, foregroundColor: _ink, elevation: 0),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            hintStyle: const TextStyle(color: _muted),
            labelStyle: const TextStyle(color: _muted),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _line)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _line)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _primary, width: 1.5)),
          ),
          cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: _line))),
          snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
        ),
        home: const AuthGate(),
      );
}

class ConfigurationApp extends StatelessWidget {
  const ConfigurationApp({required this.message, super.key});
  final String message;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: _primary)),
        home: Scaffold(
          backgroundColor: _canvas,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const _BrandMark(size: 62),
                    const SizedBox(height: 20),
                    const Text('Cần hoàn tất cấu hình Firebase',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            color: _ink)),
                    const SizedBox(height: 12),
                    const Text(
                        'Chạy flutterfire configure trong thư mục dự án, sau đó khởi động lại ứng dụng.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _muted, height: 1.5)),
                    const SizedBox(height: 20),
                    SelectableText(message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _muted, fontSize: 12)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                backgroundColor: _canvas,
                body:
                    Center(child: CircularProgressIndicator(color: _primary)));
          }
          return snapshot.data == null
              ? const LoginPage()
              : const UserListPage();
        },
      );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.size = 42});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_primary, Color(0xff42a5f5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(size * .3),
            boxShadow: [
              BoxShadow(
                  color: _primary.withValues(alpha: .23),
                  blurRadius: 18,
                  offset: const Offset(0, 7))
            ]),
        child:
            Icon(Icons.layers_rounded, color: Colors.white, size: size * .56),
      );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(), password: _password.text);
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = _friendlyAuthError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _canvas,
        body: LayoutBuilder(builder: (context, box) {
          final horizontalPadding = box.maxWidth >= 620 ? 32.0 : 20.0;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 8,
                  shadowColor: _ink.withValues(alpha: .08),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(children: [
                            _BrandMark(size: 42),
                            SizedBox(width: 12),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('QLHocPhan',
                                      style: TextStyle(
                                          color: _ink,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800)),
                                  Text('QUẢN TRỊ GIẢNG VIÊN',
                                      style: TextStyle(
                                          color: _muted,
                                          fontSize: 9,
                                          letterSpacing: 1.1,
                                          fontWeight: FontWeight.w700))
                                ])
                          ]),
                          const SizedBox(height: 36),
                          const Text('Đăng nhập',
                              style: TextStyle(
                                  color: _ink,
                                  fontSize: 30,
                                  height: 1.1,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.8)),
                          const SizedBox(height: 8),
                          const Text('Truy cập không gian quản lý giảng viên.',
                              style: TextStyle(
                                  color: _muted, fontSize: 14, height: 1.5)),
                          const SizedBox(height: 28),
                          const _FieldLabel('Email quản trị'),
                          const SizedBox(height: 8),
                          TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.username],
                              decoration: const InputDecoration(
                                  hintText: 'admin@example.com',
                                  prefixIcon: Icon(Icons.mail_outline_rounded)),
                              validator: (value) =>
                                  value == null || !value.contains('@')
                                      ? 'Nhập địa chỉ email hợp lệ'
                                      : null),
                          const SizedBox(height: 18),
                          const _FieldLabel('Mật khẩu'),
                          const SizedBox(height: 8),
                          TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                  hintText: 'Nhập mật khẩu',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                      tooltip: _obscure
                                          ? 'Hiện mật khẩu'
                                          : 'Ẩn mật khẩu',
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                      icon: Icon(_obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined))),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Vui lòng nhập mật khẩu'
                                      : null,
                              onFieldSubmitted: (_) => _login()),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                    color: const Color(0xfffff0ef),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text(_error!,
                                    style: const TextStyle(
                                        color: Color(0xffbb3f3b),
                                        height: 1.4))),
                          ],
                          const SizedBox(height: 24),
                          FilledButton(
                              onPressed: _busy ? null : _login,
                              style: FilledButton.styleFrom(
                                  backgroundColor: _primary,
                                  minimumSize: const Size.fromHeight(52),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13)),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                              child: _busy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Text('Đăng nhập')),
                          const SizedBox(height: 22),
                          const Row(children: [
                            Expanded(child: Divider(color: _line)),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('FIREBASE AUTH',
                                    style: TextStyle(
                                        color: _muted,
                                        fontSize: 10,
                                        letterSpacing: 1.1,
                                        fontWeight: FontWeight.w700))),
                            Expanded(child: Divider(color: _line))
                          ])
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          color: _ink, fontSize: 13, fontWeight: FontWeight.w700));
}

String _friendlyAuthError(FirebaseAuthException error) => switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' =>
        'Email hoặc mật khẩu chưa chính xác.',
      'too-many-requests' =>
        'Bạn thử đăng nhập quá nhiều lần. Vui lòng đợi một lúc rồi thử lại.',
      'network-request-failed' =>
        'Không kết nối được mạng. Hãy kiểm tra kết nối rồi thử lại.',
      _ => error.message ?? 'Đăng nhập chưa thành công. Vui lòng thử lại.',
    };

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});
  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _search = TextEditingController();
  String _query = '';
  CollectionReference<Map<String, dynamic>> get _users =>
      FirebaseFirestore.instance.collection('Giang Vien');

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _delete(DocumentSnapshot<Map<String, dynamic>> document) async {
    final idgv = document.data()?['IDGV'] ?? '';
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xffc64e55)),
              title: const Text('Xóa hồ sơ này?'),
              content: Text('Giảng viên $idgv sẽ bị xóa khỏi danh sách.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Giữ lại')),
                FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xffc64e55)),
                    child: const Text('Xóa hồ sơ'))
              ],
            ));
    if (confirmed == true && mounted) {
      try {
        await _users.doc(document.id).delete();
        if (mounted) _showMessage('Đã xóa giảng viên.');
      } catch (error) {
        if (mounted) _showMessage('Không xóa được hồ sơ: $error', error: true);
      }
    }
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xffa9323b) : _ink));
  }

  Future<void> _openForm(
      {DocumentSnapshot<Map<String, dynamic>>? document}) async {
    final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => UserFormDialog(document: document));
    if (result == true && mounted) {
      _showMessage(document == null
          ? 'Đã thêm giảng viên mới.'
          : 'Đã cập nhật giảng viên.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _canvas,
        body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1040;
          if (!wide) {
            return _mainContent(context, constraints.maxWidth, wide: false);
          }
          return Row(children: [
            _Sidebar(onLogout: () => FirebaseAuth.instance.signOut()),
            Expanded(
                child: _mainContent(context, constraints.maxWidth - 250,
                    wide: true)),
          ]);
        })),
      );

  Widget _mainContent(BuildContext context, double width,
          {required bool wide}) =>
      Column(children: [
        if (!wide) _mobileTopBar(),
        Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _users.orderBy('Fullname').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _errorState(snapshot.error.toString());
            }
            if (!snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: _primary));
            }
            final allDocs = snapshot.data!.docs;
            final docs = allDocs.where((document) {
              final data = document.data();
              return '${data['Fullname'] ?? ''} ${data['IDGV'] ?? ''}'
                  .toLowerCase()
                  .contains(_query);
            }).toList();
            final withPhoto = allDocs
                .where((d) => (d.data()['Image'] as String? ?? '').isNotEmpty)
                .length;
            return _dashboard(
                context, width, wide, allDocs.length, withPhoto, docs);
          },
        )),
      ]);

  Widget _mobileTopBar() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 14, 4),
        child: Row(children: [
          const _BrandMark(size: 38),
          const SizedBox(width: 11),
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('QLHocPhan',
                    style: TextStyle(
                        color: _ink,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
                Text('Quản trị giảng viên',
                    style: TextStyle(color: _muted, fontSize: 11))
              ])),
          IconButton(
              tooltip: 'Đăng xuất',
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout_rounded, color: _muted)),
        ]),
      );

  Widget _dashboard(BuildContext context, double width, bool wide, int total,
      int withPhoto, List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final compact = width < 650;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          compact ? 18 : 34, compact ? 20 : 34, compact ? 18 : 34, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1380),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (wide) _desktopTopBar(),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('TỔNG QUAN',
                        style: TextStyle(
                            color: _primary.withValues(alpha: .9),
                            fontSize: 11,
                            letterSpacing: 1.65,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('Giảng viên',
                        style: TextStyle(
                            color: _ink,
                            fontSize: compact ? 27 : 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1)),
                    const SizedBox(height: 7),
                    const Text('Theo dõi và cập nhật hồ sơ trong hệ thống.',
                        style: TextStyle(color: _muted, fontSize: 14)),
                  ])),
              if (!compact)
                FilledButton.icon(
                    onPressed: () => _openForm(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Thêm giảng viên'),
                    style: FilledButton.styleFrom(
                        backgroundColor: _primary,
                        minimumSize: const Size(188, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        textStyle:
                            const TextStyle(fontWeight: FontWeight.w700))),
            ]),
            if (compact) ...[
              const SizedBox(height: 18),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                      onPressed: () => _openForm(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Thêm giảng viên'),
                      style: FilledButton.styleFrom(
                          backgroundColor: _primary,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.w700)))),
            ],
            const SizedBox(height: 26),
            _stats(width, total, withPhoto),
            const SizedBox(height: 28),
            _peoplePanel(context, docs, total, compact),
          ]),
        ),
      ),
    );
  }

  Widget _desktopTopBar() => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Row(children: [
          const Icon(Icons.grid_view_rounded, size: 18, color: _muted),
          const SizedBox(width: 9),
          const Text('Không gian làm việc',
              style: TextStyle(color: _muted, fontSize: 13)),
          const Spacer(),
          CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xffe8f2fb),
              child: Text(
                  (FirebaseAuth.instance.currentUser?.email ?? 'A')[0]
                      .toUpperCase(),
                  style: const TextStyle(
                      color: _primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800))),
          const SizedBox(width: 10),
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(FirebaseAuth.instance.currentUser?.email ?? 'Admin',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _ink, fontSize: 13, fontWeight: FontWeight.w600))),
        ]),
      );

  Widget _stats(double width, int total, int withPhoto) {
    final count = width < 550 ? 1 : 3;
    final items = [
      _StatCard(
          icon: Icons.groups_2_outlined,
          label: 'Tổng hồ sơ',
          value: '$total',
          detail: 'Đang lưu trong hệ thống',
          tint: const Color(0xffe8f2fb),
          iconColor: _primary),
      _StatCard(
          icon: Icons.image_outlined,
          label: 'Có hình ảnh',
          value: '$withPhoto',
          detail: 'Hồ sơ đã có ảnh đại diện',
          tint: const Color(0xffe4f6f1),
          iconColor: const Color(0xff2c9a7a)),
      _StatCard(
          icon: Icons.cloud_done_outlined,
          label: 'Trạng thái',
          value: 'Hoạt động',
          detail: 'Đồng bộ trực tiếp Firestore',
          tint: const Color(0xfffff2df),
          iconColor: const Color(0xffd38c29),
          valueSize: 21),
    ];
    if (count == 1) {
      return Column(
          children: items
              .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10), child: item))
              .toList());
    }
    return Row(children: [
      for (var i = 0; i < items.length; i++)
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(right: i == items.length - 1 ? 0 : 14),
                child: items[i]))
    ]);
  }

  Widget _peoplePanel(
          BuildContext context,
          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
          int total,
          bool compact) =>
      Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: _ink.withValues(alpha: .025),
                  blurRadius: 24,
                  offset: const Offset(0, 8))
            ]),
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                compact ? 16 : 22, 20, compact ? 16 : 22, 18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Danh sách hồ sơ',
                          style: TextStyle(
                              color: _ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('$total giảng viên',
                          style: const TextStyle(color: _muted, fontSize: 12))
                    ])),
                if (!compact) _CountPill(count: docs.length),
              ]),
              const SizedBox(height: 16),
              TextField(
                  controller: _search,
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
                  decoration: InputDecoration(
                      hintText: 'Tìm theo mã hoặc họ tên',
                      prefixIcon:
                          const Icon(Icons.search_rounded, color: _muted),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _search.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded)),
                      isDense: true)),
            ]),
          ),
          const Divider(height: 1, color: _line),
          if (docs.isEmpty)
            _emptyList(compact)
          else if (compact) ...[
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: _CountPill(count: docs.length))),
            ...docs.map((document) => _PersonCard(
                document: document,
                onEdit: () => _openForm(document: document),
                onDelete: () => _delete(document))),
          ] else
            _desktopTable(docs),
        ]),
      );

  Widget _desktopTable(
          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) =>
      LayoutBuilder(builder: (context, constraints) {
        final tableWidth =
            constraints.maxWidth < 760 ? 760.0 : constraints.maxWidth;
        final columnWidth = tableWidth - 144;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: DataTable(
              headingRowHeight: 48,
              dataRowMinHeight: 72,
              dataRowMaxHeight: 76,
              horizontalMargin: 24,
              columnSpacing: 32,
              headingTextStyle: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7),
              columns: const [
                DataColumn(label: Text('GIẢNG VIÊN')),
                DataColumn(label: Text('MÃ GIẢNG VIÊN')),
                DataColumn(label: Text('TỔNG SỐ LỚP')),
                DataColumn(label: Text('THAO TÁC'))
              ],
              rows: docs.map((document) {
                final data = document.data();
                return DataRow(cells: [
                  DataCell(SizedBox(
                      width: columnWidth * .43,
                      child: Row(children: [
                        _UserAvatar(
                            name: data['Fullname'] ?? '', image: data['Image']),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(data['Fullname'] ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: _ink, fontWeight: FontWeight.w700)))
                      ]))),
                  DataCell(SizedBox(
                      width: columnWidth * .32,
                      child: Text(data['IDGV'] ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xff46536b))))),
                  DataCell(SizedBox(
                      width: columnWidth * .12,
                      child: Text('${data['SumClass'] ?? 0} lớp',
                          style: const TextStyle(
                              color: _ink, fontWeight: FontWeight.w700)))),
                  DataCell(SizedBox(
                      width: columnWidth * .13,
                      child: Row(children: [
                        IconButton(
                            tooltip: 'Sửa hồ sơ',
                            onPressed: () => _openForm(document: document),
                            icon: const Icon(Icons.edit_outlined, size: 20)),
                        IconButton(
                            tooltip: 'Xóa hồ sơ',
                            onPressed: () => _delete(document),
                            color: const Color(0xffc64e55),
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 20))
                      ]))),
                ]);
              }).toList(),
            ),
          ),
        );
      });

  Widget _emptyList(bool compact) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 42),
        child: Column(children: [
          Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                  color: Color(0xffe8f2fb), shape: BoxShape.circle),
              child: const Icon(Icons.person_search_rounded,
                  color: _primary, size: 30)),
          const SizedBox(height: 15),
          Text(_query.isEmpty ? 'Chưa có hồ sơ nào' : 'Không tìm thấy kết quả',
              style: const TextStyle(
                  color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
              _query.isEmpty
                  ? 'Thêm giảng viên đầu tiên để bắt đầu quản lý.'
                  : 'Thử tìm bằng mã hoặc họ tên khác.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted)),
          if (_query.isEmpty) ...[
            const SizedBox(height: 18),
            OutlinedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Thêm hồ sơ'))
          ],
        ]),
      );

  Widget _errorState(String error) => Center(
      child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_rounded,
                color: Color(0xffc64e55), size: 42),
            const SizedBox(height: 12),
            const Text('Chưa tải được dữ liệu',
                style: TextStyle(
                    color: _ink, fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted))
          ])));
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Container(
        width: 250,
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: _line))),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 28, 18, 22),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                _BrandMark(size: 42),
                SizedBox(width: 11),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('QLHocPhan',
                      style: TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.7,
                          fontSize: 14)),
                  Text('ADMIN CONSOLE',
                      style: TextStyle(
                          color: _muted,
                          fontSize: 9,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700))
                ])
              ]),
              const SizedBox(height: 45),
              const Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 10),
                  child: Text('MENU',
                      style: TextStyle(
                          color: _muted,
                          fontSize: 10,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w800))),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xffe8f2fb),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Row(children: [
                    Icon(Icons.people_alt_rounded, color: _primary, size: 19),
                    SizedBox(width: 12),
                    Text('Giảng viên',
                        style: TextStyle(
                            color: _primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800))
                  ])),
              const Spacer(),
              Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: _canvas, borderRadius: BorderRadius.circular(14)),
                  child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.cloud_done_outlined,
                            color: Color(0xff299475), size: 19),
                        SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Đang đồng bộ',
                                  style: TextStyle(
                                      color: _ink,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12)),
                              SizedBox(height: 4),
                              Text('Cơ sở dữ liệu trực tiếp',
                                  style: TextStyle(color: _muted, fontSize: 11))
                            ]))
                      ])),
              const SizedBox(height: 12),
              Material(
                  color: Colors.transparent,
                  child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: const Icon(Icons.logout_rounded,
                          color: _muted, size: 20),
                      title: const Text('Đăng xuất',
                          style: TextStyle(
                              color: _muted,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                      onTap: onLogout)),
            ])),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.detail,
      required this.tint,
      required this.iconColor,
      this.valueSize = 30});
  final IconData icon;
  final String label, value, detail;
  final Color tint, iconColor;
  final double valueSize;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: tint, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: iconColor, size: 22)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w800,
                        fontSize: valueSize)),
                const SizedBox(height: 3),
                Text(detail,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 10))
              ])),
        ]),
      );
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
          color: const Color(0xffe8f2fb),
          borderRadius: BorderRadius.circular(30)),
      child: Text('$count kết quả',
          style: const TextStyle(
              color: _primary, fontSize: 11, fontWeight: FontWeight.w800)));
}

class _PersonCard extends StatelessWidget {
  const _PersonCard(
      {required this.document, required this.onEdit, required this.onDelete});
  final QueryDocumentSnapshot<Map<String, dynamic>> document;
  final VoidCallback onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final data = document.data();
    return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Row(children: [
            _UserAvatar(
                name: data['Fullname'] ?? '', image: data['Image'], size: 46),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(data['Fullname'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(data['IDGV'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 12))
                ])),
            PopupMenuButton<String>(
                tooltip: 'Tùy chọn',
                onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Sửa hồ sơ'))),
                      PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                              leading: Icon(Icons.delete_outline),
                              title: Text('Xóa hồ sơ')))
                    ],
                icon: const Icon(Icons.more_horiz_rounded, color: _muted)),
          ]),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: _line)),
          Row(children: [
            const Icon(Icons.class_outlined, color: _muted, size: 16),
            const SizedBox(width: 8),
            const Text('Tổng số lớp',
                style: TextStyle(color: _muted, fontSize: 12)),
            const Spacer(),
            Text('${data['SumClass'] ?? 0}',
                style:
                    const TextStyle(color: _ink, fontWeight: FontWeight.w800))
          ]),
        ]));
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.name, required this.image, this.size = 40});
  final String name;
  final String? image;
  final double size;
  @override
  Widget build(BuildContext context) {
    final provider = userImageProvider(image);
    final initial =
        name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
    return CircleAvatar(
        radius: size / 2,
        backgroundColor: const Color(0xffe8f2fb),
        backgroundImage: provider,
        child: provider == null
            ? Text(initial,
                style: const TextStyle(
                    color: _primary, fontWeight: FontWeight.w800))
            : null);
  }
}

ImageProvider? userImageProvider(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.startsWith('data:image/')) {
    final comma = value.indexOf(',');
    if (comma < 0) return null;
    try {
      return MemoryImage(base64Decode(value.substring(comma + 1)));
    } catch (_) {
      return null;
    }
  }
  return NetworkImage(value);
}

Future<void> showUserForm(BuildContext context,
    {DocumentSnapshot<Map<String, dynamic>>? document}) async {
  await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UserFormDialog(document: document));
}

class UserFormDialog extends StatefulWidget {
  const UserFormDialog({this.document, super.key});
  final DocumentSnapshot<Map<String, dynamic>>? document;
  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _idgv = TextEditingController();
  final _sumClass = TextEditingController();
  final _picker = ImagePicker();
  Uint8List? _bytes;
  String? _imageUrl;
  String? _error;
  bool _busy = false;
  bool get _editing => widget.document != null;

  @override
  void initState() {
    super.initState();
    final data = widget.document?.data();
    _name.text = data?['Fullname'] ?? '';
    _idgv.text = data?['IDGV'] ?? '';
    _imageUrl = data?['Image'];
    _sumClass.text = '${data?['SumClass'] ?? 0}';
  }

  @override
  void dispose() {
    _name.dispose();
    _idgv.dispose();
    _sumClass.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 55,
          maxWidth: 640,
          maxHeight: 640);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > 650 * 1024) {
        setState(() =>
            _error = 'Ảnh vẫn quá lớn sau khi nén. Hãy chọn ảnh nhỏ hơn.');
        return;
      }
      if (mounted) {
        setState(() {
          _bytes = bytes;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Không đọc được ảnh đã chọn: $error');
      }
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final image = _bytes == null
          ? (_imageUrl ?? '')
          : 'data:image/jpeg;base64,${base64Encode(_bytes!)}';
      final data = <String, dynamic>{
        'IDGV': _idgv.text.trim(),
        'Fullname': _name.text.trim(),
        'Image': image,
        'SumClass': int.parse(_sumClass.text.trim())
      };
      final users = FirebaseFirestore.instance.collection('Giang Vien');
      if (_editing) {
        await users.doc(widget.document!.id).update(data);
      } else {
        await users.add(data);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error =
            'Không lưu được hồ sơ. Kiểm tra kết nối và quyền truy cập. $error');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 560;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: mobile ? 12 : 28, vertical: mobile ? 18 : 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 820),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 14, 17),
              child: Row(children: [
                Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        color: const Color(0xffe8f2fb),
                        borderRadius: BorderRadius.circular(13)),
                    child: Icon(
                        _editing
                            ? Icons.edit_outlined
                            : Icons.person_add_alt_1_rounded,
                        color: _primary)),
                const SizedBox(width: 13),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                          _editing ? 'Chỉnh sửa giảng viên' : 'Thêm giảng viên',
                          style: const TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 17)),
                      const SizedBox(height: 3),
                      const Text('Thông tin được đồng bộ trực tiếp',
                          style: TextStyle(color: _muted, fontSize: 11))
                    ])),
                IconButton(
                    onPressed:
                        _busy ? null : () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded, color: _muted)),
              ])),
          const Divider(height: 1, color: _line),
          Flexible(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
                  child: Form(
                      key: _form,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                                child: Column(children: [
                              GestureDetector(
                                  onTap: _pickImage,
                                  child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        CircleAvatar(
                                            radius: 43,
                                            backgroundColor:
                                                const Color(0xffe8f2fb),
                                            backgroundImage: _bytes != null
                                                ? MemoryImage(_bytes!)
                                                : userImageProvider(_imageUrl),
                                            child: _bytes == null &&
                                                    userImageProvider(
                                                            _imageUrl) ==
                                                        null
                                                ? const Icon(
                                                    Icons
                                                        .person_outline_rounded,
                                                    color: _primary,
                                                    size: 34)
                                                : null),
                                        Container(
                                            width: 27,
                                            height: 27,
                                            decoration: BoxDecoration(
                                                color: _primary,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2)),
                                            child: const Icon(Icons.add,
                                                color: Colors.white, size: 17)),
                                      ])),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.photo_library_outlined,
                                      size: 17),
                                  label: Text(
                                      _imageUrl == null || _imageUrl!.isEmpty
                                          ? 'Chọn ảnh đại diện'
                                          : 'Thay ảnh đại diện')),
                              const Text(
                                  'Ảnh sẽ được nén và lưu trong hồ sơ Firestore.',
                                  style: TextStyle(color: _muted, fontSize: 11),
                                  textAlign: TextAlign.center),
                            ])),
                            const SizedBox(height: 20),
                            const _FieldLabel('MÃ GIẢNG VIÊN (IDGV)'),
                            const SizedBox(height: 7),
                            TextFormField(
                                controller: _idgv,
                                decoration: const InputDecoration(
                                    hintText: 'Ví dụ: GV001',
                                    prefixIcon: Icon(Icons.badge_outlined)),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Vui lòng nhập mã giảng viên'
                                        : null),
                            const SizedBox(height: 16),
                            const _FieldLabel('HỌ VÀ TÊN'),
                            const SizedBox(height: 7),
                            TextFormField(
                                controller: _name,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                    hintText: 'Ví dụ: Nguyễn Minh Anh',
                                    prefixIcon:
                                        Icon(Icons.person_outline_rounded)),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Vui lòng nhập họ tên'
                                        : null),
                            const SizedBox(height: 16),
                            const _FieldLabel('TỔNG SỐ LỚP'),
                            const SizedBox(height: 7),
                            TextFormField(
                                controller: _sumClass,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    hintText: 'Ví dụ: 5',
                                    prefixIcon: Icon(Icons.class_outlined)),
                                validator: (value) {
                                  final count =
                                      int.tryParse(value?.trim() ?? '');
                                  return count == null || count < 0
                                      ? 'Nhập số lớp hợp lệ'
                                      : null;
                                }),
                            if (_error != null) ...[
                              const SizedBox(height: 13),
                              Text(_error!,
                                  style: const TextStyle(
                                      color: Color(0xffbb3f3b),
                                      fontSize: 12,
                                      height: 1.4))
                            ],
                          ])))),
          const Divider(height: 1, color: _line),
          Padding(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed:
                            _busy ? null : () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13))),
                        child: const Text('Hủy'))),
                const SizedBox(width: 10),
                Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                        onPressed: _busy ? null : _save,
                        style: FilledButton.styleFrom(
                            backgroundColor: _primary,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13))),
                        icon: _busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check_rounded),
                        label: Text(_busy ? 'Đang lưu…' : 'Lưu hồ sơ'))),
              ])),
        ]),
      ),
    );
  }
}
