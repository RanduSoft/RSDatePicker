# RSDatePicker

A beautiful UIView wrapper for UIDatePicker. Requires iOS 13.2 or newer

## Setup
- Storyboard

Create a `UIView` and set its custom class to `RSDatePicker` and link it with a `IBOutlet` in the class you want

- Code
 
`let datePicker = RSDatePicker(frame: CGRect)`

## Usage

You can customize the date picker in multiple ways:

- `initialDate` sets the default date
- `minimumDate` sets the minimum selectable date
- `maximumDate` sets the maximum selectable date
- `pickerMode` sets the date picker mode (`.date`, `time`, `.dateAndTime`)
- `dateFormat` sets the date format for the visible label
- `closeWhenSelectingDate` allows you to enable/disable closing after a date was picked
- `closeAnimationDuration` controls the animation speed when closing the picker
- `calendarIconIsHidden` controls if the calendar icon is hidden
- `calendarIconSizeMultiplier` controls the multiplier of the aspect ratio of the calendar imageview

You can change the margins (`left/right/top/bottomMargin`) of the container view

There is also a callback for receiving the new picked date: `didChangeDate`

You can also get or set the current date whenever you need by using `currentDate`

## License
RSDatePicker is available under the **MPL-2.0 license**. More info available [here](https://www.mozilla.org/en-US/MPL/2.0/).
