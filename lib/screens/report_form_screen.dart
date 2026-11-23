import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// idle = form ready, loading = request pending, success = report sent,
/// empty = no reports to show, error = the (simulated) request failed.
enum ReportUiState { idle, loading, success, empty, error }

/// A report kept in memory only (simulated, not saved to any database).
class _SentReport {
  final String ref;
  final String title;
  final String transport;
  final String category;
  final DateTime sentAt;

  const _SentReport({
    required this.ref,
    required this.title,
    required this.transport,
    required this.category,
    required this.sentAt,
  });
}

/// Activity 9: ParkKeys "Report a Problem" form with Loading, Success,
/// Empty and Error responses. The server is SIMULATED with Future.delayed.
class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  String? _transport;
  String? _category;

  ReportUiState _uiState = ReportUiState.idle;
  bool _showList = false; // false = New Report, true = My Reports
  bool _simulateFailure = false; // demo switch for the Error state

  final List<_SentReport> _reports = [];
  int _counter = 0;

  bool get _loading => _uiState == ReportUiState.loading;

  /// Empty = the list tab is open and there are no reports.
  ReportUiState get _state =>
      (_showList && _reports.isEmpty) ? ReportUiState.empty : _uiState;

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  // ---------- actions ----------

  /// Validate first; only a valid form is sent.
  void _submit() {
    if (_loading) return; // prevents duplicate submissions
    if (!_formKey.currentState!.validate()) return;
    _send();
  }

  /// The simulated request. Also used by the Retry button.
  Future<void> _send() async {
    if (_loading) return;
    setState(() => _uiState = ReportUiState.loading);
    try {
      await Future<void>.delayed(const Duration(seconds: 3)); // simulated
      if (_simulateFailure) throw Exception('Simulated failure');
      if (!mounted) return;
      _counter++;
      setState(() {
        _reports.insert(
          0,
          _SentReport(
            ref: 'PK-${_counter.toString().padLeft(4, '0')}',
            title: _titleController.text.trim(),
            transport: _transport ?? '',
            category: _category ?? '',
            sentAt: DateTime.now(),
          ),
        );
        _uiState = ReportUiState.success;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _uiState = ReportUiState.error);
    }
  }

  void _openForm() => setState(() {
        _showList = false;
        if (_uiState == ReportUiState.success) _uiState = ReportUiState.idle;
      });

  void _openList() => setState(() => _showList = true);

  void _writeAnother() => setState(() {
        _titleController.clear();
        _detailsController.clear();
        _transport = null;
        _category = null;
        _uiState = ReportUiState.idle;
      });

  String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    final showDemo = !_showList && _uiState != ReportUiState.success;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.flag_outlined, color: AppColors.purple, size: 28),
            SizedBox(width: 8),
            Text(
              'Report a Problem',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkPurple,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tell us what happened.',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkPurple,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Send a queue or driver issue to the ParkKeys admin.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'New Report',
                          isOutlined: _showList,
                          onPressed: _loading ? null : _openForm,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          text: 'My Reports (${_reports.length})',
                          isOutlined: !_showList,
                          onPressed: _loading ? null : _openList,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _body(),
                  if (showDemo) ...[
                    const SizedBox(height: 20),
                    _demoControl(),
                  ],
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'ParkKeys • Report Form (simulated responses)',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
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

  Widget _body() {
    if (_showList) {
      return _state == ReportUiState.empty ? _emptyView() : _listView();
    }
    switch (_uiState) {
      case ReportUiState.success:
        return _successView();
      case ReportUiState.error:
        return _errorView();
      default:
        return _formView(); // idle and loading
    }
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      );

  // ---------- IDLE + LOADING ----------

  Widget _formView() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_loading) ...[
              const LinearProgressIndicator(
                color: AppColors.purple,
                backgroundColor: AppColors.lightPurple,
                minHeight: 5,
              ),
              const SizedBox(height: 16),
            ],
            _ChipPicker(
              label: 'Transportation',
              options: AppConstants.transports,
              value: _transport,
              isEnabled: !_loading,
              missingMessage: 'Choose the transportation.',
              onPicked: (v) => _transport = v,
            ),
            const SizedBox(height: 18),
            _ChipPicker(
              label: 'Category',
              options: AppConstants.reportCategories,
              value: _category,
              isEnabled: !_loading,
              missingMessage: 'Choose a category.',
              onPicked: (v) => _category = v,
            ),
            const SizedBox(height: 18),
            const Text('Report Title',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            AppTextField(
              controller: _titleController,
              hintText: 'Short title of the problem',
              prefixIcon: Icons.title_rounded,
              enabled: !_loading,
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return 'Enter a short title.';
                if (t.length < 5) return 'Use at least 5 characters.';
                return null;
              },
            ),
            const SizedBox(height: 18),
            const Text('What happened?',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            AppTextField(
              controller: _detailsController,
              hintText: 'Describe the problem',
              prefixIcon: Icons.notes_rounded,
              enabled: !_loading,
              minLines: 3,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return 'Describe what happened.';
                if (t.length < 20) {
                  return 'Add a little more detail (at least 20 characters).';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Send Report',
              isLoading: _loading,
              onPressed: _loading ? null : _submit,
            ),
            if (_loading) ...[
              const SizedBox(height: 12),
              const Text(
                'Sending your report… (simulated, about 3 seconds)',
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------- SUCCESS ----------

  Widget _successView() {
    final ref = _reports.isNotEmpty ? _reports.first.ref : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 46),
              const SizedBox(height: 14),
              const Text(
                'Report sent.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reference $ref. The admin will review it.',
                style: const TextStyle(
                  color: Color(0xFFE7DFFF),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppButton(text: 'View My Reports', onPressed: _openList),
        const SizedBox(height: 12),
        AppButton(
          text: 'Write Another Report',
          isOutlined: true,
          onPressed: _writeAnother,
        ),
        const SizedBox(height: 12),
        const Text(
          'Simulated response: no real server or database was used.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  // ---------- ERROR ----------

  Widget _errorView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.error, width: 1.5),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 46),
              SizedBox(height: 14),
              Text(
                'Couldn’t send your report.',
                style: TextStyle(
                  color: AppColors.darkPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'The simulated server did not respond, so your report was not saved. Your answers are still here. Tap Retry, or edit your report first.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppButton(text: 'Retry', onPressed: _send),
        const SizedBox(height: 12),
        AppButton(
          text: 'Edit Report',
          isOutlined: true,
          onPressed: () => setState(() => _uiState = ReportUiState.idle),
        ),
      ],
    );
  }

  // ---------- EMPTY ----------

  Widget _emptyView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.lightPurple,
            child: Icon(Icons.inbox_outlined,
                color: AppColors.purple, size: 38),
          ),
          const SizedBox(height: 16),
          const Text(
            'No reports yet.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPurple,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'When you send a report about a route or a driver, it will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          AppButton(text: 'Write a Report', onPressed: _openForm),
        ],
      ),
    );
  }

  // ---------- LIST (has reports) ----------

  Widget _listView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final r in _reports)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      r.ref,
                      style: const TextStyle(
                        color: AppColors.purple,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.lightPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Pending review',
                        style: TextStyle(
                          color: AppColors.purple,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  r.title,
                  style: const TextStyle(
                    color: AppColors.darkPurple,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${r.transport} · ${r.category}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  'Sent ${_hhmm(r.sentAt)} (simulated)',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        AppButton(
          text: 'Clear Demo Reports',
          isOutlined: true,
          onPressed: () => setState(() => _reports.clear()),
        ),
        const SizedBox(height: 10),
        const Text(
          'This list is kept in memory only and resets when the page is refreshed.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  // ---------- demo control ----------

  Widget _demoControl() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.lightPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo control',
                  style: TextStyle(
                    color: AppColors.darkPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Simulate server failure to show the Error state. Nothing is sent to a real server.',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          Switch(
            value: _simulateFailure,
            onChanged:
                _loading ? null : (v) => setState(() => _simulateFailure = v),
          ),
        ],
      ),
    );
  }
}

/// Chip selector that works inside a Form (shows a field-level error).
class _ChipPicker extends FormField<String> {
  _ChipPicker({
    required String label,
    required List<String> options,
    required String? value,
    required bool isEnabled,
    required String missingMessage,
    required ValueChanged<String> onPicked,
  }) : super(
          initialValue: value,
          validator: (v) => v == null ? missingMessage : null,
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final o in options)
                      ChoiceChip(
                        label: Text(o),
                        selected: state.value == o,
                        showCheckmark: false,
                        selectedColor: AppColors.lightPurple,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: state.value == o
                              ? AppColors.purple
                              : AppColors.border,
                          width: state.value == o ? 1.5 : 1,
                        ),
                        labelStyle: TextStyle(
                          color: state.value == o
                              ? AppColors.purple
                              : AppColors.darkPurple,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: isEnabled
                            ? (_) {
                                state.didChange(o);
                                onPicked(o);
                              }
                            : null,
                      ),
                  ],
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      state.errorText ?? '',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}