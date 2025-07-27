import 'package:boti_lints/src/avoid_emit_without_guard.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _BotiLints();

class _BotiLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    const AvoidEmitWithoutGuard(),
  ];
}
