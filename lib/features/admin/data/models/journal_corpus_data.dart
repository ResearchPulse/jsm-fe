import 'pipeline_test_models.dart';

class CorpusSentenceItem {
  final String sentenceId;
  final String text;
  final String doi;
  final String section;
  final String move;
  final double confidence;
  final int tokenCount;
  final bool isPassive;
  final bool hasWeSubject;

  const CorpusSentenceItem({
    required this.sentenceId,
    required this.text,
    required this.doi,
    required this.section,
    required this.move,
    required this.confidence,
    required this.tokenCount,
    this.isPassive = false,
    this.hasWeSubject = false,
  });
}

class JournalCorpusInfo {
  final String id;
  final String title;
  final String shortName;
  final String publisher;
  final String issn;
  final String yearRange;
  final String quartile;
  final double impactFactor;
  final String focusArea;
  final int totalArticles;
  final int totalSentences;
  final int totalTokens;
  final Map<String, int> moveCounts;
  final Map<String, int> sectionSentenceCounts;
  final SentenceLengthPercentiles percentiles;
  final double activeShare;
  final double passiveShare;
  final double weSubjectShare;
  final double hedgeRatePer1k;
  final double boosterRatePer1k;
  final double reportingRatePer1k;
  final List<CorpusSentenceItem> representativeSentences;
  final List<Map<String, dynamic>> corpusLexicalBundles;
  final List<Map<String, dynamic>> keynessWords;

  const JournalCorpusInfo({
    required this.id,
    required this.title,
    required this.shortName,
    required this.publisher,
    required this.issn,
    required this.yearRange,
    required this.quartile,
    required this.impactFactor,
    required this.focusArea,
    required this.totalArticles,
    required this.totalSentences,
    required this.totalTokens,
    required this.moveCounts,
    required this.sectionSentenceCounts,
    required this.percentiles,
    required this.activeShare,
    required this.passiveShare,
    required this.weSubjectShare,
    required this.hedgeRatePer1k,
    required this.boosterRatePer1k,
    required this.reportingRatePer1k,
    required this.representativeSentences,
    required this.corpusLexicalBundles,
    required this.keynessWords,
  });
}

class JournalCorpusRegistry {
  JournalCorpusRegistry._();

