import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class BotiSimpleRule extends DartLintRule {
  const BotiSimpleRule() : super(code: _code);

  static const _code = LintCode(
    name: 'boti_method_check',
    problemMessage: 'SUCESSO: O lint simples foi detectado neste método!',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      if (node.name.lexeme.startsWith('metodo')) {
        reporter.atNode(node, code);
      }
    });
  }
}
