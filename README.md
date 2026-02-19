# RSDatePicker

A customizable UIView date/time picker that presents an inline picker in a dropdown popover. Requires iOS 15 or newer.

## Setup

- **Storyboard**: Create a `UIView`, set its custom class to `RSDatePicker`, and connect it with an `@IBOutlet`

- **Code**: `let datePicker = RSDatePicker(frame: CGRect(x: 0, y: 0, width: 200, height: 44))`

## Usage

Tapping the view opens a popover with the native `UIDatePicker` in inline style, similar to a dropdown.

### Configuration

- `currentDate` sets the selected date (optional — shows `initialText` when nil)
- `initialText` sets the placeholder text when no date is selected
- `minimumDate` sets the minimum selectable date (optional)
- `maximumDate` sets the maximum selectable date (optional)
- `pickerMode` sets the picker mode (`.date` or `.time`)
- `dateFormat` sets the date format for the visible label (optional)
- `closeWhenSelectingDate` enables auto-close after a date is picked (date mode only)

### Appearance

- `font` sets the label font
- `textColor` sets the label text color
- `calendarIconIsHidden` controls calendar icon visibility
- `calendarIconTint` sets the icon tint color
- `calendarIconSizeMultiplier` controls the icon size relative to the view height (0.1–1.0)
- `calendarIconImage` sets a custom icon image
- `left/right/top/bottomMargin` adjusts the content margins

### Popover

- `popoverAlignment` controls where the popover arrow points (`.leading`, `.center`, `.trailing`)
- `popoverSize` sets a custom popover size (optional — uses sensible defaults)

### Callback

Use `didChangeDate` to receive the selected date:

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
datePicker.leftMargin = 20
datePicker.rightMargin = 16

datePicker.pickerMode = .date
datePicker.currentDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
datePicker.initialText = "Select Date"
datePicker.calendarIconIsHidden = false
datePicker.calendarIconTint = .label
datePicker.calendarIconSizeMultiplier = 0.8
datePicker.calendarIconImage = UIImage(systemName: "calendar")
datePicker.popoverAlignment = .center
datePicker.closeWhenSelectingDate = true
datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: -4, to: Date())
datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 20, to: Date())
datePicker.didChangeDate = { newDate in
    print(newDate)
}
```

## License

RSDatePicker is available under the **MPL-2.0 license**. More info available [here](https://www.mozilla.org/en-US/MPL/2.0/).
