import Foundation
import SwiftUI
import UIKit

internal extension UIControl {
    @objc dynamic func peavySendAction(_ action: Selector,
                                     to target: Any?,
                                     for event: UIEvent?) {
        peavySendAction(action, to: target, for: event)
        Task {
            guard let target else { return }
            let to = Mirror(reflecting: target).subjectType
            let from = Mirror(reflecting: self).subjectType

            var label = self.accessibilityIdentifier ?? self.accessibilityLabel
            var selected = ""

            if let segmented = self as? UISegmentedControl {
              let selected = segmented.titleForSegment(at: segmented.selectedSegmentIndex)
              label = label ?? selected
            } else if let switcher = self as? UISwitch {
                label = label ?? switcher.title
                selected = " (selected=\(switcher.isOn))"
            } else if let textField = self as? UITextField {
              label = label ?? textField.placeholder
            } else if self.isSelected {
              selected = " (selected=true)"
            }

            Peavy.i("Action: \(to):\(action.description) from \(from) (\(label ?? "<no label>"))\(selected)")
        }
    }
}

internal extension UIAlertAction {
    @objc dynamic class func peavyInit(title: String?,
                                       style: UIAlertAction.Style,
                                       handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return peavyInit(title: title, style: style) { a in
            var style: String = ""
            switch a.style {
            case .default: style = "default"
            case .cancel: style = "cancel"
            case .destructive: style = "destructive"
            default: style = "\(a.style.rawValue)"
            }

            Peavy.i("Action: \(style) \(a.title ?? "<no title>")")
            handler?(a)
        }
    }
}

internal extension UIViewController {
    @objc dynamic func peavyDidAppear(_ animated: Bool) {
        peavyDidAppear(animated)
        Task {
            let from = Mirror(reflecting: self).subjectType
            var line = "UIViewController Appeared: \(from)"
            if let title = self.title {
                line += " (\(title))"
            }
            if let uiHosting = self as? UIHostingController<AnyView> {
                line += ": \(String(describing: uiHosting.rootView))"
            }
            Peavy.i(line)
        }
    }
}

let uiSetup: Void = {
    let uiControlClass = UIControl.self
    let curSendAction = class_getInstanceMethod(uiControlClass, #selector(uiControlClass.sendAction(_:to:for:)))
    let peavySendAction = class_getInstanceMethod(uiControlClass, #selector(uiControlClass.peavySendAction))
    method_exchangeImplementations(curSendAction!, peavySendAction!)
    
    let uiViewControllerClass = UIViewController.self
    let curDidAppear = class_getInstanceMethod(uiViewControllerClass, #selector(uiViewControllerClass.viewDidAppear(_:)))
    let peavyDidAppear = class_getInstanceMethod(uiViewControllerClass, #selector(uiViewControllerClass.peavyDidAppear(_:)))
    method_exchangeImplementations(curDidAppear!, peavyDidAppear!)
    
    let alertActionClass = UIAlertAction.self
    let curInit = class_getClassMethod(alertActionClass, #selector(UIAlertAction.init(title:style:handler:)))
    let peavyInit = class_getClassMethod(alertActionClass, #selector(UIAlertAction.peavyInit(title:style:handler:)))
    method_exchangeImplementations(curInit!, peavyInit!)
}()

internal extension Peavy {
    func setupUiLogging() {
        if options.enableUiLogging {
            uiSetup
        }
    }
}
