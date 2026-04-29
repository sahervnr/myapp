import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with your actual Back4App Keys
  const keyApplicationId = 'RnwytUszpQVleHsgRUj4iPRVq6puPjfCdlleQ3oy';
  const keyClientKey = 'KFPqyN9ZvXk3tGe5my1k9aT3B5jnVsOHlVcyi2Nn';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AuthScreen(),
  ));
}

// --- 1. USER AUTHENTICATION SCREEN ---
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool isLogin = true;

  void handleAuth() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (isLogin) {
      final user = ParseUser(username, password, null);
      var response = await user.login();
      if (response.success) {
        navigate();
      } else {
        showError(response.error!.message);
      }
    } else {
      // Registration logic with Student Email check
      if (!email.contains('@')) {
        showError("Please use a valid student email ID");
        return;
      }
      final user = ParseUser(username, password, email);
      var response = await user.signUp();
      if (response.success) {
        navigate();
      } else {
        showError(response.error!.message);
      }
    }
  }

  void navigate() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TaskListScreen()));
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Login" : "Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: "Username")),
            if (!isLogin) TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Student Email")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: handleAuth, child: Text(isLogin ? "Login" : "Sign Up")),
            TextButton(onPressed: () => setState(() => isLogin = !isLogin), 
                       child: Text(isLogin ? "Need an account? Register" : "Have an account? Login"))
          ],
        ),
      ),
    );
  }
}

// --- 2. TASK LIST SCREEN (READ, DELETE, LOGOUT) ---
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  Future<List<ParseObject>> getTasks() async {
    QueryBuilder<ParseObject> queryTask = QueryBuilder<ParseObject>(ParseObject('Task'));
    final response = await queryTask.query();
    return response.results as List<ParseObject>? ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            final user = await ParseUser.currentUser() as ParseUser;
            await user.logout();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
          })
        ],
      ),
      body: FutureBuilder<List<ParseObject>>(
        future: getTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.get<String>('title')!),
                subtitle: Text(task.get<String>('description') ?? ""),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), 
                               onPressed: () => navigateToEdit(task)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), 
                               onPressed: () async {
                                 await task.delete();
                                 setState(() {});
                               }),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToEdit(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void navigateToEdit(ParseObject? task) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)));
    setState(() {});
  }
}

// --- 3. CREATE & UPDATE SCREEN ---
class EditTaskScreen extends StatefulWidget {
  final ParseObject? task;
  const EditTaskScreen({super.key, this.task});
  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.get<String>('title')!;
      _descController.text = widget.task!.get<String>('description') ?? "";
    }
  }

  void saveTask() async {
    final task = widget.task ?? ParseObject('Task');
    task.set('title', _titleController.text);
    task.set('description', _descController.text);
    await task.save();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? "Add Task" : "Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveTask, child: const Text("Save Task"))
          ],
        ),
      ),
    );
  }
}