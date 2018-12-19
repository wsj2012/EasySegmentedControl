//
//  EasySegmentedControl.swift
//  EasySegmentedControl
//
//  Created by 王树军 on 2018/12/17.
//  Copyright © 2018 王树军. All rights reserved.
//

import UIKit
import QuartzCore

public enum SelectionStyle: Int {
    case TextWidthStripe
    case FullWidthStripe
    case Box
    case Arrow
}

public enum IndicatorLocation: Int {
    case Up
    case Down
    case None
}

public enum WidthStyle: Int {
    case Fixed
    case Dynamic
}

struct BorderType: OptionSet {
    let rawValue: UInt
    static let None = BorderType(rawValue: 0)
    static let top = BorderType(rawValue: 1 << 0)
    static let Left = BorderType(rawValue: 1 << 1)
    static let Bottom = BorderType(rawValue: 1 << 2)
    static let Right = BorderType(rawValue: 1 << 3)
}

public let NoSegment =  -1

public enum Type: Int {
    case Text
    case Images
    case TextImages
}

public enum ImagePosition: Int {
    case BehindText
    case LeftOfText
    case RightOfText
    case AboveText
    case BelowText
}

public class EasySegmentedControl: UIControl {
    
    public typealias IndexChangeBlock = (_ index: Int) -> Void
    public typealias EasyTitleFormatterBlock = (_ segmentedControl: EasySegmentedControl, _ title: String, _ index: Int, _ selected: Bool) -> NSAttributedString?
    
    private var _sectionTitles: [Any?] = [Any?].init()
    public var sectionTitles: [Any?] {
        set {
            _sectionTitles = newValue
            setNeedsLayout()
            setNeedsDisplay()
        }
        
        get {
            return _sectionTitles
        }
    }
    
    private var _sectionImages: [UIImage] = [UIImage].init()
    public var sectionImages: [UIImage] {
        set {
            _sectionImages = newValue
            setNeedsLayout()
            setNeedsDisplay()
        }
        
        get {
            return _sectionImages
        }
    }
    
    public var sectionSelectedImages: [UIImage]?
    public var indexChangeBlock: IndexChangeBlock?
    public var titleFormatter: EasyTitleFormatterBlock?
    public var titleTextAttributes: [NSAttributedString.Key: Any]?
    public var selectedTitleTextAttributes: [NSAttributedString.Key: Any]?
    public var backgroundsColor: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    public var selectionIndicatorColor: UIColor = #colorLiteral(red: 0.2044631541, green: 0.7111002803, blue: 0.898917675, alpha: 1)
    public var selectionIndicatorBoxColor: UIColor = #colorLiteral(red: 0.2044631541, green: 0.7111002803, blue: 0.898917675, alpha: 1)
    public var verticalDividerColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    private var _selectionIndicatorBoxOpacity: CGFloat = 0.2
    public var selectionIndicatorBoxOpacity: CGFloat {
        set {
            _selectionIndicatorBoxOpacity = newValue
            selectionIndicatorBoxLayer.opacity = Float(_selectionIndicatorBoxOpacity)
        }
        
        get {
            return _selectionIndicatorBoxOpacity
        }
    }
    
    public var verticalDividerWidth: CGFloat = 1.0
    public var type: Type = .Text
    public var selectionStyle: SelectionStyle = .TextWidthStripe
    
    private var _segmentWidthStyle: WidthStyle = .Fixed
    public var segmentWidthStyle: WidthStyle {
        set {
            if type == .Images {
                _segmentWidthStyle = .Fixed
            }else {
                _segmentWidthStyle = newValue
            }
        }
        
        get {
            return _segmentWidthStyle
        }
    }
    
    private var _selectionIndicatorLocation: IndicatorLocation = .Up
    public var selectionIndicatorLocation: IndicatorLocation {
        set {
            _selectionIndicatorLocation = newValue
            if _selectionIndicatorLocation == .None {
                selectionIndicatorHeight = 0.0
            }
        }
        
        get {
            return _selectionIndicatorLocation
        }
    }
    
    private var _borderType: BorderType = .None
    var borderType: BorderType {
        set {
            _borderType = newValue
            setNeedsDisplay()
        }
        
        get {
            return _borderType
        }
    }
    
    public var imagePosition: ImagePosition = .BehindText
    public var textImageSpacing: CGFloat = 0.0
    public var borderColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    public var borderWidth: CGFloat = 1.0
    public var userDraggable: Bool = true
    public var touchEnabled: Bool = true
    public var verticalDividerEnabled: Bool = false
    public var stretchSegmentsToScreenSize: Bool = false
    public var selectedSegmentIndex: Int = 0
    public var selectionIndicatorHeight: CGFloat = 5.0
    public var selectionIndicatorEdgeInsets: UIEdgeInsets =  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    public var segmentEdgeInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    public var enlargeEdgeInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    public var shouldAnimateUserSelection: Bool = true
    
