import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoEmitAfterAsyncGap extends DartLintRule {
  const NoEmitAfterAsyncGap() : super(code: _code);

  static const _code = LintCode(
    name: 'no_emit_after_async_gap',
    problemMessage:
        'Não chame "emit" após um gap assíncrono (await) sem antes verificar a propriedade "isClosed".',
    correctionMessage:
        'Antes de chamar "emit", adicione uma verificação como "if (isClosed) return;".',
  );

  @override
  void run(CustomLintResolver resolver, reporter, CustomLintContext context) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'emit') return;

      final target = node.realTarget;
      final type =
          target?.staticType ??
          node
              .thisOrAncestorOfType<ClassDeclaration>()
              ?.declaredElement
              ?.thisType;

      if (type == null || !_isBlocOrCubit(type, resolver)) {
        return;
      }

      final asyncVisitor = _AsyncGapVisitor();
      node.parent?.accept(asyncVisitor);

      if (asyncVisitor.foundAsyncGap && !asyncVisitor.isGuarded) {
        reporter.atNode(node, code);
      }
    });
  }

  bool _isBlocOrCubit(DartType type, CustomLintResolver resolver) {
    final typeName = type.getDisplayString();
    return typeName.contains('Bloc') || typeName.contains('Cubit');
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
      final condition = node.expression;
      if (condition is SimpleIdentifier && condition.name == 'isClosed') {
        if (_statementExits(node.thenStatement)) {
          isGuarded = true;
        }
      }
    }
  }

  bool _statementExits(Statement statement) {
    // Não existe unParenthesized para Statement, então apenas use statement.
    if (statement is ReturnStatement ||
        statement is BreakStatement ||
        statement is ContinueStatement ||
        statement is ThrowExpression) {
      return true;
    }
    if (statement is Block && statement.statements.isNotEmpty) {
      return _statementExits(statement.statements.last);
    }
    return false;
  }
}
