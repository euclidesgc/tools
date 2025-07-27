import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoEmitAfterAsyncGap extends DartLintRule {
  const NoEmitAfterAsyncGap() : super(code: _code);

  static const _code = LintCode(
    name: 'no_emit_after_async_gap',
    problemMessage: 'Achei uma função emit() aqui!',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      node.body.visitChildren(_EmitMethodVisitor(reporter));
    });
  }
}

class _EmitMethodVisitor extends RecursiveAstVisitor<void> {
  final ErrorReporter reporter;
  _EmitMethodVisitor(this.reporter);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'emit') {
      reporter.atNode(node, NoEmitAfterAsyncGap._code);
    }
    super.visitMethodInvocation(node);
  }
}
