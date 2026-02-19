//
//  DemoView.swift
//  RSDatePicker
//

import UIKit
import SwiftUI

final class DemoViewController: UIViewController {

	private let scrollView = UIScrollView()
	private let stackView: UIStackView = {
		let sv = UIStackView()
		sv.axis = .vertical
		sv.spacing = 24
		sv.translatesAutoresizingMaskIntoConstraints = false
		return sv
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemGroupedBackground
		title = "RSDatePicker Demo"

		setupScrollView()
		addSection("Default (date mode)", picker: makeDefault())
		addSection("Time mode", picker: makeTimePicker())
		addSection("Custom styling", picker: makeCustomStyled())
		addSection("No icon, centered text", picker: makeNoIcon())
		addSection("Custom icon & tint", picker: makeCustomIcon())
		addSection("Small icon (0.5x)", picker: makeSmallIcon())
		addSection("With date limits", picker: makeDateLimits())
		addSection("Popover aligned leading", picker: makeLeadingAlignment())
		addSection("Popover aligned center", picker: makeCenterAlignment())
		addSection("Custom popover size", picker: makeCustomPopoverSize())
		addSection("Custom margins", picker: makeCustomMargins())
		addSection("No auto-close", picker: makeNoAutoClose())
	}

	private func setupScrollView() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		scrollView.addSubview(stackView)

		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
			stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
			stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
			stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
			stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
		])
	}

	private func addSection(_ title: String, picker: RSDatePicker) {
		let label = UILabel()
		label.text = title
		label.font = .systemFont(ofSize: 13, weight: .medium)
		label.textColor = .secondaryLabel

		let container = UIView()
		container.backgroundColor = .systemBackground
		container.layer.cornerRadius = 12
		container.clipsToBounds = true

		picker.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(picker)
		NSLayoutConstraint.activate([
			picker.topAnchor.constraint(equalTo: container.topAnchor),
			picker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			picker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
			picker.bottomAnchor.constraint(equalTo: container.bottomAnchor),
			picker.heightAnchor.constraint(equalToConstant: 52)
		])

		stackView.addArrangedSubview(label)
		stackView.addArrangedSubview(container)
		stackView.setCustomSpacing(6, after: label)
	}

	// MARK: - Picker Variants

	private func makeDefault() -> RSDatePicker {
		let picker = RSDatePicker()
		picker.pickerMode = .date
		picker.initialText = "Select date"
		picker.didChangeDate = { print("Default:", $0) }
		return picker
	}

	private func makeTimePicker() -> RSDatePicker {
		let picker = RSDatePicker()
		picker.pickerMode = .time
		picker.initialText = "Select time"
		picker.currentDate = Date()
		picker.didChangeDate = { print("Time:", $0) }
		return picker
	}

	private func makeCustomStyled() -> RSDatePicker {
		let picker = RSDatePicker()
		picker.pickerMode = .date
		picker.font = .systemFont(ofSize: 20, weight: .semibold)
		picker.textColor = .systemIndigo
		picker.calendarIconTint = .systemIndigo
		picker.currentDate = Date()
		picker.didChangeDate = { print("Styled:", $0) }
		return picker
	}

	private func makeNoIcon() -> RSDatePicker {
		let picker = RSDatePicker()
		picker.pickerMode = .date
		picker.calendarIconIsHidden = true
		picker.initialText = "Tap to pick a date"
		picker.didChangeDate = { print("No icon:", $0) }
		return picker
	}

	private func makeCustomIcon() -> RSDatePicker {
		let picker = RSDatePicker()
		picker.pickerMode = .date
		picker.calendarIconImage = UIImage(systemName: "clock.fill")
		picker.calendarIconTint = .systemOrange
		picker.textColor = .systemOrange
		picker.currentDate = Date()
		picker.didChangeDate = { print("Custom icon:", $0) }
		return picker
	}

	private func makeSmallIcon() -> RSDatePicker {
		let picker = RSDatePicker()
		picker.pickerMode = .date
		picker.calendarIconSizeMultiplier = 0.5
		picker.currentDate = Date()
		picker.didChangeDate = { print("Small icon:", $0) }
		return picker
	}

	private func makeDateLimits() -> RSDatePicker {
		let picker = RSDatePicker()
		picker.pickerMode = .date
		picker.minimumDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())
		picker.maximumDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
		picker.currentDate = Date()
		picker.initialText = "±7 days range"
		picker.didChangeDate = { print("Limited:", $0) }
		return picker
	}

	private func makeLeadingAlignment() -> RSDatePicker {
		let picker = RSDatePicker()
		picker.pickerMode = .date
		picker.popoverAlignment = .leading
		picker.initialText = "Popover → leading"
		picker.didChangeDate = { print("Leading:", $0) }
		return picker
	}

	private func makeCenterAlignment() -> RSDatePicker {
		let picker = RSDatePicker()
		picker.pickerMode = .date
		picker.popoverAlignment = .center
		picker.initialText = "Popover → center"
		picker.didChangeDate = { print("Center:", $0) }
		return picker
	}

	private func makeCustomPopoverSize() -> RSDatePicker {
		let picker = RSDatePicker()
		picker.pickerMode = .date
		picker.popoverSize = CGSize(width: 350, height: 420)
		picker.initialText = "Larger popover (350×420)"
		picker.didChangeDate = { print("Custom size:", $0) }
		return picker
	}

	private func makeCustomMargins() -> RSDatePicker {
		let picker = RSDatePicker()
		picker.pickerMode = .date
		picker.leftMargin = 24
		picker.rightMargin = 24
		picker.topMargin = 14
		picker.bottomMargin = 14
		picker.initialText = "Extra padding (24h / 14v)"
		picker.didChangeDate = { print("Margins:", $0) }
		return picker
	}

	private func makeNoAutoClose() -> RSDatePicker {
		let picker = RSDatePicker()
		picker.pickerMode = .date
		picker.closeWhenSelectingDate = false
		picker.initialText = "No auto-close"
		picker.didChangeDate = { print("No close:", $0) }
		return picker
	}
}

// MARK: - SwiftUI Preview

private struct DemoViewRepresentable: UIViewControllerRepresentable {
	func makeUIViewController(context: Context) -> UINavigationController {
		UINavigationController(rootViewController: DemoViewController())
	}

	func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

#Preview("RSDatePicker Demo") {
	DemoViewRepresentable()
        .ignoresSafeArea(.all)
}
