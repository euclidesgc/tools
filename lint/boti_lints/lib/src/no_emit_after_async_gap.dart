import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoEmitAfterAsyncGap extends DartLintRule {
  const NoEmitAfterAsyncGap() : super(code: _code);

  static const _code = LintCode(
    name: 'no_emit_after_async_gap',
    problemMessage:
        'Não chame "emit" após um gap assíncrono (await) sem antes verificar a propriedade "isClosed".',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'emit') return;

      final targetType = node.realTarget?.staticType ??
          node
              .thisOrAncestorOfType<ClassDeclaration>()
              ?.declaredElement
              ?.thisType;

      if (targetType == null || !_isBlocOrCubit(targetType)) {
        return;
      }

      final asyncVisitor = _AsyncGapVisitor();
      node.parent?.accept(asyncVisitor);

      if (asyncVisitor.foundAsyncGap && !asyncVisitor.isGuarded) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }

  bool _isBlocOrCubit(DartType type) {
    if (type is! InterfaceType) return false;
    return type.allSupertypes.any((supertype) =>
        supertype.element.name == 'BlocBase' &&
        supertype.element.library.name == 'bloc');
  }
}

class _AsyncGapVisitor extends UnifyingAstVisitor<void> {
  bool foundAsyncGap = false;
  bool isGuarded = false;

  @override
  void visitNode(AstNode node) {
    if (isGuarded || node is FunctionBody) return;
    _checkNode(node);
    if (!isGuarded) {
      node.parent?.accept(this);
    }
  }

  void _checkNode(AstNode node) {
    if (node is AwaitExpression) {
      foundAsyncGap = true;
      return;
    }

    if (node is IfStatement) {
      final condition = _unparenthesize(node.expression);

      if ((condition is Identifier && condition.name == 'isClosed') ||
          (condition is PropertyAccess &&
              condition.propertyName.name == 'isClosed')) {
        if (_statementExits(node.thenStatement)) {
          isGuarded = true;
        }
      }
    }
  }

  Expression _unparenthesize(Expression expression) {
    var current = expression;
    while (current is ParenthesizedExpression) {
      current = current.expression;
    }
    return current;
  }

  bool _statementExits(Statement statement) {
    if (statement is ReturnStatement) return true;
    if (statement is Block && statement.statements.isNotEmpty) {
      return _statementExits(statement.statements.last);
    }
    return false;
  }
}
