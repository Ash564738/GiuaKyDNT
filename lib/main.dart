import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    runApp(const UserAdminApp());
  } catch (e) {
    runApp(ConfigurationApp(message: e.toString()));
  }
}

class ConfigurationApp extends StatelessWidget {
  const ConfigurationApp({required this.message, super.key});
  final String message;
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xff3157d5), useMaterial3: true),
        home: Scaffold(body: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(padding: const EdgeInsets.all(32), child: Column(
            mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text('Chưa cấu hình Firebase', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Tạo project Firebase, bật Authentication (Email/Password), Firestore và Storage. Sau đó chạy: flutterfire configure'),
              const SizedBox(height: 12),
              SelectableText(message, style: const TextStyle(color: Colors.grey)),
            ],
          )),
        ))),
      );
}

class UserAdminApp extends StatelessWidget {
  const UserAdminApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Quản lý người dùng',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff3157d5)), useMaterial3: true),
        home: const AuthGate(),
      );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          return snapshot.data == null ? const LoginPage() : const UserListPage();
        },
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
  String? _error;
  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _password.text);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Đăng nhập thất bại');
    } finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: SingleChildScrollView(child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 420), child: Card(margin: const EdgeInsets.all(24), child: Padding(
      padding: const EdgeInsets.all(28), child: Form(key: _form, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.admin_panel_settings, size: 54, color: Color(0xff3157d5)),
        const SizedBox(height: 14), const Text('Quản trị người dùng', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email admin', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()), validator: (v) => v == null || !v.contains('@') ? 'Nhập email hợp lệ' : null),
        const SizedBox(height: 14), TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Nhập mật khẩu' : null, onFieldSubmitted: (_) => _login()),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
        const SizedBox(height: 18), FilledButton(onPressed: _busy ? null : _login, child: Padding(padding: const EdgeInsets.all(12), child: _busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : const Text('Đăng nhập'))),
        const SizedBox(height: 12), const Text('Tạo tài khoản admin trong Firebase Authentication trước khi sử dụng.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      ])),
    ),
  ))));
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});
  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _search = TextEditingController();
  String _query = '';
  CollectionReference<Map<String, dynamic>> get _users => FirebaseFirestore.instance.collection('users');
  @override
  void dispose() { _search.dispose(); super.dispose(); }
  Future<void> _delete(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Xóa người dùng?'), content: Text('Bạn muốn xóa ${doc.data()?['email'] ?? ''}?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xóa'))]));
    if (ok == true && mounted) { await _users.doc(doc.id).delete(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa người dùng'))); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Quản lý người dùng'), actions: [IconButton(tooltip: 'Đăng xuất', onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout)), const SizedBox(width: 8)]),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => showUserForm(context), icon: const Icon(Icons.person_add_alt_1), label: const Text('Thêm người dùng')),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1100), child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: _search, onChanged: (v) => setState(() => _query = v.trim().toLowerCase()), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Tìm theo họ tên hoặc email', suffixIcon: _query.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() => _query = ''); }, icon: const Icon(Icons.clear)), border: const OutlineInputBorder())),
      const SizedBox(height: 16), Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: _users.orderBy('hoten').snapshots(), builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.where((d) { final x = d.data(); return ('${x['hoten']} ${x['email']}').toLowerCase().contains(_query); }).toList();
        if (docs.isEmpty) return const Center(child: Text('Chưa có người dùng. Nhấn “Thêm người dùng” để bắt đầu.'));
        return LayoutBuilder(builder: (context, box) => box.maxWidth < 650
          ? ListView.separated(itemCount: docs.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (context, i) => _UserCard(doc: docs[i], onEdit: () => showUserForm(context, doc: docs[i]), onDelete: () => _delete(docs[i])))
          : Card(clipBehavior: Clip.antiAlias, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: box.maxWidth, child: DataTable(columns: const [DataColumn(label: Text('Ảnh')), DataColumn(label: Text('Họ tên')), DataColumn(label: Text('Email')), DataColumn(label: Text('Mật khẩu')), DataColumn(label: Text('Thao tác'))], rows: docs.map((d) { final x = d.data(); final mask = ((x['matkhau'] as String?)?.length.clamp(1, 12).toInt() ?? 1); return DataRow(cells: [DataCell(_Avatar(url: x['hinhanh'] as String?)), DataCell(Text(x['hoten'] ?? '')), DataCell(Text(x['email'] ?? '')), DataCell(Text('•' * mask)), DataCell(Row(children: [IconButton(tooltip: 'Sửa', onPressed: () => showUserForm(context, doc: d), icon: const Icon(Icons.edit_outlined)), IconButton(tooltip: 'Xóa', onPressed: () => _delete(d), icon: const Icon(Icons.delete_outline))]))]); }).toList()))));
      }))
    ])))),
  );
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.doc, required this.onEdit, required this.onDelete});
  final DocumentSnapshot<Map<String, dynamic>> doc; final VoidCallback onEdit, onDelete;
  @override
  Widget build(BuildContext context) { final x = doc.data()!; final mask = ((x['matkhau'] as String?)?.length.clamp(1, 12).toInt() ?? 1); return Card(child: ListTile(contentPadding: const EdgeInsets.all(12), leading: _Avatar(url: x['hinhanh'] as String?), title: Text(x['hoten'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${x['email'] ?? ''}\nMật khẩu: ${'•' * mask}'), isThreeLine: true, trailing: PopupMenuButton<String>(onSelected: (v) => v == 'edit' ? onEdit() : onDelete(), itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Sửa')), PopupMenuItem(value: 'delete', child: Text('Xóa'))]))); }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url}); final String? url;
  @override
  Widget build(BuildContext context) => CircleAvatar(radius: 25, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, backgroundImage: url == null || url!.isEmpty ? null : NetworkImage(url!), child: url == null || url!.isEmpty ? const Icon(Icons.person) : null);
}