  // 1. IEEE Transactions on Software Engineering (TSE)
  static const JournalCorpusInfo tse = JournalCorpusInfo(
    id: 'tse',
    title: 'IEEE Transactions on Software Engineering',
    shortName: 'IEEE TSE',
    publisher: 'IEEE Computer Society',
    issn: '0098-5589',
    yearRange: '2021 – 2024',
    quartile: 'Q1',
    impactFactor: 6.5,
    focusArea: 'Kiến trúc phần mềm, Tái cấu trúc (Refactoring), Khai phá kho dữ liệu (MSR), Phân tích mã nguồn',
    totalArticles: 300,
    totalSentences: 3280,
    totalTokens: 86420,
    moveCounts: {
      'METHOD': 892,
      'RESULT': 764,
      'CONTRIBUTION': 382,
      'BACKGROUND': 345,
      'GAP': 298,
      'PURPOSE': 264,
      'LIMITATION': 178,
      'CONCLUSION': 157,
    },
    sectionSentenceCounts: {
      'INTRO': 820,
      'METHODS': 950,
      'RESULTS': 780,
      'DISCUSSION': 460,
      'CONCLUSION': 270,
    },
    percentiles: SentenceLengthPercentiles(
      p10: 13.8,
      p25: 18.5,
      p50: 25.2,
      p75: 33.6,
      p90: 44.8,
    ),
    activeShare: 0.718,
    passiveShare: 0.282,
    weSubjectShare: 0.214,
    hedgeRatePer1k: 14.8,
    boosterRatePer1k: 8.6,
    reportingRatePer1k: 11.2,
    corpusLexicalBundles: [
      {'bundle': 'in this paper we', 'count': 412, 'type': 'Contribution', 'coverage': 0.84},
      {'bundle': 'as shown in table', 'count': 356, 'type': 'Referential', 'coverage': 0.78},
      {'bundle': 'the results of our', 'count': 298, 'type': 'Results', 'coverage': 0.72},
      {'bundle': 'in order to evaluate', 'count': 264, 'type': 'Purpose', 'coverage': 0.68},
      {'bundle': 'threats to validity are', 'count': 245, 'type': 'Limitation', 'coverage': 0.81},
      {'bundle': 'statistically significant difference was', 'count': 188, 'type': 'Statistical', 'coverage': 0.54},
      {'bundle': 'with respect to the', 'count': 176, 'type': 'Comparison', 'coverage': 0.49},
    ],
    keynessWords: [
      {'word': 'empirically', 'll': 89.4, 'ratio': 2.45, 'p': 0.000001, 'cov': 0.42},
      {'word': 'refactoring', 'll': 78.2, 'ratio': 3.12, 'p': 0.000001, 'cov': 0.38},
      {'word': 'codebases', 'll': 64.5, 'ratio': 2.80, 'p': 0.000002, 'cov': 0.31},
      {'word': 'repository', 'll': 58.9, 'ratio': 2.15, 'p': 0.000005, 'cov': 0.45},
      {'word': 'grounded', 'll': 45.2, 'ratio': 1.95, 'p': 0.000012, 'cov': 0.28},
      {'word': 'validation', 'll': 41.7, 'ratio': 1.82, 'p': 0.000021, 'cov': 0.52},
    ],
    representativeSentences: [
      CorpusSentenceItem(
        sentenceId: 'TSE-0142',
        text: 'However, existing rule-based static analysis tools frequently fail to identify complex architectural code smells across multi-module enterprise systems.',
        doi: '10.1109/TSE.2023.3289102',
        section: 'INTRO',
        move: 'GAP',
        confidence: 0.94,
        tokenCount: 22,
      ),
      CorpusSentenceItem(
        sentenceId: 'TSE-0289',
        text: 'Despite extensive academic literature on automated refactoring, there remains a critical gap concerning how software architects prioritize technical debt in industrial settings.',
        doi: '10.1109/TSE.2022.3194851',
        section: 'INTRO',
        move: 'GAP',
        confidence: 0.96,
        tokenCount: 25,
      ),
      CorpusSentenceItem(
        sentenceId: 'TSE-0084',
        text: 'In this paper, we propose DeepRefactor, a novel heterogeneous graph neural network framework for automated smell localization and refactoring suggestion.',
        doi: '10.1109/TSE.2023.3289102',
        section: 'INTRO',
        move: 'CONTRIBUTION',
        confidence: 0.97,
        tokenCount: 23,
        hasWeSubject: true,
      ),
      CorpusSentenceItem(
        sentenceId: 'TSE-0891',
        text: 'We constructed a unified Abstract Syntax Tree and Program Dependence Graph across 500 popular Apache open-source projects using Tree-sitter.',
        doi: '10.1109/TSE.2023.3289102',
        section: 'METHODS',
        move: 'METHOD',
        confidence: 0.94,
        tokenCount: 21,
        hasWeSubject: true,
      ),
      CorpusSentenceItem(
        sentenceId: 'TSE-1120',
        text: 'All statistical hypotheses were tested using two-tailed Wilcoxon signed-rank tests with Cliff delta effect sizes at a significance threshold of alpha = 0.01.',
        doi: '10.1109/TSE.2022.3194851',
        section: 'METHODS',
        move: 'METHOD',
        confidence: 0.95,
        tokenCount: 25,
        isPassive: true,
      ),
      CorpusSentenceItem(
        sentenceId: 'TSE-1782',
        text: 'Our extensive experimental evaluation clearly demonstrates that DeepRefactor achieves a Top-1 F1-score of 91.4% in detecting God Class and Feature Envy.',
        doi: '10.1109/TSE.2023.3289102',
        section: 'RESULTS',
        move: 'RESULT',
        confidence: 0.96,
        tokenCount: 24,
      ),
      CorpusSentenceItem(
        sentenceId: 'TSE-2680',
        text: 'One primary limitation of our empirical study is that the training corpus is currently restricted to object-oriented Java and C++ codebases.',
        doi: '10.1109/TSE.2023.3289102',
        section: 'DISCUSSION',
        move: 'LIMITATION',
        confidence: 0.97,
        tokenCount: 22,
      ),
      CorpusSentenceItem(
        sentenceId: 'TSE-3120',
        text: 'In conclusion, DeepRefactor establishes an actionable machine-learning pipeline for repository-scale architectural code health inspection.',
        doi: '10.1109/TSE.2023.3289102',
        section: 'CONCLUSION',
        move: 'CONCLUSION',
        confidence: 0.98,
        tokenCount: 17,
      ),
    ],
  );

