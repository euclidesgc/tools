import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// Regra "Hello, World!": apenas encontra o método `emit`.
class NoEmitAfterAsyncGap extends DartLintRule {
  const NoEmitAfterAsyncGap() : super(code: _code);

  // O nome da regra continua o mesmo para não precisarmos mudar o analysis_options.yaml
  static const _code = LintCode(
    name: 'no_emit_after_async_gap',
    problemMessage: 'SUCESSO: O lint encontrou uma chamada ao método emit()!',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      if (node.name.lexeme.startsWith('emit')) {
        reporter.atNode(node, code);
      }
    });
  }
}
