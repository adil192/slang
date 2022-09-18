import 'package:slang/api/locale.dart';
import 'package:slang/api/pluralization.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang/builder/model/pluralization.dart';
import 'package:slang/builder/utils/regex_utils.dart';
import 'package:slang/builder/utils/string_interpolation_extensions.dart';

/// Utility class handling overridden translations
class TranslationOverrides {
  static String? string(
      TranslationMetadata meta, String path, Map<String, Object> param) {
    final node = meta.overrides[path];
    if (node == null || node is! StringTextNode) {
      return null;
    }
    return node.content.applyParamsAndLinks(meta, param);
  }

  static String? plural(
      TranslationMetadata meta, String path, Map<String, Object> param) {
    final node = meta.overrides[path];
    if (node == null || node is! PluralNode || param[node.paramName] == null) {
      return null;
    }

    final PluralResolver resolver;
    if (node.pluralType == PluralType.cardinal) {
      resolver = meta.cardinalResolver ??
          PluralResolvers.cardinal(meta.locale.languageCode);
    } else {
      resolver = meta.ordinalResolver ??
          PluralResolvers.ordinal(meta.locale.languageCode);
    }

    return resolver(
      param[node.paramName] as num,
      zero: node.quantities[Quantity.zero]?.content
          .applyParamsAndLinks(meta, param),
      one: node.quantities[Quantity.one]?.content
          .applyParamsAndLinks(meta, param),
      two: node.quantities[Quantity.two]?.content
          .applyParamsAndLinks(meta, param),
      few: node.quantities[Quantity.few]?.content
          .applyParamsAndLinks(meta, param),
      many: node.quantities[Quantity.many]?.content
          .applyParamsAndLinks(meta, param),
      other: node.quantities[Quantity.other]?.content
          .applyParamsAndLinks(meta, param),
    );
  }

  static String? context(
      TranslationMetadata meta, String path, Map<String, Object> param) {
    final node = meta.overrides[path];
    if (node == null || node is! ContextNode) {
      return null;
    }
    final context = param[node.paramName];
    if (context == null || context is! Enum) {
      return null;
    }

    return node.entries[context.name]?.content.applyParamsAndLinks(meta, param);
  }

  static Map<String, String>? map(TranslationMetadata meta, String path) {
    final node = meta.overrides[path];
    if (node == null ||
        node is! ObjectNode ||
        !node.isMap ||
        node.genericType != 'String') {
      return null;
    }

    return {
      for (final entry in node.entries.entries)
        entry.key: (entry.value as StringTextNode).content.applyLinks(meta, {}),
    };
  }

  static List<String>? list(TranslationMetadata meta, String path) {
    final node = meta.overrides[path];
    if (node == null || node is! ListNode || node.genericType != 'String') {
      return null;
    }

    return node.entries
        .map((e) => (e as StringTextNode).content.applyLinks(meta, {}))
        .toList();
  }
}

extension TranslationOverridesStringExt on String {
  /// Replaces every ${param} with the given parameter
  String applyParams(Map<String, Object> param) {
    return replaceDartNormalizedInterpolation(replacer: (match) {
      final nodeParam = match.substring(2, match.length - 1);
      final providedParam = param[nodeParam];
      if (providedParam == null) {
        return match; // do not replace, keep as is
      }
      return providedParam.toString();
    });
  }

  /// Replaces every ${_root.<path>} with the real string
  String applyLinks(TranslationMetadata meta, Map<String, Object> param) {
    return replaceDartNormalizedInterpolation(replacer: (match) {
      final nodeParam = match.substring(2, match.length - 1);
      if (!nodeParam.startsWith('_root.')) {
        return match;
      }

      final path = RegexUtils.linkPathRegex.firstMatch(nodeParam)?.group(1);
      if (path == null) {
        return match;
      }

      final refInFlatMap = meta.getTranslation(path);
      if (refInFlatMap == null) {
        return match;
      }

      if (refInFlatMap is String) {
        return refInFlatMap;
      }

      if (refInFlatMap is Function) {
        return Function.apply(
          refInFlatMap,
          [],
          {
            for (final p in param.entries) Symbol(p.key): p.value,
          },
        );
      }

      return match; // this should not happen (must be string or function)
    });
  }

  /// Shortcut to call both at once.
  String applyParamsAndLinks(
      TranslationMetadata meta, Map<String, Object> param) {
    return applyParams(param).applyLinks(meta, param);
  }
}