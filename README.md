# RSDatePicker

A beautiful UIView wrapper for UIDatePicker. Requires iOS 13.4 or newer

## Setup
- Storyboard

Create a `UIView` and set its custom class to `RSDatePicker` and link it with a `IBOutlet` in the class you want

- Code
 
`let datePicker = RSDatePicker(frame: CGRect)`

## Usage

You can customize the date picker in multiple ways:

- `currentDate` sets the default date (optional)
- `initialText` sets the default text if a date is not selected (optional)
- `minimumDate` sets the minimum selectable date (optional)
- `maximumDate` sets the maximum selectable date (optional)
- `pickerMode` sets the date picker mode (`.date` or `time`) (optional)
- `dateFormat` sets the date format for the visible label (optional)
- `closeWhenSelectingDate` allows you to enable/disable closing after a date was picked
- `closeAnimationDuration` controls the animation speed when closing the picker
- `calendarIconIsHidden` controls if the calendar icon is hidden
- `calendarIconSizeMultiplier` controls the multiplier of the aspect ratio of the calendar imageview
- `left/right/top/bottomMargin` changes the margins of the container view

There is also a callback for receiving the new picked date: `didChangeDate`

You can also get the current date whenever you need by using `currentDate`

## Full example

```swift
import RSDatePicker

(...)

@IBOutlet weak var datePicker: RSDatePicker!

(...)

self.datePicker.cornerRadius = 16
self.datePicker.leftMargin = 20
self.datePicker.rightMargin = 16
        
self.datePicker.pickerMode = .date
self.datePicker.currentDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) // yesterday
self.datePicker.initialText = "Select Date"
self.datePicker.calendarIconIsHidden = false
self.datePicker.calendarIconTint = .label
self.datePicker.calendarIconSizeMultiplier = 0.8
self.datePicker.forceScalePicker = true
self.datePicker.closeWhenSelectingDate = true
self.datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) // 4 days ago
self.datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 20, to: Date()) // 20 days in the future
self.datePicker.didChangeDate = { newDate in
  print(newDate)
}
```

## License
RSDatePicker is available under the **MPL-2.0 license**. More info available [here](https://www.mozilla.org/en-US/MPL/2.0/).