    lazy private var selectionIndicatorStripLayer: CALayer = {
        let layer = CALayer(layer: self)
        return layer
    }()
    
    lazy private var selectionIndicatorBoxLayer: CALayer = {
        let layer = CALayer(layer: self)
        return layer
    }()
    
    lazy private var selectionIndicatorArrowLayer: CALayer = {
        let layer = CALayer(layer: self)
        return layer
    }()
    
    // 重写父类frame的setter方法必须使用didSet
    override public var frame: CGRect  {
        didSet {
            let newFrame = frame
            super.frame = newFrame
            updateSegmentsRects()
        }
    }
    
    private var segmentWidth: CGFloat = 0.0
    private var segmentWidthsArray: [NSNumber]?
    lazy private var scrollView: EasyScrollView = {
        let s = EasyScrollView.init()
        s.scrollsToTop = false
        s.showsVerticalScrollIndicator = false
        s.showsHorizontalScrollIndicator = false
        return s
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(with sectiontitles: [Any]) {
        self.init(frame: .zero)
        self.sectionTitles = sectiontitles
        self.type = .Text
    }
    
    public convenience init(with sectionImages: [UIImage], sectionSelectedImages: [UIImage] ) {
        self.init(frame: .zero)
        self.sectionImages = sectionImages
        self.sectionSelectedImages = sectionSelectedImages
        self.type = .Images
    }
    
    public convenience init(with sectionImages: [UIImage], sectionSelectedImages: [UIImage], sectiontitles: [Any]) {
        self.init(frame: .zero)
        if sectionImages.count != sectiontitles.count {
            NSException.raise(NSExceptionName.rangeException, format: "***%s: Images bounds (%ld) Don't match Title bounds (%ld)", arguments: getVaList([#function, sectionImages.count, sectiontitles.count]))
        }
        
        self.sectionImages = sectionImages
        self.sectionSelectedImages = sectionSelectedImages
        self.sectionTitles = sectiontitles
        self.type = .TextImages
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.segmentWidth = 0.0
    }
    
    private func commonInit() {
        self.addSubview(scrollView)
        isOpaque = false
        scrollView.scrollsToTop = false
        selectionIndicatorBoxOpacity = 0.2
        selectionIndicatorBoxLayer.opacity = Float(selectionIndicatorBoxOpacity)
        selectionIndicatorBoxLayer.borderWidth = 1.0
        selectionIndicatorLocation = .Up
        segmentWidthStyle = .Fixed
        contentMode = .redraw
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateSegmentsRects()
    }
    
    //MARK: - Drawing
    private func measureTitle(at index: NSInteger) -> CGSize {
        if index >= sectionTitles.count {
            return .zero
        }
        
        let title = sectionTitles[index]
        
        var size: CGSize = .zero
        let selected: Bool = (index == selectedSegmentIndex) ? true : false
        if title is String, titleFormatter == nil {
            let titleAttrs:[NSAttributedString.Key: Any] = selected ? resultingSelectedTitleTextAttributes() : resultingTitleTextAttributes()
            size = (title as! String).size(withAttributes: titleAttrs)
            let font: UIFont = titleAttrs[NSAttributedString.Key.font] as! UIFont
            size = CGSize(width: ceil(size.width), height: ceil(size.height - font.descender))
        }else if title is String, let formatter = titleFormatter, let attrString = formatter(self, title as! String, index, selected) {
            size = attrString.size()
        }else if title is NSAttributedString {
            size = (title as! NSAttributedString).size()
        }else {
            assert(title == nil, "Unexpected type of segment title nil")
            size = .zero
        }
        
        // it's different from HM return CGRectIntegral((CGRect){CGPointZero, size}).size
        return size
    }
    
    private func attributedTitle(at index: NSInteger) -> NSAttributedString {
        let selected = (index == selectedSegmentIndex) ? true : false
        if let title = sectionTitles[index], title is NSAttributedString {
            return title as! NSAttributedString
        }else if let formatter = titleFormatter {
            return formatter(self, sectionTitles[index] as! String, index, selected)!
        }else {
            var titleAttrs = selected ? resultingSelectedTitleTextAttributes() : resultingTitleTextAttributes()
            if let titleColor = titleAttrs[NSAttributedString.Key.foregroundColor] {
                var dict = titleAttrs
                dict[NSAttributedString.Key.foregroundColor] = (titleColor as! UIColor)
                titleAttrs = dict
            }
            return NSAttributedString(string: sectionTitles[index] as! String, attributes: titleAttrs)
        }
    }
    
    override public func draw(_ rect: CGRect) {
        backgroundsColor.setFill()
        UIRectFill(bounds)
        selectionIndicatorArrowLayer.backgroundColor = selectionIndicatorColor.cgColor
        selectionIndicatorStripLayer.backgroundColor = selectionIndicatorColor.cgColor
        selectionIndicatorBoxLayer.backgroundColor = selectionIndicatorBoxColor.cgColor
        selectionIndicatorBoxLayer.borderColor = selectionIndicatorBoxColor.cgColor
        scrollView.layer.sublayers = nil
        let oldRect = rect
        if type == .Text {
            for (index, _) in sectionTitles.enumerated() {
                var stringWidth: CGFloat = 0.0
                var stringHeight: CGFloat = 0.0
                let size = measureTitle(at: index)
                stringWidth = size.width
                stringHeight = size.height
                var rectDiv: CGRect =  .zero
                var fullRect: CGRect = .zero
                
                let locationUp: CGFloat = (selectionIndicatorLocation == .Up) ? 1.0 : 0
                let selectionStyleNotBox: CGFloat = (selectionStyle != .Box) ? 1.0 : 0.0
                
                let a = (frame.size.height - selectionStyleNotBox * selectionIndicatorHeight) / 2 - stringHeight / 2
                let b = selectionIndicatorHeight * locationUp
                let y = roundf(Float(a + b))
                
                var rect: CGRect = .zero
                if segmentWidthStyle == .Fixed {
                    rect = CGRect(x: segmentWidth * CGFloat(index) + (segmentWidth - stringWidth) / 2.0, y: CGFloat(y), width: stringWidth, height: stringHeight)
                    rectDiv = CGRect(x: segmentWidth * CGFloat(index) - verticalDividerWidth / 2.0, y: selectionIndicatorHeight * 2, width: verticalDividerWidth, height: frame.size.height -  (selectionIndicatorHeight * 4))
                    fullRect = CGRect(x: segmentWidth * CGFloat(index), y: 0, width: segmentWidth, height: oldRect.size.height)
                }else {
                    var xOffset: Float = 0
                    var i = 0
                    if let widthArr = self.segmentWidthsArray {
                        for item in widthArr {
                            if index == i { break }
                            xOffset = xOffset + item.floatValue
                            i += 1
                        }
                        
                        let widthForIndex = widthArr[index].floatValue
                        rect = CGRect(x: CGFloat(xOffset), y: CGFloat(y), width: CGFloat(widthForIndex), height: stringHeight)
                        fullRect = CGRect(x: segmentWidth * CGFloat(index), y: 0, width: CGFloat(widthForIndex), height: oldRect.size.height)
                        rectDiv = CGRect(x: CGFloat(xOffset) - verticalDividerWidth / 2, y: selectionIndicatorHeight * 2, width: verticalDividerWidth, height: frame.size.height - selectionIndicatorHeight * 4)
                    }
                }
                // fix rect position/size to avoid blurry labels
                rect = CGRect(x: CGFloat(ceilf(Float(rect.origin.x))), y: CGFloat(ceilf(Float(rect.origin.y))), width: CGFloat(ceilf(Float(rect.size.width))), height: CGFloat(ceilf(Float(rect.size.height))))
                let titleLayer = CATextLayer.init()
                titleLayer.frame = rect
                titleLayer.alignmentMode = .center
                if Float(UIDevice.current.systemVersion)! < Float(10.0) {
                    titleLayer.truncationMode = .end
                }
                titleLayer.string = attributedTitle(at: index)
                titleLayer.contentsScale = UIScreen.main.scale
                scrollView.layer.addSublayer(titleLayer)
                
                // Vertical Divider
                if verticalDividerEnabled, index > 0 {
                    let verticalDividerLayer = CALayer.init()
                    verticalDividerLayer.frame = rectDiv
                    verticalDividerLayer.backgroundColor = verticalDividerColor.cgColor
                    scrollView.layer.addSublayer(verticalDividerLayer)
                }
                addBackgroundAndBorderLayer(with: fullRect)
            }
        }else if type == .Images {
            for (index, img) in sectionImages.enumerated() {
                let imageW = img.size.width
                let imageH = img.size.height
                
                let a = roundf(Float(frame.size.height - selectionIndicatorHeight)) / 2 - Float(imageH) / 2
                let b = (selectionIndicatorLocation == .Up) ? selectionIndicatorHeight : 0
                let y = a + Float(b)
                let x = segmentWidth * CGFloat(index) + (segmentWidth - imageW) / 2.0
                let rect = CGRect(x: x, y: CGFloat(y), width: imageW, height: imageH)
                
                let imageLayer = CALayer.init()
                imageLayer.frame = rect
                if selectedSegmentIndex == index {
                    if let selectedImages = sectionSelectedImages {
                        let highlightIcon = selectedImages[index]
                        imageLayer.contents = highlightIcon.cgImage
                    }else {
                        imageLayer.contents = img.cgImage
                    }
                }else {
                    imageLayer.contents = img.cgImage
                }
                
                scrollView.layer.addSublayer(imageLayer)
                // Vertical Divider
                if verticalDividerEnabled, index > 0 {
                    let verticalDividerLayer = CALayer.init()
                    verticalDividerLayer.frame = CGRect(x: segmentWidth * CGFloat(index) - verticalDividerWidth / 2, y: selectionIndicatorHeight * 2, width: verticalDividerWidth, height: frame.size.height - selectionIndicatorHeight * 4)
                    verticalDividerLayer.backgroundColor = verticalDividerColor.cgColor
                    scrollView.layer.addSublayer(verticalDividerLayer)
                }
                addBackgroundAndBorderLayer(with: rect)
            }
        }else if type == .TextImages {
            for (index, img) in sectionImages.enumerated() {
                let imageW = img.size.width
                let imageH = img.size.height
                let stringSize = measureTitle(at: index)
                let stringH = stringSize.height
                let stringW = stringSize.width
                
                var imageXOffset = segmentWidth * CGFloat(index) // start with edge inset
                var textXOffset = segmentWidth * CGFloat(index)
                var imageYOffset = ceilf(Float((frame.size.height - imageH) / 2.0))
                var textYOffset = ceilf(Float((frame.size.height - stringH) / 2.0))
                
                if segmentWidthStyle == .Fixed {
                    if (imagePosition == .LeftOfText || imagePosition == .RightOfText) {
                        let whitespace = segmentWidth - stringSize.width - imageW - textImageSpacing
                        if imagePosition == .LeftOfText {
                            imageXOffset += whitespace / 2.0
                            textXOffset = imageXOffset + imageW + textImageSpacing
                        }else {
                            textXOffset = whitespace / 2.0
                            imageXOffset = textXOffset + stringW + textImageSpacing
                        }
                    }else {
                        imageXOffset = segmentWidth * CGFloat(index) + (segmentWidth - imageW) / 2.0
                        textXOffset = segmentWidth * CGFloat(index) + (segmentWidth - stringW) / 2.0
                        let whitespace = frame.size.height - imageH - stringH - textImageSpacing
                        if imagePosition == .AboveText {
                            imageYOffset = ceilf(Float(whitespace / 2.0))
                            textYOffset = imageYOffset + Float(imageH) + Float(textImageSpacing)
                        }else if imagePosition == .BelowText {
                            textYOffset = ceilf(Float(whitespace / 2.0))
                            imageYOffset = textYOffset + Float(stringH) + Float(textImageSpacing)
                        }
                    }
                }else if segmentWidthStyle == .Dynamic {
                    var xOffset: Float = 0.0
                    var i = 0
                    
                    if let widthArr = self.segmentWidthsArray {
                        for item in widthArr {
                            if index == i { break }
                            xOffset = xOffset + item.floatValue
                            i += 1
                        }
                        if (imagePosition == .LeftOfText || imagePosition == .RightOfText) {
                            if imagePosition ==  .LeftOfText {
                                imageXOffset = CGFloat(xOffset)
                                textXOffset = imageXOffset + imageW + textImageSpacing
                            }else {
                                textXOffset = CGFloat(xOffset)
                                imageXOffset = textXOffset + stringW + textImageSpacing
                            }
                        }else {
                            imageXOffset = CGFloat(xOffset) + (CGFloat(widthArr[i].floatValue) - imageW) / 2.0
                            textXOffset = CGFloat(xOffset) + (CGFloat(widthArr[i].floatValue) - stringW) / 2.0
                            let whitespace = frame.size.height - imageH - stringH - textImageSpacing
                            if imagePosition == .AboveText {
                                imageYOffset = ceilf(Float(whitespace) / 2.0)
                                textYOffset = imageYOffset + Float(imageH) + Float(textImageSpacing)
                            }else if imagePosition == .BelowText {
                                textYOffset = ceilf(Float(whitespace) / 2.0)
                                imageYOffset = textYOffset + Float(stringH) + Float(textImageSpacing)
                            }
                        }
                    }
                }
                
                let imageRect = CGRect(x: imageXOffset, y: CGFloat(imageYOffset), width: imageW, height: imageH)
                let textRect = CGRect(x: CGFloat(ceilf(Float(textXOffset))), y: CGFloat(ceilf(textYOffset)), width: CGFloat(ceilf(Float(stringW))), height: CGFloat(ceilf(Float(stringH))))
                
                let titleLayer = CATextLayer.init()
                titleLayer.frame = textRect
                titleLayer.alignmentMode = .center
                titleLayer.string = attributedTitle(at: index)
                if Float(UIDevice.current.systemVersion)! < Float(10.0) {
                    titleLayer.truncationMode = .end
                }
                
                let imageLayer = CALayer.init()
                imageLayer.frame = imageRect
                if selectedSegmentIndex == index {
                    if let selectedImages = sectionSelectedImages {
                        let highlightIcon = selectedImages[index]
                        imageLayer.contents = highlightIcon.cgImage
                    }else {
                        imageLayer.contents = img.cgImage
                    }
                }else {
                    imageLayer.contents = img.cgImage
                }
                
                scrollView.layer.addSublayer(imageLayer)
                titleLayer.contentsScale = UIScreen.main.scale
                scrollView.layer.addSublayer(titleLayer)
                
                addBackgroundAndBorderLayer(with: imageRect)
            }
        }
        
        if selectedSegmentIndex != NoSegment {
            if selectionStyle == .Arrow {
                if selectionIndicatorArrowLayer.superlayer == nil {
                    setArrowFrame()
                    scrollView.layer.addSublayer(selectionIndicatorArrowLayer)
                }
            }else {
                if selectionIndicatorStripLayer.superlayer == nil {
                    selectionIndicatorStripLayer.frame = frameForSelectionIndicator()
                    scrollView.layer.addSublayer(selectionIndicatorStripLayer)
                    
                    if selectionStyle == .Box, selectionIndicatorBoxLayer.superlayer == nil {
                        selectionIndicatorBoxLayer.frame = frameForFillerSelectionIndicator()
                        scrollView.layer.insertSublayer(selectionIndicatorBoxLayer, at: 0)
                    }
                }
            }
        }
    }
    
    private func addBackgroundAndBorderLayer(with fullRect: CGRect) {
        let backgroundLayer = CALayer.init()
        backgroundLayer.frame = fullRect
        layer.insertSublayer(backgroundLayer, at: 0)
        
        // border layer
        if _borderType == BorderType.top {
            let borderLayer = CALayer.init()
            borderLayer.frame = CGRect(x: 0, y: 0, width: fullRect.size.width, height: borderWidth)
            borderLayer.backgroundColor = borderColor.cgColor
            backgroundLayer.addSublayer(borderLayer)
        }
        if _borderType == BorderType.Left {
            let borderLayer = CALayer.init()
            borderLayer.frame = CGRect(x: 0, y: 0, width: borderWidth, height: fullRect.size.height)
            borderLayer.backgroundColor = borderColor.cgColor
            backgroundLayer.addSublayer(borderLayer)
        }
        if _borderType == BorderType.Bottom {
            let borderLayer = CALayer.init()
            borderLayer.frame = CGRect(x: 0, y: fullRect.size.height - borderWidth, width: fullRect.size.width, height: borderWidth)
            borderLayer.backgroundColor = borderColor.cgColor
            backgroundLayer.addSublayer(borderLayer)
        }
        if _borderType == BorderType.Right {
            let borderLayer = CALayer.init()
            borderLayer.frame = CGRect(x: fullRect.size.width - borderWidth, y: 0, width: borderWidth, height: fullRect.size.height)
            borderLayer.backgroundColor = borderColor.cgColor
            backgroundLayer.addSublayer(borderLayer)
        }
    }
    
    private func setArrowFrame() {
        selectionIndicatorArrowLayer.frame = frameForSelectionIndicator()
        selectionIndicatorArrowLayer.mask = nil
        let arrowPath = UIBezierPath.init()
        var p1 = CGPoint.zero
        var p2 = CGPoint.zero
        var p3 = CGPoint.zero
        
        if selectionIndicatorLocation == .Down {
            p1 = CGPoint(x: selectionIndicatorArrowLayer.bounds.size.width / 2, y: 0)
            p2 = CGPoint(x: 0, y: selectionIndicatorArrowLayer.bounds.size.height)
            p3 = CGPoint(x: selectionIndicatorArrowLayer.bounds.size.width, y: selectionIndicatorArrowLayer.bounds.size.height)
        }
        if  selectionIndicatorLocation == .Up {
            p1 = CGPoint(x: selectionIndicatorArrowLayer.bounds.size.width / 2, y: selectionIndicatorArrowLayer.bounds.size.height)
            p2 = CGPoint(x: selectionIndicatorArrowLayer.bounds.size.width, y: 0)
            p3 = CGPoint.zero
        }
        arrowPath.move(to: p1)
        arrowPath.addLine(to: p2)
        arrowPath.addLine(to: p3)
        arrowPath.close()
        
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = selectionIndicatorArrowLayer.bounds
        maskLayer.path = arrowPath.cgPath
        selectionIndicatorArrowLayer.mask = maskLayer
    }
    
    private func frameForSelectionIndicator() -> CGRect {
        var indicatorYOffset: CGFloat = 0.0
        if selectionIndicatorLocation == .Down {
            indicatorYOffset = bounds.size.height - selectionIndicatorHeight + selectionIndicatorEdgeInsets.bottom
        }
        
        if selectionIndicatorLocation == .Up {
            indicatorYOffset = selectionIndicatorEdgeInsets.top
        }
        
        var sectionWidth: CGFloat = 0.0
        if type == .Text {
            sectionWidth = measureTitle(at: selectedSegmentIndex).width
        }else if type == .Images {
            sectionWidth = sectionImages[selectedSegmentIndex].size.width
        }else if type == .TextImages {
            let stringWidth = measureTitle(at: selectedSegmentIndex).width
            let imageWidth = sectionImages[selectedSegmentIndex].size.width
            sectionWidth = max(stringWidth, imageWidth)
        }
        
        if selectionStyle == .Arrow {
            let widthToEndOfSelectedSegment = (segmentWidth * CGFloat(selectedSegmentIndex)) + segmentWidth;
            let widthToStartOfSelectedIndex = segmentWidth * CGFloat(selectedSegmentIndex);
            let x = widthToStartOfSelectedIndex + ((widthToEndOfSelectedSegment - widthToStartOfSelectedIndex) / 2) - (self.selectionIndicatorHeight/2);
            return CGRect(x: x - selectionIndicatorHeight / 2, y: indicatorYOffset, width: selectionIndicatorHeight * 2, height: selectionIndicatorHeight)
        }else {
            if selectionStyle == .TextWidthStripe, sectionWidth <= segmentWidth, segmentWidthStyle != .Dynamic {
                let widthToEndOfSelectedSegment = segmentWidth * CGFloat(selectedSegmentIndex) + segmentWidth;
                let widthToStartOfSelectedIndex = self.segmentWidth * CGFloat(selectedSegmentIndex);
                
                let x = ((widthToEndOfSelectedSegment - widthToStartOfSelectedIndex) / 2) + (widthToStartOfSelectedIndex - sectionWidth / 2);
                return CGRect(x: x + selectionIndicatorEdgeInsets.left, y: indicatorYOffset, width: sectionWidth - selectionIndicatorEdgeInsets.right, height: selectionIndicatorHeight)
            }else {
                if segmentWidthStyle == .Dynamic {
                    var selectedSegmentOffset: CGFloat = 0.0
                    var i = 0;
                    if let widthsArr = self.segmentWidthsArray {
                        for item in widthsArr {
                            if selectedSegmentIndex == i { break }
                            selectedSegmentOffset = selectedSegmentOffset + CGFloat(item.floatValue)
                            i += 1
                        }
                        return CGRect(x: selectedSegmentOffset + selectionIndicatorEdgeInsets.left, y: indicatorYOffset, width: CGFloat(widthsArr[selectedSegmentIndex].floatValue) - selectionIndicatorEdgeInsets.right, height: selectionIndicatorHeight + self.selectionIndicatorEdgeInsets.bottom)
                    }
                }
                
                return CGRect(x: (segmentWidth + selectionIndicatorEdgeInsets.left) * CGFloat(selectedSegmentIndex), y: indicatorYOffset, width: segmentWidth - selectionIndicatorEdgeInsets.right, height: selectionIndicatorHeight)
            }
        }
    }
    
    private func frameForFillerSelectionIndicator() -> CGRect {
        if segmentWidthStyle == .Dynamic {
            var selectedSegmentOffset: CGFloat = 0.0
            var i = 0
            if let widthsArr = self.segmentWidthsArray {
                for item in widthsArr {
                    if selectedSegmentIndex == i { break }
                    selectedSegmentOffset = selectedSegmentOffset + CGFloat(item.floatValue)
                    i += 1
                }
                return CGRect(x: selectedSegmentOffset, y: 0, width: CGFloat(widthsArr[selectedSegmentIndex].floatValue), height: frame.size.height)
            }
        }
        return CGRect(x: segmentWidth * CGFloat(selectedSegmentIndex), y: 0, width: segmentWidth, height: frame.size.height)
    }
    
    private func updateSegmentsRects() {
        scrollView.contentInset = .zero
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        if sectionCount() > 0 {
            segmentWidth = frame.size.width / CGFloat(sectionCount())
        }
        
        if type == .Text, segmentWidthStyle == .Fixed {
            for(index, _) in self.sectionTitles.enumerated() {
                let stringWidth = measureTitle(at: index).width + segmentEdgeInset.left + segmentEdgeInset.right
                segmentWidth = max(stringWidth, segmentWidth)
            }
        }else if type == .Text, segmentWidthStyle == .Dynamic {
            var mutableSegmentWidths:[NSNumber] = [NSNumber].init()
            var totalWidth: CGFloat = 0.0
            for (index, _) in self.sectionTitles.enumerated() {
                let stringWidth = measureTitle(at: index).width + segmentEdgeInset.left + segmentEdgeInset.right
                totalWidth += stringWidth
                mutableSegmentWidths.append(NSNumber.init(value: Float(stringWidth)))
            }
            
            if stretchSegmentsToScreenSize, totalWidth < bounds.size.width {
                let whitespace = bounds.size.width - totalWidth
                let whitespaceForSegment = whitespace / CGFloat(mutableSegmentWidths.count)
                
                for (index, value) in mutableSegmentWidths.enumerated() {
                    let extendedWidth = whitespaceForSegment + CGFloat(value.floatValue)
                    mutableSegmentWidths[index] = NSNumber.init(value: Float(extendedWidth))
                }
            }
            segmentWidthsArray = mutableSegmentWidths
        }else if type == .Images {
            for sectionImage in sectionImages {
                let imageWidth = sectionImage.size.width + segmentEdgeInset.left + segmentEdgeInset.right
                segmentWidth = max(imageWidth, segmentWidth)
            }
        }else if type == .TextImages, segmentWidthStyle == .Fixed {
            for (index, _) in sectionTitles.enumerated() {
                let stringWidth = measureTitle(at: index).width + segmentEdgeInset.left + segmentEdgeInset.right
                segmentWidth = max(stringWidth, segmentWidth)
            }
        }else if type == .TextImages, segmentWidthStyle == .Dynamic {
            var mutableSegmentWidths:[NSNumber] = [NSNumber].init()
            var totalWidth: CGFloat = 0.0
            let i = 0
            for (index, _) in sectionTitles.enumerated() {
                let stringWidth = measureTitle(at: index).width + segmentEdgeInset.right
                let sectionImage = sectionImages[i]
                let imageWidth = sectionImage.size.width + segmentEdgeInset.left
                var combinedWidth: CGFloat = 0.0
                if imagePosition == .LeftOfText || imagePosition == .RightOfText {
                    combinedWidth = imageWidth + stringWidth + textImageSpacing
                }else {
                    combinedWidth = max(imageWidth, stringWidth)
                }
                
                totalWidth += combinedWidth
                mutableSegmentWidths.append(NSNumber.init(value: Float(combinedWidth)))
            }
            if stretchSegmentsToScreenSize, totalWidth < bounds.size.width {
                let whitespace = bounds.size.width - totalWidth
                let whitespaceForSegment = whitespace / CGFloat(mutableSegmentWidths.count)
                for (index, value) in mutableSegmentWidths.enumerated() {
                    let extendedWidth = whitespaceForSegment + CGFloat(value.floatValue)
                    mutableSegmentWidths[index] = NSNumber.init(value: Float(extendedWidth))
                }
            }
            segmentWidthsArray = mutableSegmentWidths
        }
        scrollView.isScrollEnabled = userDraggable
        scrollView.contentSize = CGSize(width: totalSegmentedControlWidth(), height: frame.size.height)
    }
    
    private func sectionCount() -> Int {
        if type == .Text {
            return sectionTitles.count
        }else if (type == .Images || type == .TextImages) {
            return sectionImages.count
        }
        return 0
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            return
        }
        if self.sectionTitles.count > 0 || self.sectionImages.count > 0 {
            updateSegmentsRects()
        }
    }
    
    //MARK: - Touch
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = ((touches as NSSet).anyObject() as AnyObject)
        let touchLocation = touch.location(in: self)
        let enlargeRect = CGRect(x: bounds.origin.x - enlargeEdgeInset.left, y: bounds.origin.y - enlargeEdgeInset.top, width: bounds.size.width + enlargeEdgeInset.left + enlargeEdgeInset.right, height: bounds.size.height + enlargeEdgeInset.top + enlargeEdgeInset.bottom)
        if enlargeRect.contains(touchLocation) {
            var segment = 0
            if segmentWidthStyle == .Fixed {
                segment = Int((touchLocation.x + scrollView.contentOffset.x) / segmentWidth)
            }else if segmentWidthStyle == .Dynamic {
                var widthLeft = touchLocation.x + scrollView.contentOffset.x
                if let widthsArr = self.segmentWidthsArray {
                    for item in widthsArr {
                        widthLeft = widthLeft - CGFloat(item.floatValue)
                        if widthLeft <= 0 { break }
                        segment += 1
                    }
                }
            }
            
            var sectionsCount = 0
            if type == .Images {
                sectionsCount = sectionImages.count
            }else if type == .TextImages || type == .Text {
                sectionsCount = self.sectionTitles.count
            }
            
            if segment != selectedSegmentIndex, segment < sectionsCount {
                if self.touchEnabled {
                    setSelectedSegment(index: segment, animated: shouldAnimateUserSelection, notify: true)
                }
            }
        }
    }
    
    //MARK: - Scrolling
    private func totalSegmentedControlWidth() -> CGFloat {
        if type == .Text, segmentWidthStyle == .Fixed {
            return CGFloat(self.sectionTitles.count) * segmentWidth
        }else if let arr = segmentWidthsArray, segmentWidthStyle == .Dynamic {
            var sum: CGFloat = 0.0
            arr.forEach { (value) in
                sum += CGFloat(value.floatValue)
            }
            return sum
        }else {
            return CGFloat(sectionImages.count) * segmentWidth
        }
    }
    
    private func scrollToSelectedSegmentIndex(_ animated: Bool) {
        var rectForSelectedIndex = CGRect.zero
        var selectedSegmentOffset: CGFloat = 0.0
        if segmentWidthStyle == .Fixed {
            rectForSelectedIndex = CGRect(x: segmentWidth * CGFloat(selectedSegmentIndex), y: 0, width: segmentWidth, height: frame.size.height)
            selectedSegmentOffset = frame.size.width / 2 - segmentWidth / 2
        }else {
            var i = 0
            var offsetter: CGFloat = 0.0
            if let widthsArr = segmentWidthsArray {
                for item in widthsArr {
                    if selectedSegmentIndex == i { break }
                    offsetter = offsetter + CGFloat(item.floatValue)
                    i += 1
                }
                rectForSelectedIndex = CGRect(x: offsetter, y: 0, width: CGFloat(widthsArr[selectedSegmentIndex].floatValue), height: frame.size.height)
                selectedSegmentOffset = frame.size.width / 2 - CGFloat(widthsArr[selectedSegmentIndex].floatValue) / 2
            }
        }
        
        var rectToScrollTo = rectForSelectedIndex
        rectToScrollTo.origin.x -= selectedSegmentOffset
        rectToScrollTo.size.width += selectedSegmentOffset * 2
        scrollView.scrollRectToVisible(rectToScrollTo, animated: animated)
    }
    
    //MARK: - Index Change
    public func setSelectedSegment(index: Int) {
        setSelectedSegment(index: index, animated: false, notify: false)
    }
    
    public func setSelectedSegment(index: Int, animated: Bool) {
        setSelectedSegment(index: index, animated: animated, notify: false)
    }
    
    public func setSelectedSegment(index: Int, animated: Bool, notify: Bool) {
        selectedSegmentIndex = index
        setNeedsDisplay()
        
        if index == NoSegment {
            selectionIndicatorArrowLayer.removeFromSuperlayer()
            selectionIndicatorStripLayer.removeFromSuperlayer()
            selectionIndicatorBoxLayer.removeFromSuperlayer()
        }else {
            scrollToSelectedSegmentIndex(animated)
            if animated {
                if selectionStyle == .Arrow {
                    if selectionIndicatorArrowLayer.superlayer == nil {
                        scrollView.layer.addSublayer(selectionIndicatorArrowLayer)
                        setSelectedSegment(index: index, animated: false, notify: true)
                        return
                    }
                }else {
                    if selectionIndicatorStripLayer.superlayer == nil {
                        scrollView.layer.addSublayer(selectionIndicatorStripLayer)
                        if selectionStyle == .Box, selectionIndicatorBoxLayer.superlayer == nil {
                            scrollView.layer.insertSublayer(selectionIndicatorBoxLayer, at: 0)
                        }
                        setSelectedSegment(index: index, animated: false, notify: true)
                        return
                    }
                }
                if notify {
                    notifyForSegmentChangeTo(index: index)
                }
                
                selectionIndicatorArrowLayer.actions = nil
                selectionIndicatorStripLayer.actions = nil
                selectionIndicatorBoxLayer.actions = nil
                
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.15)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .linear))
                setArrowFrame()
                selectionIndicatorBoxLayer.frame = frameForSelectionIndicator()
                selectionIndicatorStripLayer.frame = frameForSelectionIndicator()
                selectionIndicatorBoxLayer.frame = frameForFillerSelectionIndicator()
                CATransaction.commit()
            }else {
                let newActions:[String: CAAction] = ["position": NSNull.init(), "bounds": NSNull.init()]
                selectionIndicatorArrowLayer.actions = newActions
                setArrowFrame()
                
                selectionIndicatorStripLayer.actions = newActions
                selectionIndicatorStripLayer.frame = frameForSelectionIndicator()
                selectionIndicatorBoxLayer.actions = newActions
                selectionIndicatorBoxLayer.frame = frameForFillerSelectionIndicator()
                
                if notify {
                    notifyForSegmentChangeTo(index: index)
                }
            }
        }
    }
    
    private func notifyForSegmentChangeTo(index: Int) {
        if superview != nil {
            sendActions(for: .valueChanged)
        }
        if let block = indexChangeBlock {
            block(index)
        }
    }
    
    //MARK: - Styling Support
    private func resultingTitleTextAttributes() -> [NSAttributedString.Key: Any] {
        var defaults: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19),
                                                       NSAttributedString.Key.foregroundColor: UIColor.black]
        if let attributes = titleTextAttributes {
            attributes.forEach { (key, value) in
                defaults.updateValue(value, forKey: key)
            }
        }
        return defaults
    }
    
    private func resultingSelectedTitleTextAttributes() -> [NSAttributedString.Key: Any] {
        var resultingAttrs = resultingTitleTextAttributes()
        if let selAttributes = selectedTitleTextAttributes {
            selAttributes.forEach { (key, value) in
                resultingAttrs.updateValue(value, forKey: key)
            }
        }
        return resultingAttrs
    }
}


class EasyScrollView: UIScrollView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDragging {
            next?.touchesBegan(touches, with: event)
        }else {
            super.touchesBegan(touches, with: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDragging {
            next?.touchesMoved(touches, with: event)
        }else {
            super.touchesMoved(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDragging {
            next?.touchesEnded(touches, with: event)
        }else {
            super.touchesEnded(touches, with: event)
        }
    }
    
}
