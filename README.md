# RSDatePicker

A beautiful UIView wrapper for UIDatePicker. Requires iOS 13.2 or newer

## Setup
- Storyboard
	1. Create a `UIView` and set its custom class to `RSDatePicker`
	2. Link it with a `IBOutlet` in the class you want
	3. Check usage

- Code
	1. `let datePicker = RSDatePicker(frame: CGRect)`
	2. Check usage


## Usage

You can customize the date picker in multiple ways:

- `initialDate` sets the default date
- `minimumDate` sets the minimum selectable date
- `maximumDate` sets the maximum selectable date
- `pickerMode` sets the date picker mode (`.date`, `time`, `.dateAndTime`)
- `dateFormat` sets the date format for the visible label
- `closeWhenSelectingDate` allows you to enable/disable closing after a date was picked
- `closeAnimationDuration` controls the animation speed when closing the picker

There is also a callback for receiving the new picked date: `didChangeDate`
You can also get or set the current date whenever you need by using `currentDate`

## License
RSDatePicker is available under the **MPL-2.0 license**. More info available [here](https://www.mozilla.org/en-US/MPL/2.0/).
