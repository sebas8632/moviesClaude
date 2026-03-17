# MoviesClaude

## Project Overview
SwiftUI + SwiftData movies app targeting iOS and macOS.

## Structure
```
MoviesClaude/
├── MoviesClaude/          # Main app target
│   ├── MoviesClaudeApp.swift   # App entry point, ModelContainer setup
│   ├── ContentView.swift       # Root view
│   ├── Item.swift              # Placeholder model (to be replaced)
│   └── Assets.xcassets/
├── MoviesClaudeTests/          # Unit tests
└── MoviesClaudeUITests/        # UI tests
```

## Tech Stack
- **SwiftUI** — declarative UI
- **SwiftData** — persistence layer (`@Model`, `@Query`, `modelContext`)
- **Swift** — language
- **Xcode** — IDE

## Conventions
- Use `@Model` for SwiftData model classes
- Use `@Query` for fetching data in views
- Use `@Environment(\.modelContext)` for insert/delete operations
- Prefer `NavigationSplitView` for master-detail layouts on iPad/macOS
- Keep views small and compose them from smaller subviews
- Use comments sparingly; only comment complex or non-obvious code