  // 2. ACM Transactions on Software Engineering and Methodology (TOSEM)
  static const JournalCorpusInfo tosem = JournalCorpusInfo(
    id: 'tosem',
    title: 'ACM Transactions on Software Engineering and Methodology',
    shortName: 'ACM TOSEM',
    publisher: 'Association for Computing Machinery',
    issn: '1049-331X',
    yearRange: '2021 – 2024',
    quartile: 'Q1',
    impactFactor: 5.8,
    focusArea: 'AI for Code, Sinh ca kiểm thử tự động bằng LLM, Kiểm chứng hình thức, Tổng hợp chương trình',
    totalArticles: 285,
    totalSentences: 3120,
    totalTokens: 81900,
    moveCounts: {
      'METHOD': 840,
      'RESULT': 752,
      'CONTRIBUTION': 415,
      'BACKGROUND': 295,
      'GAP': 310,
      'PURPOSE': 238,
      'LIMITATION': 142,
      'CONCLUSION': 128,
    },
    sectionSentenceCounts: {
      'INTRO': 860,
      'METHODS': 910,
      'RESULTS': 790,
      'DISCUSSION': 340,
      'CONCLUSION': 220,
    },
    percentiles: SentenceLengthPercentiles(
      p10: 12.2,
      p25: 16.8,
      p50: 22.4, // Shorter, more crisp sentences
      p75: 29.5,
      p90: 39.2,
    ),
    activeShare: 0.785, // Higher active voice
    passiveShare: 0.215,
    weSubjectShare: 0.268, // High author agency in ACM papers
    hedgeRatePer1k: 12.1,
    boosterRatePer1k: 10.4,
    reportingRatePer1k: 13.8,
    corpusLexicalBundles: [
      {'bundle': 'to the best of our', 'count': 388, 'type': 'Gap', 'coverage': 0.88},
      {'bundle': 'large language models for', 'count': 365, 'type': 'Domain', 'coverage': 0.74},
      {'bundle': 'we propose a novel', 'count': 342, 'type': 'Contribution', 'coverage': 0.81},
      {'bundle': 'experimental results show that', 'count': 315, 'type': 'Results', 'coverage': 0.76},
      {'bundle': 'in terms of precision', 'count': 278, 'type': 'Evaluation', 'coverage': 0.69},
      {'bundle': 'outperforms the baseline by', 'count': 240, 'type': 'Comparison', 'coverage': 0.65},
    ],
    keynessWords: [
      {'word': 'prompting', 'll': 96.2, 'ratio': 3.42, 'p': 0.000001, 'cov': 0.48},
      {'word': 'benchmark', 'll': 84.1, 'ratio': 2.95, 'p': 0.000001, 'cov': 0.55},
      {'word': 'synthesizer', 'll': 72.8, 'ratio': 2.70, 'p': 0.000002, 'cov': 0.34},
      {'word': 'mutation', 'll': 61.4, 'ratio': 2.30, 'p': 0.000004, 'cov': 0.39},
      {'word': 'testsuites', 'll': 55.7, 'ratio': 2.18, 'p': 0.000008, 'cov': 0.42},
      {'word': 'zero-shot', 'll': 49.3, 'ratio': 2.05, 'p': 0.000015, 'cov': 0.36},
    ],
    representativeSentences: [
      CorpusSentenceItem(
        sentenceId: 'TOSEM-0031',
        text: 'Although modern LLM-based test generation tools produce syntactically valid assertions, they frequently suffer from subtle semantic hallucinations and oracle inaccuracies.',
        doi: '10.1145/3611643.3616281',
        section: 'INTRO',
        move: 'GAP',
        confidence: 0.96,
        tokenCount: 22,
      ),
      CorpusSentenceItem(
        sentenceId: 'TOSEM-0082',
        text: 'In this paper, we propose PromptTest, an automated feedback-driven prompt mutation framework designed to synthesize semantically sound unit tests for Python APIs.',
        doi: '10.1145/3611643.3616281',
        section: 'INTRO',
        move: 'CONTRIBUTION',
        confidence: 0.98,
        tokenCount: 24,
        hasWeSubject: true,
      ),
      CorpusSentenceItem(
        sentenceId: 'TOSEM-0415',
        text: 'We formulate the test generation challenge as a reinforcement learning task guided by symbolic execution constraints and mutation score feedback.',
        doi: '10.1145/3576038.3582410',
        section: 'METHODS',
        move: 'METHOD',
        confidence: 0.95,
        tokenCount: 21,
        hasWeSubject: true,
      ),
      CorpusSentenceItem(
        sentenceId: 'TOSEM-0920',
        text: 'Each candidate test suite was executed in an isolated Docker container with strict CPU and memory resource quotas to eliminate non-deterministic flaky failures.',
        doi: '10.1145/3576038.3582410',
        section: 'METHODS',
        move: 'METHOD',
        confidence: 0.93,
        tokenCount: 24,
        isPassive: true,
      ),
      CorpusSentenceItem(
        sentenceId: 'TOSEM-1428',
        text: 'PromptTest achieves an average branch coverage of 84.6%, statistically outperforming state-of-the-art tools EvoSuite and GitHub Copilot by 17.3% (p < 0.001).',
        doi: '10.1145/3611643.3616281',
        section: 'RESULTS',
        move: 'RESULT',
        confidence: 0.97,
        tokenCount: 23,
      ),
      CorpusSentenceItem(
        sentenceId: 'TOSEM-2104',
        text: 'A primary threat to external validity lies in the selection of open-source benchmark repositories, which may not capture proprietary domain-specific APIs.',
        doi: '10.1145/3576038.3582410',
        section: 'DISCUSSION',
        move: 'LIMITATION',
        confidence: 0.95,
        tokenCount: 23,
      ),
      CorpusSentenceItem(
        sentenceId: 'TOSEM-2890',
        text: 'To conclude, our empirical findings demonstrate that constraint-guided LLM prompting can dramatically elevate the quality of automated test generation.',
        doi: '10.1145/3611643.3616281',
        section: 'CONCLUSION',
        move: 'CONCLUSION',
        confidence: 0.97,
        tokenCount: 21,
        hasWeSubject: true,
      ),
    ],
  );

