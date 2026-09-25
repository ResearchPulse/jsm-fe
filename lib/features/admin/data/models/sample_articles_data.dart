import 'pipeline_test_models.dart';

class SampleArticlesData {
  SampleArticlesData._();

  static NormalizedArticle get sampleArticle1 => NormalizedArticle(
        articleId: 'ieee-tse-2024-art01',
        doi: '10.1109/TSE.2024.3382910',
        title: 'DeepRefactor: Graph Neural Network Approach for Automated Code Refactoring',
        journalId: 'ieee-tse',
        journalName: 'IEEE Transactions on Software Engineering',
        publicationYear: 2024,
        authors: ['Alice Nguyen', 'Duc Le', 'Robert K. Yin'],
        sections: [
          NormalizedSection(
            type: 'INTRO',
            title: '1. Introduction',
            originalTitle: '1. Introduction',
            sentences: [
              NormalizedSentence(
                sentenceId: 's1',
                text:
                    'Software maintenance accounts for more than seventy percent of overall software lifecycle expenditures in modern enterprise applications.',
                tokens: [
                  'Software',
                  'maintenance',
                  'accounts',
                  'for',
                  'lifecycle',
                  'expenditures',
                  'enterprise'
                ],
              ),
              NormalizedSentence(
                sentenceId: 's2',
                text:
                    'However, existing rule-based static analysis tools frequently fail to identify complex architectural code smells across multi-module repositories.',
                tokens: [
                  'However',
                  'existing',
                  'static',
                  'analysis',
                  'fail',
                  'identify',
                  'architectural',
                  'smells'
                ],
              ),
              NormalizedSentence(
                sentenceId: 's3',
                text:
                    'The objective of this research is to investigate whether structural graph embeddings can reliably distinguish benign code patterns from refactoring candidates.',
                tokens: [
                  'objective',
                  'research',
                  'investigate',
                  'structural',
                  'graph',
                  'embeddings',
                  'refactoring'
                ],
              ),
              NormalizedSentence(
                sentenceId: 's4',
                text:
                    'In this paper, we propose DeepRefactor, a novel heterogeneous graph neural network framework for automated smell localization and refactoring suggestion.',
                tokens: [
                  'In',
                  'this',
                  'paper',
                  'we',
                  'propose',
                  'DeepRefactor',
                  'graph',
                  'neural',
                  'network',
                  'framework'
                ],
              ),
            ],
          ),
          NormalizedSection(
            type: 'METHODS',
            title: '2. Methodology',
            originalTitle: '2. Proposed Methodology',
            sentences: [
              NormalizedSentence(
                sentenceId: 's5',
                text:
                    'We constructed a unified Abstract Syntax Tree and Program Dependence Graph across 500 popular Apache open-source projects.',
                tokens: [
                  'We',
                  'constructed',
                  'Abstract',
                  'Syntax',
                  'Tree',
                  'Program',
                  'Dependence',
                  'Graph',
                  'Apache'
                ],
              ),
              NormalizedSentence(
                sentenceId: 's6',
                text:
                    'The graph representation is processed using a two-layer Relational Graph Convolutional Network followed by attention pooling.',
                tokens: [
                  'graph',
                  'representation',
                  'processed',
                  'Relational',
                  'Graph',
                  'Convolutional',
                  'attention',
                  'pooling'
                ],
              ),
            ],
          ),
          NormalizedSection(
            type: 'RESULTS',
            title: '3. Empirical Results',
            originalTitle: '3. Empirical Results',
            sentences: [
              NormalizedSentence(
                sentenceId: 's7',
                text:
                    'Our extensive experimental evaluation clearly demonstrates that DeepRefactor achieves a Top-1 F1-score of 91.4% in detecting God Class and Feature Envy.',
                tokens: [
                  'experimental',
                  'evaluation',
                  'demonstrates',
                  'DeepRefactor',
                  'achieves',
                  'F1-score',
                  'God',
                  'Class'
                ],
              ),
              NormalizedSentence(
                sentenceId: 's8',
                text:
                    'Compared to the state-of-the-art heuristic baseline JDeodorant, our approach achieves an improvement of 18.2% in precision.',
                tokens: [
                  'Compared',
                  'state-of-the-art',
                  'baseline',
                  'JDeodorant',
                  'improvement',
                  'precision'
                ],
              ),
            ],
          ),
          NormalizedSection(
            type: 'DISCUSSION',
            title: '4. Discussion & Limitations',
            originalTitle: '4. Discussion & Limitations',
            sentences: [
              NormalizedSentence(
                sentenceId: 's9',
                text:
                    'These findings suggest that semantic node relations provide crucial contextual cues that token-based transformers often miss.',
                tokens: [
                  'findings',
                  'suggest',
                  'semantic',
                  'node',
                  'relations',
                  'contextual',
                  'cues',
                  'transformers'
                ],
              ),
              NormalizedSentence(
                sentenceId: 's10',
                text:
                    'One primary limitation of our empirical study is that the training corpus is currently restricted to object-oriented Java systems.',
                tokens: [
                  'primary',
                  'limitation',
                  'empirical',
                  'study',
                  'training',
                  'corpus',
                  'restricted',
                  'Java'
                ],
              ),
            ],
          ),
          NormalizedSection(
            type: 'CONCLUSION',
            title: '5. Conclusion',
            originalTitle: '5. Conclusion and Future Directions',
            sentences: [
              NormalizedSentence(
                sentenceId: 's11',
                text:
                    'In conclusion, DeepRefactor establishes an actionable machine-learning pipeline for repository-scale architectural code health inspection.',
                tokens: [
                  'conclusion',
                  'DeepRefactor',
                  'establishes',
                  'actionable',
                  'machine-learning',
                  'pipeline',
                  'health'
                ],
              ),
            ],
          ),
        ],
      );

