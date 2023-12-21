enum FileType { json, yaml, csv, arb }

enum FallbackStrategy { none, baseLocale, baseLocaleEmptyString }

/// Similar to [FallbackStrategy] but [FallbackStrategy.baseLocaleEmptyString]
/// has been already handled in the previous step.
enum GenerateFallbackStrategy { none, baseLocale }

enum OutputFormat { singleFile, multipleFiles }

enum StringInterpolation { dart, braces, doubleBraces }

enum TranslationClassVisibility { private, public }

enum CaseStyle { camel, pascal, snake }

enum PluralAuto { off, cardinal, ordinal }

extension Parser on String {
  FallbackStrategy? toFallbackStrategy() {
    switch (this) {
      case 'none':
        return FallbackStrategy.none;
      case 'base_locale':
        return FallbackStrategy.baseLocale;
      case 'base_locale_empty_string':
        return FallbackStrategy.baseLocaleEmptyString;
      default:
        return null;
    }
  }

  OutputFormat? toOutputFormat() {
    switch (this) {
      case 'single_file':
        return OutputFormat.singleFile;
      case 'multiple_files':
        return OutputFormat.multipleFiles;
      default:
        return null;
    }
  }

  TranslationClassVisibility? toTranslationClassVisibility() {
    switch (this) {
      case 'private':
        return TranslationClassVisibility.private;
      case 'public':
        return TranslationClassVisibility.public;
      default:
        return null;
    }
  }

  StringInterpolation? toStringInterpolation() {
    switch (this) {
      case 'dart':
        return StringInterpolation.dart;
      case 'braces':
        return StringInterpolation.braces;
      case 'double_braces':
        return StringInterpolation.doubleBraces;
      default:
        return null;
    }
  }

  CaseStyle? toCaseStyle() {
    switch (this) {
      case 'camel':
        return CaseStyle.camel;
      case 'snake':
        return CaseStyle.snake;
      case 'pascal':
        return CaseStyle.pascal;
      default:
        return null;
    }
  }

  PluralAuto? toPluralAuto() {
    switch (this) {
      case 'off':
        return PluralAuto.off;
      case 'cardinal':
        return PluralAuto.cardinal;
      case 'ordinal':
        return PluralAuto.ordinal;
      default:
        return null;
    }
  }
}

extension FallbackStrategyExt on FallbackStrategy {
  GenerateFallbackStrategy toGenerateFallbackStrategy() {
    switch (this) {
      case FallbackStrategy.none:
        return GenerateFallbackStrategy.none;
      case FallbackStrategy.baseLocale:
        return GenerateFallbackStrategy.baseLocale;
      case FallbackStrategy.baseLocaleEmptyString:
        return GenerateFallbackStrategy.baseLocale;
    }
  }
}
