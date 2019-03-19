import UIKit

private let TTHudWhite = true
private let TTHudMinWH: CGFloat = 80
private let TTHudTakeMax: CGFloat = 0.7
private let TTHudPadding: CGFloat = 15
private let TTHudShowViewCornerRadius: CGFloat = 5
private let TThudHideDelay: TimeInterval = 1
private let TTHudTitleFontSize: CGFloat = 16

class TTProgressHud: UIView {
    
    private var showView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        showView = UIView()
        showView.backgroundColor = TTHudWhite ? UIColor(white: 0.8, alpha: 0.6) : UIColor.black
        showView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        showView.layer.cornerRadius = TTHudShowViewCornerRadius
        addSubview(showView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        showView.center = CGPoint(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TTProgressHud {
    class func showHud(_ view: UIView, message: String = "", color: UIColor? = nil) {
        hideHud(for: view)
        let hud = TTProgressHud(frame: view.bounds)
        hud.create(message, color: color)
        view.addSubview(hud)
    }
    
    class func showHud(_ view: UIView, imgName: String, hideDelay delay: TimeInterval = TThudHideDelay) {
        hideHud(for: view)
        let hud = TTProgressHud(frame: view.bounds)
        hud.create(imgName)
        view.addSubview(hud)
        hud.perform(#selector(removeFromSuperview), with: nil, afterDelay: delay)
    }
    
    class func showHud(_ view: UIView, imgName: String, message: String, textColor color: UIColor? = nil, hideDelay delay: TimeInterval = TThudHideDelay) {
        hideHud(for: view)
        let hud = TTProgressHud(frame: view.bounds)
        hud.create(imgName, message: message, textColor: color)
        view.addSubview(hud)
        hud.perform(#selector(removeFromSuperview), with: nil, afterDelay: delay)
    }
    
    class func hideHud(for view: UIView, animated: Bool = false) {
        for subView in view.subviews where subView is TTProgressHud {
            if animated {
                UIView.animate(withDuration: 1, animations: {
                    subView.alpha = 0
                }, completion: { (finished) in
                    subView.removeFromSuperview()
                })
            }else{
                subView.removeFromSuperview()
            }
        }
    }
}
//MARK: - fileprivate
private extension TTProgressHud {
    func create(_ imageName: String) {
        let imageView = createImgView(imageName)
        showView.frame = CGRect(x: 0, y: 0, width: TTHudMinWH, height: TTHudMinWH)
        imageView.center = CGPoint(x: TTHudMinWH * 0.5, y: TTHudMinWH * 0.5)
    }
    
    func create(_ imageName: String, message: String, textColor: UIColor?) {
        let imageView = createImgView(imageName)
        adjustViewAndAddTitleLabel(imageView, message: message, textColor: textColor)
    }
    
    func create(_ message: String, color: UIColor?) {
        if message == "" {
            let indicatorView = createActivityIndicatorView()
            showView.frame = CGRect(x: 0, y: 0, width: TTHudMinWH, height: TTHudMinWH)
            indicatorView.center = CGPoint(x: TTHudMinWH / 2, y: TTHudMinWH / 2)
            return
        }
        
        let indicatorView = createActivityIndicatorView()
        adjustViewAndAddTitleLabel(indicatorView, message: message, textColor: color)
    }
    
    func adjustViewAndAddTitleLabel(_ view: UIView, message: String, textColor: UIColor?) {
        let titleLabel = createTitleLabel()
        titleLabel.text = message
        if let textColor = textColor {
            titleLabel.textColor = textColor
        }
        let maxSize = CGSize(width: bounds.size.width * TTHudTakeMax, height: bounds.size.height * TTHudTakeMax)
        let textSize = message.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : titleLabel.font], context: nil).size
        var showW = textSize.width + TTHudPadding * 2;
        if showW < TTHudMinWH {
            showW = TTHudMinWH
        }
        let showH = TTHudPadding + view.frame.size.height + TTHudPadding * 2.34
        showView.frame = CGRect(x: 0, y: 0, width: showW, height: showH)
        view.center = CGPoint(x: showW * 0.5, y: view.frame.size.height * 0.5 + TTHudPadding)
        titleLabel.frame = CGRect(x: TTHudPadding, y: view.frame.maxY + TTHudPadding / 3, width: showW - TTHudPadding * 2, height: TTHudPadding + 2)
    }
}

private extension TTProgressHud {
    func createActivityIndicatorView() -> UIActivityIndicatorView {
        let indicatorView = UIActivityIndicatorView(style: .whiteLarge)
        indicatorView.color = TTHudWhite ? UIColor.black : UIColor.white
        indicatorView.startAnimating()
        showView.addSubview(indicatorView)
        return indicatorView
    }
    
    func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = TTHudWhite ? UIColor.black : UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: TTHudTitleFontSize)
        titleLabel.backgroundColor = UIColor.clear
        showView.addSubview(titleLabel)
        return titleLabel
    }
    
    func createImgView(_ imageName: String) -> UIImageView {
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        showView.addSubview(imageView)
        return imageView
    }
}
