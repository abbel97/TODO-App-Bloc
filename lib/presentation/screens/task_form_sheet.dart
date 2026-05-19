import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/task_bloc.dart';
import '../../bloc/task_event.dart';
import '../../models/task_model.dart';

class TaskFormSheet extends StatefulWidget {
  final TaskModel? existing;
  const TaskFormSheet({super.key, this.existing});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey   = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _selectedDate;
  bool _isSaving = false;

  static const _purple  = Color(0xFF6B35B5);
  static const _bgField = Color(0xFFF0EEF8);
  static const _textSub = Color(0xFF9CA3AF);
  static const _hint    = Color(0xFFB0A8CC);

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final t = widget.existing!;
      _titleCtrl.text = t.title;
      _notesCtrl.text = t.notes;
      _selectedDate   = DateTime.tryParse(t.dueDate);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _purple),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final task = TaskModel(
      id:          widget.existing?.id,
      title:       _titleCtrl.text.trim(),
      notes:       _notesCtrl.text.trim(),
      dueDate:     DateFormat('yyyy-MM-dd').format(_selectedDate!),
      isCompleted: widget.existing?.isCompleted ?? false,
    );

    if (_isEdit) {
      context.read<TaskBloc>().add(UpdateTask(task));
    } else {
      context.read<TaskBloc>().add(AddTask(task));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _bgField,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close, size: 18,
                        color: Color(0xFF6B7280)),
                  ),
                ),
                Text(
                  _isEdit ? 'Edit Task' : 'Add New Task',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(width: 34), // balance
              ],
            ),

            const SizedBox(height: 24),

            // ── Task Title ───────────────────────────────────────────────
            const _Label('Task Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Color(0xFF1F1F1F)),
              decoration: const InputDecoration(hintText: 'e.g. Buy groceries',
                  hintStyle: TextStyle(color: _hint)),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Title is required.'
                  : null,
            ),

            const SizedBox(height: 20),

            // ── When (date picker) ───────────────────────────────────────
            const _Label('When'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _bgField,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: _purple, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate == null
                          ? 'Select a date'
                          : DateFormat('MMM d, yyyy').format(_selectedDate!),
                      style: TextStyle(
                        color: _selectedDate == null
                            ? _hint
                            : const Color(0xFF1F1F1F),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Notes ────────────────────────────────────────────────────
            const _Label('Notes'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              style: const TextStyle(color: Color(0xFF1F1F1F)),
              decoration: const InputDecoration(
                hintText: 'Add your notes here',
                hintStyle: TextStyle(color: _hint),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 28),

            // ── Save button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_isEdit ? 'Save Changes' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );
}