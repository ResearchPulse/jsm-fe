import 'package:flutter/widgets.dart';

/// Supported locales in the application.
enum AppLocaleType {
  en('en', 'English', 'English', 'EN'),
  vi('vi', 'Tiếng Việt', 'Vietnamese', 'VI');

  final String code;
  final String nativeName;
  final String englishName;
  final String label;

  const AppLocaleType(this.code, this.nativeName, this.englishName, this.label);

  Locale get locale => Locale(code);

  static AppLocaleType fromLocale(Locale locale) {
    if (locale.languageCode == 'vi') return AppLocaleType.vi;
    return AppLocaleType.en;
  }
}

/// Provides strongly-typed translations for English and Vietnamese.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  bool get isVietnamese => locale.languageCode == 'vi';

  // Common & Branding
  String get appTitle => isVietnamese
      ? 'Hệ Thống Theo Dõi Xu Hướng Xuất Bản Khoa Học'
      : 'Scientific Journal Publication Trend Tracking System';

  String get hyperDataLab => 'HyperData Lab';
  String get brandSub => 'journal system miner';

  String get search => isVietnamese ? 'Tìm kiếm' : 'Search';
  String get searchPlaceholder => isVietnamese
      ? 'Tìm kiếm tạp chí, snapshot, jobs...'
      : 'Search journals, snapshots, jobs...';

  String get cancel => isVietnamese ? 'Hủy bỏ' : 'Cancel';
  String get confirm => isVietnamese ? 'Xác nhận' : 'Confirm';
  String get save => isVietnamese ? 'Lưu' : 'Save';
  String get close => isVietnamese ? 'Đóng' : 'Close';
  String get back => isVietnamese ? 'Quay lại' : 'Back';
  String get loading => isVietnamese ? 'Đang tải...' : 'Loading...';
  String get success => isVietnamese ? 'Thành công' : 'Success';
  String get error => isVietnamese ? 'Lỗi' : 'Error';
  String get noData => isVietnamese ? 'Không có dữ liệu' : 'No data available';

  // Language Switcher
  String get language => isVietnamese ? 'Ngôn ngữ' : 'Language';
  String get english => 'English';
  String get vietnamese => 'Tiếng Việt';
  String get switchLanguage =>
      isVietnamese ? 'Chuyển sang Tiếng Anh' : 'Switch to Vietnamese';
  String get languageSwitcherTooltip =>
      isVietnamese ? 'Đổi ngôn ngữ' : 'Change language';

  // Topbar / Navbar & Action Buttons
  String get signOut => isVietnamese ? 'Đăng xuất' : 'Sign out';
  String get adminDashboard =>
      isVietnamese ? 'Bảng điều khiển quản trị' : 'Admin dashboard';
  String get user => isVietnamese ? 'Người dùng' : 'User';
  String get admin => isVietnamese ? 'Quản trị' : 'Admin';
  String get checker => isVietnamese ? 'Kiểm tra' : 'Checker';
  String get backToHome => isVietnamese ? 'Quay về trang chủ' : 'Back to home';
  String get expandSidebar =>
      isVietnamese ? 'Mở rộng thanh menu' : 'Expand sidebar';
  String get collapseSidebar =>
      isVietnamese ? 'Thu gọn thanh menu' : 'Collapse sidebar';

  // User Sidebar & Header
  String get academicWorkspace => isVietnamese ? 'Không gian Học thuật' : 'Academic Workspace';
  String get journalDashboardBadge => isVietnamese ? 'Cổng Tạp chí' : 'Journal Dashboard';
  String get navManuscriptChecker => isVietnamese ? 'Kiểm tra Bản thảo' : 'Manuscript Checker';
  String get navJournalRecommendations => isVietnamese ? 'Gợi ý Tạp chí' : 'Journal Recommendations';
  String get navEvaluationHistory => isVietnamese ? 'Lịch sử Đánh giá' : 'Evaluation History';
  String get accountProfile => isVietnamese ? 'Hồ sơ tài khoản' : 'Account Profile';
  String get adminManagement => isVietnamese ? 'Trang quản trị (Admin)' : 'Admin Dashboard';
  String get journalRecTitle => isVietnamese ? 'Gợi Ý Tạp Chí Phù Hợp' : 'Suitable Journal Recommendations';
  String get journalRecDesc => isVietnamese
      ? 'Tính năng phân tích ngữ nghĩa và đề xuất các tạp chí Q1/Q2/Scopus phù hợp nhất với bản thảo của bạn đang được hoàn thiện.'
      : 'Semantic analysis and journal recommendation for Q1/Q2/Scopus journals matching your manuscript is under development.';
  String get backToManuscriptChecker =>
      isVietnamese ? 'Quay lại Kiểm tra Bản thảo' : 'Back to Manuscript Checker';
  String get evalHistoryTitle =>
      isVietnamese ? 'Lịch Sử Đánh Giá Bản Thảo' : 'Manuscript Evaluation History';
  String get evalHistoryDesc => isVietnamese
      ? 'Bạn chưa có lượt kiểm tra bản thảo nào gần đây. Hãy bắt đầu bằng cách nộp bản thảo tại tab Kiểm tra Bản thảo.'
      : 'You have no recent manuscript checks. Start by submitting your draft in the Manuscript Checker tab.';
  String get checkManuscriptNow =>
      isVietnamese ? 'Kiểm tra Bản thảo ngay' : 'Check Manuscript Now';


  // Admin Navigation Menu
  String get navJournalsCenter =>
      isVietnamese ? 'Trung tâm Tạp chí' : 'Journals Center';
  String get navNlpProfiles =>
      isVietnamese ? 'Hồ sơ & Đối chuẩn NLP' : 'NLP Profiles & Benchmarks';
  String get navSystemTechnical =>
      isVietnamese ? 'Hệ thống & Kỹ thuật' : 'System & Technical';

  // Admin Header Breadcrumbs & Titles
  String get titleJournalsMining =>
      isVietnamese ? 'Trung Tâm Tạp Chí & Khai Phá' : 'Journals & Mining Hub';
  String get titleNlpProfiles =>
      isVietnamese ? 'Hồ Sơ & Đối Chuẩn NLP' : 'NLP Profiles & Benchmarks';
  String get titleSystemDebug =>
      isVietnamese ? 'Hệ Thống & Kỹ Thuật' : 'System & Engineering';
  String get titleAdminDashboard =>
      isVietnamese ? 'Bảng Điều Khiển Quản Trị' : 'Admin Dashboard';

  String get breadcrumbResearch => isVietnamese
      ? 'Nghiên cứu / Khai phá & Pipeline'
      : 'Research / Mining & Pipeline';
  String get breadcrumbAcademic => isVietnamese
      ? 'Học thuật / Hồ sơ phong cách & Corpus'
      : 'Academic / Style Profile & Corpus';
  String get breadcrumbSystem => isVietnamese
      ? 'Hệ thống / Giám sát & Cài đặt'
      : 'System / Monitoring & Settings';
  String get breadcrumbAdmin => isVietnamese ? 'Quản trị' : 'Administration';

  // Mining Trigger Modal
  String get triggerMiningTitle =>
      isVietnamese ? 'Kích hoạt Khai phá Tạp chí' : 'Trigger Journal Mining';
  String get triggerMiningDesc => isVietnamese
      ? 'Tạo tác vụ chạy nền để cào bài, bóc tách cấu trúc bằng Grobid và trích xuất hồ sơ phong cách.'
      : 'Create background task to scrape papers, parse structures with Grobid, and extract style profiles.';
  String get issnOrJournalName =>
      isVietnamese ? 'Mã ISSN hoặc Tên tạp chí' : 'ISSN code or Journal name';
  String get issnHint => isVietnamese
      ? 'Ví dụ: 0098-5589 hoặc IEEE TSE'
      : 'e.g. 0098-5589 or IEEE TSE';
  String get fromYear => isVietnamese ? 'Từ năm' : 'From year';
  String get toYear => isVietnamese ? 'Đến năm' : 'To year';
  String get targetPapersCount =>
      isVietnamese ? 'Số lượng bài báo mục tiêu' : 'Target papers count';
  String get papersUnit => isVietnamese ? 'bài' : 'papers';
  String get startAnalysis =>
      isVietnamese ? 'Bắt đầu phân tích' : 'Start analysis';
  String get analysisTriggeredSuccess => isVietnamese
      ? 'Đã kích hoạt tác vụ phân tích tạp chí thành công.'
      : 'Journal analysis task triggered successfully.';

  // Home Page
  String get journalDashboardTitle =>
      isVietnamese ? 'Bảng điều khiển Tạp chí' : 'Journal Dashboard';

  // Login Page
  String get signIn => isVietnamese ? 'Đăng nhập' : 'Sign in';
  String get loginTitlePart1 => 'HyperData';
  String get loginTitlePart2 => 'Lab';
  String get academicMiningBadge => isVietnamese
      ? 'Nền tảng Khai phá & Phân tích Học thuật'
      : 'Academic Mining & Analysis Platform';
  String get loginHeading => isVietnamese
      ? 'Hệ Thống Khai Phá & Theo Dõi Tạp Chí Khoa Học'
      : 'Scientific Journal Publication Trend Tracking';
  String get loginSubheading => isVietnamese
      ? 'Đăng nhập bằng tài khoản học thuật để truy cập dữ liệu đối chuẩn'
      : 'Sign in with your academic credentials to access benchmark datasets';
  String get ssoNote => isVietnamese
      ? 'Tài khoản được xác thực qua cổng Central SSO chung của HyperDataLab.'
      : 'Accounts are authenticated via HyperDataLab Central SSO portal.';
  String get securityStandard => isVietnamese
      ? 'Bảo mật tiêu chuẩn OpenID Connect & OAuth 2.0'
      : 'Secured with OpenID Connect & OAuth 2.0 standards';

  // User Info Page
  String get userInfoTitle =>
      isVietnamese ? 'Thông tin người dùng' : 'User Information';
  String get notSignedIn => isVietnamese ? 'Chưa đăng nhập.' : 'Not signed in.';
  String get signedInUser =>
      isVietnamese ? 'Người dùng đã đăng nhập' : 'Signed-in user';
  String get subjectLabel =>
      isVietnamese ? 'Mã định danh (Subject)' : 'Subject ID';
  String get emailLabel => isVietnamese ? 'Email' : 'Email';
  String get nameLabel => isVietnamese ? 'Họ và tên' : 'Name';

  // Student Manuscript Checker Page
  String get studentCheckerTitle => isVietnamese
      ? 'Kiểm Tra Bản Thảo Sinh Viên'
      : 'Student Manuscript Checker';
  String get newCheck => isVietnamese ? 'Kiểm tra mới' : 'New Check';

  String get studentCheckerSubtitle => isVietnamese
      ? 'Phân tích & Thẩm định Bản thảo Học thuật'
      : 'Academic Manuscript Analysis & Review';
  String get checkManuscriptAlignment => isVietnamese
      ? 'Kiểm tra độ căn chỉnh bản thảo'
      : 'Check Manuscript Alignment';
  String get checkManuscriptDesc => isVietnamese
      ? 'Đánh giá bản thảo của sinh viên dựa trên tiêu chuẩn phong cách của tạp chí mục tiêu và phát hiện các thủ pháp tu từ bị thiếu.'
      : 'Evaluate your student draft against target journal style standards and detect missing rhetorical moves.';
  String get targetJournalProfile => isVietnamese
      ? 'Hồ sơ tạp chí mục tiêu'
      : 'Target Journal Profile';
  String get selectFromCatalog => isVietnamese
      ? 'Chọn từ danh mục'
      : 'Select from catalog';
  String get enterCustomJournalId => isVietnamese
      ? 'Nhập ID tạp chí thủ công'
      : 'Enter custom journal ID';
  String get targetJournalIdHint => 'e.g. 550e8400-e29b-41d4-a716-446655440000';
  
  String get directTextDraft => isVietnamese
      ? 'Soạn thảo trực tiếp'
      : 'Direct Text / Draft';
  String get uploadManuscriptFile => isVietnamese
      ? 'Tải lên tập tin'
      : 'Upload File';
  String get pasteDraftHere => isVietnamese
      ? 'Dán hoặc soạn thảo văn bản học thuật tại đây...\n\nBao gồm các tiêu đề mục như "Introduction", "Methods", v.v. để chấm điểm chính xác.'
      : 'Paste or draft your academic manuscript here...\n\nInclude section headings like "Introduction", "Methods", etc. for accurate rhetorical move scoring.';
  String get loadSample => isVietnamese ? 'Tải bản thảo mẫu' : 'Load Sample Manuscript';
  String get clear => isVietnamese ? 'Xoá' : 'Clear';
  String get words => isVietnamese ? 'từ' : 'words';

  String get uploadTitle => isVietnamese
      ? 'Tải lên từ thiết bị'
      : 'Upload from your device';
  String get uploadDesc => isVietnamese
      ? 'Hỗ trợ: .txt, .pdf. Tối đa 15MB.'
      : 'Supported formats: .txt, .pdf. Max size: 15MB.';
  String get selectFile => isVietnamese ? 'Chọn tập tin' : 'Select File';
  String get changeFile => isVietnamese ? 'Đổi tập tin' : 'Change File';

  String get generateWarningsAndExemplars => isVietnamese
      ? 'Tạo các cảnh báo ngữ cảnh & ví dụ đã xuất bản'
      : 'Generate contextual warnings & published exemplars';
  String get checkAlignmentBtn => isVietnamese
      ? 'Phân tích mức độ phù hợp'
      : 'Check Alignment';
  String get pleaseChooseFile => isVietnamese
      ? 'Vui lòng chọn một tập tin (.pdf, .txt).'
      : 'Please choose a file (.pdf, .txt).';
  String get selectTargetJournal => isVietnamese
      ? 'Chọn Tạp Chí Mục Tiêu'
      : 'Select Target Journal';
  String get searchJournalDropdownHint => isVietnamese
      ? 'Tìm kiếm tên tạp chí, chuyên ngành...'
      : 'Search journal title, domain...';
  String noJournalsMatched(String query) => isVietnamese
      ? 'Không tìm thấy tạp chí nào khớp với "$query"'
      : 'No journals matched "$query"';
  String get includeValidatedExemplars => isVietnamese
      ? 'Bao gồm các câu mẫu trích dẫn từ kho ngữ liệu tạp chí'
      : 'Include validated exemplars from journal corpus';
  String get includeValidatedExemplarsDesc => isVietnamese
      ? 'Đính kèm các câu văn tham chiếu chuẩn mực và mã DOI thực tế vào các cảnh báo phong cách & thủ pháp tu từ.'
      : 'Attaches authentic reference sentences and DOIs to generated style & rhetorical move warnings.';
  String get readyForCheck => isVietnamese
      ? 'sẵn sàng để kiểm tra'
      : 'ready for check';
  String get returnToSubmissionForm => isVietnamese
      ? 'Quay lại biểu mẫu gửi bài'
      : 'Return to Submission Form';
  String get noManuscriptSectionsFound => isVietnamese
      ? 'Không tìm thấy các phần mục bản thảo'
      : 'No Manuscript Sections Found';
  String get submitAnotherDraft => isVietnamese
      ? 'Nộp bản thảo khác'
      : 'Submit Another Draft';
  String get checkAnotherManuscript => isVietnamese
      ? 'Kiểm tra bản thảo khác'
      : 'Check Another Manuscript';

  // Results & Diagnostics
  String get targetProfile => isVietnamese ? 'Hồ sơ mục tiêu' : 'Target Profile';
  String get outOf100 => isVietnamese ? 'TRÊN THANG 100' : 'OUT OF 100';
  String get suitabilityAssessment => isVietnamese ? 'Đánh giá mức độ phù hợp' : 'Suitability Assessment';
  String get diagnosticsAndWarnings => isVietnamese ? 'Chẩn đoán & Cảnh báo phong cách' : 'Diagnostics & Style Warnings';
  String get noWarningsDetected => isVietnamese ? 'Không phát hiện cảnh báo phong cách nào. Bản thảo rất phù hợp với tạp chí mục tiêu.' : 'No style warnings detected. Manuscript aligns well with target journal.';
  String get publishedExemplar => isVietnamese ? 'Câu mẫu tham chiếu (Tạp chí mục tiêu)' : 'Validated Journal Exemplar';
  String get missingResearchGapTitle => isVietnamese ? 'Phát hiện thiếu khoảng trống nghiên cứu' : 'Missing Research Gap Detected';
  String get sentenceLengthAnalysis => isVietnamese ? 'Phân tích độ dài câu' : 'Sentence Length Analysis';
  String get voicePersonAnalysis => isVietnamese ? 'Tỷ lệ giọng văn & Ngôi nhân xưng' : 'Voice & Person Comparison';
  String get stanceAnalysis => isVietnamese ? 'Dấu hiệu lập trường & Nhún nhường' : 'Stance & Epistemic Markers';
  String get sectionScoresTitle => isVietnamese ? 'Điểm căn chỉnh từng phần' : 'Section Alignment Scores';
  String get rhetoricalMovesTitle => isVietnamese ? 'Thủ pháp tu từ CARS' : 'Rhetorical Move Analysis';
  String get studentDraftMedian => isVietnamese ? 'Bản thảo của bạn' : 'Your draft';
  String get journalBenchmark => isVietnamese ? 'Chuẩn tạp chí' : 'Journal benchmark';
  String get passiveVoiceRate => isVietnamese ? 'Câu bị động' : 'Passive voice';
  String get weAuthorRate => isVietnamese ? 'Ngôi tác giả (We/Us)' : 'Author person (We)';
  String get hedgesRate => isVietnamese ? 'Từ cẩn trọng (Hedges)' : 'Hedges';
  String get boostersRate => isVietnamese ? 'Từ khẳng định (Boosters)' : 'Boosters';
  String get per1kWords => isVietnamese ? '/1k từ' : '/1k words';
  String get manuscriptMedian => isVietnamese ? 'TRUNG VỊ BẢN THẢO' : 'MANUSCRIPT MEDIAN';
  String get journalMedian => isVietnamese ? 'TRUNG VỊ TẠP CHÍ' : 'JOURNAL MEDIAN';
  String get expectedP10P90 => isVietnamese ? 'KHOẢNG P10 - P90' : 'EXPECTED P10 - P90';
  String sectionsCount(int count) => isVietnamese ? '$count phần mục' : '$count sections';

  String ratingLevelLabel(String level) {
    switch (level) {
      case 'EXCELLENT_ALIGNMENT':
        return isVietnamese ? 'Tương thích xuất sắc' : 'Excellent Alignment';
      case 'MODERATE_ALIGNMENT':
        return isVietnamese ? 'Tương thích vừa phải' : 'Moderate Alignment';
      case 'SIGNIFICANT_DEVIATION':
        return isVietnamese ? 'Độ lệch đáng kể' : 'Significant Deviation';
      default:
        return level.replaceAll('_', ' ');
    }
  }
  // Journals Catalog & Mining Hub (Tab 0)
  String get journalsCatalogTitle => isVietnamese
      ? 'Danh Mục & Trung Tâm Khai Phá Tạp Chí'
      : 'Journal Catalog & Mining Center';
  String get journalsCatalogSubtitle => isVietnamese
      ? 'Chọn tạp chí để kích hoạt khai phá 1-chạm (300 bài), giám sát bóc tách TEI XML và xem hồ sơ phong cách NLP tức thì.'
      : 'Select a journal to trigger 1-touch mining (300 papers), monitor TEI XML parsing, and view instant NLP style profiles.';
  String get reloadList =>
      isVietnamese ? 'Tải lại danh sách' : 'Reload list';
  String get addJournalManual =>
      isVietnamese ? 'Nhập tạp chí thủ công' : 'Add Journal Manually';
  String get searchJournalPlaceholder => isVietnamese
      ? 'Tìm theo tên, ISSN, nhà xuất bản...'
      : 'Search by title, ISSN, publisher...';
  String get filterAll => isVietnamese ? 'Tất cả' : 'All';
  String get filterConfigured =>
      isVietnamese ? 'Đã cấu hình' : 'Configured';
  String get filterUnconfigured => isVietnamese ? 'Chưa có' : 'Unconfigured';
  String get retry => isVietnamese ? 'Thử lại' : 'Retry';
  String get miningCenterTitle => isVietnamese
      ? 'Trung Tâm Khai Phá & Hồ Sơ Phong Cách'
      : 'Mining & Style Profile Center';
  String get miningCenterDesc => isVietnamese
      ? 'Chọn một tạp chí từ danh sách bên trái để kích hoạt khai phá 1-chạm (300 bài), theo dõi chu trình 4 giai đoạn và xem hồ sơ phong cách NLP tức thì.'
      : 'Select a journal from the left list to trigger 1-touch mining (300 papers), track 4-stage pipeline, and view instant NLP style profiles.';
  String get badge1Touch => isVietnamese
      ? '1-Chạm Khai phá 300 bài'
      : '1-Touch 300 Papers Mining';
  String get badgeTeiXml => isVietnamese
      ? 'Bóc tách TEI XML & MinIO'
      : 'TEI XML & MinIO Parsing';
  String get badgeNlpStyle => isVietnamese
      ? 'Phân tích Phong cách NLP'
      : 'NLP Style Profiling';
  String get configured => isVietnamese ? 'Đã cấu hình' : 'Configured';
  String get notConfigured =>
      isVietnamese ? 'Chưa cấu hình' : 'Not configured';

  // Style & Corpus Unified Workspace (Tab 1)
  String get tabNlpProfilesTitle => isVietnamese
      ? 'Hồ Sơ Phong Cách NLP & CARS Moves'
      : 'NLP Style Profiles & CARS Moves';
  String get tabNlpProfilesSubtitle => isVietnamese
      ? 'Hyland Stance, CARS Rhetorical Moves, Phân phối câu'
      : 'Hyland Stance, CARS Rhetorical Moves, Sentence distribution';
  String get tabCorpusSnapshotsTitle => isVietnamese
      ? 'Kho Corpus Snapshots & Dữ Liệu'
      : 'Corpus Snapshots & Datasets';
  String get tabCorpusSnapshotsSubtitle => isVietnamese
      ? 'Reference Corpus, Phiên bản kho bài, Tải JSON/CSV'
      : 'Reference Corpus, Paper snapshots, JSON/CSV exports';

  // System & Debug Unified Workspace (Tab 2)
  String get tabJobMonitorTitle => isVietnamese
      ? 'Nhật Ký Tác Vụ & Debug'
      : 'Job Monitor & Debug Logs';
  String get tabJobMonitorSubtitle => isVietnamese
      ? 'Giám sát Celery, logs bóc tách, retry bài lỗi'
      : 'Celery task monitor, parsing logs, failed paper retry';
  String get tabServiceSettingsTitle =>
      isVietnamese ? 'Cài Đặt Dịch Vụ' : 'Service Settings';
  String get tabServiceSettingsSubtitle => isVietnamese
      ? 'MinIO Storage, GROBID Server, OpenAlex Pool'
      : 'MinIO Storage, GROBID Server, OpenAlex Pool';
  String get tabUserManagementTitle =>
      isVietnamese ? 'Quản Lý Người Dùng' : 'User Management';
  String get tabUserManagementSubtitle => isVietnamese
      ? 'Phân quyền Admin, Researcher, Quota API'
      : 'Admin & Researcher roles, API quota controls';

  // Snapshots View
  String get snapshotsTitle => isVietnamese
      ? 'Kho Lưu Trữ Corpus Snapshots (Bất Biến)'
      : 'Corpus Snapshots Archive (Immutable)';
  String get snapshotsSubtitle => isVietnamese
      ? 'Tập hợp bài báo đã qua bóc tách cấu trúc bằng Grobid và làm sạch, được đóng băng phục vụ đối chiếu phong cách.'
      : 'Frozen collections of cleaned and Grobid-parsed papers for style profile benchmarking.';
  String get reloadSnapshots =>
      isVietnamese ? 'Tải lại danh sách snapshot' : 'Reload snapshots';

  // Profiles Review View
  String get profilesReviewTitle => isVietnamese
      ? 'Kiểm Duyệt Hồ Sơ Phong Cách Tạp Chí'
      : 'Journal Style Profile Review';
  String get profilesReviewSubtitle => isVietnamese
      ? 'So sánh và đánh giá phong cách học thuật qua biểu đồ Radar đa chiều và bảng chỉ số chi tiết.'
      : 'Compare and evaluate academic writing styles via multidimensional radar charts and detailed metrics.';
  String get reloadProfiles =>
      isVietnamese ? 'Tải lại hồ sơ' : 'Reload profiles';

  // Job Monitor View
  String get jobMonitorTitle =>
      isVietnamese ? 'Giám Sát Tác Vụ Khai Phá' : 'Mining Task Monitor';
  String get jobMonitorSubtitle => isVietnamese
      ? 'Giám sát trạng thái các tác vụ khai phá dữ liệu, tra cứu nhật ký và xử lý lại bài lỗi.'
      : 'Monitor data mining tasks, inspect logs, and retry failed paper pipelines.';
  String get reloadJobs =>
      isVietnamese ? 'Cập nhật trạng thái tác vụ' : 'Refresh task status';

  // Users View
  String get usersViewTitle =>
      isVietnamese ? 'Quản Lý Tài Khoản Người Dùng' : 'User Account Management';
  String get usersViewSubtitle => isVietnamese
      ? 'Cấp phát và quản lý quyền truy cập cho Giảng viên (khảo sát tạp chí) và Sinh viên (kiểm tra bản thảo).'
      : 'Provision and manage access for Lecturers (journal surveying) and Students (manuscript checking).';
  String get reloadUsers =>
      isVietnamese ? 'Tải lại danh sách tài khoản' : 'Reload user list';

  // Statuses
  String get statusRunning => isVietnamese ? 'Đang xử lý' : 'Processing';
  String get statusPending => isVietnamese ? 'Hàng đợi' : 'Queued';
  String get statusCompleted => isVietnamese ? 'Hoàn thành' : 'Completed';
  String get statusFailed => isVietnamese ? 'Thất bại' : 'Failed';
  String get statusCancelled => isVietnamese ? 'Đã hủy' : 'Cancelled';

  // Job Monitor Dialogs & Actions
  String get confirmCancelTitle =>
      isVietnamese ? 'Xác nhận hủy tác vụ' : 'Confirm Cancel Task';
  String confirmCancelDesc(String title) => isVietnamese
      ? 'Bạn có chắc chắn muốn dừng tác vụ khai phá của tạp chí "$title" không? Quá trình tải bài báo sẽ dừng lại.'
      : 'Are you sure you want to stop the mining task for "$title"? The paper download process will be stopped.';
  String get dismiss => isVietnamese ? 'Bỏ qua' : 'Dismiss';
  String get stopTask => isVietnamese ? 'Dừng tác vụ' : 'Stop Task';
  String get cancelJob => isVietnamese ? 'Hủy tác vụ' : 'Cancel Job';
  String get deleteJob => isVietnamese ? 'Xóa tác vụ' : 'Delete Job';
  String get jobIdLabel => isVietnamese ? 'Mã Job' : 'Job ID';
  String retryFailedArticles(int count) => isVietnamese
      ? 'Thử lại $count bài lỗi'
      : 'Retry $count failed';
  String get totalTarget => isVietnamese ? 'Tổng mục tiêu' : 'Target Total';
  String get downloadedPdf => isVietnamese ? 'Đã tải PDF' : 'Downloaded PDF';
  String get parsedTeiXml => isVietnamese ? 'Parse TEI XML' : 'Parsed TEI XML';
  String get normalizedDb => isVietnamese ? 'Chuẩn hóa DB' : 'Normalized DB';
  String get failedArticles => isVietnamese ? 'Bài lỗi' : 'Failed Articles';
  String get articleDetails =>
      isVietnamese ? 'Chi tiết từng bài báo' : 'Article Details';
  String get papers => isVietnamese ? 'bài báo' : 'papers';
  String get noJobsFound => isVietnamese
      ? 'Không có tác vụ nào trong trạng thái đã chọn.'
      : 'No tasks found for the selected status.';

  // Pipeline Stages
  String get stageCompleted => isVietnamese
      ? 'Giai đoạn 6/6: Đóng gói Snapshot & Profile hoàn tất'
      : 'Stage 6/6: Snapshot & Profile packaging complete';
  String get stageCancelled => isVietnamese
      ? 'Tác vụ đã dừng lại (Đã hủy bởi quản trị viên)'
      : 'Task stopped (Cancelled by administrator)';
  String get stage1 => isVietnamese
      ? 'Giai đoạn 1/6: Thu thập metadata bài báo (OpenAlex)'
      : 'Stage 1/6: Harvest article metadata (OpenAlex)';
  String get stage2 => isVietnamese
      ? 'Giai đoạn 2/6: Tải toàn văn PDF từ nguồn Open Access'
      : 'Stage 2/6: Download full-text PDF from Open Access';
  String get stage3 => isVietnamese
      ? 'Giai đoạn 3/6: Grobid engine parsing TEI XML'
      : 'Stage 3/6: Grobid engine parsing TEI XML';
  String get stage4 => isVietnamese
      ? 'Giai đoạn 4/6: Chuẩn hóa Schema & Checksum SHA-256'
      : 'Stage 4/6: Normalize Schema & Checksum SHA-256';
  String get stage5 => isVietnamese
      ? 'Giai đoạn 5/6: Trích xuất Stance & Rhetorical Moves NLP'
      : 'Stage 5/6: Extract NLP Stance & Rhetorical Moves';
  String get stage6 => isVietnamese
      ? 'Giai đoạn 6/6: Đóng gói Corpus Snapshot & Hồ sơ'
      : 'Stage 6/6: Package Corpus Snapshot & Profiles';

  // Settings View
  String get settingsTitle => isVietnamese
      ? 'Cài Đặt Hệ Thống & Tham Số Vận Hành'
      : 'System Settings & Operational Parameters';
  String get settingsSubtitle => isVietnamese
      ? 'Quản trị bảo mật dữ liệu bản thảo, quy tắc lưu trữ tạm thời và giới hạn tốc độ cào bài học thuật.'
      : 'Manage manuscript privacy, temporary retention rules, and academic crawling rate limits.';
  String get ssoTitle => isVietnamese
      ? 'Xác Thực Tập Trung Phòng Thí Nghiệm (Central SSO)'
      : 'Central Laboratory Authentication (Central SSO)';
  String get ssoConnected => isVietnamese
      ? 'Đang kết nối phiên OIDC SSO'
      : 'Connected to OIDC SSO session';
  String get ssoProvider => isVietnamese
      ? 'Nhà cung cấp danh tính phòng lab (Keycloak OIDC) • Client ID: researchpulse-ecosystem'
      : 'Lab identity provider (Keycloak OIDC) • Client ID: researchpulse-ecosystem';
  String get ssoActive => isVietnamese ? 'HOẠT ĐỘNG' : 'ACTIVE';
  String get privacyTitle => isVietnamese
      ? 'Bảo Mật Bản Thảo & Chính Sách Lưu Trữ'
      : 'Manuscript Privacy & Retention Policy';
  String get privacyDesc => isVietnamese
      ? 'Bản thảo của tác giả chỉ là các bản nháp tạm thời phục vụ chấm điểm và không bao giờ bị gộp vào kho Corpus vĩnh viễn.'
      : 'Author manuscripts are only temporary drafts for evaluation and are never merged permanently into the Corpus.';
  String get autoPurgeTitle => isVietnamese
      ? 'Tự động dọn dẹp file nháp tạm thời'
      : 'Auto-purge temporary draft files';
  String autoPurgeSubtitle(int days) => isVietnamese
      ? 'Tự động xóa sạch file bản thảo PDF/DOCX sau $days ngày (tối đa 30 ngày)'
      : 'Automatically purge manuscript PDF/DOCX files after $days days (max 30 days)';
  String get politePoolTitle => isVietnamese
      ? 'Cơ Chế Cào Bài Lịch Sự (Polite Pool)'
      : 'Polite Crawler Mechanism (Polite Pool)';
  String get politePoolDesc => isVietnamese
      ? 'Gắn email của phòng lab vào HTTP header khi gửi request đến OpenAlex / CrossRef để tránh lỗi chặn IP (HTTP 429).'
      : 'Attach lab email to HTTP headers when querying OpenAlex / CrossRef to avoid IP blocks (HTTP 429).';
  String get politePoolEnable => isVietnamese
      ? 'Kích hoạt Polite Pool cho OpenAlex'
      : 'Enable Polite Pool for OpenAlex';
  String politePoolSubtitle(int rate) => isVietnamese
      ? 'Giới hạn tối đa $rate requests / giây'
      : 'Limit to maximum $rate requests / second';
  String get saveAllSettings =>
      isVietnamese ? 'Lưu toàn bộ cài đặt' : 'Save All Settings';
  String get settingsSaved => isVietnamese
      ? 'Đã lưu các thiết lập hệ thống thành công.'
      : 'System settings saved successfully.';

  // Snapshots Table
  String get viewSnapshotProgress => isVietnamese
      ? 'Xem tiến trình tạo Snapshot'
      : 'View Snapshot Creation Progress';
  String get searchSnapshotHint => isVietnamese
      ? 'Tìm kiếm theo tên tạp chí, mã Snapshot, SHA-256 Hash...'
      : 'Search by journal name, snapshot ID, SHA-256 Hash...';
  String get colJournalSnapshot => isVietnamese
      ? 'TẠP CHÍ & MÃ SNAPSHOT'
      : 'JOURNAL & SNAPSHOT ID';
  String get colYearRange =>
      isVietnamese ? 'GIAI ĐOẠN NĂM' : 'YEAR RANGE';
  String get colArticleCount =>
      isVietnamese ? 'SỐ LƯỢNG BÀI' : 'ARTICLE COUNT';
  String get colHash => isVietnamese
      ? 'MÃ HASH BẢO MẬT (SHA-256)'
      : 'SECURITY HASH (SHA-256)';
  String get colFrozenDate =>
      isVietnamese ? 'NGÀY ĐÓNG BĂNG' : 'FROZEN DATE';
  String get colActions => isVietnamese ? 'THAO TÁC' : 'ACTIONS';

  // Profiles Review
  String get publishStandard =>
      isVietnamese ? 'Xuất bản Tiêu chuẩn' : 'Publish Standard';
  String get publishSuccess => isVietnamese
      ? 'Hồ sơ phong cách đã được xuất bản làm tiêu chuẩn đối chiếu cho sinh viên.'
      : 'Style profile published as benchmark for students.';
  String get compareMaxLimit => isVietnamese
      ? 'Chỉ có thể so sánh tối đa 3 tạp chí cùng một lúc.'
      : 'Can only compare up to 3 journals simultaneously.';

  // Users View
  String get roleBadgeStudent =>
      isVietnamese ? 'Vai trò Student' : 'Student Role';
  String get roleBadgeLecturer =>
      isVietnamese ? 'Vai trò Lecturer' : 'Lecturer Role';
  String get createStudentTitle =>
      isVietnamese ? 'Tạo tài khoản Sinh viên' : 'Create Student Account';
  String get createStudentSubtitle => isVietnamese
      ? 'Cấp quyền truy cập module kiểm tra bản thảo bài báo (.docx / .pdf)'
      : 'Grant access to manuscript checker (.docx / .pdf)';
  String get createLecturerTitle =>
      isVietnamese ? 'Tạo tài khoản Giảng viên' : 'Create Lecturer Account';
  String get createLecturerSubtitle => isVietnamese
      ? 'Cấp quyền xem hồ sơ phong cách, cấu hình tạp chí và xuất dữ liệu'
      : 'Grant access to style profiles, journal configs, and data exports';
  String get initiateNow =>
      isVietnamese ? 'Khởi tạo ngay' : 'Initialize now';
  String get colFullName => isVietnamese ? 'HỌ VÀ TÊN' : 'FULL NAME';
  String get colAccountEmail =>
      isVietnamese ? 'EMAIL TÀI KHOẢN' : 'ACCOUNT EMAIL';
  String get colRole => isVietnamese ? 'VAI TRÒ' : 'ROLE';
  String get colStatus => isVietnamese ? 'TRẠNG THÁI' : 'STATUS';
  String get roleAdminLabel =>
      isVietnamese ? 'Quản trị viên (Admin)' : 'Admin';
  String get roleLecturerLabel =>
      isVietnamese ? 'Giảng viên (Lecturer)' : 'Lecturer';
  String get roleStudentLabel =>
      isVietnamese ? 'Sinh viên (Student)' : 'Student';
  String get activeStatus => isVietnamese ? 'Hoạt động' : 'Active';
  String get inactiveStatus => isVietnamese ? 'Tạm khóa' : 'Inactive';
  String get saveChanges => isVietnamese ? 'Lưu thay đổi' : 'Save changes';
  String get cancelChanges => isVietnamese ? 'Hủy thay đổi' : 'Cancel changes';
  String get confirmDeleteUserTitle =>
      isVietnamese ? 'Xác nhận xóa tài khoản' : 'Confirm Account Deletion';
  String get confirmDeleteUserDesc => isVietnamese
      ? 'Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản sau?'
      : 'Are you sure you want to permanently delete the following account?';
  String get confirmDeleteUserWarning => isVietnamese
      ? 'Hành động này không thể hoàn tác. Mọi quyền truy cập của người dùng này sẽ bị hủy bỏ ngay lập tức.'
      : 'This action cannot be undone. All access permissions for this user will be revoked immediately.';
  String get deletePermanently =>
      isVietnamese ? 'Xóa vĩnh viễn' : 'Delete permanently';
  String get noUsersFound => isVietnamese
      ? 'Chưa có tài khoản người dùng nào được tạo.'
      : 'No user accounts have been created yet.';
  String get cannotDeleteLastAdmin => isVietnamese
      ? 'Không thể xóa Quản trị viên duy nhất của hệ thống.'
      : 'Cannot delete the only Administrator of the system.';
  String get cannotDemoteLastAdmin => isVietnamese
      ? 'Không thể khóa hoặc hạ quyền Quản trị viên duy nhất của hệ thống.'
      : 'Cannot lock or demote the only Administrator of the system.';
  String get joined => isVietnamese ? 'Tham gia' : 'Joined';
  String get deleteAccountTooltip =>
      isVietnamese ? 'Xóa tài khoản' : 'Delete account';

  // Overview View
  String get dataMinerCoordination => isVietnamese ? 'Trung tâm điều phối khai phá dữ liệu' : 'Data Mining Coordination Center';
  String get pipelineReady => isVietnamese ? 'Pipeline Sẵn sàng (Live API)' : 'Pipeline Ready (Live API)';
  String get systemSyncing => isVietnamese ? 'Hệ thống đang đồng bộ' : 'System is syncing';
  String get refreshMetrics => isVietnamese ? 'Làm mới số liệu' : 'Refresh metrics';
  String get journalMiningOverview => isVietnamese ? 'Tổng Quan Chu Trình Khai Phá Tạp Chí' : 'Journal Mining Pipeline Overview';
  String get dataPipelineFlow => isVietnamese ? 'Chu Trình Khai Phá Tuyến Tính (Data Pipeline Flow)' : 'Linear Data Mining Pipeline Flow';
  String get pipelineDescription => isVietnamese ? 'Điều phối toàn trình: Thu thập metadata tạp chí ➔ Cấu hình trích xuất ➔ Bóc tách cấu trúc bằng Grobid ➔ Đóng băng Corpus Snapshot ➔ Xây dựng hồ sơ phong cách.' : 'End-to-end coordination: Fetch journal metadata ➔ Extraction config ➔ Structure parsing with Grobid ➔ Freeze Corpus Snapshot ➔ Build style profile.';
  String get clickPhaseToNavigate => isVietnamese ? 'Bấm vào từng giai đoạn để chuyển ngay tới giao diện quản lý tương ứng.' : 'Click each phase to navigate to the respective management interface.';
  String get startNewAnalysis => isVietnamese ? 'Kích hoạt phân tích mới' : 'Start new analysis';
  String get registerNewJournal => isVietnamese ? 'Đăng ký tạp chí mới' : 'Register new journal';
  String get viewJobDetails => isVietnamese ? 'Theo dõi chi tiết Job' : 'View job details';
  String get trackedJournals => isVietnamese ? 'Tạp chí theo dõi' : 'Tracked Journals';
  String get savedInDatabase => isVietnamese ? 'Đã lưu trong CSDL' : 'Saved in Database';
  String get jobsRunningTotal => isVietnamese ? 'Tác vụ đang chạy / Tổng' : 'Running Jobs / Total';
  String get frozenDatasets => isVietnamese ? 'Bộ dữ liệu bất biến' : 'Frozen Datasets';
  String get userAccounts => isVietnamese ? 'Tài khoản người dùng' : 'User Accounts';
  String get lecturersAndStudents => isVietnamese ? 'Giảng viên & Sinh viên' : 'Lecturers & Students';
  String get categoryAndConfig => isVietnamese ? 'Danh mục & Cấu hình' : 'Catalog & Configurations';
  String journalsAndConfigsCount(int journals, int configs) => isVietnamese ? '$journals tạp chí • $configs cấu hình' : '$journals journals • $configs configurations';
  String get systemReady => isVietnamese ? 'Sẵn sàng' : 'Ready';
  String runningJobsCountLabel(int count) => isVietnamese ? '$count job đang xử lý' : '$count jobs processing';
  String get running => isVietnamese ? 'Đang chạy' : 'Running';
  String snapshotsCountLabel(int count) => isVietnamese ? '$count bộ bất biến' : '$count frozen datasets';
  String get secured => isVietnamese ? 'Bảo mật' : 'Secured';
  String get styleProfiles => isVietnamese ? 'Hồ sơ phong cách' : 'Style Profiles';
  String get recentMiningJobs => isVietnamese ? 'Tác Vụ Khai Phá Gần Đây' : 'Recent Mining Jobs';
  String get viewAll => isVietnamese ? 'Xem tất cả' : 'View all';
  String get noRecentJobs => isVietnamese ? 'Chưa có tác vụ nào được kích hoạt gần đây.' : 'No mining jobs have been started recently.';
  String get systemServiceStatus => isVietnamese ? 'Trạng Thái Dịch Vụ Hệ Thống' : 'System Service Status';
  String get configSystemParams => isVietnamese ? 'Cấu hình tham số hệ thống' : 'Configure system parameters';
  String get miningJournal => isVietnamese ? 'Tạp chí khai phá' : 'Mining Journal';
  String get statusProcessing => isVietnamese ? 'Đang xử lý' : 'Processing';
  
  // Job Monitor View
  String get retrySuccess => isVietnamese ? 'Thử lại thành công' : 'Retry successful';
  String retriedArticles(int retried) => isVietnamese ? 'Đã gửi lại $retried bài báo vào hàng đợi xử lý.' : 'Successfully requeued $retried articles for processing.';
  String get retryFailed => isVietnamese ? 'Thử lại thất bại' : 'Retry failed';
  String get jobCancelledSuccess => isVietnamese ? 'Đã hủy tác vụ thành công.' : 'Job cancelled successfully.';
  String get jobCancelledTitle => isVietnamese ? 'Đã hủy tác vụ' : 'Job Cancelled';
  String get jobCancelFailed => isVietnamese ? 'Không thể hủy tác vụ. Vui lòng thử lại.' : 'Failed to cancel job. Please try again.';
  String get jobCancelFailedTitle => isVietnamese ? 'Hủy thất bại' : 'Cancellation Failed';
  String get jobDeletedSuccess => isVietnamese ? 'Đã xóa tác vụ thành công khỏi hệ thống.' : 'Job successfully removed from the system.';
  String get jobDeletedTitle => isVietnamese ? 'Xóa tác vụ thành công' : 'Job Deleted';
  String get jobDeleteFailed => isVietnamese ? 'Không thể xóa tác vụ. Vui lòng thử lại.' : 'Failed to delete job. Please try again.';
  String get jobDeleteFailedTitle => isVietnamese ? 'Xóa thất bại' : 'Deletion Failed';
  String articleDetailsFor(String title) => isVietnamese ? 'Chi tiết bài báo: $title' : 'Article Details: $title';
  String jobMetricsSummary(String id, int total) => isVietnamese ? 'Mã Job: $id • Tổng $total bài' : 'Job ID: $id • Total $total articles';
  String get filterNormalizedTEI => isVietnamese ? 'Đã chuẩn hóa TEI' : 'Normalized TEI';
  String get filterFetchedPDF => isVietnamese ? 'Đã tải PDF' : 'Fetched PDF';
  String get filterError => isVietnamese ? 'Lỗi' : 'Error';
  String get errorLoadingArticles => isVietnamese ? 'Lỗi tải danh sách bài báo: ' : 'Error loading articles: ';
  String get noArticlesInJob => isVietnamese ? 'Chưa có bài báo nào được ghi nhận trong job này.' : 'No articles have been recorded in this job yet.';
  String get noArticlesWithStatus => isVietnamese ? 'Không có bài báo nào với trạng thái này.' : 'No articles found with this status.';
  String get untitledArticle => isVietnamese ? 'Bài báo không tiêu đề' : 'Untitled article';
  String get yearLabel => isVietnamese ? 'Năm: ' : 'Year: ';
  String retryFailedArticlesBtn(int failed) => isVietnamese ? 'Thử lại $failed bài lỗi' : 'Retry $failed failed articles';

  String get unknown => isVietnamese ? 'Chưa rõ' : 'Unknown';
  String get viewProfile => isVietnamese ? 'Xem hồ sơ' : 'View Profile';
  String get successTitle => isVietnamese ? 'Kích hoạt thành công' : 'Activated Successfully';
  String get configSavedTitle => isVietnamese ? 'Đã lưu cấu hình' : 'Configuration Saved';


  // Style Comparison & Profiles
  String get comparisonJournals => isVietnamese ? 'Tạp chí so sánh' : 'Comparison Journals';
  String comparisonJournalsCount(int count) => isVietnamese ? 'Tạp chí so sánh ($count/3):' : 'Comparison Journals ($count/3):';
  String get singleViewHint => isVietnamese ? 'Đang xem đơn lẻ • Bấm (+) để thêm tạp chí so sánh' : 'Single view • Click (+) to add comparison journal';
  String comparingJournalsParallel(int count) => isVietnamese ? 'Đang so sánh $count tạp chí song song' : 'Comparing $count journals in parallel';
  String get addComparisonJournalTooltip => isVietnamese ? 'Thêm tạp chí so sánh (tối đa 3)' : 'Add comparison journal (max 3)';
  String journalIndex(int idx) => isVietnamese ? 'Tạp chí $idx' : 'Journal $idx';
  String get noProfilesExtracted => isVietnamese ? 'Chưa có hồ sơ phong cách nào được trích xuất. Vui lòng chạy phân tích một tạp chí trước.' : 'No style profiles extracted yet. Please run mining on a journal first.';
  String get publishSuccessTitle => isVietnamese ? 'Xuất bản thành công' : 'Published successfully';
  
  // Comparison Overview Card
  String get comparisonOverviewTitle => isVietnamese ? 'Tổng Quan Chỉ Số Đối Chiếu' : 'Comparison Metrics Overview';
  String get metricSentenceLength => isVietnamese ? 'Độ dài câu' : 'Sentence Length';
  String get metricLexicalDensity => isVietnamese ? 'Mật độ từ vựng' : 'Lexical Density';
  String get metricHedges => isVietnamese ? 'Từ rào đón' : 'Hedges';
  String get metricBoosters => isVietnamese ? 'Từ khẳng định' : 'Boosters';
  String get metricNeutralStance => isVietnamese ? 'Lập trường trung lập' : 'Neutral Stance';
  String get metricCarsCoverage => isVietnamese ? 'Độ phủ cấu trúc CARS' : 'CARS Coverage';
  String get unitWordsPerSentence => isVietnamese ? 'từ/câu' : 'words/sent.';
  String get unitPer1kWords => isVietnamese ? '/1k từ' : '/1k words';
  String get unitWords => isVietnamese ? 'từ' : 'words';

  // Key Differences Panel
  String get keyDifferencesTitle => isVietnamese ? 'Sai Biệt Nổi Bật' : 'Key Differences';
  String get top3Differences => isVietnamese ? 'Top 3 Khác Biệt Lớn Nhất' : 'Top 3 Key Differences';
  String get styleDifferencesSubtitle => isVietnamese ? 'Các phương diện phong cách có độ lệch lớn nhất giữa các tạp chí:' : 'Style dimensions with largest deviations between journals:';
  String get collapse => isVietnamese ? 'Thu gọn' : 'Collapse';
  String get explain => isVietnamese ? 'Giải thích' : 'Explain';
  String styleFeatureTitle(String name) => isVietnamese ? 'Đặc Trưng Phong Cách: $name' : 'Style Characteristics: $name';
  String get sentenceComplexity => isVietnamese ? 'Độ phức hợp câu văn' : 'Sentence Complexity';
  String get academicTone => isVietnamese ? 'Giọng điệu học thuật' : 'Academic Tone';
  String get objectiveNeutral => isVietnamese ? 'Khách quan & Trung lập' : 'Objective & Neutral';
  String get lexicalDensityLabel => isVietnamese ? 'Mật độ từ vựng' : 'Lexical Density';
  String get sentenceLengthLabel => isVietnamese ? 'Độ dài câu' : 'Sentence Length';
  String get boostersLabel => isVietnamese ? 'Mức độ khẳng định' : 'Boosters';
  String get hedgingLabel => isVietnamese ? 'Mức độ rào đón' : 'Hedging';
  String get neutralStanceLabel => isVietnamese ? 'Lập trường trung lập' : 'Neutral Stance';
  String higherByLabel(String name, String diff) => isVietnamese ? '$name cao hơn $diff' : '$name higher by $diff';

  // Metric Differences Dumbbell Chart
  String get metricDifferencesTitle => isVietnamese ? 'Chênh Lệch Chỉ Số' : 'Metric Differences';
  String get sortLabel => isVietnamese ? 'Sắp xếp:' : 'Sort:';
  String get largestSort => isVietnamese ? 'Lớn nhất' : 'Largest';
  String get defaultSort => isVietnamese ? 'Mặc định' : 'Default';

  // Sentence Distribution
  String get sentenceDistributionTitle => isVietnamese ? 'Phân Bố Độ Dài Câu (P10 - P50 - P90)' : 'Sentence Length Distribution (P10 - P50 - P90)';
  String get sentenceDistributionSubtitle => isVietnamese ? 'Phạm vi độ dài câu từ phân vị 10% đến 90% (P50 là trung vị):' : 'Sentence length range from 10th to 90th percentile (P50 is median):';

  // Stance Distribution
  String get stanceDistributionTitle => isVietnamese ? 'Phân Bố Lập Trường' : 'Stance Distribution';
  String get stanceDistributionSubtitle => isVietnamese ? 'Tỷ lệ phân loại lập trường các câu luận điểm trong bài báo (100% stacked):' : 'Distribution of stances across argumentative sentences (100% stacked):';
  String get stanceNeutral => isVietnamese ? 'Trung lập' : 'Neutral';
  String get stanceSupport => isVietnamese ? 'Ủng hộ' : 'Support';
  String get stanceRefute => isVietnamese ? 'Phản bác' : 'Refute';

  // Style Difference Matrix
  String get styleMatrixTitle => isVietnamese ? 'Ma Trận Sai Biệt Phong Cách' : 'Style Difference Matrix';
  String get styleMatrixSubtitle => isVietnamese ? 'Bảng đối chiếu cường độ các thuộc tính (đậm nhạt thể hiện mức độ so sánh tương đối):' : 'Comparison matrix of style attribute intensities (shading shows relative scale):';
  String get referenceMetric => isVietnamese ? 'Chỉ số đối chiếu' : 'Reference Metric';

  // Style Fingerprint & Radar Chart
  String get styleFingerprintTitle => isVietnamese ? 'Dấu Ấn Phong Cách' : 'Style Fingerprint';
  String get multiStyleFingerprintTitle => isVietnamese ? 'Dấu Ấn Phong Cách Đa Chiều' : 'Multidimensional Style Fingerprint';
  String get styleFingerprintSubtitle => isVietnamese ? 'Chuẩn hóa 6 trục 0–100% để nhận diện hình thái tổng thể văn phong học thuật:' : 'Normalized 6-axis scale (0–100%) identifying academic writing style morphology:';
  String get parallelCoordinates => isVietnamese ? 'Tọa độ song song' : 'Parallel Coordinates';
  String get radarCoordinates => isVietnamese ? 'Biểu đồ Radar' : 'Radar Chart';
  String get radarAxisSentenceLength => isVietnamese ? 'Độ dài câu' : 'Sentence Length';
  String get radarAxisLexicalDensity => isVietnamese ? 'Mật độ từ vựng' : 'Lexical Density';
  String get radarAxisHedges => isVietnamese ? 'Rào đón (Hedges)' : 'Hedging';
  String get radarAxisBoosters => isVietnamese ? 'Khẳng định (Boosters)' : 'Boosters';
  String get radarAxisNeutral => isVietnamese ? 'Trung lập (Stance)' : 'Neutral Stance';
  String get radarAxisCars => isVietnamese ? 'Khung CARS' : 'CARS Moves';
  String rawSentenceLength(String len) => isVietnamese ? '$len từ/câu' : '$len words/sent.';
  String rawLexicalDensity(String pct) => isVietnamese ? '$pct% mật độ' : '$pct% density';
  String rawPer1k(String val) => isVietnamese ? '$val/1k từ' : '$val/1k words';
  String rawNeutral(String pct) => isVietnamese ? '$pct% trung tính' : '$pct% neutral';
  String rawCars(String pct) => isVietnamese ? '$pct% hoàn thiện' : '$pct% complete';
  String get selectJournalsForRadar => isVietnamese ? 'Chọn tạp chí để hiển thị biểu đồ Radar' : 'Select journals to display Radar chart';
  String get measuredLabel => isVietnamese ? 'Đo được: ' : 'Measured: ';

  // CARS Moves Chart
  String get carsMovesChartTitle => isVietnamese ? 'Cấu Trúc Tu Từ — Mô Hình CARS Moves' : 'Rhetorical Structure — CARS Moves';
  String get carsMovesSubtitle => isVietnamese ? 'Độ phủ các bước tu từ trong phần Mở đầu (Introduction) giữa các tạp chí:' : 'Coverage of rhetorical moves in the Introduction section across journals:';
  String get move1Title => isVietnamese ? 'Move 1: Xác lập lãnh địa' : 'Move 1: Establishing a Territory';
  String get move1Sub => isVietnamese ? 'Xác lập lãnh địa nghiên cứu (tầm quan trọng, bối cảnh đề tài)' : 'Establishing research territory (centrality, background context)';
  String get move2Title => isVietnamese ? 'Move 2: Tạo khoảng trống' : 'Move 2: Establishing a Niche';
  String get move2Sub => isVietnamese ? 'Tạo khoảng trống nghiên cứu (chỉ ra hạn chế, mâu thuẫn tri thức)' : 'Creating research niche (limitations, knowledge gap)';
  String get move3Title => isVietnamese ? 'Move 3: Chiếm lĩnh khoảng trống' : 'Move 3: Occupying the Niche';
  String get move3Sub => isVietnamese ? 'Chiếm lĩnh khoảng trống (mục tiêu nghiên cứu, đóng góp bài báo)' : 'Occupying the niche (research aims, new contributions)';

  // Writing Examples Section
  String get writingExamplesTitle => isVietnamese ? 'Minh Chứng Câu Văn Mẫu Mở Đầu' : 'Exemplary Opening Sentences';
  String get writingExamplesSubtitle => isVietnamese ? 'Trích dẫn câu mở đầu điển hình phản ánh phong cách học thuật từ các bài báo tiêu biểu:' : 'Exemplary opening sentences reflecting academic style from representative papers:';
  String get copySentenceTooltip => isVietnamese ? 'Sao chép câu văn' : 'Copy sentence';
  String get sentenceCopied => isVietnamese ? 'Đã sao chép câu văn mẫu vào clipboard.' : 'Exemplary sentence copied to clipboard.';

  // Journals & Configurations
  String get defaultDomainCs => isVietnamese ? 'Khoa học máy tính & Công nghệ' : 'Computer Science & Technology';
  String get needAtLeastOneJournalConfig => isVietnamese ? 'Vui lòng đăng ký ít nhất một tạp chí trước khi thiết lập cấu hình.' : 'Please register at least one journal before setting up configuration.';
  String get newMiningConfigTitle => isVietnamese ? 'Thiết lập cấu hình khai phá mới' : 'Create New Mining Configuration';
  String get newMiningConfigDesc => isVietnamese ? 'Xác định khoảng năm xuất bản và số lượng bài báo mục tiêu để Grobid bóc tách cấu trúc TEI XML.' : 'Specify year range and target paper count for Grobid TEI XML parsing.';
  String get applicableJournalRequired => isVietnamese ? 'Tạp chí áp dụng *' : 'Applicable Journal *';
  String get researchDomainRequired => isVietnamese ? 'Lĩnh vực nghiên cứu (Domain) *' : 'Research Domain *';
  String get domainPlaceholder => isVietnamese ? 'Ví dụ: Bioinformatics & Computational Biology' : 'E.g.: Bioinformatics & Computational Biology';
  String get domainSyncNote => isVietnamese ? 'Tự động đồng bộ từ OpenAlex. Bạn có thể giữ nguyên hoặc điều chỉnh.' : 'Automatically synced from OpenAlex. You can keep or adjust it.';
  String get fromYearLabel => isVietnamese ? 'Từ năm' : 'From Year';
  String get toYearLabel => isVietnamese ? 'Đến năm' : 'To Year';
  String get targetPapersLabel => isVietnamese ? 'Số bài báo mục tiêu (Target)' : 'Target Papers Count';
  String papersCountLabel(int count) => isVietnamese ? '$count bài' : '$count papers';
  String articlesCountLabel(int count) => isVietnamese ? '$count bài báo' : '$count articles';
  String get enterDomainWarning => isVietnamese ? 'Vui lòng nhập tên lĩnh vực nghiên cứu.' : 'Please enter research domain.';
  String get configCreatedSuccess => isVietnamese ? 'Đã tạo cấu hình khai phá thành công.' : 'Mining configuration created successfully.';
  String get startYearGreaterThanEndYear => isVietnamese ? 'Năm bắt đầu không được lớn hơn năm kết thúc.' : 'Start year cannot be greater than end year.';
  String get manualJournalEntryTitle => isVietnamese ? 'Nhập Tạp chí thủ công' : 'Manual Journal Entry';
  String get manualJournalEntryDesc => isVietnamese ? 'Dành cho tạp chí nội bộ, trong nước hoặc chưa có trên OpenAlex.' : 'For internal, domestic, or unlisted journals on OpenAlex.';
  String get fullJournalTitleRequired => isVietnamese ? 'Tên Tạp chí đầy đủ (Title) *' : 'Full Journal Title *';
  String get journalTitlePlaceholder => isVietnamese ? 'Ví dụ: IEEE Transactions on Software Engineering' : 'E.g.: IEEE Transactions on Software Engineering';
  String get filterByDomain => isVietnamese ? 'Lọc theo chuyên ngành' : 'Filter by Domain';
  String get domainLabel => isVietnamese ? 'Chuyên ngành' : 'Domain';
  String get prevPageTooltip => isVietnamese ? 'Trang trước' : 'Previous page';
  String get nextPageTooltip => isVietnamese ? 'Trang sau' : 'Next page';
  String get configDetailsTooltip => isVietnamese ? 'Cấu hình chi tiết' : 'Configure details';
  String openAlexSearchingGlobal(String q) => isVietnamese ? 'Đang tra cứu "$q" trên OpenAlex toàn cầu...' : 'Searching global OpenAlex for "$q"...';
  String get openAlexConnectingDesc => isVietnamese ? 'Hệ thống đang kết nối trực tiếp đến chỉ mục học thuật mở OpenAlex' : 'Connecting directly to OpenAlex open academic index';
  String get noJournalFoundOpenAlex => isVietnamese ? 'Không tìm thấy tạp chí nào có tên hoặc ISSN phù hợp trên OpenAlex.' : 'No journals found matching this name or ISSN on OpenAlex.';
  String get tryAnotherKeywords => isVietnamese ? 'Vui lòng thử từ khóa khác (ví dụ: "IEEE", "Finance", "Nature") hoặc mã ISSN.' : 'Please try other keywords (e.g. "IEEE", "Finance", "Nature") or ISSN.';
  String notFoundInLocalDb(String q) => isVietnamese ? 'Không tìm thấy "$q" trong CSDL nội bộ' : 'No local database records for "$q"';
  String get notStoredInSystemDesc => isVietnamese ? 'Tạp chí này chưa được lưu trữ trong hệ thống. Bạn có muốn tra cứu trực tiếp từ kho học thuật toàn cầu OpenAlex để nạp vào không?' : 'This journal is not yet in the system. Would you like to search OpenAlex to import it?';
  String lookupOnOpenAlexBtn(String q) => isVietnamese ? 'Tra cứu "$q" trên OpenAlex' : 'Lookup "$q" on OpenAlex';
  String get noJournalsInDb => isVietnamese ? 'Chưa có tạp chí nào trong cơ sở dữ liệu.' : 'No journals in the database yet.';
  String get searchOrManualHint => isVietnamese ? 'Gõ tên tạp chí vào ô tìm kiếm ở trên để tra cứu từ OpenAlex, hoặc nhập thủ công.' : 'Type journal name in the search bar above to look up on OpenAlex, or enter manually.';
  String get manualEntryBtn => isVietnamese ? 'Nhập thủ công' : 'Manual Entry';
  String openAlexResultsCount(int count) => isVietnamese ? 'Kết quả tra cứu từ OpenAlex ($count tạp chí phù hợp):' : 'OpenAlex search results ($count matching journals):';
  String get hideOpenAlexResults => isVietnamese ? 'Ẩn kết quả OpenAlex' : 'Hide OpenAlex results';
  String get importedToDb => isVietnamese ? 'Đã nạp vào CSDL' : 'Imported to Database';
  String get importingToDb => isVietnamese ? 'Đang nạp...' : 'Importing...';
  String get importToDbBtn => isVietnamese ? 'Nạp vào CSDL' : 'Import to DB';
  String get savedInSystem => isVietnamese ? 'Đã lưu hệ thống' : 'Saved in system';
  String get notImportedToDb => isVietnamese ? 'Chưa nạp CSDL' : 'Not in DB';
  String get syncCommandCenterDesc => isVietnamese ? 'Đang đồng bộ dữ liệu tác vụ và hồ sơ phong cách...' : 'Syncing mining jobs and style profile data...';
  String get unknownJournalTitle => isVietnamese ? 'Chưa rõ tên tạp chí' : 'Unknown journal title';
  String get unknownPublisher => isVietnamese ? 'Chưa rõ nhà xuất bản' : 'Unknown publisher';
  String get badgeMining => isVietnamese ? 'Đang khai phá...' : 'Mining...';
  String get badgeCompleteProfile => isVietnamese ? 'Hoàn tất & Có hồ sơ' : 'Complete & Has Profile';
  String get badgePipelineError => isVietnamese ? 'Lỗi chu trình' : 'Pipeline Error';
  String get badgeReadyMining => isVietnamese ? 'Sẵn sàng khai phá' : 'Ready to mine';
  String get badgeNotConfigured => isVietnamese ? 'Chưa thiết lập' : 'Not configured';
  String get startMiningAndAnalysis => isVietnamese ? 'Bắt đầu Khai phá & Phân tích' : 'Start Mining & Analysis';
  String get reMineAction => isVietnamese ? 'Khai phá lại' : 'Re-mine';
  String get customMiningParams => isVietnamese ? 'Tùy chỉnh thông số khai phá' : 'Customize mining parameters';
  String get defaultOptimizedConfigNote => isVietnamese ? 'Mặc định tối ưu: Tự động chuẩn hóa TEI XML' : 'Optimized default: Automatic TEI XML normalization';
  String get analyzingCardTitle => isVietnamese ? 'Đang phân tích' : 'Analyzing';
  String get completedAnalysisCardTitle => isVietnamese ? 'Đã hoàn tất phân tích' : 'Analysis Completed';
  String get progressAnalysisCardTitle => isVietnamese ? 'Tiến độ phân tích' : 'Analysis Progress';
  String get viewJobAndLogsDetails => isVietnamese ? 'Xem chi tiết tác vụ & logs' : 'View job details & logs';
  String get nlpStyleProfileSectionTitle => isVietnamese ? 'Hồ Sơ Phong Cách NLP & Rhetorical Moves' : 'NLP Style Profile & Rhetorical Moves';
  String get viewComprehensiveCorpusBenchmark => isVietnamese ? 'Xem toàn diện & Đối chuẩn Corpus ➔' : 'Comprehensive View & Corpus Benchmark ➔';
  String get sentenceLengthWords => isVietnamese ? 'Độ dài câu (Từ)' : 'Sentence Length (Words)';
  String get hylandStance => isVietnamese ? 'Lập trường Hyland' : 'Hyland Stance';
  String get cautiousTone => isVietnamese ? 'cẩn trọng' : 'cautious';
  String get academicStandard => isVietnamese ? 'Chuẩn học thuật' : 'Academic standard';
  String get avgLabel => isVietnamese ? 'Trung bình' : 'Average';
  String get worksOnOpenAlexLabel => isVietnamese ? 'bài trên OpenAlex' : 'works on OpenAlex';
  String get citationsLabel => isVietnamese ? 'trích dẫn' : 'citations';

  String get journal => isVietnamese ? 'Tạp chí' : 'Journal';

  String reMineActionCount(int count) => isVietnamese ? 'Khai phá lại ($count bài)' : 'Re-mine ($count papers)';
  String startMiningActionCount(int count) => isVietnamese ? 'Bắt đầu Khai phá & Phân tích ($count bài)' : 'Start Mining & Analysis ($count papers)';
  String defaultOptimizedConfigDetails(int count, int yFrom, int yTo) => isVietnamese
      ? 'Mặc định tối ưu: $count bài báo • Năm $yFrom–$yTo • Tự động chuẩn hóa TEI XML'
      : 'Optimized default: $count papers • Years $yFrom–$yTo • Automatic TEI XML normalization';
  String get targetPapersColon => isVietnamese ? 'Số bài báo mục tiêu:' : 'Target papers count:';
  String parsingPaperProgress(int current, int total) => isVietnamese ? 'Đang bóc tách bài $current / $total' : 'Parsing article $current / $total';
  String miningCompleteStatus(int count) => isVietnamese
      ? 'Dữ liệu toàn văn đã chuẩn hóa ($count bài) và sẵn sàng khảo sát đối chuẩn học thuật.'
      : 'Full-text data normalized ($count papers) and ready for academic benchmarking.';
  String clickMineAbovePrompt(int count) => isVietnamese
      ? 'Nhấn nút "Khai phá ($count bài)" phía trên để bắt đầu phân tích.'
      : 'Click "Start Mining ($count papers)" above to start analysis.';
  String completedPapersFraction(int current, int total) => isVietnamese
      ? 'Đã hoàn thành: $current / $total bài báo'
      : 'Completed: $current / $total papers';
  String failedPapersCount(int count) => isVietnamese ? '$count bài lỗi' : '$count failed papers';
  String get targetPapersHelp => isVietnamese
      ? 'Nhập trực tiếp hoặc chọn nhanh số bài báo Grobid sẽ trích xuất toàn văn:'
      : 'Enter directly or quickly choose target papers count for Grobid full-text parsing:';
  String updatedTargetPapers(int count) => isVietnamese ? 'Đã cập nhật mục tiêu: $count bài báo' : 'Updated target: $count papers';
  String get configSectionDesc => isVietnamese
      ? 'Thiết lập phạm vi năm khảo sát, số lượng bài báo mục tiêu và hồ sơ TEI XML phục vụ bóc tách cấu trúc với Grobid.'
      : 'Set survey year range, target papers count, and TEI XML profile for Grobid structure parsing.';
  String get clickToChangeTarget => isVietnamese ? 'Nhấn để đổi số lượng bài báo' : 'Click to change target papers count';
  String worksAndCitations(int works, int citations) => isVietnamese ? '$works bài viết • $citations trích dẫn' : '$works articles • $citations citations';
  String showingJournalsRange(int start, int end, int total) => isVietnamese
      ? 'Hiển thị $start - $end / $total tạp chí'
      : 'Showing $start - $end of $total journals';
  String pageCountLabel(int current, int total) => isVietnamese ? 'Trang $current / $total' : 'Page $current of $total';
  String get noJournalsMatchedFilter => isVietnamese ? 'Không có tạp chí nào phù hợp với bộ lọc đã chọn.' : 'No journals match the selected filter.';
  String get clearFilter => isVietnamese ? 'Xóa bộ lọc' : 'Clear filter';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension on BuildContext for quick access to translations.
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
