import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoEmitAfterAsyncGap extends DartLintRule {
  const NoEmitAfterAsyncGap() : super(code: _code);

  static const _code = LintCode(
    name: 'no_emit_after_async_gap',
    problemMessage:
        'Do not use emit() after await without checking if Cubit is closed. Add "if (isClosed) return;" before emit.',
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
  void visitBlock(Block node) {
    final statements = node.statements;
    final awaitIndexes = <int>{};

    // Descobre onde há await
    for (int i = 0; i < statements.length; i++) {
      bool hasAwait = false;
      statements[i].visitChildren(_AwaitFinder((_) => hasAwait = true));
      if (hasAwait) awaitIndexes.add(i);
    }

    // Para cada emit, verifica se está protegido
    for (int i = 0; i < statements.length; i++) {
      statements[i].visitChildren(
        _EmitFinder((emitNode) {
          bool isGuarded = false;

          // Caso 1: if (isClosed) return; logo acima
          if (i > 0) {
            final prev = statements[i - 1];
            if (prev is IfStatement && _isIsClosedReturnGuard(prev)) {
              isGuarded = true;
            }
          }

          // Caso 2: dentro de if (!isClosed) { emit(...) }
          AstNode? parent = emitNode.parent;
          while (parent != null) {
            if (parent is IfStatement &&
                _isNotIsClosedGuard(parent, emitNode)) {
              isGuarded = true;
              break;
            }
            parent = parent.parent;
          }

          // Só reporta se não estiver protegido e houver await antes
          if (!isGuarded && awaitIndexes.any((awaitIdx) => awaitIdx < i)) {
            reporter.atNode(emitNode, NoEmitAfterAsyncGap._code);
          }
        }),
      );
    }
    super.visitBlock(node);
  }
}

class _AwaitFinder extends RecursiveAstVisitor<void> {
  final void Function(AwaitExpression) onAwait;
  _AwaitFinder(this.onAwait);
  @override
  void visitAwaitExpression(AwaitExpression node) {
    onAwait(node);
    super.visitAwaitExpression(node);
  }
}

class _EmitFinder extends RecursiveAstVisitor<void> {
  final void Function(MethodInvocation) onEmit;
  _EmitFinder(this.onEmit);
  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'emit') {
      onEmit(node);
    }
    super.visitMethodInvocation(node);
  }
}

// Função auxiliar: if (isClosed) return;
bool _isIsClosedReturnGuard(IfStatement stmt) {
  final cond = stmt.expression;
  if (cond is SimpleIdentifier && cond.name == 'isClosed') {
    final thenStmt = stmt.thenStatement;
    if (thenStmt is ReturnStatement) {
      return true;
    }
  }
  return false;
}

// Função auxiliar: if (!isClosed) { emit(...) }
bool _isNotIsClosedGuard(IfStatement stmt, AstNode emitNode) {
  final cond = stmt.expression;
  if (cond is PrefixExpression &&
      cond.operator.lexeme == '!' &&
      cond.operand is SimpleIdentifier &&
      (cond.operand as SimpleIdentifier).name == 'isClosed') {
    final thenStmt = stmt.thenStatement;
    if (thenStmt is Block &&
        thenStmt.statements.any((s) => s == emitNode.parent)) {
      return true;
    }
  }
  return false;
}