Future<void> showUserForm(BuildContext context, {DocumentSnapshot<Map<String, dynamic>>? doc}) async {
  await showDialog<void>(context: context, barrierDismissible: false, builder: (_) => UserFormDialog(doc: doc));
}

class UserFormDialog extends StatefulWidget {
  const UserFormDialog({this.doc, super.key}); final DocumentSnapshot<Map<String, dynamic>>? doc;
  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _form = GlobalKey<FormState>(); final _name = TextEditingController(); final _email = TextEditingController(); final _password = TextEditingController();
  final _picker = ImagePicker(); Uint8List? _bytes; String? _imageUrl; String? _error; bool _busy = false;
  bool get _editing => widget.doc != null;
  @override
  void initState() { super.initState(); final d = widget.doc?.data(); _name.text = d?['hoten'] ?? ''; _email.text = d?['email'] ?? ''; _password.text = d?['matkhau'] ?? ''; _imageUrl = d?['hinhanh']; }
  @override
  void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }
  Future<void> _pick() async { final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 78, maxWidth: 1200); if (file != null) { final b = await file.readAsBytes(); if (mounted) setState(() { _bytes = b; }); } }
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      var url = _imageUrl ?? '';
      if (_bytes != null) { final ref = FirebaseStorage.instance.ref('user-images/${const Uuid().v4()}'); await ref.putData(_bytes!, SettableMetadata(contentType: 'image/jpeg')); url = await ref.getDownloadURL(); }
      final data = <String, dynamic>{'email': _email.text.trim(), 'matkhau': _password.text, 'hoten': _name.text.trim(), 'hinhanh': url};
      final collection = FirebaseFirestore.instance.collection('users');
      if (_editing) { await collection.doc(widget.doc!.id).update(data); } else { await collection.add(data); }
      if (mounted) Navigator.pop(context);
    } catch (e) { setState(() => _error = 'Không lưu được: $e'); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(_editing ? 'Sửa thông tin người dùng' : 'Thêm người dùng'),
    content: SizedBox(width: 460, child: SingleChildScrollView(child: Form(key: _form, child: Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(onTap: _pick, child: CircleAvatar(radius: 42, backgroundImage: _bytes != null ? MemoryImage(_bytes!) : (_imageUrl == null || _imageUrl!.isEmpty ? null : NetworkImage(_imageUrl!)) as ImageProvider?, child: _bytes == null && (_imageUrl == null || _imageUrl!.isEmpty) ? const Icon(Icons.add_a_photo_outlined, size: 28) : null)),
      TextButton.icon(onPressed: _pick, icon: const Icon(Icons.photo_library_outlined), label: const Text('Chọn ảnh')),
      TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Họ tên', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v == null || v.trim().isEmpty ? 'Nhập họ tên' : null),
      TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), validator: (v) => v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()) ? 'Email không hợp lệ' : null),
      TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu người dùng', prefixIcon: Icon(Icons.lock_outline)), validator: (v) => v == null || v.length < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null),
      if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: const TextStyle(color: Colors.red))),
    ]))),
    actions: [TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Hủy')), FilledButton(onPressed: _busy ? null : _save, child: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator()) : const Text('Lưu'))],
  );
}
