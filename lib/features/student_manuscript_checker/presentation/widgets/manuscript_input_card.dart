import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/datasources/manuscript_file_picker.dart';
import '../../domain/entities/target_journal.dart';
import '../cubit/student_manuscript_checker_cubit.dart';
import '../cubit/student_manuscript_checker_state.dart';

class ManuscriptInputCard extends StatefulWidget {
  final StudentManuscriptCheckerInitial initialState;

  const ManuscriptInputCard({
    super.key,
    required this.initialState,
  });

  @override
  State<ManuscriptInputCard> createState() => _ManuscriptInputCardState();
}

class _ManuscriptInputCardState extends State<ManuscriptInputCard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _textController;
  late final TextEditingController _journalIdController;

  String? _selectedJournalId;
  String? _selectedJournalTitle;
  bool _includeExemplars = true;
  String? _pickedFileName;
  List<int>? _pickedFileBytes;
  bool _isManualJournal = false;

  static const String _sampleManuscript = '''Introduction
Recent deep learning architectures have achieved impressive benchmarks in academic text analysis. However, prior approaches remain limited in their ability to detect subtle stylistic deviations in student research drafts. To address this critical gap, this paper introduces a profile-anchored manuscript verification pipeline.

Methods
We evaluated our feature extractor across three domain corpora using 10-fold cross validation. The network was trained using the AdamW optimizer with a learning rate of 0.001 and weight decay of 0.01. Sentences were parsed through a dependency tree to determine passive voice proportion and syntactic complexity.

Results
Our empirical experiments demonstrate that stylometric alignment scores correlate strongly with peer review acceptance rates.

Discussion
These findings highlight the necessity of providing immediate linguistic feedback to novice researchers before formal journal submission.''';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _textController =
        TextEditingController(text: widget.initialState.draftText ?? '');
    _journalIdController = TextEditingController(
        text: widget.initialState.selectedJournalId ?? '');
    _selectedJournalId = widget.initialState.selectedJournalId;
    _selectedJournalTitle = widget.initialState.selectedJournalTitle;
    _includeExemplars = widget.initialState.includeExemplars;
    _pickedFileName = widget.initialState.fileName;
    _pickedFileBytes = widget.initialState.fileBytes;

    if (widget.initialState.availableJournals.isNotEmpty &&
        _selectedJournalId == null) {
      final first = widget.initialState.availableJournals.first;
      _selectedJournalId = first.id;
      _selectedJournalTitle = first.title;
      _journalIdController.text = first.id;
    }
  }

  @override
  void didUpdateWidget(ManuscriptInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((_selectedJournalId == null || _selectedJournalId!.isEmpty) &&
        widget.initialState.availableJournals.isNotEmpty) {
      final first = widget.initialState.availableJournals.first;
      _selectedJournalId = first.id;
      _selectedJournalTitle = first.title;
      _journalIdController.text = first.id;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _journalIdController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final file = await ManuscriptFilePickerSeam.picker();
    if (file != null) {
      setState(() {
        _pickedFileName = file.name;
        _pickedFileBytes = file.bytes;
      });
      if (mounted) {
        context.read<StudentManuscriptCheckerCubit>().setPickedFile(
              file.name,
              file.bytes,
            );
      }
    }
  }

  void _loadSampleText() {
    setState(() {
      _textController.text = _sampleManuscript;
    });
    context
        .read<StudentManuscriptCheckerCubit>()
        .updateDraftText(_sampleManuscript);
  }

  void _handleSubmit() {
    final available = widget.initialState.availableJournals;
    var journalId = _isManualJournal
        ? _journalIdController.text.trim()
        : (_selectedJournalId ?? _journalIdController.text.trim());

    if (journalId.isEmpty && available.isNotEmpty) {
      journalId = available.first.id;
      _selectedJournalTitle = available.first.title;
    }

    if (_tabController.index == 0) {
      // Text mode
      final text = _textController.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter or paste manuscript text.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      context.read<StudentManuscriptCheckerCubit>().submit(
            fileBytes: utf8.encode(text),
            filename: 'manuscript.txt',
            targetJournalId: journalId,
            includeExemplars: _includeExemplars,
            journalTitle: _selectedJournalTitle,
          );
    } else {
      // File mode
      if (_pickedFileBytes == null || _pickedFileBytes!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please choose a file (.pdf, .docx, .txt).'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      context.read<StudentManuscriptCheckerCubit>().submit(
            fileBytes: _pickedFileBytes!,
            filename: _pickedFileName ?? 'manuscript.pdf',
            targetJournalId: journalId,
            includeExemplars: _includeExemplars,
            journalTitle: _selectedJournalTitle,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final journals = widget.initialState.availableJournals;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Check Manuscript Alignment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Manrope',
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Evaluate your student draft against target journal style standards and detect missing rhetorical moves.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontFamily: 'Manrope',
            ),
          ),

          const SizedBox(height: 24),

          // ── Section 1: Target Journal Selection ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Target Journal Profile',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope',
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isManualJournal = !_isManualJournal;
                  });
                },
                child: Text(
                  _isManualJournal
                      ? 'Select from catalog'
                      : 'Enter custom journal ID',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (!_isManualJournal && journals.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedJournalId,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.menu_book_rounded,
                    size: 18, color: AppColors.primary),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: journals.map((TargetJournal j) {
                return DropdownMenuItem<String>(
                  value: j.id,
                  child: Text(
                    j.domain != null
                        ? '${j.title} (${j.domain})'
                        : j.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Manrope',
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  final found =
                      journals.firstWhere((j) => j.id == val, orElse: () => journals.first);
                  setState(() {
                    _selectedJournalId = val;
                    _selectedJournalTitle = found.title;
                    _journalIdController.text = val;
                  });
                  context.read<StudentManuscriptCheckerCubit>().selectJournal(
                        val,
                        found.title,
                      );
                }
              },
            ),
          ] else ...[
            TextField(
              controller: _journalIdController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.vpn_key_outlined,
                    size: 18, color: AppColors.primary),
                hintText: 'e.g. 550e8400-e29b-41d4-a716-446655440000',
              ),
              onChanged: (val) {
                _selectedJournalId = val;
                context.read<StudentManuscriptCheckerCubit>().selectJournal(
                      val,
                      'Target Journal',
                    );
              },
            ),
          ],

          const SizedBox(height: 24),

          // ── Section 2: Manuscript Input Tabs ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Manrope',
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.edit_note_rounded, size: 18),
                  text: 'Direct Text / Draft',
                ),
                Tab(
                  icon: Icon(Icons.upload_file_rounded, size: 18),
                  text: 'Upload File',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab views
          SizedBox(
            height: 220,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Text Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText:
                              'Paste or draft your academic manuscript here…\n\nInclude section headings like "Introduction", "Methods", etc. for accurate rhetorical move scoring.',
                          contentPadding: EdgeInsets.all(14),
                        ),
                        onChanged: (val) {
                          context
                              .read<StudentManuscriptCheckerCubit>()
                              .updateDraftText(val);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: _loadSampleText,
                          icon: const Icon(Icons.auto_stories_outlined,
                              size: 15),
                          label: const Text('Load Sample Manuscript'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ),
                        Text(
                          '${_textController.text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length} words',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSubtle,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Tab 2: File Upload
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _pickedFileName != null
                              ? Icons.description_rounded
                              : Icons.cloud_upload_outlined,
                          size: 40,
                          color: _pickedFileName != null
                              ? AppColors.primary
                              : AppColors.textSubtle,
                        ),
                        const SizedBox(height: 10),
                        if (_pickedFileName != null) ...[
                          Text(
                            _pickedFileName!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${((_pickedFileBytes?.length ?? 0) / 1024).toStringAsFixed(1)} KB ready for check',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.green700,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Supports PDF, DOCX, or TXT manuscripts',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Click below to browse files from your device',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.folder_open_rounded, size: 16),
                          label: Text(_pickedFileName != null
                              ? 'Change File'
                              : 'Select Manuscript File'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Section 3: Options (Exemplars toggle) ──
          InkWell(
            onTap: () {
              setState(() {
                _includeExemplars = !_includeExemplars;
              });
              context
                  .read<StudentManuscriptCheckerCubit>()
                  .toggleIncludeExemplars(_includeExemplars);
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: _includeExemplars,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _includeExemplars = val;
                        });
                        context
                            .read<StudentManuscriptCheckerCubit>()
                            .toggleIncludeExemplars(val);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Include validated exemplars from journal corpus',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontFamily: 'Manrope',
                          ),
                        ),
                        Text(
                          'Attaches authentic reference sentences and DOIs to generated style & rhetorical move warnings.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Section 4: Submit Button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleSubmit,
              icon: const Icon(Icons.spellcheck_rounded, size: 18),
              label: const Text('Check Manuscript Alignment'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
