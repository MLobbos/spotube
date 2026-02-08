# Security Best Practices for Spotube

## Overview
This document outlines security best practices for developing and contributing to Spotube.

## Secrets Management

### Environment Variables
- **NEVER** commit secrets or API keys to version control
- Use `.env` files for local development (already in `.gitignore`)
- Use `envied` package for compile-time environment variables
- Example `.env.example` is provided as a template

### API Keys and Tokens
```dart
// ✅ Good - Using envied for secrets
@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SPOTIFY_CLIENT_ID')
  static const String spotifyClientId = _Env.spotifyClientId;
}

// ❌ Bad - Hardcoded secrets
const String apiKey = "abc123def456"; // NEVER DO THIS
```

## Data Encryption

### Sensitive User Data
- Use `flutter_secure_storage` for sensitive data (credentials, tokens)
- The app uses `EncryptedKvStoreService` for encrypted storage
- Never store sensitive data in plain text

### Encrypted Storage Usage
```dart
// ✅ Good - Using encrypted storage
await EncryptedKvStoreService.set('auth_token', token);

// ❌ Bad - Using plain storage for sensitive data
await SharedPreferences.getInstance().then((prefs) => 
  prefs.setString('auth_token', token) // Unencrypted!
);
```

## Network Security

### HTTPS Only
- Always use HTTPS for API calls
- Validate SSL certificates (avoid disabling certificate validation)
- Use certificate pinning for critical APIs if needed

### API Request Security
```dart
// ✅ Good - Proper error handling without exposing details
try {
  final response = await dio.get(url);
  return response.data;
} catch (e) {
  logger.error('API request failed', error: e);
  throw AppException('Failed to fetch data');
}

// ❌ Bad - Exposing internal errors to users
try {
  final response = await dio.get(url);
  return response.data;
} catch (e) {
  showDialog('Error: ${e.toString()}'); // May expose sensitive info
}
```

## Input Validation

### User Input Sanitization
- Always validate and sanitize user input
- Use parameterized queries for database operations (Drift handles this)
- Validate file paths and prevent path traversal attacks

### SQL Injection Prevention
```dart
// ✅ Good - Drift uses parameterized queries
await database.customSelect(
  'SELECT * FROM tracks WHERE name = ?',
  variables: [Variable.withString(userInput)],
).get();

// ❌ Bad - String interpolation (vulnerable to SQL injection)
await database.customSelect(
  'SELECT * FROM tracks WHERE name = "$userInput"'
).get();
```

## Authentication & Authorization

### Token Management
- Store auth tokens securely using encrypted storage
- Implement token refresh logic
- Clear tokens on logout
- Use short-lived tokens when possible

### Third-Party Authentication
- Use OAuth2 flows correctly
- Validate redirect URIs
- Don't expose client secrets in client-side code

## File System Security

### Safe File Operations
```dart
// ✅ Good - Validate file paths
Future<File> downloadTrack(String trackId, String filename) async {
  // Sanitize filename
  final safeFilename = filename.replaceAll(RegExp(r'[^\w\s.-]'), '');
  final downloadDir = await getApplicationDocumentsDirectory();
  final file = File('${downloadDir.path}/$safeFilename');
  
  // Prevent path traversal
  if (!file.path.startsWith(downloadDir.path)) {
    throw SecurityException('Invalid file path');
  }
  
  return file;
}

// ❌ Bad - Unvalidated file paths
Future<File> downloadTrack(String filename) async {
  return File('/downloads/$filename'); // Vulnerable to path traversal
}
```

## Logging Security

### Safe Logging Practices
```dart
// ✅ Good - Don't log sensitive data
logger.info('User logged in: ${user.id}');

// ❌ Bad - Logging sensitive information
logger.info('User logged in: ${user.email} with token ${user.authToken}');
```

### Production Logging
- Never log passwords, tokens, or API keys
- Redact sensitive information in logs
- Be cautious with error messages that may expose system details

## Dependency Security

### Keeping Dependencies Updated
- Regularly update dependencies to get security patches
- Review dependency changelogs for security fixes
- Use `flutter pub outdated` to check for updates

### Dependency Auditing
```bash
# Check for known vulnerabilities
flutter pub deps --style=list | grep -i security
```

### Git Dependencies
- Pin specific commits for git dependencies
- Review code changes in git dependencies before updating
- Consider security implications of third-party code

## Platform-Specific Security

### Android
- Use ProGuard/R8 for code obfuscation in release builds
- Enable Android backup encryption
- Request only necessary permissions
- Validate app signing certificates

### iOS
- Use Keychain for sensitive data storage
- Enable Data Protection
- Validate App Transport Security settings
- Use proper entitlements

### Desktop
- Validate deep links and custom URL schemes
- Sanitize command-line arguments
- Be cautious with native code execution
- Implement proper file permissions

## Plugin Security

### Third-Party Plugins
- Review plugin source code before installation
- Verify plugin signatures/checksums
- Monitor plugin updates for security issues
- Sandbox plugin execution when possible

### Plugin API Security
```dart
// ✅ Good - Validate plugin inputs
Future<dynamic> executePlugin(Plugin plugin, Map<String, dynamic> input) async {
  // Validate plugin
  if (!isPluginTrusted(plugin)) {
    throw SecurityException('Untrusted plugin');
  }
  
  // Sanitize inputs
  final sanitizedInput = sanitizePluginInput(input);
  
  return await plugin.execute(sanitizedInput);
}
```

## Code Review Security Checklist

Before submitting a PR, ensure:
- [ ] No hardcoded secrets or API keys
- [ ] Sensitive data is encrypted at rest
- [ ] All user inputs are validated and sanitized
- [ ] Error messages don't expose sensitive information
- [ ] Dependencies are up-to-date
- [ ] No SQL injection vulnerabilities
- [ ] File operations validate paths
- [ ] Authentication tokens are handled securely
- [ ] Logging doesn't include sensitive data
- [ ] Platform-specific security best practices are followed

## Vulnerability Reporting

If you discover a security vulnerability in Spotube:
1. **DO NOT** open a public issue
2. Email the maintainers directly (check README for contact info)
3. Include detailed steps to reproduce
4. Allow time for the issue to be fixed before public disclosure

## Security Tools

### Recommended Tools
- **flutter analyze** - Built-in static analysis
- **CodeQL** - Advanced security scanning (available in CI)
- **OWASP Dependency Check** - Check for known vulnerabilities
- **Semgrep** - Pattern-based code analysis

### Running Security Scans
```bash
# Static analysis
flutter analyze

# Dependency audit
flutter pub outdated --json
```

## Additional Resources

- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [Dart Security Guidelines](https://dart.dev/guides/security)