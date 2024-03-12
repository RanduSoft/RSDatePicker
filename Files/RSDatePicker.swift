//
//  RSDatePicker
//
//  Created by Radu Ursache - RanduSoft
//  v1.7.1
//

/*
   Known issues:
	- Selecting the same day in different month/year with closeWhenSelectingDate = true will not close the popup. Fixing this will actually make the popup close for each month/year change
	- The popup will be presented over the view when using a big frame height. This could be fixed by fiddling with the transform of the underlaying date picker
 */

import UIKit

@available(iOS 13.4, *)
open class RSDatePicker: UIView {
	
	// xib loader
	@IBOutlet public weak var view: UIView!
	private var didLoad: Bool = false
	private var timer: Timer?
	
	@IBOutlet private weak var calendarImageView: UIImageView!
	@IBOutlet private weak var datePicker: UIDatePicker!
	@IBOutlet private weak var dateLabel: UILabel!
	@IBOutlet private weak var stackViewMarginLeft: NSLayoutConstraint!
	@IBOutlet private weak var stackViewMarginRight: NSLayoutConstraint!
	@IBOutlet private weak var stackViewMarginTop: NSLayoutConstraint!
	@IBOutlet private weak var stackViewMarginBottom: NSLayoutConstraint!
	@IBOutlet private weak var calendarIconConstraint: NSLayoutConstraint!
	
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
                case .date: return "dd/MM/YYYY"
                case .time: return "HH:mm"
            }
        }
    }
    
	// config
    public var currentDate: Date? {
        didSet {
            DispatchQueue.main.async {
                self.didUpdateDate()
            }
        }
    }
	public var minimumDate: Date? {
		didSet {
			self.checkDateLimits()
		}
	}
	public var maximumDate: Date? {
		didSet {
			self.checkDateLimits()
		}
	}
	public var pickerMode: PickerMode?
	public var dateFormat: String?
	public var closeWhenSelectingDate: Bool = true
	public var closeAnimationDuration: CGFloat = 0.3
    public var calendarIconTint: UIColor = .label {
        didSet {
            self.calendarImageView.tintColor = self.calendarIconTint
        }
    }
	public var calendarIconIsHidden: Bool = false {
		didSet {
			self.calendarImageView.isHidden = self.calendarIconIsHidden
			self.dateLabel.textAlignment = self.calendarIconIsHidden ? .center : .left
		}
	}
	public var calendarIconSizeMultiplier: CGFloat? {
		didSet {
			guard let newMultiplier = self.calendarIconSizeMultiplier, newMultiplier >= 0 && newMultiplier <= 1 else { return }
			self.calendarIconConstraint = self.calendarIconConstraint.setMultiplier(newMultiplier)
			self.layoutIfNeeded()
		}
	}
    public var calendarIconImage: UIImage = UIImage(systemName: "calendar")! {
        didSet {
            self.calendarImageView.image = self.calendarIconImage
        }
    }
	public var font: UIFont? {
		didSet {
			self.dateLabel.font = self.font
		}
	}
	public var textColor: UIColor? {
		didSet {
			self.dateLabel.textColor = self.textColor
		}
	}
    public var initialText: String = "Select date" {
        didSet {
            guard self.currentDate == nil else { return }
            self.didUpdateDate()
        }
    }
	public var leftMargin: Double = 8 {
		didSet {
			self.updateMargins()
		}
	}
	public var rightMargin: Double = 8 {
		didSet {
			self.updateMargins()
		}
	}
	public var topMargin: Double = 8 {
		didSet {
			self.updateMargins()
		}
	}
	public var bottomMargin: Double = 8 {
		didSet {
			self.updateMargins()
		}
	}
	public var forceScalePicker: Bool = false
    
    override open var backgroundColor: UIColor? {
        didSet {
            guard self.view != nil else { return }
            self.view.backgroundColor = self.backgroundColor
        }
    }
	
	// callback
	public var didChangeDate: ((Date) -> Void)?
	
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
        
		self.timer = Timer(timeInterval: 0.5, repeats: true, block: { [weak self] _ in
			self?.hideDateLabel()
		})
		RunLoop.main.add(self.timer!, forMode: .common)
        
        self.updateUI()
	}
    
    open func updateUI() { }
	
	private func prepareDatePicker() {
		self.hideDateLabel()
        self.datePicker.preferredDatePickerStyle = .compact
		self.datePicker.layer.zPosition = CGFloat(MAXFLOAT)
        self.datePicker.datePickerMode = self.pickerMode?.datePickerMode ?? .date
		self.datePicker.alpha = 0.03
		self.checkDateLimits()
		self.updateMargins()
        
        self.dateLabel.text = self.initialText
	}
	
    private func didUpdateDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.dateFormat ?? (self.pickerMode?.defaultFormat ?? PickerMode.date.defaultFormat)
        
        guard let currentDate = self.currentDate else {
            self.dateLabel.text = self.initialText
            return
        }
        
        self.datePicker.date = currentDate
        self.dateLabel.text = dateFormatter.string(from: currentDate)
	}
	
	private func checkDateLimits() {
		self.datePicker.minimumDate = self.minimumDate
		self.datePicker.maximumDate = self.maximumDate
        
        guard let currentDate = self.currentDate else { return }
		
		if let minimumDate = self.minimumDate, currentDate < minimumDate {
			self.currentDate = minimumDate
		} else if let maximumDate = self.maximumDate, currentDate > maximumDate {
			self.currentDate = maximumDate
		}
	}
	
	private func hideDateLabel() {
        let datePickerSubviews = UIView.getAllSubviews(from: self.datePicker)
        
        let datePickerLinkedLabel = datePickerSubviews
            .filter({ "\($0.classForCoder)" == "_UIDatePickerLinkedLabel" }).first
        let datePickerTimeLabel = datePickerSubviews
            .filter({ "\($0.classForCoder)" == "_UIDatePickerCompactTimeLabel" }).first
        
        datePickerLinkedLabel?.alpha = 0
        datePickerTimeLabel?.alpha = 0.1 // can't be lower or it won't work
//        datePickerTimeLabel?.backgroundColor = .red // debug
		
		if self.forceScalePicker {
            let scaleX: Double = 6
            let scaleY: Double = 2.3
            
            if let actualPickerContainer = datePickerLinkedLabel?.superview {
                actualPickerContainer.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            }
            datePickerTimeLabel?.transform = CGAffineTransform(scaleX: scaleX * 2, y: scaleY)
		}
	}
	
	@IBAction private func dateChangedAction(_ sender: UIDatePicker) {
		let changedDay: Bool = Calendar.current.component(.day, from: self.currentDate ?? Date()) != Calendar.current.component(.day, from: sender.date)
		
		self.hideDateLabel()
		self.currentDate = sender.date
        self.didChangeDate?(sender.date)
		
		guard self.closeWhenSelectingDate else { return }
		guard changedDay else { return }
		
		guard let datePickerVC = self.getTopMostVC() else { return }
		let animationDuration = self.closeAnimationDuration
		
		let screenSize = UIScreen.main.bounds
		let positionOnScreen = self.convert(CGPoint.zero, to: nil)
		let anchorX = (positionOnScreen.x + self.frame.width / 2) / screenSize.width
		let anchorY = positionOnScreen.y / screenSize.height
		
		UIView.animate(withDuration: animationDuration, delay: 0.1, options: .curveEaseOut) { [weak self] in
			self?.setAnchorPoint(CGPoint(x: anchorX, y: anchorY), for: datePickerVC.view)
			datePickerVC.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
			
			UIView.animate(withDuration: animationDuration / 2) {
				datePickerVC.view.alpha = 0
			}
		} completion: { [weak self] finished in
			if finished {
				DispatchQueue.main.async {
					datePickerVC.dismiss(animated: false)
					self?.hideDateLabel()
				}
			}
		}
	}
	
	private func updateMargins() {
		DispatchQueue.main.async {
			self.stackViewMarginLeft.constant = self.leftMargin
			self.stackViewMarginRight.constant = self.rightMargin
			self.stackViewMarginTop.constant = self.topMargin
			self.stackViewMarginBottom.constant = self.bottomMargin
			
			self.view.layoutIfNeeded()
		}
	}
}

