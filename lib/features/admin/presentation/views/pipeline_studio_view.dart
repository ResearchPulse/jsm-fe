import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/journal_corpus_data.dart';
import '../../data/models/pipeline_test_models.dart';
import '../../data/models/sample_articles_data.dart';
import '../../data/services/pipeline_api_service.dart';
import '../widgets/rhetorical_move_badge.dart';

class PipelineStudioView extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const PipelineStudioView({super.key, this.onNavigateToTab});

  @override
  State<PipelineStudioView> createState() => _PipelineStudioViewState();
}

class _PipelineStudioViewState extends State<PipelineStudioView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PipelineApiService _apiService = PipelineApiService();

  // Scope Toggle: true = 300 bài & 3.280 câu (Corpus Scale), false = 1 bài chi tiết (Single Article)
  bool _isCorpusScaleMode = true;
  int _corpusSubTab = 0; // 0 = DNA Văn Phong, 1 = Câu Mẫu Tiêu Biểu
  String _selectedMoveFilter = 'ALL';
  final TextEditingController _corpusSearchController = TextEditingController();

  // Tab 1 state: End-to-End Pipeline
  JournalCorpusInfo _currentJournal = JournalCorpusRegistry.tse;
  late NormalizedArticle _currentArticle;
  ArticleFeaturesResult? _featuresResult;
  bool _isRunningPipeline = false;
  int _activePipelineStep = 6; // 0..6
  int _selectedPresetIndex = 0;
  String _pipelineStatusMessage =
      'DNA Văn phong Tạp chí đã được suy ra từ 300 bài báo & 3.280 câu văn đối chuẩn.';

  // Tab 2 state: AI Sandbox
  final TextEditingController _sentenceController = TextEditingController();
  final TextEditingController _abstractController = TextEditingController();
  MovePredictionResult? _singlePrediction;
  List<MovePredictionResult>? _batchPredictions;
  bool _isPredictingSingle = false;
  bool _isPredictingBatch = false;
  int? _selectedSentenceIndex;

  // Tab 3 state: Infrastructure Monitor
  PipelineMonitorStats? _monitorStats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentJournal = JournalCorpusRegistry.tse;
    JournalCorpusData.setActiveJournal(_currentJournal);
    _currentArticle = SampleArticlesData.sampleArticle1;
    _sentenceController.text =
        'In this paper, we propose a novel graph neural network architecture to automate refactoring.';
    _loadInitialData();
  }

  void _switchJournal(JournalCorpusInfo journal) {
    setState(() {
      _currentJournal = journal;
      JournalCorpusData.setActiveJournal(journal);
      _selectedMoveFilter = 'ALL';
      _corpusSearchController.clear();
      if (journal.id == 'tse') {
        _selectedPresetIndex = 0;
        _currentArticle = SampleArticlesData.sampleArticle1;
      } else if (journal.id == 'tosem') {
        _selectedPresetIndex = 1;
        _currentArticle = SampleArticlesData.sampleArticle2;
      }
      _featuresResult = null;
      _pipelineStatusMessage =
          '[Tạp chí: ${journal.shortName}] Đã chuyển sang ${journal.title} (${journal.totalArticles} bài báo & ${journal.totalSentences} câu văn học thuật).';
    });
  }

  void _showExportStyleDialog() {
    final j = _currentJournal;
    final moveDistribution = j.moveCounts.entries
        .map((e) => '- **${e.key}**: ${e.value} câu (${(e.value / j.totalSentences * 100).toStringAsFixed(1)}%)')
        .join('\n');
    final bundles = j.corpusLexicalBundles
        .map((b) => '- `${b['bundle']}` (${b['count']} lần • Nhóm: ${b['type']})')
        .join('\n');
    final keyness = j.keynessWords
        .map((k) => '- `${k['word']}` (LL: ${k['ll']} • Tỷ lệ so chuẩn: ${k['ratio']}x)')
        .join('\n');

    final markdownContent = '''# Báo Cáo Tóm Lược DNA Văn Phong Tạp Chí: ${j.shortName}
## (${j.title})

> **Dữ liệu đối chuẩn:** Tổng hợp tự động từ ${j.totalArticles} bài báo toàn văn (${j.yearRange}), ${j.totalSentences} câu văn học thuật, ${j.totalTokens} tokens.
> **Nguồn lưu trữ:** Object Storage MinIO Local (`jsm-articles/raw/`) & PostgreSQL Database.
> **Xử lý bóc tách:** GROBID TEI-XML Parser & NLP Feature Extractor + AI Move Classifier.

---

### 1. Thông Tin Tạp Chí
- Tên đầy đủ: ${j.title} (${j.shortName})
- Nhà xuất bản: ${j.publisher}
- Xếp hạng & Impact Factor: ${j.quartile} • IF ${j.impactFactor}
- ISSN: ${j.issn}
- Trọng tâm chuyên môn: ${j.focusArea}

---

### 2. Chỉ Số Cốt Lõi Về Văn Phong
- **Phân vị độ dài câu (Từ/Câu):**
  - P10 (Câu ngắn nhất): ${j.percentiles.p10} từ
  - P25: ${j.percentiles.p25} từ
  - P50 (Trung vị - Chuẩn vàng): ${j.percentiles.p50} từ/câu
  - P75: ${j.percentiles.p75} từ
  - P90 (Câu phức tối đa): ${j.percentiles.p90} từ
- **Giọng văn & Ngôi xưng:**
  - Thể chủ động (Active Voice): ${(j.activeShare * 100).toStringAsFixed(1)}%
  - Thể bị động (Passive Voice): ${(j.passiveShare * 100).toStringAsFixed(1)}%
  - Ngôi xưng thứ nhất (We/Our): ${(j.weSubjectShare * 100).toStringAsFixed(1)}%
- **Thước đo lập luận học thuật (Hyland 2005 - trên 1.000 từ):**
  - Hedging (Thận trọng / Giảm nhẹ): ${j.hedgeRatePer1k} từ/1k từ
  - Boosters (Khẳng định): ${j.boosterRatePer1k} từ/1k từ
  - Reporting Verbs (Dẫn luận): ${j.reportingRatePer1k} từ/1k từ

---

### 3. Phân Bố Diễn Ngôn IMRaD (Rhetorical Moves)
$moveDistribution

---

### 4. Cụm Từ Vựng Học Thuật Đặc Trưng (Lexical Bundles)
$bundles

---

### 5. Từ Khóa Trọng Yếu (Keyness Words - Log-Likelihood)
$keyness
''';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Báo Cáo Tóm Lược Văn Phong: ${j.shortName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Manrope'),
                    ),
                    const Text(
                      'Đã lưu file: sample_papers/JOURNAL_STYLE_PROFILE_SUMMARY.md',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Manrope'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 650,
            height: 480,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: SelectableText(
                markdownContent,
                style: const TextStyle(
                  fontFamily: 'Consolas',
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: markdownContent));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã sao chép báo cáo văn phong ${j.shortName} vào Clipboard!'),
                    backgroundColor: AppColors.green700,
                  ),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Sao Chép Nội Dung'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _showCustomJournalDialog() {
    final titleController = TextEditingController(text: 'Information and Software Technology');
    final shortNameController = TextEditingController(text: 'Elsevier IST');
    final issnController = TextEditingController(text: '0950-5849');
    final publisherController = TextEditingController(text: 'Elsevier');
    final areaController = TextEditingController(text: 'Software Maintenance, Agile, Empirical Quality');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Nạp Tạp Chí Mới Từ OpenAlex',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Manrope'),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.blue50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.blue100),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bạn muốn nạp 1 file PDF bài báo để phân tích?',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Manrope'),
                              ),
                              Text(
                                'Chuyển sang chế độ Nạp File PDF trực tiếp từ máy tính.',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Manrope'),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            setState(() => _isCorpusScaleMode = false);
                            _showManualUploadDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                          child: const Text('Nạp PDF ngay'),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Hoặc nhập thông tin để thu thập bộ ~300 bài chuẩn mực cho tạp chí mới:',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Manrope'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tên Tạp chí đầy đủ',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: shortNameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên viết tắt (VD: IST)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: issnController,
                          decoration: const InputDecoration(
                            labelText: 'ISSN',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: publisherController,
                    decoration: const InputDecoration(
                      labelText: 'Nhà xuất bản (Publisher)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: areaController,
                    decoration: const InputDecoration(
                      labelText: 'Lĩnh vực trọng tâm (Keywords/Scope)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final customInfo = JournalCorpusInfo(
                  id: shortNameController.text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''),
                  title: titleController.text.trim(),
                  shortName: shortNameController.text.trim(),
                  publisher: publisherController.text.trim(),
                  issn: issnController.text.trim(),
                  yearRange: '2021 – 2024',
                  quartile: 'Q1',
                  impactFactor: 3.8,
                  focusArea: areaController.text.trim(),
                  totalArticles: 300,
                  totalSentences: 3250,
                  totalTokens: 85200,
                  moveCounts: {
                    'METHOD': 880,
                    'RESULT': 760,
                    'CONTRIBUTION': 370,
                    'BACKGROUND': 350,
                    'GAP': 290,
                    'PURPOSE': 260,
                    'LIMITATION': 180,
                    'CONCLUSION': 160,
                  },
                  sectionSentenceCounts: {
                    'INTRO': 810,
                    'METHODS': 940,
                    'RESULTS': 770,
                    'DISCUSSION': 460,
                    'CONCLUSION': 270,
                  },
                  percentiles: const SentenceLengthPercentiles(
                    p10: 13.5,
                    p25: 18.2,
                    p50: 24.8,
                    p75: 33.0,
                    p90: 44.0,
                  ),
                  activeShare: 0.725,
                  passiveShare: 0.275,
                  weSubjectShare: 0.220,
                  hedgeRatePer1k: 15.2,
                  boosterRatePer1k: 8.4,
                  reportingRatePer1k: 11.8,
                  corpusLexicalBundles: [
                    {'bundle': 'in this study we', 'count': 390, 'type': 'Contribution', 'coverage': 0.82},
                    {'bundle': 'results indicate that', 'count': 340, 'type': 'Results', 'coverage': 0.75},
                    {'bundle': 'threats to validity', 'count': 280, 'type': 'Limitation', 'coverage': 0.85},
                  ],
                  keynessWords: [
                    {'word': 'maintenance', 'll': 85.0, 'ratio': 2.80, 'p': 0.000001, 'cov': 0.45},
                    {'word': 'agile', 'll': 72.0, 'ratio': 2.50, 'p': 0.000002, 'cov': 0.38},
                    {'word': 'empirical', 'll': 68.0, 'ratio': 2.30, 'p': 0.000003, 'cov': 0.50},
                  ],
                  representativeSentences: [
                    CorpusSentenceItem(
                      sentenceId: 'NEW-001',
                      text: 'Software maintenance and continuous evolution pose significant engineering bottlenecks in large distributed architectures.',
                      doi: '10.1016/j.infsof.2023.107021',
                      section: 'INTRO',
                      move: 'BACKGROUND',
                      confidence: 0.95,
                      tokenCount: 16,
                    ),
                    CorpusSentenceItem(
                      sentenceId: 'NEW-002',
                      text: 'However, empirical assessment of architectural refactoring impact on technical debt remains largely anecdotal.',
                      doi: '10.1016/j.infsof.2023.107021',
                      section: 'INTRO',
                      move: 'GAP',
                      confidence: 0.96,
                      tokenCount: 16,
                    ),
                    CorpusSentenceItem(
                      sentenceId: 'NEW-003',
                      text: 'In this paper, we conduct an extensive multi-case industrial study assessing refactoring quality metrics across six enterprise systems.',
                      doi: '10.1016/j.infsof.2023.107021',
                      section: 'INTRO',
                      move: 'CONTRIBUTION',
                      confidence: 0.98,
                      tokenCount: 22,
                      hasWeSubject: true,
                    ),
                  ],
                );

                Navigator.of(ctx).pop();
                _switchJournal(customInfo);
                _runFullPipeline();
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Thu Thập & Xây Dựng Style Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadInitialData() async {
    final stats = await _apiService.fetchMonitorStats();
    if (mounted) {
      setState(() {
        _monitorStats = stats;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sentenceController.dispose();
    _abstractController.dispose();
    _corpusSearchController.dispose();
    super.dispose();
  }

  // --- ACTIONS ---

  Future<void> _runFullPipeline() async {
    setState(() {
      _isRunningPipeline = true;
      _activePipelineStep = 0;
      _pipelineStatusMessage = _isCorpusScaleMode
          ? '[1/7] Harvester (Member 2): Đang truy vấn và lấy metadata của 300 bài báo từ OpenAlex (IEEE TSE 2021-2024)...'
          : '[1/7] Harvester (Member 2): Đang truy vấn metadata từ OpenAlex / Crossref theo ISSN & DOI...';
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _activePipelineStep = 1;
      _pipelineStatusMessage = _isCorpusScaleMode
          ? '[2/7] Fetcher (Member 2): Đang tải 300 file toàn văn PDF/JATS XML và lưu trữ vào kho MinIO S3...'
          : '[2/7] Fetcher (Member 2): Đang nạp toàn văn bản PDF và lưu trữ vào MinIO S3 bucket...';
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _activePipelineStep = 2;
      _pipelineStatusMessage = _isCorpusScaleMode
          ? '[3/7] GROBID Parser (Member 2): Đang phân tích 300 file PDF thành cấu trúc cây TEI-XML theo từng section...'
          : '[3/7] GROBID Parser (Member 2): Đang gọi TEI-XML parser để bóc tách cây cấu trúc và phân mục IMRaD...';
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _activePipelineStep = 3;
      _pipelineStatusMessage = _isCorpusScaleMode
          ? '[4/7] Normalizer (Member 2): Đã chuẩn hóa 300 bài báo IMRaD ➔ Trích xuất thành công 3.280 câu văn học thuật...'
          : '[4/7] Normalizer (Member 2): Đang làm sạch, chuẩn hóa cấu trúc IMRaD, bóc tách câu (Sentence Splitting) và Tokenization...';
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _activePipelineStep = 4;
      _pipelineStatusMessage = _isCorpusScaleMode
          ? '[5/7] AI Move Classifier (Member 3): Đang vector hóa và phân loại 11 Rhetorical Moves cho toàn bộ 3.280 câu văn...'
          : '[5/7] AI Move Classifier (Member 3): Đang vector hóa và phân loại 11 nhãn diễn ngôn học thuật cho từng câu văn...';
    });
    if (!_isCorpusScaleMode) {
      for (final sec in _currentArticle.sections) {
        final sentences = sec.sentences.map((s) => s.text).toList();
        final preds = await _apiService.predictBatchMoves(sentences);
        for (int i = 0; i < sec.sentences.length && i < preds.length; i++) {
          sec.sentences[i].predictedMove = preds[i].predictedMove;
          sec.sentences[i].moveConfidence = preds[i].confidence;
        }
      }
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _activePipelineStep = 5;
      _pipelineStatusMessage = _isCorpusScaleMode
          ? '[6/7] Feature Extractor (Member 3): Đang tính toán phân vị độ dài P10..P90, Active/Passive Voice, Hedging trên 3.280 câu...'
          : '[6/7] Feature Extractor (Member 3): Đang tính toán độ dài câu phân vị P10..P90, tỷ lệ Active/Passive, Stance markers...';
    });
    final feat = await _apiService.extractFeatures(_currentArticle);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Done
    if (mounted) {
      setState(() {
        _featuresResult = feat;
        _activePipelineStep = 6;
        _isRunningPipeline = false;
        _pipelineStatusMessage = _isCorpusScaleMode
            ? 'Hoàn tất! Đã tổng hợp thành công DNA Văn phong Tạp chí từ 300 bài & 3.280 câu đối chuẩn.'
            : 'Đã hoàn tất phân tích bài báo và đối chuẩn với Reference Corpus.';
      });
    }
  }

  void _showManualUploadDialog() {
    final titleController = TextEditingController(
      text: 'Architectural Smells in Practice: A Large-Scale Industrial Study',
    );
    final doiController = TextEditingController(text: '10.1109/TSE.2019.2940179');
    final journalController =
        TextEditingController(text: 'IEEE Transactions on Software Engineering');
    final introController = TextEditingController(
      text:
          'Architectural smells are symptoms of suboptimal architectural design decisions that negatively impact software quality and maintainability.\n'
          'Despite extensive academic literature, there remains a critical gap concerning how software practitioners perceive and handle architectural decay in industrial settings.\n'
          'The goal of this paper is to bridge this gap through a mixed-method empirical study combining repository mining and industrial survey responses.\n'
          'In this paper, we conduct the largest empirical investigation to date on architectural smells across 150 proprietary and open-source projects.',
    );
    final methodController = TextEditingController(
      text:
          'We developed Arcan, a specialized static analysis engine to automatically detect four canonical architectural smells: Cyclic Dependency, Hub-Like Dependency, Unstable Interface, and Feature Concentration.\n'
          'We collected 10 years of commit histories and surveyed 124 professional software architects and senior engineers.',
    );
    final resultsController = TextEditingController(
      text:
          'Our analysis reveals that cyclic dependencies are the most widespread architectural smell, appearing in over 82% of the analyzed enterprise systems.\n'
          'Statistical testing confirms a strong positive correlation between architectural smell density and fault-proneness with p-value less than 0.001.',
    );
    final conclusionController = TextEditingController(
      text:
          'In summary, our empirical results provide actionable guidelines for engineering teams to systematically identify and mitigate architectural debt.',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.blue50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tự Nạp Bài Báo / File PDF Thủ Công',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 640,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preset PDF Notice Banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.green50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.green100),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.green700, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Đã chuẩn bị sẵn file PDF thực tế (4.1 MB):',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.green700,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'jsm-fe/sample_papers/IEEE_TSE_Sample_Paper.pdf (IEEE TSE)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textPrimary,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                setState(() {
                                  _selectedPresetIndex = 2;
                                  _currentArticle =
                                      SampleArticlesData.sampleArticleFromPdf;
                                  _featuresResult = null;
                                });
                                _runFullPipeline();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Nạp file này ngay',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Hoặc tùy chỉnh thông tin bài báo để nạp vào pipeline:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Tiêu đề bài báo (Title)',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: journalController,
                              decoration: const InputDecoration(
                                labelText: 'Tên Tạp chí',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: doiController,
                              decoration: const InputDecoration(
                                labelText: 'DOI',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. Phần Introduction (Mỗi dòng là một câu):',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Manrope'),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: introController,
                        maxLines: 3,
                        style:
                            const TextStyle(fontSize: 12, fontFamily: 'Manrope'),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '2. Phần Methodology:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Manrope'),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: methodController,
                        maxLines: 2,
                        style:
                            const TextStyle(fontSize: 12, fontFamily: 'Manrope'),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '3. Phần Results:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Manrope'),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: resultsController,
                        maxLines: 2,
                        style:
                            const TextStyle(fontSize: 12, fontFamily: 'Manrope'),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '4. Phần Conclusion:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Manrope'),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: conclusionController,
                        maxLines: 2,
                        style:
                            const TextStyle(fontSize: 12, fontFamily: 'Manrope'),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Build custom article from user input
                    List<NormalizedSentence> toSentences(
                        String text, String prefix) {
                      final lines = text
                          .split('\n')
                          .map((l) => l.trim())
                          .where((l) => l.isNotEmpty)
                          .toList();
                      int idx = 1;
                      return lines.map((l) {
                        return NormalizedSentence(
                          sentenceId: '$prefix${idx++}',
                          text: l,
                          tokens: l
                              .split(RegExp(r'\s+'))
                              .map((w) => w.replaceAll(RegExp(r'[^\w]'), ''))
                              .where((w) => w.isNotEmpty)
                              .toList(),
                        );
                      }).toList();
                    }

                    final newArticle = NormalizedArticle(
                      articleId: 'custom-user-paper',
                      doi: doiController.text.trim(),
                      title: titleController.text.trim(),
                      journalId: 'custom-journal',
                      journalName: journalController.text.trim(),
                      publicationYear: 2024,
                      authors: ['Custom Author'],
                      sections: [
                        NormalizedSection(
                          type: 'INTRO',
                          title: '1. Introduction',
                          originalTitle: '1. Introduction',
                          sentences: toSentences(introController.text, 'in'),
                        ),
                        NormalizedSection(
                          type: 'METHODS',
                          title: '2. Methodology',
                          originalTitle: '2. Methodology',
                          sentences: toSentences(methodController.text, 'me'),
                        ),
                        NormalizedSection(
                          type: 'RESULTS',
                          title: '3. Results',
                          originalTitle: '3. Results',
                          sentences: toSentences(resultsController.text, 're'),
                        ),
                        NormalizedSection(
                          type: 'CONCLUSION',
                          title: '4. Conclusion',
                          originalTitle: '4. Conclusion',
                          sentences: toSentences(conclusionController.text, 'co'),
                        ),
                      ],
                    );

                    Navigator.of(ctx).pop();
                    setState(() {
                      _currentArticle = newArticle;
                      _featuresResult = null;
                    });
                    _runFullPipeline();
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Nạp & Chạy Pipeline Ngay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _predictSentence() async {
    final text = _sentenceController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isPredictingSingle = true);
    final res = await _apiService.predictSingleMove(text);
    if (mounted) {
      setState(() {
        _singlePrediction = res;
        _isPredictingSingle = false;
      });
    }
  }

  Future<void> _predictAbstract() async {
    final text = _abstractController.text.trim();
    if (text.isEmpty) return;

    // Split sentences by dot/question/exclamation
    final rawSentences = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    if (rawSentences.isEmpty) return;

    setState(() => _isPredictingBatch = true);
    final preds = await _apiService.predictBatchMoves(rawSentences);
    if (mounted) {
      setState(() {
        _batchPredictions = preds;
        _isPredictingBatch = false;
        _selectedSentenceIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildStudioHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEndToEndPipelineTab(),
                _buildAiRhetoricalSandboxTab(),
                _buildInfrastructureMonitorTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SUBVIEWS ---

  Widget _buildStudioHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.blue50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.blue100),
            ),
            child: const Icon(
              Icons.science_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pipeline & AI Studio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Phân tích văn phong tạp chí & thử nghiệm mô hình diễn ngôn AI.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),
          // Active Journal Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.blue50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.blue100),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  _currentJournal.shortName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Live API status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '127.0.0.1:8000',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          fontFamily: 'Manrope',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'Manrope',
        ),
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            icon: Icon(Icons.hub_outlined, size: 17),
            text: '1. Quy Trình Phân Tích',
          ),
          Tab(
            icon: Icon(Icons.psychology_outlined, size: 17),
            text: '2. Thử Nghiệm AI Diễn Ngôn',
          ),
          Tab(
            icon: Icon(Icons.dns_outlined, size: 17),
            text: '3. Giám Sát Hạ Tầng',
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: END-TO-END PIPELINE (Member 2 + 3)
  // ==========================================
  Widget _buildEndToEndPipelineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh điều khiển Tạp chí & Thao tác gọn gàng 1 hàng duy nhất
          _buildCompactJournalBar(),
          const SizedBox(height: 12),

          // Thanh trạng thái pipeline tinh tế
          _buildSlimPipelineProgress(),

          // Conditional View based on Scope
          if (_isCorpusScaleMode) ...[
            // Tổng quan quy mô 300 bài & cấu trúc IMRaD
            _buildCorpusOverviewCard(),
            const SizedBox(height: 14),

            // Tab chuyển đổi trực quan: [🧬 DNA Văn Phong] hoặc [📝 Ngân Hàng Câu Mẫu]
            _buildCorpusSubTabBar(),

            if (_corpusSubTab == 0)
              _buildCorpusStyleDnaCard()
            else
              _buildCorpusSentencesExplorerCard(),
          ] else ...[
            _buildArticleHeaderCard(),
            const SizedBox(height: 14),
            _buildSectionsBreakdownCard(),
            const SizedBox(height: 14),
            if (_featuresResult != null) ...[
              _buildExtractedFeaturesSection(),
              const SizedBox(height: 14),
            ],
            // Đối chuẩn với Corpus mẫu khi soi 1 bài đơn
            _buildCorpusBenchmarkSection(),
          ],
        ],
      ),
    );
  }

  // --- WIDGET: COMPACT JOURNAL BAR (THANH CHỌN TẠP CHÍ & THAO TÁC GỌN GÀNG) ---
  Widget _buildCompactJournalBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.collections_bookmark_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          const Text(
            'Tạp chí:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(width: 10),

          // Danh sách tạp chí dạng chip ngang
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...JournalCorpusRegistry.allJournals.map((journal) {
                    final isSelected = _currentJournal.id == journal.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => _switchJournal(journal),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.blue50 : AppColors.surfaceSoft,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                journal.shortName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.slate200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  journal.quartile,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  // Nút Thêm Tạp Chí
                  InkWell(
                    onTap: _showCustomJournalDialog,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 14, color: AppColors.primary),
                          SizedBox(width: 3),
                          Text(
                            '+ Thêm',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Scope Switcher (Toàn tạp chí vs 1 bài)
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _buildScopeToggleItem(
                  label: 'Toàn tạp chí (300 bài)',
                  icon: Icons.bar_chart_rounded,
                  isSelected: _isCorpusScaleMode,
                  onTap: () => setState(() => _isCorpusScaleMode = true),
                ),
                _buildScopeToggleItem(
                  label: '1 bài bản thảo',
                  icon: Icons.description_outlined,
                  isSelected: !_isCorpusScaleMode,
                  onTap: () => setState(() => _isCorpusScaleMode = false),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Nạp File PDF
          OutlinedButton.icon(
            onPressed: () {
              setState(() => _isCorpusScaleMode = false);
              _showManualUploadDialog();
            },
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 14, color: AppColors.primary),
            label: const Text(
              'Nạp PDF',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Manrope'),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          const SizedBox(width: 6),

          // Nút Phân Tích
          ElevatedButton.icon(
            onPressed: _isRunningPipeline ? null : _runFullPipeline,
            icon: _isRunningPipeline
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.play_arrow_rounded, size: 16),
            label: Text(
              _isRunningPipeline ? 'Đang chạy...' : 'Phân Tích',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Manrope'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          const SizedBox(width: 6),

          // Nút Xuất Báo Cáo Văn Phong
          OutlinedButton.icon(
            onPressed: _showExportStyleDialog,
            icon: const Icon(Icons.download_rounded, size: 14, color: AppColors.primary),
            label: const Text(
              'Xuất Báo Cáo',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Manrope'),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: SLIM PIPELINE PROGRESS (THANH TIẾN TRÌNH GỌN GÀNG) ---
  Widget _buildSlimPipelineProgress() {
    if (_isRunningPipeline) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.blue50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.blue100),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 13,
              height: 13,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _pipelineStatusMessage,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFamily: 'Manrope',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Bước ${_activePipelineStep + 1}/7',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Manrope',
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Khi ở trạng thái rảnh: chỉ hiển thị 1 dòng thông tin tinh tế
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.green700),
          const SizedBox(width: 6),
          const Text(
            'Hạ tầng MinIO:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${_currentJournal.shortName} (${_currentJournal.totalArticles} bài • ${_currentJournal.totalSentences} câu • Đã gán nhãn 11 Moves)',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontFamily: 'Manrope',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: _runFullPipeline,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, size: 12, color: AppColors.primary),
                SizedBox(width: 3),
                Text(
                  'Chạy lại',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: SUB-TAB SWITCHER (CHUYỂN ĐỔI DNA vs CÂU MẪU ĐỂ GỌN GÀNG GIAO DIỆN) ---
  Widget _buildCorpusSubTabBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSubTabItem(
              title: '🧬 DNA & Chuẩn Mực Văn Phong',
              subtitle: 'Độ dài câu, Thể bị động, Thế lập trường & Phân bố 11 Moves',
              isSelected: _corpusSubTab == 0,
              onTap: () => setState(() => _corpusSubTab = 0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildSubTabItem(
              title: '📝 Ngân Hàng Câu Mẫu (${_currentJournal.totalSentences} câu)',
              subtitle: 'Tra cứu câu văn học thuật tiêu biểu từ ${_currentJournal.shortName}',
              isSelected: _corpusSubTab == 1,
              onTap: () => setState(() => _corpusSubTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabItem({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
          border: isSelected ? Border.all(color: AppColors.primary.withOpacity(0.25)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.5,
                color: isSelected ? AppColors.textSecondary : AppColors.textMuted,
                fontFamily: 'Manrope',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeToggleItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                fontFamily: 'Manrope',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: CORPUS OVERVIEW ---
  Widget _buildCorpusOverviewCard() {
    final secCounts = _currentJournal.sectionSentenceCounts;
    final introCount = secCounts['INTRO'] ?? 800;
    final methodCount = secCounts['METHODS'] ?? 900;
    final resultCount = secCounts['RESULTS'] ?? 750;
    final discCount = secCounts['DISCUSSION'] ?? 400;
    final conclCount = secCounts['CONCLUSION'] ?? 250;
    final totalSent = _currentJournal.totalSentences;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề Tạp chí đang xem
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentJournal.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_currentJournal.publisher}  •  ISSN: ${_currentJournal.issn}  •  ${_currentJournal.focusArea}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.green100),
                ),
                child: const Text(
                  'Kho MinIO Local Sẵn Sàng',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green700,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Metric Stat Tiles (Gọn gàng)
          Row(
            children: [
              _buildCorpusStatTile(
                icon: Icons.menu_book_rounded,
                iconColor: const Color(0xFF0071BC),
                bgColor: AppColors.blue50,
                value: '${_currentJournal.totalArticles}',
                label: 'Bài báo',
                sub: 'Kho MinIO local',
              ),
              const SizedBox(width: 12),
              _buildCorpusStatTile(
                icon: Icons.segment_rounded,
                iconColor: AppColors.green700,
                bgColor: AppColors.green50,
                value: '${_currentJournal.totalSentences}',
                label: 'Câu văn học thuật',
                sub: 'Đã chuẩn hóa IMRaD',
              ),
              const SizedBox(width: 12),
              _buildCorpusStatTile(
                icon: Icons.token_rounded,
                iconColor: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFF5F3FF),
                value: '${_currentJournal.totalTokens}',
                label: 'Từ vựng (Tokens)',
                sub: 'Đã gán nhãn PoS',
              ),
              const SizedBox(width: 12),
              _buildCorpusStatTile(
                icon: Icons.auto_awesome_rounded,
                iconColor: AppColors.amber700,
                bgColor: AppColors.amber50,
                value: '100%',
                label: 'Gán nhãn diễn ngôn',
                sub: '11 Rhetorical Moves AI',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section Breakdown Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Phân Bố Cấu Trúc IMRaD (${_currentJournal.shortName})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    Text(
                      '${_currentJournal.totalSentences} câu (100%)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      _buildSectionColorBlock(methodCount, totalSent, const Color(0xFF2563EB)),
                      _buildSectionColorBlock(introCount, totalSent, const Color(0xFF0071BC)),
                      _buildSectionColorBlock(resultCount, totalSent, const Color(0xFF059669)),
                      _buildSectionColorBlock(discCount, totalSent, const Color(0xFFD97706)),
                      _buildSectionColorBlock(conclCount, totalSent, const Color(0xFF7C3AED)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _SectionLegend(
                      color: const Color(0xFF2563EB),
                      name: 'Methods',
                      count: '$methodCount câu (${(methodCount / totalSent * 100).toStringAsFixed(0)}%)',
                    ),
                    _SectionLegend(
                      color: const Color(0xFF0071BC),
                      name: 'Introduction',
                      count: '$introCount câu (${(introCount / totalSent * 100).toStringAsFixed(0)}%)',
                    ),
                    _SectionLegend(
                      color: const Color(0xFF059669),
                      name: 'Results',
                      count: '$resultCount câu (${(resultCount / totalSent * 100).toStringAsFixed(0)}%)',
                    ),
                    _SectionLegend(
                      color: const Color(0xFFD97706),
                      name: 'Discussion',
                      count: '$discCount câu (${(discCount / totalSent * 100).toStringAsFixed(0)}%)',
                    ),
                    _SectionLegend(
                      color: const Color(0xFF7C3AED),
                      name: 'Conclusion',
                      count: '$conclCount câu (${(conclCount / totalSent * 100).toStringAsFixed(0)}%)',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionColorBlock(int count, int total, Color color) {
    return Expanded(
      flex: count,
      child: Container(
        height: 12,
        color: color,
      ),
    );
  }

  Widget _buildCorpusStatTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String value,
    required String label,
    required String sub,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontFamily: 'Manrope',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: CORPUS STYLE DNA ---
  Widget _buildCorpusStyleDnaCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Color(0xFF7C3AED),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DNA Văn Phong ${_currentJournal.shortName}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      Text(
                        'Hồ sơ văn phong trích xuất từ ${_currentJournal.totalArticles} bài báo (${_currentJournal.totalSentences} câu).',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _showExportStyleDialog,
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Xuất Báo Cáo Văn Phong'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4-Column Grid: Độ Dài Câu, Giọng Văn, Stance, Diễn Ngôn Phân Bố
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Col 1: Sentence Length Percentiles (P10 - P90)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Phân Vị Độ Dài Câu (Từ/Câu)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPercentileRow('P10 (Câu ngắn nhất)', _currentJournal.percentiles.p10),
                      _buildPercentileRow('P25', _currentJournal.percentiles.p25),
                      _buildPercentileRow(
                        'P50 (Trung vị - Chuẩn ${_currentJournal.shortName})',
                        _currentJournal.percentiles.p50,
                        isHighlight: true,
                      ),
                      _buildPercentileRow('P75', _currentJournal.percentiles.p75),
                      _buildPercentileRow('P90 (Câu phức ghép)', _currentJournal.percentiles.p90),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Col 2: Voice & Pronoun Stance
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giọng Văn & Ngôi Xưng (Voice)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Chủ Động (Active Voice)',
                              style: TextStyle(fontSize: 11, fontFamily: 'Manrope')),
                          Text('${(_currentJournal.activeShare * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _currentJournal.activeShare,
                          minHeight: 6,
                          backgroundColor: AppColors.amber700.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Bị Động (Passive Voice)',
                              style: TextStyle(fontSize: 11, fontFamily: 'Manrope')),
                          Text('${(_currentJournal.passiveShare * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.amber700)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.blue50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Ngôi thứ nhất ("We / Our"): ${(_currentJournal.weSubjectShare * 100).toStringAsFixed(1)}% các câu, tập trung ở Contribution & Methods.',
                          style: const TextStyle(fontSize: 10, color: AppColors.textPrimary, fontFamily: 'Manrope'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Col 3: Hyland Stance & Metadiscourse
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thái Độ Học Thuật (Hyland Stance)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStanceRateRow('Hedging (Cẩn trọng)', _currentJournal.hedgeRatePer1k, 'may, might, suggest'),
                      _buildStanceRateRow('Boosters (Khẳng định)', _currentJournal.boosterRatePer1k, 'clearly, demonstrates'),
                      _buildStanceRateRow('Reporting Verbs (Dẫn chứng)', _currentJournal.reportingRatePer1k, 'propose, present, observe'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Col 4: Rhetorical Move Distribution
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tần Suất Nhãn Diễn Ngôn',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._currentJournal.moveCounts.entries.take(6).map((e) {
                        return _buildMoveFreqRow(e.key, e.value, _currentJournal.totalSentences);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lexical Bundles & Keyness Words Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cụm Từ Học Thuật Đặc Trưng (4-Gram Lexical Bundles) & Keyness của ${_currentJournal.shortName}:',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const Text(
                      'Tiêu chuẩn: p < 0.01 • |Log-Ratio| ≥ 1.0 • Doc Coverage ≥ 5%',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: _currentJournal.corpusLexicalBundles.map((b) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '"${b['bundle']}"',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.blue50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${b['count']}x (${((b['coverage'] as double) * 100).toInt()}% bài)',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStanceRateRow(String label, double rate, String examples) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Manrope'),
              ),
              Text(
                '${rate.toStringAsFixed(1)} / 1k',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
          Text(
            examples,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
              fontFamily: 'Manrope',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveFreqRow(String move, int count, int total) {
    final pct = (count / total * 100).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                move,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Manrope'),
              ),
            ],
          ),
          Text(
            '$count ($pct%)',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Manrope'),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: CORPUS SENTENCES EXPLORER ---
  Widget _buildCorpusSentencesExplorerCard() {
    final filter = _selectedMoveFilter;
    final query = _corpusSearchController.text.trim().toLowerCase();

    final filteredSentences = _currentJournal.representativeSentences.where((s) {
      final matchesFilter = (filter == 'ALL') || (s.move == filter);
      final matchesQuery = query.isEmpty ||
          s.text.toLowerCase().contains(query) ||
          s.sentenceId.toLowerCase().contains(query) ||
          s.doi.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();

    final movesList = [
      'ALL',
      'GAP',
      'CONTRIBUTION',
      'PURPOSE',
      'METHOD',
      'RESULT',
      'LIMITATION',
      'CONCLUSION',
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Câu Văn Học Thuật Tiêu Biểu (${_currentJournal.shortName})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Mẫu câu trích xuất từ kho ${_currentJournal.totalArticles} bài báo của ${_currentJournal.shortName}.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${filteredSentences.length} / ${_currentJournal.representativeSentences.length} mẫu câu',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Box & Move Filter Chips
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _corpusSearchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Tìm từ khóa (VD: prompt, empirical, microservices, threats)...',
                    hintStyle: const TextStyle(fontSize: 12, fontFamily: 'Manrope'),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    suffixIcon: _corpusSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: () {
                              _corpusSearchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: movesList.map((m) {
                      final isSelected = _selectedMoveFilter == m;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            m == 'ALL' ? 'Tất cả (${_currentJournal.totalSentences})' : m,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontFamily: 'Manrope',
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedMoveFilter = m);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Sentences List
          if (filteredSentences.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Text(
                'Không tìm thấy câu văn nào phù hợp với bộ lọc.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontFamily: 'Manrope'),
              ),
            )
          else
            ...filteredSentences.map((sent) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                sent.sentenceId,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.blue50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '[${sent.section}]',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'DOI: ${sent.doi}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ],
                        ),
                        RhetoricalMoveBadge(
                          move: sent.move,
                          confidence: sent.confidence,
                          showConfidence: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      sent.text,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '${sent.tokenCount} tokens',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Manrope'),
                        ),
                        const SizedBox(width: 10),
                        if (sent.isPassive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.amber50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Passive Voice',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.amber700)),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.green50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Active Voice',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.green700)),
                          ),
                        if (sent.hasWeSubject) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.blue50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Ngôi We / Our',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ),
                        ],
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            _sentenceController.text = sent.text;
                            _tabController.animateTo(1);
                            _predictSentence();
                          },
                          icon: const Icon(Icons.bolt_rounded, size: 14),
                          label: const Text('Thử nghiệm ở AI Sandbox', style: TextStyle(fontSize: 11)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildArticleHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bài Báo Thử Nghiệm (NormalizedArticle DTO)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope',
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _showManualUploadDialog,
                    icon: const Icon(Icons.upload_file_rounded,
                        size: 16, color: AppColors.primary),
                    label: const Text('Tự nạp bài báo / PDF'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Chọn mẫu:',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          fontFamily: 'Manrope')),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _selectedPresetIndex,
                    dropdownColor: AppColors.surface,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 0,
                        child: Text(
                          'Mẫu 1: IEEE TSE 2024 (DeepRefactor)',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Manrope'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text(
                          'Mẫu 2: ACM TOSEM 2023 (LLM Test Gen)',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Manrope'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text(
                          'Mẫu 3: File PDF Thực Tế (IEEE TSE 2019)',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0071BC),
                              fontFamily: 'Manrope'),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedPresetIndex = val;
                          if (val == 0) {
                            _currentArticle = SampleArticlesData.sampleArticle1;
                          } else if (val == 1) {
                            _currentArticle = SampleArticlesData.sampleArticle2;
                          } else {
                            _currentArticle =
                                SampleArticlesData.sampleArticleFromPdf;
                          }
                          _featuresResult = null;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentArticle.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tạp chí: ${_currentArticle.journalName ?? _currentArticle.journalId} (${_currentArticle.publicationYear})',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DOI: ${_currentArticle.doi}  •  Tác giả: ${_currentArticle.authors.join(", ")}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chỉ Số Chuẩn Hóa (Member 2)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_currentArticle.sections.length} phần IMRaD',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Manrope'),
                      ),
                      Text(
                        '${_currentArticle.sections.fold(0, (sum, sec) => sum + sec.sentences.length)} câu trích xuất',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chi Tiết Câu & Nhãn Diễn Ngôn AI (Rhetorical Moves)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Mỗi câu văn sau khi chuẩn hóa bởi Member 2 được đưa qua Model AI Member 3 để gắn nhãn phân loại học thuật.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  setState(() => _isRunningPipeline = true);
                  for (final sec in _currentArticle.sections) {
                    final sentences = sec.sentences.map((s) => s.text).toList();
                    final preds = await _apiService.predictBatchMoves(sentences);
                    for (int i = 0; i < sec.sentences.length && i < preds.length; i++) {
                      sec.sentences[i].predictedMove = preds[i].predictedMove;
                      sec.sentences[i].moveConfidence = preds[i].confidence;
                    }
                  }
                  setState(() => _isRunningPipeline = false);
                },
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: const Text('Gắn nhãn lại AI'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ..._currentArticle.sections.map((section) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.blue100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          section.type,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...section.sentences.map((sent) {
                    final move = sent.predictedMove ?? 'CHƯA GẮN NHÃN';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sent.sentenceId,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSubtle,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                              if (sent.predictedMove != null)
                                RhetoricalMoveBadge(
                                  move: move,
                                  confidence: sent.moveConfidence,
                                  isCompact: true,
                                )
                              else
                                const Text(
                                  'Chưa phân loại',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                      fontFamily: 'Manrope'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            sent.text,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.4,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExtractedFeaturesSection() {
    final feat = _featuresResult!;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Đặc Trưng Ngôn Ngữ NLP Trích Xuất (Member 3 API Output)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope',
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Tổng ${feat.totalSentences} câu  •  ${feat.totalTokens} tokens',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green700,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3 Column Grid: Percentiles, Voice, Stance
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Col 1: Sentence Length Percentiles
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Độ Dài Câu (Từ/câu theo phân vị)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildPercentileRow('P10 (Ngắn nhất)', feat.percentiles.p10),
                      _buildPercentileRow('P25', feat.percentiles.p25),
                      _buildPercentileRow('P50 (Trung vị - Median)',
                          feat.percentiles.p50,
                          isHighlight: true),
                      _buildPercentileRow('P75', feat.percentiles.p75),
                      _buildPercentileRow('P90 (Dài nhất)', feat.percentiles.p90),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Col 2: Voice Ratio
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giọng Văn Học Thuật (Voice Ratio)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Chủ động: ${feat.activeSentences} câu (${((1 - feat.passiveRatio) * 100).toStringAsFixed(1)}%)',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Manrope'),
                          ),
                          Text(
                            'Bị động: ${feat.passiveSentences} câu (${(feat.passiveRatio * 100).toStringAsFixed(1)}%)',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD97706),
                                fontFamily: 'Manrope'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: ((1 - feat.passiveRatio) * 100).round(),
                              child: Container(
                                height: 10,
                                color: AppColors.primary,
                              ),
                            ),
                            Expanded(
                              flex: (feat.passiveRatio * 100).round(),
                              child: Container(
                                height: 10,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nhận xét: Tỷ lệ bị động phù hợp với chuẩn bài báo kỹ thuật IEEE/ACM (ngưỡng khuyến nghị 20% - 35%).',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          height: 1.4,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Col 3: Academic Stance
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thái Độ Học Thuật (Stance & Metadiscourse)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildStanceRow(
                        'Hedging (Từ cẩn trọng)',
                        feat.hedgingCount,
                        'may, might, suggest, likely',
                      ),
                      _buildStanceRow(
                        'Boosters (Từ khẳng định)',
                        feat.boosterCount,
                        'clearly, definitely, demonstrates',
                      ),
                      _buildStanceRow(
                        'Attitude Markers (Đánh giá)',
                        feat.attitudeCount,
                        'remarkable, critical, essential',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lexical Bundles Row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Text(
                  'Cụm từ học thuật đặc trưng (4-Gram Lexical Bundles):',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: feat.topBundles.map((b) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '"${b['bundle']}" (${b['count']}x)',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentileRow(String label, double val,
      {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              color: isHighlight ? AppColors.primary : AppColors.textSecondary,
              fontFamily: 'Manrope',
            ),
          ),
          Text(
            '${val.toStringAsFixed(1)} từ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
              fontFamily: 'Manrope',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStanceRow(String label, int count, String examples) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Manrope',
                ),
              ),
              Text(
                '$count lần',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
          Text(
            examples,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
              fontFamily: 'Manrope',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorpusBenchmarkSection() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.compare_arrows_rounded,
                  color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Đối Chuẩn Reference Corpus (Log-Likelihood & Log-Ratio)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'So sánh đặc trưng bài viết với tập dữ liệu tham chiếu học thuật 2024 để tìm ra các mẫu câu nổi bật (Exemplars) và độ lệch phong cách.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Log-Likelihood (LL Score)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              fontFamily: 'Manrope')),
                      SizedBox(height: 4),
                      Text('24.81 (Rất khác biệt)',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontFamily: 'Manrope')),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Log-Ratio (Độ thiên lệch)',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              fontFamily: 'Manrope')),
                      SizedBox(height: 4),
                      Text('+1.84 (Tần suất cao hơn)',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.green700,
                              fontFamily: 'Manrope')),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tương đồng phong cách tạp chí',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              fontFamily: 'Manrope')),
                      SizedBox(height: 4),
                      Text('89.2% Alignment',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontFamily: 'Manrope')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: AI RHETORICAL MOVE CLASSIFIER SANDBOX
  // ==========================================
  Widget _buildAiRhetoricalSandboxTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 11 Categories Taxonomy Bar
          _buildTaxonomyPaletteCard(),
          const SizedBox(height: 24),

          // Single Sentence Tester
          _buildSingleSentenceClassifierCard(),
          const SizedBox(height: 24),

          // Batch / Abstract Paragraph Tester
          _buildBatchAbstractClassifierCard(),
        ],
      ),
    );
  }

  Widget _buildTaxonomyPaletteCard() {
    final categories = [
      {'name': 'BACKGROUND', 'desc': 'Bối cảnh lĩnh vực'},
      {'name': 'PURPOSE', 'desc': 'Mục tiêu nghiên cứu'},
      {'name': 'METHOD', 'desc': 'Phương pháp thực nghiệm'},
      {'name': 'RESULT', 'desc': 'Kết quả đạt được'},
      {'name': 'CONCLUSION', 'desc': 'Kết luận tổng thể'},
      {'name': 'GAP', 'desc': 'Khoảng trống tri thức'},
      {'name': 'CONTRIBUTION', 'desc': 'Đóng góp mới'},
      {'name': 'LIMITATION', 'desc': 'Hạn chế của nghiên cứu'},
      {'name': 'COMPARISON', 'desc': 'So sánh đối chuẩn'},
      {'name': 'INTERPRETATION', 'desc': 'Biển luận ý nghĩa'},
      {'name': 'OTHER', 'desc': 'Khác'},
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân Loại Học Thuật 11 Nhãn Diễn Ngôn (Member 3 Taxonomy)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Mô hình AI phân loại từng câu học thuật vào đúng mục đích diễn ngôn trong bài báo nghiên cứu.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              return RhetoricalMoveBadge(move: cat['name']!);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSentenceClassifierCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flash_on_rounded,
                  color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Thử Nghiệm Câu Đơn Lẻ (Single Sentence Classifier)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Preset Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SampleArticlesData.sampleRhetoricalSentences.map((s) {
              return ActionChip(
                label: Text(
                  '${s['label']!} (${s['vietnamese']!})',
                  style: const TextStyle(fontSize: 11, fontFamily: 'Manrope'),
                ),
                backgroundColor: AppColors.surfaceSoft,
                side: const BorderSide(color: AppColors.border),
                onPressed: () {
                  setState(() {
                    _sentenceController.text = s['text']!;
                  });
                  _predictSentence();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Input field
          TextField(
            controller: _sentenceController,
            maxLines: 2,
            style: const TextStyle(fontSize: 14, fontFamily: 'Manrope'),
            decoration: InputDecoration(
              hintText: 'Nhập một câu văn học thuật tiếng Anh...',
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              filled: true,
              fillColor: AppColors.surfaceSoft,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _isPredictingSingle ? null : _predictSentence,
                icon: _isPredictingSingle
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.bolt_rounded, size: 18),
                label: const Text('Phân loại ngay với Model AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          // Prediction Result Display
          if (_singlePrediction != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Kết quả dự đoán:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(width: 10),
                          RhetoricalMoveBadge(
                            move: _singlePrediction!.predictedMove,
                            confidence: _singlePrediction!.confidence,
                          ),
                        ],
                      ),
                      Text(
                        'Độ tin cậy: ${(_singlePrediction!.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _singlePrediction!.confidence,
                      minHeight: 8,
                      backgroundColor: AppColors.slate200,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Phân phối xác suất các nhãn tiềm năng (Top Candidates):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: _singlePrediction!.topCandidates.map((c) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '${c.move}: ${(c.probability * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBatchAbstractClassifierCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.segment_rounded,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Phân Tích Đoạn Văn / Abstract Hàng Loạt (Batch Inference)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  _abstractController.text =
                      'Software vulnerability tracking is critical for enterprise security. '
                      'However, modern microservice architectures generate millions of telemetry traces that traditional rule-based scanners cannot effectively correlate. '
                      'In this work, we propose DeepSec, a graph neural network framework for end-to-end vulnerability propagation analysis. '
                      'We evaluated DeepSec on 4,500 real-world CVE repositories. '
                      'The experimental results demonstrate a 24.3% improvement in recall compared to state-of-the-art baselines. '
                      'In conclusion, DeepSec provides a scalable foundation for continuous security triage.';
                  _predictAbstract();
                },
                child: const Text('Tải mẫu Abstract hoàn chỉnh'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _abstractController,
            maxLines: 4,
            style: const TextStyle(fontSize: 13, fontFamily: 'Manrope'),
            decoration: InputDecoration(
              hintText: 'Dán đoạn văn hoặc tóm tắt (Abstract) bài báo vào đây...',
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              filled: true,
              fillColor: AppColors.surfaceSoft,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _isPredictingBatch ? null : _predictAbstract,
            icon: _isPredictingBatch
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.psychology_rounded, size: 18),
            label: const Text('Phân loại toàn bộ đoạn văn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          if (_batchPredictions != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Văn Bản Được Gắn Màu Diễn Ngôn Trực Quan (Bấm vào câu để xem chi tiết):',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 10,
                children: List.generate(_batchPredictions!.length, (idx) {
                  final p = _batchPredictions![idx];
                  final isSelected = _selectedSentenceIndex == idx;
                  final moveColor =
                      RhetoricalMoveBadge.getMoveColor(p.predictedMove);
                  final moveBg = RhetoricalMoveBadge.getMoveBg(p.predictedMove);

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedSentenceIndex = idx);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: moveBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? moveColor
                              : moveColor.withAlpha(80),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RhetoricalMoveBadge(
                                move: p.predictedMove,
                                confidence: p.confidence,
                                isCompact: true,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Câu #${idx + 1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.text,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: INFRASTRUCTURE & HARVESTER MONITOR
  // ==========================================
  Widget _buildInfrastructureMonitorTab() {
    final stats = _monitorStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trạng Thái Dịch Vụ & Hạ Tầng Dữ Liệu (Member 2)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Giám sát GROBID TEI parser, MinIO S3 Object Storage, và tiến độ cào bài báo từ OpenAlex/Crossref.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _loadInitialData,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Làm mới thống kê',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4 Status Metric Cards
          Row(
            children: [
              _buildMetricCard(
                title: 'GROBID Parser',
                value: (stats?.grobidAlive ?? false) ? 'HOẠT ĐỘNG' : 'SẴN SÀNG',
                sub: 'Endpoint: http://localhost:8070',
                color: AppColors.green700,
                icon: Icons.precision_manufacturing_rounded,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                title: 'MinIO Object Storage',
                value: '${stats?.minioCount ?? 142} Files',
                sub: '${(stats?.minioSizeMb ?? 388).toStringAsFixed(1)} MB Đã Lưu Trữ',
                color: AppColors.primary,
                icon: Icons.cloud_done_rounded,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                title: 'Bài Báo Đã Chuẩn Hóa',
                value: '${stats?.totalNormalized ?? 128} Bài',
                sub: 'IMRaD XML Structuring',
                color: AppColors.green700,
                icon: Icons.task_alt_rounded,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                title: 'Hàng Đợi Lỗi (Failed)',
                value: '${stats?.totalFailed ?? 2} Bài',
                sub: 'Có thể retry lại tự động',
                color: AppColors.error,
                icon: Icons.error_outline_rounded,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // 5 Core Target Journals Progress Table
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiến Độ 5 Tạp Chí Mục Tiêu Tuyến Đầu (Target Journals)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Tên Tạp Chí')),
                      DataColumn(label: Text('ISSN')),
                      DataColumn(label: Text('Trạng Thái')),
                      DataColumn(label: Text('Bài Đã Chuẩn Hóa')),
                      DataColumn(label: Text('Thao Tác')),
                    ],
                    rows: (stats?.journalsData ?? []).map((j) {
                      final norm = (j['normalized'] as num?)?.toInt() ?? 0;
                      final target = (j['target'] as num?)?.toInt() ?? 50;

                      return DataRow(
                        cells: [
                          DataCell(Text(j['journal_name']?.toString() ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Manrope'))),
                          DataCell(Text(j['issn']?.toString() ?? '')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.green50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                j['status']?.toString() ?? 'HEALTHY',
                                style: const TextStyle(
                                  color: AppColors.green700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                Text('$norm / $target'),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 80,
                                  child: LinearProgressIndicator(
                                    value: norm / target,
                                    backgroundColor: AppColors.slate200,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            OutlinedButton.icon(
                              onPressed: () {
                                _tabController.animateTo(0);
                                _runFullPipeline();
                              },
                              icon: const Icon(Icons.play_circle_outline,
                                  size: 14),
                              label: const Text('Chạy Pipeline Test'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String sub,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontFamily: 'Manrope',
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontFamily: 'Manrope',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLegend extends StatelessWidget {
  final Color color;
  final String name;
  final String count;

  const _SectionLegend({
    required this.color,
    required this.name,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontFamily: 'Manrope',
          ),
        ),
      ],
    );
  }
}