  // 3. Journal of Systems and Software (Elsevier JSS)
  static const JournalCorpusInfo jss = JournalCorpusInfo(
    id: 'jss',
    title: 'Journal of Systems and Software',
    shortName: 'Elsevier JSS',
    publisher: 'Elsevier Science',
    issn: '0164-1212',
    yearRange: '2021 – 2024',
    quartile: 'Q1',
    impactFactor: 4.4,
    focusArea: 'Hệ thống phân tán & Microservices, DevOps, Nghiên cứu thực nghiệm công nghiệp, Chất lượng hệ thống',
    totalArticles: 310,
    totalSentences: 3450,
    totalTokens: 92100,
    moveCounts: {
      'METHOD': 980,
      'RESULT': 810,
      'CONTRIBUTION': 350,
      'BACKGROUND': 390,
      'GAP': 270,
      'PURPOSE': 280,
      'LIMITATION': 210,
      'CONCLUSION': 160,
    },
    sectionSentenceCounts: {
      'INTRO': 780,
      'METHODS': 1040,
      'RESULTS': 820,
      'DISCUSSION': 510,
      'CONCLUSION': 300,
    },
    percentiles: SentenceLengthPercentiles(
      p10: 14.5,
      p25: 19.8,
      p50: 27.1, // Longer, explanatory industrial case studies
      p75: 35.8,
      p90: 47.6,
    ),
    activeShare: 0.664,
    passiveShare: 0.336, // Higher passive in system architecture descriptions
    weSubjectShare: 0.172,
    hedgeRatePer1k: 16.5,
    boosterRatePer1k: 7.2,
    reportingRatePer1k: 10.5,
    corpusLexicalBundles: [
      {'bundle': 'in the context of', 'count': 445, 'type': 'Context', 'coverage': 0.86},
      {'bundle': 'the case study was', 'count': 382, 'type': 'Method', 'coverage': 0.79},
      {'bundle': 'practitioners reported that the', 'count': 310, 'type': 'Findings', 'coverage': 0.71},
      {'bundle': 'from the perspective of', 'count': 285, 'type': 'Stance', 'coverage': 0.67},
      {'bundle': 'threats to internal validity', 'count': 260, 'type': 'Limitation', 'coverage': 0.83},
    ],
    keynessWords: [
      {'word': 'microservices', 'll': 91.5, 'ratio': 3.10, 'p': 0.000001, 'cov': 0.44},
      {'word': 'industrial', 'll': 82.3, 'ratio': 2.85, 'p': 0.000001, 'cov': 0.58},
      {'word': 'maintainability', 'll': 71.0, 'ratio': 2.50, 'p': 0.000002, 'cov': 0.49},
      {'word': 'practitioners', 'll': 68.4, 'ratio': 2.45, 'p': 0.000003, 'cov': 0.52},
      {'word': 'monolith', 'll': 54.2, 'ratio': 2.15, 'p': 0.000008, 'cov': 0.33},
      {'word': 'devops', 'll': 48.7, 'ratio': 1.95, 'p': 0.000014, 'cov': 0.38},
    ],
    representativeSentences: [
      CorpusSentenceItem(
        sentenceId: 'JSS-0045',
        text: 'Despite the pervasive adoption of microservice architectures, enterprise organizations encounter severe integration challenges during continuous service decomposition.',
        doi: '10.1016/j.jss.2023.111824',
        section: 'INTRO',
        move: 'GAP',
        confidence: 0.94,
        tokenCount: 20,
      ),
      CorpusSentenceItem(
        sentenceId: 'JSS-0112',
        text: 'The main goal of this empirical inquiry is to characterize the socio-technical factors that influence architectural migration from legacy monolithic software systems.',
        doi: '10.1016/j.jss.2023.111824',
        section: 'INTRO',
        move: 'PURPOSE',
        confidence: 0.93,
        tokenCount: 22,
      ),
      CorpusSentenceItem(
        sentenceId: 'JSS-0780',
        text: 'Data collection was conducted over an eight-month observational period through semi-structured interviews with 36 software architects across five global telecommunication enterprises.',
        doi: '10.1016/j.jss.2022.111450',
        section: 'METHODS',
        move: 'METHOD',
        confidence: 0.96,
        tokenCount: 23,
        isPassive: true,
      ),
      CorpusSentenceItem(
        sentenceId: 'JSS-1650',
        text: 'Our quantitative analysis reveals that cyclic service dependencies increase deployment failure rates by 38.4% across continuous delivery pipelines.',
        doi: '10.1016/j.jss.2023.111824',
        section: 'RESULTS',
        move: 'RESULT',
        confidence: 0.95,
        tokenCount: 19,
      ),
      CorpusSentenceItem(
        sentenceId: 'JSS-2490',
        text: 'A potential threat to validity is that survey respondents might have exhibited positive self-selection bias toward modern container orchestration frameworks.',
        doi: '10.1016/j.jss.2022.111450',
        section: 'DISCUSSION',
        move: 'LIMITATION',
        confidence: 0.96,
        tokenCount: 21,
      ),
      CorpusSentenceItem(
        sentenceId: 'JSS-3210',
        text: 'In summary, our industrial case study offers actionable architectural patterns for mitigating latency degradation during large-scale microservice evolution.',
        doi: '10.1016/j.jss.2023.111824',
        section: 'CONCLUSION',
        move: 'CONCLUSION',
        confidence: 0.97,
        tokenCount: 20,
      ),
    ],
  );

