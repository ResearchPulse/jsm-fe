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
  String get cancelJob => isVietnamese ? 'Hủy job' : 'Cancel job';
  String get deleteJob => isVietnamese ? 'Hủy / Xóa' : 'Cancel / Delete';
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
