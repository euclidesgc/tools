import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/no_emit_after_async_gap.dart';

PluginBase createPlugin() => _BotiLints();

class _BotiLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    const NoEmitAfterAsyncGap(),
  ];
}
