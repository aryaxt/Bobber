//
//  RounderHeaderView.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 3/7/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class RoundedHeaderView: UIView {
	
	@IBOutlet private var titleLabel: UILabel!
	
	// MARK: - UIView Methods -
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		
		titleLabel.backgroundColor = UIColor.blackColor()
		titleLabel.textColor = UIColor.whiteColor()
		titleLabel.font = UIFont.systemFontOfSize(12)
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		let size = CGFloat(titleLabel.frame.size.height/2)
		let beizierPath = UIBezierPath(roundedRect: titleLabel.bounds, byRoundingCorners: .TopRight | .BottomRight, cornerRadii: CGSizeMake(size, size))
		let maskLayer = CAShapeLayer()
		maskLayer.frame = titleLabel.bounds;
		maskLayer.path = beizierPath.CGPath;
		titleLabel.layer.mask = maskLayer;
	}
	
	// MARK: - Public Methods -
	
	public func setTitle(title: String) {
		titleLabel.text = "   \(title)   "
		
		setNeedsLayout()
		layoutIfNeeded()
	}
	
	public class func height() -> CGFloat {
		return 50
	}
	
}
