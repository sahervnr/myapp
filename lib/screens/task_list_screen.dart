import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../core/parse_service.dart';
import '../widgets/custom_input.dart';
import 'auth_screen.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ParseService _backendEngine = ParseService();
  late Future<List<ParseObject>> _asyncTaskPipeline;

  @override
  void initState() {
    super.initState();
    _triggerPipelineRefresh();
  }

  void _triggerPipelineRefresh() {
    setState(() {
      _asyncTaskPipeline = _backendEngine.fetchRemoteTasks();
    });
  }

  void _handleSessionTermination() async {
    final ParseUser activeSession = await ParseUser.currentUser() as ParseUser;
    await activeSession.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        title: const Text(
          "My Workspace",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new_rounded, color: colors.error),
            onPressed: _handleSessionTermination,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _triggerPipelineRefresh(),
        child: FutureBuilder<List<ParseObject>>(
          future: _asyncTaskPipeline,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  const Icon(
                    Icons.playlist_remove_rounded,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "No active tasks registered.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              );
            }

            final dataCollection = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: dataCollection.length,
              itemBuilder: (context, index) {
                final currentTask = dataCollection[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      currentTask.get<String>('title') ?? 'Untitled Metric',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        currentTask.get<String>('description') ??
                            'No context metadata provided.',
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_calendar_rounded,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () => _routeToEditor(currentTask),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_sweep_rounded,
                            color: Colors.redAccent,
                          ),
                          onPressed: () async {
                            await _backendEngine.removeTaskRecord(currentTask);
                            if (!mounted) return;
                            AlertUtility.showNotice(
                              context,
                              "Item purged successfully.",
                            );
                            _triggerPipelineRefresh();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _routeToEditor(null),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text("Add Task"),
      ),
    );
  }

  void _routeToEditor(ParseObject? dataPointer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTaskScreen(task: dataPointer)),
    );
    _triggerPipelineRefresh();
  }
}