  // 4. Empirical Software Engineering (Springer EMSE)
  static const JournalCorpusInfo emse = JournalCorpusInfo(
    id: 'emse',
    title: 'Empirical Software Engineering',
    shortName: 'Springer EMSE',
    publisher: 'Springer Nature',
    issn: '1382-3256',
    yearRange: '2021 – 2024',
    quartile: 'Q1',
    impactFactor: 4.2,
    focusArea: 'Yếu tố con người & văn hóa lập trình, Phương pháp định tính (Qualitative), Grounded Theory, Khảo sát diện rộng',
    totalArticles: 270,
    totalSentences: 2980,
    totalTokens: 79600,
    moveCounts: {
      'METHOD': 810,
      'RESULT': 710,
      'CONTRIBUTION': 340,
      'BACKGROUND': 330,
      'GAP': 280,
      'PURPOSE': 240,
      'LIMITATION': 150,
      'CONCLUSION': 120,
    },
    sectionSentenceCounts: {
      'INTRO': 740,
      'METHODS': 890,
      'RESULTS': 730,
      'DISCUSSION': 420,
      'CONCLUSION': 200,
    },
    percentiles: SentenceLengthPercentiles(
      p10: 13.0,
      p25: 17.9,
      p50: 24.0,
      p75: 32.2,
      p90: 42.5,
    ),
    activeShare: 0.742,
    passiveShare: 0.258,
    weSubjectShare: 0.245,
    hedgeRatePer1k: 17.8, // Very high hedging in qualitative findings
    boosterRatePer1k: 6.8,
    reportingRatePer1k: 12.4,
    corpusLexicalBundles: [
      {'bundle': 'the participants emphasized that', 'count': 374, 'type': 'Qualitative', 'coverage': 0.82},
      {'bundle': 'grounded theory approach was', 'count': 320, 'type': 'Methodology', 'coverage': 0.75},
      {'bundle': 'the findings suggest that', 'count': 305, 'type': 'Findings', 'coverage': 0.80},
      {'bundle': 'our qualitative analysis revealed', 'count': 268, 'type': 'Results', 'coverage': 0.72},
      {'bundle': 'threats to construct validity', 'count': 235, 'type': 'Limitation', 'coverage': 0.78},
    ],
    keynessWords: [
      {'word': 'qualitative', 'll': 94.6, 'ratio': 3.35, 'p': 0.000001, 'cov': 0.54},
      {'word': 'thematic', 'll': 81.2, 'ratio': 2.90, 'p': 0.000001, 'cov': 0.46},
      {'word': 'interviews', 'll': 75.8, 'ratio': 2.75, 'p': 0.000002, 'cov': 0.51},
      {'word': 'participants', 'll': 69.1, 'ratio': 2.55, 'p': 0.000003, 'cov': 0.58},
      {'word': 'grounded', 'll': 58.4, 'ratio': 2.25, 'p': 0.000007, 'cov': 0.37},
      {'word': 'perceptions', 'll': 47.9, 'ratio': 1.90, 'p': 0.000016, 'cov': 0.43},
    ],
    representativeSentences: [
      CorpusSentenceItem(
        sentenceId: 'EMSE-0052',
        text: 'While technical aspects of code review have received thorough attention, how psychological safety affects junior developer participation remains critically underexplored.',
        doi: '10.1007/s10664-023-10342-9',
        section: 'INTRO',
        move: 'GAP',
        confidence: 0.95,
        tokenCount: 22,
      ),
      CorpusSentenceItem(
        sentenceId: 'EMSE-0120',
        text: 'Our primary objective is to investigate developer burnout mechanisms through longitudinal qualitative journaling and biometric stress tracking.',
        doi: '10.1007/s10664-023-10342-9',
        section: 'INTRO',
        move: 'PURPOSE',
        confidence: 0.94,
        tokenCount: 18,
      ),
      CorpusSentenceItem(
        sentenceId: 'EMSE-0640',
        text: 'Two independent researchers performed open thematic coding on 140 interview transcripts, achieving an inter-rater reliability Cohen kappa of 0.88.',
        doi: '10.1007/s10664-022-10210-5',
        section: 'METHODS',
        move: 'METHOD',
        confidence: 0.96,
        tokenCount: 21,
      ),
      CorpusSentenceItem(
        sentenceId: 'EMSE-1530',
        text: 'Participants reported that harsh peer review comments significantly decreased their willingness to contribute to core modules by 42%.',
        doi: '10.1007/s10664-023-10342-9',
        section: 'RESULTS',
        move: 'RESULT',
        confidence: 0.95,
        tokenCount: 19,
      ),
      CorpusSentenceItem(
        sentenceId: 'EMSE-2310',
        text: 'A notable threat to internal validity is social desirability bias, where interviewees may downplay interpersonal friction within distributed agile squads.',
        doi: '10.1007/s10664-022-10210-5',
        section: 'DISCUSSION',
        move: 'LIMITATION',
        confidence: 0.97,
        tokenCount: 22,
      ),
      CorpusSentenceItem(
        sentenceId: 'EMSE-2910',
        text: 'In conclusion, establishing explicit guidelines for non-violent code review communication fosters substantial psychological safety across software engineering teams.',
        doi: '10.1007/s10664-023-10342-9',
        section: 'CONCLUSION',
        move: 'CONCLUSION',
        confidence: 0.98,
        tokenCount: 20,
      ),
    ],
  );

