class MoveCandidate {
  final String move;
  final double probability;

  const MoveCandidate({required this.move, required this.probability});

  factory MoveCandidate.fromJson(Map<String, dynamic> json) {
    return MoveCandidate(
      move: json['move'] as String? ?? 'OTHER',
      probability: (json['probability'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MovePredictionResult {
  final String text;
  final String predictedMove;
  final double confidence;
  final List<MoveCandidate> topCandidates;

  const MovePredictionResult({
    required this.text,
    required this.predictedMove,
    required this.confidence,
    required this.topCandidates,
  });

  factory MovePredictionResult.fromJson(Map<String, dynamic> json) {
    final candidatesList = (json['top_candidates'] as List<dynamic>?)
            ?.map((c) => MoveCandidate.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];
    return MovePredictionResult(
      text: json['text'] as String? ?? '',
      predictedMove: json['predicted_move'] as String? ?? 'OTHER',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      topCandidates: candidatesList,
    );
  }
}

class NormalizedSentence {
  final String sentenceId;
  final String text;
  final List<String> tokens;
  String? predictedMove;
  double? moveConfidence;

  NormalizedSentence({
    required this.sentenceId,
    required this.text,
    required this.tokens,
    this.predictedMove,
    this.moveConfidence,
  });

  factory NormalizedSentence.fromJson(Map<String, dynamic> json) {
    return NormalizedSentence(
      sentenceId: json['sentence_id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      tokens: (json['tokens'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [],
      predictedMove: json['predicted_move'] as String?,
      moveConfidence: (json['move_confidence'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'sentence_id': sentenceId,
        'text': text,
        'tokens': tokens,
      };
}

class NormalizedSection {
  final String type;
  final String title;
  final String originalTitle;
  final List<NormalizedSentence> sentences;

  NormalizedSection({
    required this.type,
    required this.title,
    required this.originalTitle,
    required this.sentences,
  });

  factory NormalizedSection.fromJson(Map<String, dynamic> json) {
    return NormalizedSection(
      type: json['type'] as String? ?? 'OTHER',
      title: json['title'] as String? ?? '',
      originalTitle: json['original_title'] as String? ?? '',
      sentences: (json['sentences'] as List<dynamic>?)
              ?.map((s) => NormalizedSentence.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'original_title': originalTitle,
        'sentences': sentences.map((s) => s.toJson()).toList(),
      };
}

class NormalizedArticle {
  final String articleId;
  final String doi;
  final String title;
  final String journalId;
  final String? journalName;
  final int publicationYear;
  final List<String> authors;
  final List<NormalizedSection> sections;

  NormalizedArticle({
    required this.articleId,
    required this.doi,
    required this.title,
    required this.journalId,
    this.journalName,
    required this.publicationYear,
    required this.authors,
    required this.sections,
  });

  factory NormalizedArticle.fromJson(Map<String, dynamic> json) {
    return NormalizedArticle(
      articleId: json['article_id'] as String? ?? '',
      doi: json['doi'] as String? ?? '',
      title: json['title'] as String? ?? '',
      journalId: json['journal_id'] as String? ?? '',
      journalName: json['journal_name'] as String?,
      publicationYear: (json['publication_year'] as num?)?.toInt() ?? 2024,
      authors: (json['authors'] as List<dynamic>?)
              ?.map((a) => a.toString())
              .toList() ??
          [],
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) => NormalizedSection.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'article_id': articleId,
        'doi': doi,
        'title': title,
        'journal_id': journalId,
        'journal_name': journalName,
        'publication_year': publicationYear,
        'authors': authors,
        'sections': sections.map((s) => s.toJson()).toList(),
      };
}

class SentenceLengthPercentiles {
  final double p10;
  final double p25;
  final double p50;
  final double p75;
  final double p90;

  const SentenceLengthPercentiles({
    required this.p10,
    required this.p25,
    required this.p50,
    required this.p75,
    required this.p90,
  });

  factory SentenceLengthPercentiles.fromJson(Map<String, dynamic> json) {
    return SentenceLengthPercentiles(
      p10: (json['p10'] as num?)?.toDouble() ?? 12.0,
      p25: (json['p25'] as num?)?.toDouble() ?? 18.0,
      p50: (json['p50'] as num?)?.toDouble() ?? 24.5,
      p75: (json['p75'] as num?)?.toDouble() ?? 32.0,
      p90: (json['p90'] as num?)?.toDouble() ?? 41.0,
    );
  }
}

class ArticleFeaturesResult {
  final String articleId;
  final int totalSentences;
  final int totalTokens;
  final SentenceLengthPercentiles percentiles;
  final double passiveRatio;
  final int activeSentences;
  final int passiveSentences;
  final int hedgingCount;
  final int boosterCount;
  final int attitudeCount;
  final Map<String, int> movesBreakdown;
  final List<Map<String, dynamic>> topBundles;

  const ArticleFeaturesResult({
    required this.articleId,
    required this.totalSentences,
    required this.totalTokens,
    required this.percentiles,
    required this.passiveRatio,
    required this.activeSentences,
    required this.passiveSentences,
    required this.hedgingCount,
    required this.boosterCount,
    required this.attitudeCount,
    required this.movesBreakdown,
    required this.topBundles,
  });

  factory ArticleFeaturesResult.fromJson(Map<String, dynamic> json) {
    final percJson = json['percentiles'] as Map<String, dynamic>? ?? {};
    final breakdownJson = json['rhetorical_moves_breakdown'] as Map<String, dynamic>? ?? {};
    final bundlesRaw = (json['lexical_bundles'] as List<dynamic>?) ?? [];

    return ArticleFeaturesResult(
      articleId: json['article_id'] as String? ?? 'sample',
      totalSentences: (json['total_sentences'] as num?)?.toInt() ?? 0,
      totalTokens: (json['total_tokens'] as num?)?.toInt() ?? 0,
      percentiles: SentenceLengthPercentiles.fromJson(percJson),
      passiveRatio: (json['passive_ratio'] as num?)?.toDouble() ?? 0.28,
      activeSentences: (json['active_sentences'] as num?)?.toInt() ?? 18,
      passiveSentences: (json['passive_sentences'] as num?)?.toInt() ?? 7,
      hedgingCount: (json['hedging_count'] as num?)?.toInt() ?? 14,
      boosterCount: (json['booster_count'] as num?)?.toInt() ?? 9,
      attitudeCount: (json['attitude_count'] as num?)?.toInt() ?? 5,
      movesBreakdown: breakdownJson.map((k, v) => MapEntry(k, (v as num).toInt())),
      topBundles: bundlesRaw.map((b) => b as Map<String, dynamic>).toList(),
    );
  }
}

class PipelineMonitorStats {
  final bool grobidAlive;
  final int minioCount;
  final double minioSizeMb;
  final int totalNormalized;
  final int totalArticles;
  final int totalFailed;
  final List<Map<String, dynamic>> journalsData;

  const PipelineMonitorStats({
    required this.grobidAlive,
    required this.minioCount,
    required this.minioSizeMb,
    required this.totalNormalized,
    required this.totalArticles,
    required this.totalFailed,
    required this.journalsData,
  });

  factory PipelineMonitorStats.fromJson(Map<String, dynamic> json) {
    return PipelineMonitorStats(
      grobidAlive: json['grobid_alive'] as bool? ?? false,
      minioCount: (json['minio_count'] as num?)?.toInt() ?? 0,
      minioSizeMb: (json['minio_size_mb'] as num?)?.toDouble() ?? 0.0,
      totalNormalized: (json['total_normalized'] as num?)?.toInt() ?? 0,
      totalArticles: (json['total_articles'] as num?)?.toInt() ?? 0,
      totalFailed: (json['total_failed'] as num?)?.toInt() ?? 0,
      journalsData: (json['journals_data'] as List<dynamic>?)
              ?.map((j) => j as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}
