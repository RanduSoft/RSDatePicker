//
//  RSDatePicker
//
//  Created by Radu Ursache - RanduSoft
//  v1.0
//

import UIKit

@available(iOS 13.2, *)
@IBDesignable public class RSDatePicker: UIView {
	
	// xib loader
	@IBOutlet public weak var view: UIView!
	private var didLoad: Bool = false
	
	@IBOutlet private weak var datePicker: UIDatePicker!
	@IBOutlet private weak var dateLabel: UILabel!
	
	// config
	public var initialDate: Date?
	public var minimumDate: Date?
	public var maximumDate: Date?
	public var pickerMode: UIDatePicker.Mode?
	public var dateFormat: String?
	public var closeAnimationDuration: CGFloat = 0.3
	
	// callback
	public var didChangeDate: ((Date) -> Void)?
	public var currentDate = Date() {
		didSet {
			self.didUpdateDate()
		}
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.nibSetup()
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.nibSetup()
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		if !self.didLoad {
			self.didLoad = true
			self.viewDidLoad()
		}
	}
	
	private func viewDidLoad() {
		self.prepareDatePicker()
	}
	
	private func prepareDatePicker() {
		self.datePicker.date = self.initialDate ?? Date()
		self.currentDate = self.datePicker.date
		self.datePicker.minimumDate = self.minimumDate
		self.datePicker.maximumDate = self.maximumDate
		self.datePicker.datePickerMode = self.pickerMode ?? .date
		self.datePicker.alpha = 0.03
		self.didUpdateDate()
	}
	
	private func didUpdateDate() {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = self.dateFormat ?? "dd/MM/YYYY"
		self.dateLabel.text = dateFormatter.string(from: self.currentDate)
		self.datePicker.date = self.currentDate
		self.didChangeDate?(self.currentDate)
	}
	
	@IBAction private func dateChangedAction(_ sender: UIDatePicker) {
		self.currentDate = sender.date
		
		guard let datePickerVC = self.getTopMostVC() else { return }
		let animationDuration = self.closeAnimationDuration
		
		let screenSize = UIScreen.main.bounds
		let positionOnScreen = self.convert(CGPoint.zero, to: nil)
		let anchorX = (positionOnScreen.x+self.frame.width/2)/screenSize.width
		let anchorY = positionOnScreen.y/screenSize.height
		
		UIView.animate(withDuration: animationDuration, delay: 0.1, options: .curveEaseOut) { [weak self] in
			self?.setAnchorPoint(CGPoint(x: anchorX, y: anchorY), for: datePickerVC.view)
			datePickerVC.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
			
			UIView.animate(withDuration: animationDuration/2) {
				datePickerVC.view.alpha = 0
			}
		} completion: { finished in
			if finished {
				DispatchQueue.main.async {
					datePickerVC.dismiss(animated: false)
				}
			}
		}
	}
}

// utils
@available(iOS 13.2, *)
fileprivate extension RSDatePicker {
	func getTopMostVC() -> UIViewController? {
		let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

		if var topController = keyWindow?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}
			return topController
		} else {
			return nil
		}
	}
	
	// https://www.hackingwithswift.com/example-code/calayer/how-to-change-a-views-anchor-point-without-moving-it
	func setAnchorPoint(_ point: CGPoint, for view: UIView) {
		var newPoint = CGPoint(x: view.bounds.size.width * point.x, y: view.bounds.size.height * point.y)
		var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)

		newPoint = newPoint.applying(transform) ; oldPoint = oldPoint.applying(transform)

		var position = view.layer.position
		position.x -= oldPoint.x ; position.x += newPoint.x
		position.y -= oldPoint.y ; position.y += newPoint.y

		view.layer.position = position ; view.layer.anchorPoint = point
	}
}

// xib loader
@available(iOS 13.2, *)
fileprivate extension RSDatePicker {
	private func nibSetup() {
		self.view = self.loadViewFromNib()
		self.view.frame = bounds
		self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.view.translatesAutoresizingMaskIntoConstraints = true

		addSubview(self.view)
	}

	private func loadViewFromNib() -> UIView {
		guard let nibName = type(of: self).description().components(separatedBy: ".").last else {
			fatalError("Bad nib name")
		}
		
		if let defaultBundleView = UINib(nibName: nibName, bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil).first as? UIView {
			return defaultBundleView
		} else {
			fatalError("Cannot load view from bundle")
		}
	}
}
