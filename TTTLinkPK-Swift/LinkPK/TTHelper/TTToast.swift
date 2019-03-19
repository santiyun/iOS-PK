import UIKit

enum ToastType {
    case center
    case top
    case bottom
}

private let TTToastAlpha: CGFloat = 1
private let TTToastTopPadding: CGFloat = 74
private let TTToastBottomPadding: CGFloat = 59
private let TTToastDefaultDuration: TimeInterval = 2.5

private let TTToastShadowRadius: CGFloat = 6.0
private let TTToastShadowOffset = CGSize(width: 4.0, height: 4.0)
private let TTToastFontSize: CGFloat = 16
private let TTToastHorizontalPadding: CGFloat = 10
private let TTToastVerticalPadding: CGFloat = 10
private let TTToastFadeDuration: TimeInterval = 0.2
private let TTToastCornerRadius: CGFloat = 3.0

extension UIView {
    
    func showTopToast(_ message: String, duration: TimeInterval = TTToastDefaultDuration) {
        showToast(message, position: .top, duration: duration)
    }
    
    func showBottomToast(_ message: String, duration: TimeInterval = TTToastDefaultDuration) {
        showToast(message, position: .bottom, duration: duration)
    }
    
    func showToast(_ message: String, position: ToastType = .center, duration: TimeInterval = TTToastDefaultDuration, centerY: CGFloat? = nil) {
        let backView = viewForMessage(message)
        showToast(backView, duration: duration, position: position, centerY: centerY)
    }
}

private extension UIView {
    func showToast(_ toast: UIView, duration: TimeInterval, position: ToastType, centerY: CGFloat?) {
        toast.isUserInteractionEnabled = false
        makeToastCenter(toast, type: position, centerY: centerY)
        toast.alpha = 0
        addSubview(toast)
        
        UIView.animate(withDuration: TTToastFadeDuration, delay: 0, options: .curveEaseOut, animations: {
            toast.alpha = TTToastAlpha
        }) { (easeOut) in
            UIView.animate(withDuration: TTToastFadeDuration, delay: duration, options: .curveEaseIn, animations: {
                toast.alpha = 0
            }) { (easeOut) in
                toast.removeFromSuperview()
            }
        }
    }
    
    func makeToastCenter(_ toast: UIView, type: ToastType, centerY: CGFloat?) {
        let centerX = bounds.size.width * 0.5
        if let centerY = centerY {
            toast.center =  CGPoint(x: centerX, y: centerY)
            return
        }
        var toastCenter = CGPoint.zero
        let halfToastH = toast.frame.size.height * 0.5
        switch type {
        case .top:
            toastCenter = CGPoint(x: centerX, y: halfToastH + TTToastTopPadding)
        case .bottom:
            toastCenter = CGPoint(x: centerX, y: bounds.size.height - halfToastH - TTToastBottomPadding)
        default:
            toastCenter = CGPoint(x: centerX, y: bounds.size.height * 0.5)
        }
        toast.center = toastCenter
    }
    
    func viewForMessage(_ message: String) -> UIView {
        let toast = UIView()
        toast.backgroundColor = UIColor.black
        toast.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        toast.layer.cornerRadius = TTToastCornerRadius
        //
        toast.layer.shadowColor = UIColor.black.cgColor
        toast.layer.shadowOpacity = 1
        toast.layer.shadowRadius = TTToastShadowRadius
        toast.layer.shadowOffset = TTToastShadowOffset
        //label
        let messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        let font = UIFont.systemFont(ofSize: TTToastFontSize)
        messageLabel.font = font
        messageLabel.textColor = UIColor.white
        messageLabel.text = message
        
        let maxSize = CGSize(width: bounds.size.width * 0.8, height: bounds.size.height * 0.8)
        let messageSize = message.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil).size
        messageLabel.frame = CGRect(x: TTToastHorizontalPadding, y: TTToastVerticalPadding, width: messageSize.width, height: messageSize.height)
        toast.frame = CGRect(x: 0, y: 0, width: messageSize.width + 2 * TTToastHorizontalPadding, height: messageSize.height + 2 * TTToastVerticalPadding)
        toast.addSubview(messageLabel)
        return toast
    }
    
}

extension UIViewController {
    func showTopToast(_ message: String, duration: TimeInterval = TTToastDefaultDuration) {
        view.showToast(message, position: .top, duration: duration)
    }
    
    func showBottomToast(_ message: String, duration: TimeInterval = TTToastDefaultDuration) {
        view.showToast(message, position: .bottom, duration: duration)
    }
    
    func showToast(_ message: String, position: ToastType = .center, duration: TimeInterval = TTToastDefaultDuration, centerY: CGFloat? = nil) {
        view.showToast(message, position: position, duration: duration, centerY: centerY)
    }
}

