import UIKit

extension UIView {
    @IBInspectable var borderWidth: CGFloat {
        get {
            return 0.0
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor()
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return 0.0
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = newValue
        }
    }
}

private let screenRate = UIScreen.main.bounds.size.width / 375.0
extension NSLayoutConstraint {
    @IBInspectable var adjustIphone5: Bool {
        get {
            return false
        }
        set {
            if newValue {
                if UIScreen.main.bounds.size.width <= 320 {
                    constant = constant * screenRate
                }
            }
        }
    }
    
    @IBInspectable var adjustIphones: Bool {
        get {
            return false
        }
        set {
            if newValue {
                constant = constant * screenRate
            }
        }
    }
}

extension UILabel {
    @IBInspectable var adjustFont: Bool {
        get {
            return false
        }
        set {
            if newValue {
                font = UIFont.systemFont(ofSize: font.pointSize * screenRate)
            }
        }
    }
    
    @IBInspectable var adjustI5Font: Bool {
        get {
            return false
        }
        set {
            if UIScreen.main.bounds.size.width <= 320 {
                if newValue {
                    font = UIFont.systemFont(ofSize: font.pointSize * screenRate)
                }
            }
        }
    }
}

extension UIButton {
    @IBInspectable var adjustFont: Bool {
        get {
            return false
        }
        set {
            if newValue {
                guard let label = titleLabel else { return }
                label.font = UIFont.systemFont(ofSize: label.font.pointSize * screenRate)
            }
        }
    }
    
    @IBInspectable var adjustI5Font: Bool {
        get {
            return false
        }
        set {
            guard let label = titleLabel else { return }
            if UIScreen.main.bounds.size.width <= 320 {
                if newValue {
                    label.font = UIFont.systemFont(ofSize: label.font.pointSize * screenRate)
                }
            }
        }
    }
}
