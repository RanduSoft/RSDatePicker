# RSDatePicker Code Review Report

**Version reviewed:** v1.8.0
**Date:** 2026-02-19
**Files reviewed:** `RSDatePicker.swift`, `RSDatePicker.xib`, `Package.swift`, `README.md`, `.gitignore`

---

## Bugs

### 1. `"YYYY"` vs `"yyyy"` date format (Line 46)

```swift
case .date: return "dd/MM/YYYY"
```

`YYYY` is the ISO week-numbering year. Around year boundaries (e.g. Dec 31, Jan 1), it can return the wrong year. The calendar year format is lowercase `yyyy`.

**Fix:** Change to `"dd/MM/yyyy"`.

---

### 2. Debug background color left in production code (Line 233)

```swift
datePickerTimeLabel?.backgroundColor = .red // debug
```

A `.red` background is applied to an internal date picker subview. Even at alpha 0.1 this can be faintly visible. This should be removed.

---

### 3. No timer invalidation — memory/resource leak (Lines 170-173)

```swift
self.timer = Timer(timeInterval: 0.5, repeats: true, block: { [weak self] _ in
    self?.hideDateLabel()
})
RunLoop.main.add(self.timer!, forMode: .common)
```

The repeating timer is added to the run loop but never invalidated. There is no `deinit` implementation. If the view is removed from its superview, the timer keeps firing. Even with `[weak self]`, the `Timer` object itself stays alive on the run loop until it is explicitly invalidated. This is a resource leak.

**Fix:** Add a `deinit` that calls `self.timer?.invalidate()`.

---

### 4. `pickerAlignment = .center` can produce `NaN` or `-inf` (Lines 248-249)

```swift
xTransform = 0.285 * log(self.bounds.width - 218 + 60) - 0.175
```

If `self.bounds.width <= 158`, the argument to `log()` is zero or negative, producing `-inf` or `NaN`. This value is then used as a `CGAffineTransform` scale, which will corrupt the view's layout.

**Fix:** Guard against non-positive values before calling `log()`.

---

### 5. Strong `self` capture in `currentDate.didSet` (Lines 54-58)

```swift
public var currentDate: Date? {
    didSet {
        DispatchQueue.main.async {
            self.didUpdateDate()
        }
    }
}
```

`self` is captured strongly in the async block. While unlikely to cause a permanent retain cycle, it extends the view's lifetime unnecessarily past deallocation. The same issue exists in `updateMargins()` (line 300).

**Fix:** Use `[weak self]` in both closures.

---

### 6. `checkDateLimits()` crashes if called before XIB is loaded (Lines 208-210)

```swift
private func checkDateLimits() {
    self.datePicker.minimumDate = self.minimumDate
```

