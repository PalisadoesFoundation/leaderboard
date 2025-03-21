class GithubConstants {
  static const String baseUrl = 'https://api.github.com/graphql';
  static const String owner = 'PalisadoesFoundation';
  static const List<String> repositories = ['talawa', 'talawa-docs', 'talawa-admin', 'talawa-api'];

  static const Set<String> excludedUsers = {
    'dependabot[bot]',
    'dependabot-preview[bot]',
    'coderabbitai[bot]',
    'coderabbitai',
    'github-actions[bot]',
    'github-actions',
    'actions-user',
    'github-code-scanning[bot]',
    'allcontributors[bot]',
    'codecov[bot]',
    'codecov',
    'deepsource-autofix[bot]',
    'deepsource-autofix',
    'imgbot[bot]',
    'pre-commit-ci[bot]',
    'renovate[bot]',
    'stale[bot]',
    'whitesource-bolt-for-github[bot]',
    'semantic-release[bot]',
    'sonarcloud[bot]',
    'github-code-scanning',
    'snyk-bot',
    'restyled-io[bot]',
    'mergify[bot]',
    'azure-pipelines[bot]',
    'github-learning-lab[bot]',
    'fossabot',
    'github-advanced-security[bot]',
    'github-advanced-security',
    'dependabot-preview',
    'dependabot',
  };

  static const Set<String> excludedAuthors = {
    'palisadoes',
  };
}