// utils
@available(iOS 13.4, *)
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
@available(iOS 13.4, *)
fileprivate extension RSDatePicker {
	private func nibSetup() {
		self.view = self.loadViewFromNib()
		self.view.frame = bounds
		self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.view.translatesAutoresizingMaskIntoConstraints = true
        self.view.backgroundColor = self.backgroundColor

		addSubview(self.view)
	}

	private func loadViewFromNib() -> UIView {
		if let defaultBundleView = UINib(nibName: "RSDatePicker", bundle: Bundle.module).instantiate(withOwner: self, options: nil).first as? UIView {
			return defaultBundleView
		} else {
			fatalError("Cannot load view from bundle")
		}
	}
}

// constraint utils
fileprivate extension NSLayoutConstraint {
	func setMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
		NSLayoutConstraint.deactivate([self])

		let newConstraint = NSLayoutConstraint(item: firstItem as Any, attribute: firstAttribute, relatedBy: relation, toItem: secondItem, attribute: secondAttribute, multiplier: multiplier, constant: constant)

		newConstraint.priority = self.priority
		newConstraint.shouldBeArchived = self.shouldBeArchived
		newConstraint.identifier = self.identifier

		NSLayoutConstraint.activate([newConstraint])
		return newConstraint
	}
}

// get subviews
fileprivate extension UIView {
    class func getAllSubviews<T: UIView>(from parenView: UIView) -> [T] {
        return parenView.subviews.flatMap { subView -> [T] in
            var result = getAllSubviews(from: subView) as [T]
            if let view = subView as? T { result.append(view) }
            return result
        }
    }

    class func getAllSubviews(from parentView: UIView, types: [UIView.Type]) -> [UIView] {
        return parentView.subviews.flatMap { subView -> [UIView] in
            var result = getAllSubviews(from: subView) as [UIView]
            for type in types {
                if subView.classForCoder == type {
                    result.append(subView)
                    return result
                }
            }
            return result
        }
    }

    func getAllSubviews<T: UIView>() -> [T] { return UIView.getAllSubviews(from: self) as [T] }
    func get<T: UIView>(all type: T.Type) -> [T] { return UIView.getAllSubviews(from: self) as [T] }
    func get(all types: [UIView.Type]) -> [UIView] { return UIView.getAllSubviews(from: self, types: types) }
}
