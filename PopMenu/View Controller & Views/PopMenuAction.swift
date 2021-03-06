//
//  PopMenuAction.swift
//  PopMenu
//
//  Created by Cali Castle  on 4/13/18.
//  Copyright © 2018 PopMenu. All rights reserved.
//

import UIKit

@objc public protocol PopMenuAction: NSObjectProtocol {
    
    /// Title of the action.
    var title: String? { get }
    /// Image of the action.
    var image: UIImage? { get }
    /// Container view of the action.
    var view: UIView { get }
    /// The initial color of the action.
    var color: Color? { get }
    
    /// Constants for layout sizing.
    static var textLeftPadding: CGFloat { get }
    static var iconLeftPadding: CGFloat { get }
    static var iconWidthHeight: CGFloat { get }
    
    /// The color to set for both label and icon.
    var tintColor: UIColor { get set }
    /// The font for label.
    var font: UIFont { get set }
    /// The corner radius of action view.
    var cornerRadius: CGFloat { get set }
    /// Is the view highlighted by gesture.
    var highlighted: Bool { get set }
    
    /// Render the view for action.
    func renderActionView()

    @objc optional func actionSelected(animated: Bool)
    
}

public class PopMenuDefaultAction: NSObject, PopMenuAction {
    
    public let title: String?
    public let image: UIImage?
    public let view: UIView
    public let color: Color?
    
    // MARK: - Computed Properties
    
    /// Text color of the label.
    public var tintColor: Color {
        get {
            return titleLabel.textColor
        }
        set {
            titleLabel.textColor = newValue
            iconImageView.tintColor = newValue
            backgroundColor = newValue.blackOrWhiteContrastingColor()
        }
    }
    
    /// Font for the label.
    public var font: UIFont {
        get {
            return titleLabel.font
        }
        set {
            titleLabel.font = newValue
        }
    }
    
    /// Rounded corner radius for action view.
    public var cornerRadius: CGFloat {
        get {
            return view.layer.cornerRadius
        }
        set {
            view.layer.cornerRadius = newValue
        }
    }
    
    /// Inidcates if the action is being highlighted.
    public var highlighted: Bool = false {
        didSet {
            guard highlighted != oldValue else { return }
            
            highlightActionView(highlighted)
        }
    }
    
    /// Background color for highlighted state.
    private var backgroundColor: Color = .white

    // MARK: - Subviews
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.text = title
        
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        
        return imageView
    }()
    
    // MARK: - Constants
    
    public static let textLeftPadding: CGFloat = 25
    public static let iconLeftPadding: CGFloat = 18
    public static let iconWidthHeight: CGFloat = 27
    
    // MARK: - Initializer
    
    public init(title: String? = nil, image: UIImage? = nil, color: Color? = nil) {
        self.title = title
        self.image = image
        self.color = color
        
        view = UIView()
    }
    
    /// Setup necessary views.
    fileprivate func configureViews() {
        var hasImage = false

        if let _ = image {
            hasImage = true
            view.addSubview(iconImageView)
            
            NSLayoutConstraint.activate([
                iconImageView.widthAnchor.constraint(equalToConstant: PopMenuDefaultAction.iconWidthHeight),
                iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
                iconImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PopMenuDefaultAction.iconLeftPadding),
                iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: hasImage ? iconImageView.trailingAnchor : view.leadingAnchor, constant: hasImage ? 8 : PopMenuDefaultAction.textLeftPadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    /// Load and configure the action view.
    public func renderActionView() {
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        
        configureViews()
    }
    
    /// Highlight the view when panned on top,
    /// unhighlight the view when pan gesture left.
    public func highlightActionView(_ highlight: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.26, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 9, options: self.highlighted ? .curveEaseIn : .curveEaseOut, animations: {
                self.view.transform = self.highlighted ? CGAffineTransform.identity.scaledBy(x: 1.11, y: 1.11) : .identity
                self.view.backgroundColor = self.highlighted ? self.backgroundColor.withAlphaComponent(0.25) : .clear
            }, completion: nil)
        }
    }
    
    /// When the action is selected.
    public func actionSelected(animated: Bool) {
        guard animated else { return }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.175, animations: {
                self.view.transform = CGAffineTransform.identity.scaledBy(x: 0.92, y: 0.92)
                self.view.backgroundColor = self.backgroundColor.withAlphaComponent(0.2)
            }, completion: {
                if $0 {
                    UIView.animate(withDuration: 0.175, animations: {
                        self.view.transform = .identity
                        self.view.backgroundColor = .clear
                    })
                }
            })
        }
    }
    
}