  static NormalizedArticle get sampleArticle2 => NormalizedArticle(
        articleId: 'acm-tosem-2023-art04',
        doi: '10.1145/3611643.3616281',
        title: 'Evaluating LLMs on Real-world Unit Test Generation: An Empirical Study',
        journalId: 'acm-tosem',
        journalName: 'ACM Transactions on Software Engineering and Methodology',
        publicationYear: 2023,
        authors: ['Hao Chen', 'Elena Rostova', 'Minh Nguyen'],
        sections: [
          NormalizedSection(
            type: 'INTRO',
            title: '1. Introduction',
            originalTitle: '1. Introduction',
            sentences: [
              NormalizedSentence(
                sentenceId: 's1',
                text:
                    'Large language models have shown remarkable capabilities in automated source code generation and vulnerability patching.',
                tokens: ['Large', 'language', 'models', 'remarkable', 'capabilities', 'source', 'generation'],
              ),
              NormalizedSentence(
                sentenceId: 's2',
                text:
                    'Nevertheless, whether generated test cases provide adequate branch coverage without causing flaky test executions remains poorly understood.',
                tokens: ['Nevertheless', 'test', 'cases', 'branch', 'coverage', 'flaky', 'executions', 'understood'],
              ),
              NormalizedSentence(
                sentenceId: 's3',
                text:
                    'This paper presents a large-scale empirical study benchmarking GPT-4 and StarCoder on 1,200 real-world defects.',
                tokens: ['paper', 'presents', 'large-scale', 'empirical', 'benchmarking', 'GPT-4', 'defects'],
              ),
            ],
          ),
          NormalizedSection(
            type: 'RESULTS',
            title: '2. Key Findings',
            originalTitle: '2. Empirical Results',
            sentences: [
              NormalizedSentence(
                sentenceId: 's4',
                text:
                    'The empirical results show that iterative prompt feedback increases line coverage by 23.4% compared to zero-shot prompting.',
                tokens: ['empirical', 'results', 'iterative', 'prompt', 'feedback', 'increases', 'coverage'],
              ),
              NormalizedSentence(
                sentenceId: 's5',
                text:
                    'However, up to 14% of the generated assertions failed due to hallucinated mock dependencies.',
                tokens: ['However', 'generated', 'assertions', 'failed', 'hallucinated', 'mock', 'dependencies'],
              ),
            ],
          ),
        ],
      );

