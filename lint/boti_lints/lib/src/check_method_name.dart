import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class CheckMethodName extends DartLintRule {
  const CheckMethodName() : super(code: _code);

  static const _code = LintCode(
    name: 'check_method_name',
    problemMessage:
        '😨 Você usou a palavra [metodo] para dar nome ao método?! Você é biruleibe?! Você é pixuruco??',
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
