# RSDatePicker

A customizable UIView date/time picker that presents a native picker in a dropdown-style popover. Requires iOS 15 or newer.

<img src="https://i.imgur.com/Jv8IlHh.png" width="150"> <img src="https://i.imgur.com/KSvxX5D.png" width="150"> <img src="https://i.imgur.com/iyT9eP6.png" width="150">

## Setup

- **Storyboard**: Create a `UIView`, set its custom class to `RSDatePicker`, and connect it with an `@IBOutlet`

- **Code**: `let datePicker = RSDatePicker(frame: CGRect(x: 0, y: 0, width: 200, height: 44))`

## Usage

Tapping the view opens a popover containing a `UIDatePicker` — inline calendar for date mode, spinning wheels for time mode.

### Configuration

| Property | Type | Default | Description |
|---|---|---|---|
| `currentDate` | `Date?` | `nil` | Selected date. Shows placeholder when `nil` |
| `initialText` | `String?` | `nil` | Placeholder text. Auto-derives from `pickerMode` when `nil` |
| `minimumDate` | `Date?` | `nil` | Minimum selectable date |
| `maximumDate` | `Date?` | `nil` | Maximum selectable date |
| `pickerMode` | `PickerMode` | `.date` | `.date` (inline calendar) or `.time` (wheels) |
| `dateFormat` | `String?` | `nil` | Custom date format. Uses `dd/MM/yyyy` or `HH:mm` by default |
| `closeWhenSelectingDate` | `Bool` | `true` | Auto-close popover after selection (date mode only) |

### Appearance

| Property | Type | Default | Description |
|---|---|---|---|
| `font` | `UIFont?` | System 17pt | Label font |
| `textColor` | `UIColor?` | `.label` | Label text color |
| `calendarIconIsHidden` | `Bool` | `false` | Hide the icon |
| `calendarIconTint` | `UIColor` | `.label` | Icon tint color |
| `calendarIconSizeMultiplier` | `CGFloat` | `0.75` | Icon size relative to view height (0.1–1.0) |
| `calendarIconImage` | `UIImage?` | `nil` | Custom icon. Auto-derives from `pickerMode` when `nil` |
| `leftMargin` | `CGFloat` | `16` | Left content margin |
| `rightMargin` | `CGFloat` | `16` | Right content margin |
| `topMargin` | `CGFloat` | `8` | Top content margin |
| `bottomMargin` | `CGFloat` | `8` | Bottom content margin |

### Popover

| Property | Type | Default | Description |
|---|---|---|---|
| `popoverAlignment` | `PopoverAlignment` | `.trailing` | Arrow anchor: `.leading`, `.center`, or `.trailing` |
| `popoverSize` | `CGSize?` | `nil` | Custom popover size. Uses sensible defaults when `nil` |
| `pickerTintColor` | `UIColor?` | `nil` | Tint color for the picker inside the popover |

### Callback

```swift
datePicker.didChangeDate = { newDate in
    print(newDate)
}
```

### Subclassing

Override `updateUI()` for custom setup that runs after initialization.

## Full example

```swift
import RSDatePicker

@IBOutlet weak var datePicker: RSDatePicker!

datePicker.layer.cornerRadius = 16
datePicker.pickerMode = .date
datePicker.currentDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())
datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())

datePicker.font = .systemFont(ofSize: 18, weight: .medium)
datePicker.textColor = .systemIndigo
datePicker.calendarIconTint = .systemIndigo
datePicker.pickerTintColor = .systemIndigo
datePicker.calendarIconSizeMultiplier = 0.6

datePicker.popoverAlignment = .center
datePicker.closeWhenSelectingDate = true

datePicker.didChangeDate = { newDate in
    print(newDate)
}
```

## Migrating from v1

v2.0.0 is a full rewrite. The view no longer uses a XIB or an invisible `UIDatePicker` overlay — it presents a native picker in a popover instead.

### Minimum iOS

Raised from **13.4** to **15.0**.

### Removed properties

| v1 Property | Action |
|---|---|
| `forceScalePicker` | Remove. The popover handles sizing on all devices |
| `closeAnimationDuration` | Remove. The system popover animation is used |
| `pickerAlignment` (`NSTextAlignment`) | Replace with `popoverAlignment` (`.leading` / `.center` / `.trailing`) |

### Changed properties

| Property | v1 | v2 |
|---|---|---|
| `initialText` | `String` (default `"Select {DATE/TIME}"`) | `String?` (default `nil`, auto-derives from `pickerMode`) |
| `calendarIconImage` | `UIImage` (force-unwrapped default) | `UIImage?` (default `nil`, auto-derives from `pickerMode`) |
| `calendarIconSizeMultiplier` | `CGFloat?` (default `nil`) | `CGFloat` (default `0.75`) |
| `pickerMode` | `PickerMode?` (default `nil`) | `PickerMode` (default `.date`) |
| `leftMargin` / `rightMargin` | `Double` (default `8`) | `CGFloat` (default `16`) |

### New properties

| Property | Description |
|---|---|
| `popoverAlignment` | `.leading`, `.center`, `.trailing` — controls popover arrow position |
| `popoverSize` | Optional custom popover dimensions |
| `pickerTintColor` | Tint color for the picker inside the popover |

### Other changes

- The `view` IBOutlet is removed. Background color is set directly on the `RSDatePicker` instance.
- `@available(iOS 15.0, *)` annotations are removed since the package declares iOS 15 minimum.
- The icon automatically switches between `calendar` (date) and `clock` (time) based on `pickerMode`.

## License

RSDatePicker is available under the **MPL-2.0 license**. More info available [here](https://www.mozilla.org/en-US/MPL/2.0/).
