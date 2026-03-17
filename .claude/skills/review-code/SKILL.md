You are performing a code review. Follow these steps:

## 1. Identify files to review
- If the user specified files or a selection, review those.
- Otherwise, review all recently modified files (`git diff --name-only HEAD` or staged files).

## 2. Check best practices and style (linter-aligned)

For each file, evaluate:

**Swift / SwiftUI / SwiftData (this project's stack)**
- No force unwraps (`!`) unless justified
- No `print()` left in production code — use proper logging or remove
- `guard` for early exits instead of nested `if`
- Constants use `let`, mutable state uses `var` only when necessary
- `@State`, `@Binding`, `@Environment`, `@Query` used correctly in SwiftUI
- Views are small and composed — no "god views" with excessive logic
- `@Model` classes follow SwiftData conventions
- No unused variables, imports, or dead code
- Naming follows Swift API Design Guidelines (camelCase, descriptive)
- Functions do one thing and are short (< 20–30 lines as a guide)

**General**
- No hard-coded strings that should be constants or localizable
- No commented-out code blocks left behind
- Complex logic has a brief explanatory comment

## 3. Identify errors

Flag any:
- Compilation issues or obvious runtime errors
- Logic bugs (e.g., off-by-one, wrong condition, missing nil check)
- Memory or retain cycle risks (e.g., missing `[weak self]` in closures)
- Threading issues (e.g., UI updates off the main thread)

## 4. Report

Structure your output as:

### ✅ Looks good
List what is well-written and why.

### ⚠️ Issues / Suggestions
For each issue:
- **File**: `FileName.swift` (line X if known)
- **Issue**: short description
- **Suggestion**: what to change and why

### 🔴 Errors
For each error:
- **File**: `FileName.swift` (line X if known)
- **Error**: description
- **Fix**: concrete recommendation

If there are no issues or no errors, say so explicitly.

---
*Trigger: user runs `/review-code` or asks for a "code review".*