  static NormalizedArticle get sampleArticleFromPdf => NormalizedArticle(
        articleId: 'ieee-tse-2019-2940179',
        doi: '10.1109/TSE.2019.2940179',
        title: 'Architectural Smells in Practice: A Large-Scale Industrial Study',
        journalId: 'ieee-tse',
        journalName: 'IEEE Transactions on Software Engineering',
        publicationYear: 2019,
        authors: ['Dario Di Nucci', 'Fabio Palomba', 'Damian A. Tamburri', 'Alexander Serebrenik'],
        sections: [
          NormalizedSection(
            type: 'INTRO',
            title: '1. Introduction',
            originalTitle: '1. Introduction',
            sentences: [
              NormalizedSentence(
                sentenceId: 's1',
                text:
                    'Architectural smells are symptoms of suboptimal architectural design decisions that negatively impact software quality and maintainability.',
                tokens: ['Architectural', 'smells', 'symptoms', 'suboptimal', 'decisions', 'quality', 'maintainability'],
              ),
              NormalizedSentence(
                sentenceId: 's2',
                text:
                    'Despite extensive academic literature, there remains a critical gap concerning how software practitioners perceive and handle architectural decay in industrial settings.',
                tokens: ['Despite', 'literature', 'remains', 'critical', 'gap', 'practitioners', 'architectural', 'industrial'],
              ),
              NormalizedSentence(
                sentenceId: 's3',
                text:
                    'The goal of this paper is to bridge this gap through a mixed-method empirical study combining repository mining and industrial survey responses.',
                tokens: ['goal', 'paper', 'bridge', 'gap', 'mixed-method', 'empirical', 'mining', 'survey'],
              ),
              NormalizedSentence(
                sentenceId: 's4',
                text:
                    'In this paper, we conduct the largest empirical investigation to date on architectural smells across 150 proprietary and open-source projects.',
                tokens: ['In', 'this', 'paper', 'we', 'conduct', 'largest', 'investigation', 'architectural', 'projects'],
              ),
            ],
          ),
          NormalizedSection(
            type: 'METHODS',
            title: '2. Research Design & Data Collection',
            originalTitle: '2. Research Methodology',
            sentences: [
              NormalizedSentence(
                sentenceId: 's5',
                text:
                    'We developed Arcan, a specialized static analysis engine to automatically detect four canonical architectural smells: Cyclic Dependency, Hub-Like Dependency, Unstable Interface, and Feature Concentration.',
                tokens: ['developed', 'Arcan', 'static', 'engine', 'Cyclic', 'Dependency', 'Unstable', 'Interface'],
              ),
              NormalizedSentence(
                sentenceId: 's6',
                text:
                    'We collected 10 years of commit histories and surveyed 124 professional software architects and senior engineers.',
                tokens: ['collected', 'histories', 'surveyed', 'professional', 'architects', 'engineers'],
              ),
            ],
          ),
          NormalizedSection(
            type: 'RESULTS',
            title: '3. Empirical Results',
            originalTitle: '3. Results Analysis',
            sentences: [
              NormalizedSentence(
                sentenceId: 's7',
                text:
                    'Our analysis reveals that cyclic dependencies are the most widespread architectural smell, appearing in over 82% of the analyzed enterprise systems.',
                tokens: ['analysis', 'reveals', 'cyclic', 'dependencies', 'widespread', 'enterprise', 'systems'],
              ),
              NormalizedSentence(
                sentenceId: 's8',
                text:
                    'Statistical testing confirms a strong positive correlation between architectural smell density and fault-proneness with p-value less than 0.001.',
                tokens: ['Statistical', 'testing', 'confirms', 'correlation', 'smell', 'density', 'fault-proneness'],
              ),
            ],
          ),
          NormalizedSection(
            type: 'DISCUSSION',
            title: '4. Threats to Validity',
            originalTitle: '4. Discussion & Limitations',
            sentences: [
              NormalizedSentence(
                sentenceId: 's9',
                text:
                    'These observations indicate that architectural smells often persist unnoticed because existing continuous integration pipelines focus primarily on unit test coverage.',
                tokens: ['observations', 'indicate', 'smells', 'persist', 'pipelines', 'coverage'],
              ),
              NormalizedSentence(
                sentenceId: 's10',
                text:
                    'A notable limitation of our empirical study is that subjective developer surveys may suffer from social desirability bias regarding refactoring urgency.',
                tokens: ['notable', 'limitation', 'empirical', 'study', 'surveys', 'desirability', 'bias', 'refactoring'],
              ),
            ],
          ),
          NormalizedSection(
            type: 'CONCLUSION',
            title: '5. Conclusion',
            originalTitle: '5. Conclusion',
            sentences: [
              NormalizedSentence(
                sentenceId: 's11',
                text:
                    'In summary, our empirical results provide actionable guidelines for engineering teams to systematically identify and mitigate architectural debt.',
                tokens: ['summary', 'empirical', 'results', 'actionable', 'guidelines', 'mitigate', 'debt'],
              ),
            ],
          ),
        ],
      );

  static final List<Map<String, String>> sampleRhetoricalSentences = [
    {
      'label': 'BACKGROUND',
      'text':
          'Software repositories have expanded exponentially over the last two decades, generating massive historical telemetry.',
      'vietnamese': 'Bối cảnh nghiên cứu',
    },
    {
      'label': 'GAP',
      'text':
          'However, existing state-of-the-art defect prediction tools suffer from severe false positive rates in continuous integration.',
      'vietnamese': 'Khoảng trống tri thức',
    },
    {
      'label': 'PURPOSE',
      'text':
          'The primary aim of this investigation is to quantify the causal relationship between technical debt and security vulnerabilities.',
      'vietnamese': 'Mục tiêu nghiên cứu',
    },
    {
      'label': 'CONTRIBUTION',
      'text':
          'In this work, we propose VulnTrace, a novel graph neural network architecture that models taint propagation across microservices.',
      'vietnamese': 'Đóng góp mới',
    },
    {
      'label': 'METHOD',
      'text':
          'We evaluated our approach on a curated benchmark of 2,400 vulnerable commits using five-fold cross-validation.',
      'vietnamese': 'Phương pháp thực nghiệm',
    },
    {
      'label': 'RESULT',
      'text':
          'Experimental results indicate that VulnTrace achieves an F1-score of 88.6%, significantly outperforming traditional AST matching.',
      'vietnamese': 'Kết quả đạt được',
    },
    {
      'label': 'LIMITATION',
      'text':
          'A key limitation of our methodology is the assumption that inter-service API contracts remain backward compatible.',
      'vietnamese': 'Hạn chế của nghiên cứu',
    },
    {
      'label': 'CONCLUSION',
      'text':
          'In conclusion, this research provides strong empirical evidence that semantic graph flow substantially enhances vulnerability triage.',
      'vietnamese': 'Kết luận',
    },
  ];
}
