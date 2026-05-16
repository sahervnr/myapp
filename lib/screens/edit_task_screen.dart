import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../core/parse_service.dart';
import '../widgets/custom_input.dart';

class EditTaskScreen extends StatefulWidget {
  final ParseObject? task;
  const EditTaskScreen({super.key, this.task});
  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final ParseService _backendEngine = ParseService();
  bool _commitState = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.get<String>('title') ?? '';
      _descController.text = widget.task!.get<String>('description') ?? '';
    }
  }

  void _executeSaveProcedure() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _commitState = true);
    final response = await _backendEngine.commitTaskRecord(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      existingRecord: widget.task,
    );
    setState(() => _commitState = false);

    if (response.success) {
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      AlertUtility.showNotice(
        context,
        response.error?.message ?? "Failed to save data record",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null ? "Initialize Entry" : "Modify Record Context",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInputField(
                controller: _titleController,
                label: "Task Parameter Context Title",
                prefixIcon: Icons.title_rounded,
                validator: (val) => val!.trim().isEmpty
                    ? "Title configuration is required"
                    : null,
              ),
              const SizedBox(height: 18),
              CustomInputField(
                controller: _descController,
                label: "Target Specifications Description",
                prefixIcon: Icons.sticky_note_2_outlined,
              ),
              const SizedBox(height: 36),
              _commitState
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _executeSaveProcedure,
                      // We use a valid Material icon name here
                      icon: const Icon(Icons.assignment_turned_in_outlined),
                      label: const Text("Save Task Configuration"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
