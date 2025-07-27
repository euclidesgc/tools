import 'package:boti_lints/src/check_method_name.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/no_emit_after_async_gap.dart';

// Ponto de entrada para o plugin custom_lint
PluginBase createPlugin() => _BotiLints();

class _BotiLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    const CheckMethodName(),
    const NoEmitAfterAsyncGap(),
  ];
}
