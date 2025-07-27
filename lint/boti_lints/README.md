
# boti_lints

Um pacote de regras de lint personalizadas para projetos Dart/Flutter que utilizam Cubit/Bloc.

## Objetivo

O objetivo deste pacote é fornecer uma regra de lint que previne o uso do método `emit()` após um `await` sem a devida verificação se o Cubit foi fechado. Isso ajuda a evitar exceções e comportamentos inesperados em aplicações que utilizam o padrão Cubit/Bloc.

A regra principal implementada é:
- **avoid_emit_without_guard**: Garante que, após um `await`, o método `emit()` só seja chamado se houver uma verificação prévia de `isClosed`.

## Como utilizar em outros projetos

1. Adicione o pacote ao seu projeto (no `pubspec.yaml`):

```yaml
dependencies:
  boti_lints:
    git:
      url: https://github.com/euclidesgc/tools.git
      path: tools/lint/boti_lints
```

2. No arquivo `analysis_options.yaml` do seu projeto, adicione:

```yaml
analyzer:
  plugins:
    - boti_lints
```

3. Rode o comando do custom_lint para analisar seu projeto:

```sh
flutter pub run custom_lint
```

## Limitações

### Limitações do custom_lint_builder
- O `custom_lint_builder` não permite, atualmente, selecionar quais regras do plugin serão ativadas ou desativadas individualmente via `analysis_options.yaml`. Todas as regras do plugin são aplicadas automaticamente.
- Isso pode causar conflitos ou incômodos caso você queira utilizar apenas uma regra específica.
- Existem bugs conhecidos relacionados a esta limitação, como relatado em [custom_lint#issue/99](https://github.com/dart-code-checker/custom_lint/issues/99).

### Por que não usamos abordagem do bloc_lint?
- O pacote [bloc_lint](https://pub.dev/packages/bloc_lint) utiliza uma abordagem diferente, implementando lints diretamente como um analyzer plugin, o que permite maior granularidade na configuração das regras.
- Optamos por usar o `custom_lint_builder` por ser mais simples de implementar e manter, mesmo com as limitações atuais.
- Caso o `custom_lint_builder` evolua para permitir configuração granular, pretendemos adotar essa funcionalidade.

## Referências
- [Documentação do custom_lint](https://pub.dev/packages/custom_lint)
- [Discussão sobre seleção de regras no custom_lint](https://github.com/dart-code-checker/custom_lint/issues/99)
- [bloc_lint](https://pub.dev/packages/bloc_lint)
- [Discussão sobre emit após await e isClosed (issue avoid_async_emit)](https://github.com/felangel/bloc/issues/4490)

---

Sinta-se à vontade para contribuir ou sugerir melhorias!