`minimumDate` and `maximumDate` have `didSet` observers that call `checkDateLimits()`, which accesses `self.datePicker`. If these properties are set before `layoutSubviews()` runs (i.e. before the XIB loads), `self.datePicker` is `nil` (it's an `IBOutlet weak var`) and the implicit unwrap crashes.

**Fix:** Guard against `self.datePicker == nil` at the top of `checkDateLimits()`.

---

## Deprecations

### 7. `UIApplication.shared.windows` — deprecated since iOS 15 (Line 315)

```swift
let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
```

**Fix:** Use the scene-based API:
```swift
let keyWindow = UIApplication.shared.connectedScenes
    .compactMap { $0 as? UIWindowScene }
    .flatMap { $0.windows }
    .first { $0.isKeyWindow }
```

---

### 8. `UIScreen.main` — deprecated since iOS 16 (Line 277)

```swift
let screenSize = UIScreen.main.bounds
```

This also returns incorrect values on iPad with external displays.

**Fix:** Use `self.window?.windowScene?.screen.bounds` or the view's own `bounds`.

---

### 9. `CGFloat(MAXFLOAT)` — C legacy constant (Line 185)

```swift
self.datePicker.layer.zPosition = CGFloat(MAXFLOAT)
```

**Fix:** Use `CGFloat.greatestFiniteMagnitude`.

---

## Fragile / Risky Patterns

### 10. Reliance on private UIKit class names (Lines 224-229)

```swift
.filter({ "\($0.classForCoder)" == "_UIDatePickerLinkedLabel" }).first
.filter({ "\($0.classForCoder)" == "_UIDatePickerCompactTimeLabel" }).first
.filter({ "\($0.classForCoder)" == "UIButton" }).first
```

These are undocumented internal class names that Apple can rename or remove in any iOS version. There is no fallback if they are not found — the code silently does nothing, which means the date picker's native label could become visible and overlap with the custom label.

**Recommendation:** Add a comment documenting which iOS versions this was tested on. Consider a fallback strategy (e.g. making the entire `UIDatePicker` fully transparent and handling taps differently).

---

### 11. `forceScalePicker` sets font size 500 on private subviews (Lines 236-238)

```swift
($0 as? UILabel)?.font = .systemFont(ofSize: 500)
```

This relies on finding a `UILabel` inside a private `UIButton` inside a private time label. If the hierarchy changes, this silently breaks. The font size of 500 is also extreme and could cause unexpected layout behavior on future iOS versions.

---

### 12. `hideDateLabel()` runs every 0.5 seconds indefinitely (Lines 170-172)

Each invocation traverses the entire `UIDatePicker` subview hierarchy via `getAllSubviews(from:)`. This is wasteful. The function exists because the date picker can reset its internal labels after interactions, but a repeating timer is a brute-force approach.

**Recommendation:** Consider using KVO on the relevant properties, or only calling `hideDateLabel()` in response to specific events (e.g. `dateChangedAction`, layout changes).

---

### 13. `setAnchorPoint` uses `self.transform` instead of the target view's transform (Line 332)

```swift
newPoint = newPoint.applying(transform) ; oldPoint = oldPoint.applying(transform)
```

The method receives a `view` parameter but uses `self.transform` (the `RSDatePicker` instance's transform, not the target view's transform) when applying the transform. If `self` has a non-identity transform, this produces incorrect anchor point calculations.

**Fix:** Use `view.transform` instead of `transform`.

---

## Code Quality Improvements

### 14. Typo: `parenView` should be `parentView` (Line 383)

```swift
class func getAllSubviews<T: UIView>(from parenView: UIView) -> [T] {
```

---

### 15. Unused utility methods (Lines 391-406)

The following methods are defined but never called anywhere in the codebase:

- `getAllSubviews(from:types:)` (line 391)
- `getAllSubviews<T>()` instance method (line 404)
- `get<T>(all:)` (line 405)
- `get(all types:)` (line 406)

These add dead code to the library.

---

### 16. Asymmetric default margins in XIB

The XIB defines `leading = 10`, `trailing = 8`, `top = 8`, `bottom = 8`. However, the Swift code defaults all margins to `8`. The XIB's leading margin of 10 is overwritten by `updateMargins()` at line 190 anyway, but the inconsistency between XIB and code defaults is confusing.

---

### 17. Force unwrap on `calendarIconImage` default (Line 92)

```swift
public var calendarIconImage: UIImage = UIImage(systemName: "calendar")!
```

While `"calendar"` is a standard SF Symbol unlikely to be removed, force unwrapping system resources is a risky pattern. If Apple ever changes SF Symbol availability based on OS version, this crashes at property initialization time.

---

### 18. Mixed indentation (tabs vs spaces)

The file inconsistently uses tabs (e.g. lines 19-31, 60-69) and spaces (e.g. lines 33-50, 74-78). This causes messy diffs and is worth standardizing.

---

### 19. `dateChangedAction` only checks day changes for close behavior (Line 265)

```swift
let changedDay = Calendar.current.component(.day, from: self.currentDate ?? Date()) != Calendar.current.component(.day, from: sender.date)
```

When `pickerMode` is `.time`, this comparison is meaningless because the day component doesn't change. The close-on-select behavior will never trigger in time mode.

---

### 20. No accessibility support

None of the views have accessibility labels, hints, or identifiers — neither in the XIB nor set programmatically. VoiceOver users will have a poor experience with this component.

---

## Package / Configuration

### 21. Swift tools version 5.5 is outdated

`Package.swift` specifies `swift-tools-version:5.5`. The current stable Swift tools version is 6.x. While 5.5 maximizes backward compatibility, it also prevents using newer SPM features.

---

### 22. No test target

The package has no test target. There are no unit tests or UI tests for any of the public API.

---

### 23. `.gitignore` contradicts itself on `.swiftpm`

```
.swiftpm/*
.swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata
```

Line 7 ignores everything under `.swiftpm/`, and line 8 tries to un-ignore a specific file. However, Git's ignore rules require using `!` to negate a pattern. The second line is treated as a redundant ignore pattern, not an exception. The `contents.xcworkspacedata` file is still ignored.

**Fix:**
```
.swiftpm/*
!.swiftpm/xcode/
!.swiftpm/xcode/package.xcworkspace/
!.swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata
```

---

## README

### 24. Missing documentation for several public properties

The README does not mention: `font`, `textColor`, `backgroundColor`, `cornerRadius`, `closeAnimationDuration` default value, or the `updateUI()` override point.

### 25. Code fence not closed

The full example code block at the end of the README uses triple backticks with `swift` but the outer markdown code fence is not properly nested, causing rendering issues on some markdown parsers.

---

## Summary

| Severity | Count | Issues |
|----------|-------|--------|
| Bug | 6 | #1, #2, #3, #4, #5, #6 |
| Deprecation | 3 | #7, #8, #9 |
| Fragile/Risky | 4 | #10, #11, #12, #13 |
| Code Quality | 6 | #14, #15, #16, #17, #18, #19 |
| Package/Config | 3 | #21, #22, #23 |
| Documentation | 2 | #24, #25 |
| **Total** | **24** | |
