//
//  RSDatePicker
//
//  Created by Radu Ursache - RanduSoft
//  v2.0.0
//

import UIKit

open class RSDatePicker: UIView {

	public enum PickerMode {
		case date
		case time

		var datePickerMode: UIDatePicker.Mode {
			switch self {
			case .date: return .date
			case .time: return .time
			}
		}

		var defaultFormat: String {
			switch self {
			case .date: return "dd/MM/yyyy"
			case .time: return "HH:mm"
			}
		}
	}

	public enum PopoverAlignment {
		case leading
		case center
		case trailing
	}

	// MARK: - UI Elements

	private let stackView: UIStackView = {
		let sv = UIStackView()
		sv.axis = .horizontal
		sv.alignment = .center
		sv.spacing = 8
		sv.translatesAutoresizingMaskIntoConstraints = false
		sv.isUserInteractionEnabled = false
		return sv
	}()

	private let dateLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 17)
		label.textColor = .label
		return label
	}()

	private let calendarImageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFit
		iv.image = UIImage(systemName: "calendar")
		iv.tintColor = .label
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()

	private var iconHeightConstraint: NSLayoutConstraint?
	private var stackViewLeading: NSLayoutConstraint!
	private var stackViewTrailing: NSLayoutConstraint!
	private var stackViewTop: NSLayoutConstraint!
	private var stackViewBottom: NSLayoutConstraint!

	// MARK: - Configuration

	public var currentDate: Date? {
		didSet { updateDateLabel() }
	}

	public var minimumDate: Date? {
		didSet { applyDateLimits() }
	}

	public var maximumDate: Date? {
		didSet { applyDateLimits() }
	}

	public var pickerMode: PickerMode = .date {
		didSet { updateDateLabel() }
	}

	public var dateFormat: String? {
		didSet { updateDateLabel() }
	}

	public var initialText: String = "Select date" {
		didSet {
			if currentDate == nil { updateDateLabel() }
		}
	}

	public var closeWhenSelectingDate: Bool = true

	public var calendarIconTint: UIColor = .label {
		didSet { calendarImageView.tintColor = calendarIconTint }
	}

	public var calendarIconIsHidden: Bool = false {
		didSet {
			calendarImageView.isHidden = calendarIconIsHidden
			dateLabel.textAlignment = calendarIconIsHidden ? .center : .natural
		}
	}

	public var calendarIconSizeMultiplier: CGFloat = 0.75 {
		didSet {
			let clamped = max(0.1, min(1.0, calendarIconSizeMultiplier))
			updateIconSize(multiplier: clamped)
		}
	}

	public var calendarIconImage: UIImage? {
		didSet { calendarImageView.image = calendarIconImage }
	}

	public var font: UIFont? {
		didSet { dateLabel.font = font ?? .systemFont(ofSize: 17) }
	}

	public var textColor: UIColor? {
		didSet { dateLabel.textColor = textColor ?? .label }
	}

	public var leftMargin: CGFloat = 16 {
		didSet { stackViewLeading?.constant = leftMargin }
	}

	public var rightMargin: CGFloat = 16 {
		didSet { stackViewTrailing?.constant = -rightMargin }
	}

	public var topMargin: CGFloat = 8 {
		didSet { stackViewTop?.constant = topMargin }
	}

	public var bottomMargin: CGFloat = 8 {
		didSet { stackViewBottom?.constant = -bottomMargin }
	}

	public var popoverAlignment: PopoverAlignment = .trailing

	public var popoverSize: CGSize?

	// MARK: - Callback

	public var didChangeDate: ((Date) -> Void)?

	// MARK: - Open

	open func updateUI() {}

	// MARK: - Init

	public override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	private func commonInit() {
		backgroundColor = .systemBackground
		setupViews()
		setupGesture()
		setupAccessibility()
		updateDateLabel()
		updateUI()
	}

	// MARK: - Setup

	private func setupViews() {
		addSubview(stackView)
		stackView.addArrangedSubview(dateLabel)
		stackView.addArrangedSubview(calendarImageView)

		stackViewLeading = stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftMargin)
		stackViewTrailing = stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -rightMargin)
		stackViewTop = stackView.topAnchor.constraint(equalTo: topAnchor, constant: topMargin)
		stackViewBottom = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomMargin)

		NSLayoutConstraint.activate([
			stackViewLeading, stackViewTrailing, stackViewTop, stackViewBottom
		])

		let clamped = max(0.1, min(1.0, calendarIconSizeMultiplier))
		let heightConstraint = calendarImageView.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: clamped)
		let widthConstraint = calendarImageView.widthAnchor.constraint(equalTo: calendarImageView.heightAnchor)
		NSLayoutConstraint.activate([heightConstraint, widthConstraint])
		iconHeightConstraint = heightConstraint

		dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
		calendarImageView.setContentHuggingPriority(.required, for: .horizontal)
		calendarImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
	}

	private func setupGesture() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
		addGestureRecognizer(tap)
	}

	private func setupAccessibility() {
		isAccessibilityElement = true
		accessibilityTraits = .button
		accessibilityHint = pickerMode == .time
			? NSLocalizedString("Double tap to select a time", comment: "RSDatePicker accessibility hint")
			: NSLocalizedString("Double tap to select a date", comment: "RSDatePicker accessibility hint")
	}

	// MARK: - Actions

	@objc private func didTapView() {
		presentPicker()
	}

	private func presentPicker() {
		guard let parentVC = findViewController() else { return }

		let pickerVC = RSDatePickerPopoverController()
		pickerVC.datePickerMode = pickerMode.datePickerMode
		pickerVC.currentDate = currentDate
		pickerVC.minimumDate = minimumDate
		pickerVC.maximumDate = maximumDate
		pickerVC.closeOnSelection = closeWhenSelectingDate && pickerMode == .date
		pickerVC.preferredContentSize = popoverSize ?? defaultPopoverSize()
		pickerVC.modalPresentationStyle = .popover

		pickerVC.onDateChanged = { [weak self] date in
			self?.currentDate = date
			self?.didChangeDate?(date)
		}

		if let popover = pickerVC.popoverPresentationController {
			popover.sourceView = self
			popover.sourceRect = popoverSourceRect()
			popover.permittedArrowDirections = [.up, .down]
			popover.delegate = pickerVC
		}

		parentVC.present(pickerVC, animated: true)
	}

	// MARK: - Helpers

	private func updateDateLabel() {
		guard let date = currentDate else {
			dateLabel.text = initialText
			accessibilityValue = initialText
			return
		}

		let formatter = DateFormatter()
		formatter.dateFormat = dateFormat ?? pickerMode.defaultFormat
		let text = formatter.string(from: date)
		dateLabel.text = text
		accessibilityValue = text
	}

	private func applyDateLimits() {
		guard let date = currentDate else { return }
		if let min = minimumDate, date < min {
			currentDate = min
		} else if let max = maximumDate, date > max {
			currentDate = max
		}
	}

	private func updateIconSize(multiplier: CGFloat) {
		guard let old = iconHeightConstraint else { return }
		old.isActive = false
		let replacement = calendarImageView.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: multiplier)
		replacement.isActive = true
		iconHeightConstraint = replacement
		layoutIfNeeded()
	}

	private func popoverSourceRect() -> CGRect {
		let quarter = bounds.width / 4
		switch popoverAlignment {
		case .leading:
			return CGRect(x: 0, y: 0, width: quarter, height: bounds.height)
		case .center:
			return bounds
		case .trailing:
			return CGRect(x: bounds.width - quarter, y: 0, width: quarter, height: bounds.height)
		}
	}

	private func defaultPopoverSize() -> CGSize {
		switch pickerMode {
		case .date: return CGSize(width: 320, height: 380)
		case .time: return CGSize(width: 280, height: 240)
		}
	}

	private func findViewController() -> UIViewController? {
		var responder: UIResponder? = self
		while let next = responder?.next {
			if let vc = next as? UIViewController { return vc }
			responder = next
		}
		return nil
	}
}

// MARK: - Popover Controller

private class RSDatePickerPopoverController: UIViewController, UIPopoverPresentationControllerDelegate {

	var datePickerMode: UIDatePicker.Mode = .date
	var currentDate: Date?
	var minimumDate: Date?
	var maximumDate: Date?
	var closeOnSelection: Bool = true
	var onDateChanged: ((Date) -> Void)?

	private let datePicker: UIDatePicker = {
		let dp = UIDatePicker()
		dp.translatesAutoresizingMaskIntoConstraints = false
		return dp
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(datePicker)
		NSLayoutConstraint.activate([
			datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			datePicker.topAnchor.constraint(equalTo: view.topAnchor),
			datePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])

		datePicker.datePickerMode = datePickerMode
		datePicker.preferredDatePickerStyle = datePickerMode == .time ? .wheels : .inline
		datePicker.minimumDate = minimumDate
		datePicker.maximumDate = maximumDate
		if let date = currentDate {
			datePicker.date = date
		}
		datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
	}

	@objc private func dateChanged(_ sender: UIDatePicker) {
		onDateChanged?(sender.date)

		if closeOnSelection {
			dismiss(animated: true)
		}
	}

	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}

	func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
		return .none
	}
}