  static const List<JournalCorpusInfo> allJournals = [
    tse,
    tosem,
    jss,
    emse,
  ];

  static JournalCorpusInfo getById(String id) {
    return allJournals.firstWhere(
      (j) => j.id.toLowerCase() == id.toLowerCase(),
      orElse: () => tse,
    );
  }
}

// Backward-compatibility static wrapper
class JournalCorpusData {
  JournalCorpusData._();

  static JournalCorpusInfo _active = JournalCorpusRegistry.tse;
  static JournalCorpusInfo get activeJournal => _active;

  static void setActiveJournal(JournalCorpusInfo journal) {
    _active = journal;
  }

  static String get journalTitle => _active.title;
  static String get issn => _active.issn;
  static String get yearRange => _active.yearRange;
  static int get totalArticles => _active.totalArticles;
  static int get totalSentences => _active.totalSentences;
  static int get totalTokens => _active.totalTokens;
  static Map<String, int> get moveCounts => _active.moveCounts;
  static Map<String, int> get sectionSentenceCounts => _active.sectionSentenceCounts;
  static SentenceLengthPercentiles get corpusPercentiles => _active.percentiles;
  static double get activeShare => _active.activeShare;
  static double get passiveShare => _active.passiveShare;
  static double get weSubjectShare => _active.weSubjectShare;
  static double get hedgeRatePer1k => _active.hedgeRatePer1k;
  static double get boosterRatePer1k => _active.boosterRatePer1k;
  static double get reportingRatePer1k => _active.reportingRatePer1k;
  static List<CorpusSentenceItem> get representativeSentences => _active.representativeSentences;
  static List<Map<String, dynamic>> get corpusLexicalBundles => _active.corpusLexicalBundles;
  static List<Map<String, dynamic>> get keynessWords => _active.keynessWords;
}
