/// GitHub configuration template.
///
/// 1. Go to https://github.com/settings/tokens?type=beta
/// 2. Click "Generate new token" → "Fine-grained token"
/// 3. Set:
///    - Repository access: "Only select repositories" → select celpha2svx/DocFlow
///    - Permissions: Issues → Read and write
/// 4. Generate and copy the token

class GitHubConfig {
  GitHubConfig._();

  /// Paste your fine-grained PAT here
  static const String token = 'github_pat_...';

  static const String repoOwner = 'celpha2svx';
  static const String repoName = 'DocFlow';
}

/// To activate, rename this file to github_config.dart
