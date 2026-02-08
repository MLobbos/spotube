# Performance Optimization Guide for Spotube

## Overview
This document outlines performance optimization strategies and best practices for developing Spotube.

## State Management Best Practices

### Minimize `ref.watch()` Rebuilds
- **Use selective watching**: Instead of watching entire providers, use `.select()` to watch specific values:
  ```dart
  // ❌ Bad - rebuilds on any userPreferences change
  final prefs = ref.watch(userPreferencesProvider);
  final themeMode = prefs.themeMode;
  
  // ✅ Good - rebuilds only when themeMode changes
  final themeMode = ref.watch(userPreferencesProvider.select((s) => s.themeMode));
  ```

### Proper Use of `ref.listen()` vs `ref.watch()`
- **Use `ref.listen()`** for side effects (navigation, showing toasts, logging)
- **Use `ref.watch()`** for building UI that depends on state
- Keep `ref.listen()` callbacks lightweight

### Provider Optimization
- Mark providers as `autoDispose` when appropriate to free memory
- Use `family` modifiers for parameterized providers
- Consider caching expensive computations with `keepAlive()`

## Widget Optimization

### Use `const` Constructors Everywhere Possible
- Mark widgets as `const` when they don't depend on runtime values
- Helps Flutter skip rebuilding unchanged widget subtrees
- New lint rules enforce this: `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`

### Avoid Unnecessary Widget Rebuilds
- Split large widgets into smaller, focused widgets
- Use `HookConsumerWidget` instead of `StatefulWidget` where possible
- Move expensive operations out of the `build` method

## Initialization Optimization

### Current Initialization Sequence (main.dart)
The app initializes multiple services sequentially:
1. MediaKit initialization
2. Database setup
3. Encrypted storage
4. Window manager (desktop)
5. Discord RPC (desktop)
6. Multiple provider listeners (~11 ref.listen calls)

### Lazy Loading Recommendations
Consider lazy initialization for:
- **Discord RPC**: Load only when user enables it
- **Metadata plugins**: Load on-demand rather than at startup
- **Window manager tools**: Initialize only when needed
- **Home widget**: Initialize only on mobile platforms

## Database Performance

### Drift/SQLite Best Practices
- Use indexed columns for frequently queried fields
- Batch operations when inserting/updating multiple rows
- Avoid N+1 queries (use joins instead of multiple queries)
- Use compiled statements for repeated queries

## Memory Management

### Image Caching
- The app uses `cached_network_image` for efficient image caching
- Consider limiting cache size for mobile devices
- Implement cache eviction policies for old/unused images

### Audio Player Resources
- Properly dispose audio resources when not in use
- Monitor memory usage during long playback sessions
- Consider releasing resources when app is backgrounded

## Network Optimization

### API Calls
- Batch API requests when possible
- Implement request debouncing for search queries
- Use pagination for large data sets
- Cache API responses when appropriate

## Build Optimization

### Code Generation
- Use `build_runner` watch mode during development
- Keep generated files (`.g.dart`, `.freezed.dart`) in version control
- Run full build before releases to ensure consistency

### Tree Shaking
- Avoid importing entire packages when only using specific functions
- Use conditional imports for platform-specific code
- Remove unused dependencies

## Monitoring & Profiling

### Performance Monitoring
- Use Flutter DevTools for performance profiling
- Monitor frame rendering times (aim for 60fps)
- Track memory usage during extended sessions
- Profile startup time on different devices

### Key Metrics to Track
- App startup time
- Frame build time
- Memory usage
- Network request latency
- Database query performance

## Platform-Specific Optimizations

### Desktop
- Window initialization can be delayed until first shown
- Tray icon updates should be throttled
- Discord RPC updates should be batched

### Mobile
- Battery optimization permissions
- Background task limitations
- Home widget updates should be efficient
- Consider using display refresh rate APIs

### Web
- Lazy load large assets
- Minimize initial bundle size
- Use web workers for heavy computations

## Current Performance Issues (As of 2024)

### Identified Areas for Improvement
1. **main.dart initialization**: Multiple sequential async operations could be parallelized
2. **ref.watch() usage**: 156 instances across codebase - audit for unnecessary rebuilds
3. **Database queries**: Review Drift queries for optimization opportunities
4. **Image loading**: Ensure proper cache management and limits

## References
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Riverpod Performance Tips](https://riverpod.dev/docs/essentials/performance)
- [Drift Performance Guide](https://drift.simonbinder.eu/docs/advanced-features/performance/)