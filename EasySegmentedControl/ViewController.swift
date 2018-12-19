//
//  ViewController.swift
//  EasySegmentedControlDemo
//
//  Created by 王树军 on 2018/12/17.
//  Copyright © 2018 王树军. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    lazy var scrollView: UIScrollView = {
        let s = UIScrollView.init(frame: CGRect(x: 0, y: 310 + 68, width: view.frame.size.width, height: 210))
        s.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        s.isPagingEnabled = true
        s.showsHorizontalScrollIndicator = false
        s.contentSize = CGSize(width: view.frame.size.width * 3, height: 200)
        s.delegate = self
        s.scrollRectToVisible(CGRect(x: view.frame.size.width, y: 0, width: view.frame.size.width, height: 200), animated: false)
        return s
    }()
    
    lazy var sc4: EasySegmentedControl = {
        let sc = EasySegmentedControl.init(frame: CGRect(x: 0, y: 260 + 68, width: view.frame.size.width, height: 50))
        sc.sectionTitles = ["Worldwide", "Local", "Headlines"]
        sc.selectedSegmentIndex = 1
        sc.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        sc.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        sc.selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)]
        sc.selectionIndicatorColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        sc.selectionStyle = .Box;
        sc.selectionIndicatorLocation = .Up;
        sc.tag = 3;
        return sc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "HMSegmentedControl Demo"
        view.backgroundColor = .white
        edgesForExtendedLayout = UIRectEdge.all
        
        let viewWidth = view.frame.size.width
        let sc = EasySegmentedControl.init(with: ["Trending", "News", "Library"])
        sc.frame = CGRect(x: 0, y: 88, width: viewWidth, height: 40)
        sc.autoresizingMask = [.flexibleRightMargin, .flexibleWidth]
        sc.backgroundsColor = UIColor.clear
        sc.addTarget(self, action: #selector(segmentedControlChangedValue(segmentedControl:)), for: .valueChanged)
        view.addSubview(sc)
                
        let sc1 = EasySegmentedControl.init(with: ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight"])
        sc1.autoresizingMask = [.flexibleRightMargin, .flexibleWidth]
        sc1.frame = CGRect(x: 0, y: 60 + 68, width: viewWidth, height: 40)
        sc1.segmentEdgeInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        sc1.selectionStyle = .FullWidthStripe
        sc1.selectionIndicatorLocation = .Down
        sc1.verticalDividerEnabled = true
        sc1.verticalDividerColor = .black
        sc1.verticalDividerWidth = 1.0
        sc1.titleFormatter = {(seg, title, index, selected) in
            let attString = NSAttributedString.init(string: title, attributes: [NSAttributedString.Key.foregroundColor : UIColor.blue])
            return attString
        }
        sc1.addTarget(self, action: #selector(segmentedControlChangedValue(segmentedControl:)), for: .valueChanged)
        view.addSubview(sc1)
        
        // Segmented control with images
        let images: [UIImage] = [UIImage(named: "1")!, UIImage(named: "2")!, UIImage(named: "3")!, UIImage(named: "4")!]
        let selectedImages: [UIImage] = [UIImage(named: "1-selected")!, UIImage(named: "2-selected")!, UIImage(named: "3-selected")!, UIImage(named: "4-selected")!]
        let titles: [String] = ["1", "2", "3", "4"]
        let sc2 = EasySegmentedControl.init(with: images, sectionSelectedImages: selectedImages, sectiontitles: titles)
        sc2.imagePosition = .LeftOfText
        sc2.frame = CGRect(x: 0, y: 120 + 68, width: viewWidth, height: 50)
        sc2.selectionIndicatorHeight = 4.0
        sc2.backgroundsColor = UIColor.clear
        sc2.selectionIndicatorLocation = .Down
        sc2.selectionStyle = .TextWidthStripe
        sc2.segmentWidthStyle = .Dynamic
        sc2.addTarget(self, action: #selector(segmentedControlChangedValue(segmentedControl:)), for: .valueChanged)
        view.addSubview(sc2)
        
        //Segmented control with more customization and indexChangeBlock
        let sc3 = EasySegmentedControl.init(with: ["one", "Two", "Three", "4", "Five"])
        sc3.frame = CGRect(x: 0, y: 180 + 68, width: viewWidth, height: 50)
        sc3.indexChangeBlock = { index in
            print("Selected index \(index) (via block)")
        }
        sc3.selectionIndicatorHeight = 4.0
        sc3.backgroundsColor = UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1)
        sc3.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        sc3.selectionIndicatorColor = UIColor(red: 0.5, green: 0.8, blue: 1, alpha: 1)
        sc3.selectionIndicatorBoxColor = UIColor.black
        sc3.selectionIndicatorBoxOpacity = 1.0
        sc3.selectionStyle = .Box
        sc3.selectedSegmentIndex = NoSegment
        sc3.selectionIndicatorLocation = .Down
        sc3.shouldAnimateUserSelection = false
        sc3.tag = 2
        view.addSubview(sc3)
        
        // Tying up the segmented control to a scroll view
        sc4.indexChangeBlock = {[weak self] index in
            if let strongSelf = self {
                strongSelf.scrollView.scrollRectToVisible(CGRect(x: viewWidth * CGFloat(index), y: 0, width: viewWidth, height: 200), animated: true)
            }
        }
        view.addSubview(sc4)
        
        view.addSubview(scrollView)
        
        let lable1 = UILabel.init(frame: CGRect(x: 0, y: 0, width: viewWidth, height: 210))
        setApperanceFor(label: lable1)
        lable1.text = "Worldwide"
        scrollView.addSubview(lable1)
        
        let lable2 = UILabel.init(frame: CGRect(x: viewWidth, y: 0, width: viewWidth, height: 210))
        setApperanceFor(label: lable2)
        lable2.text = "Local"
        scrollView.addSubview(lable2)
        
        let lable3 = UILabel.init(frame: CGRect(x: viewWidth * 2, y: 0, width: viewWidth, height: 210))
        setApperanceFor(label: lable3)
        lable3.text = "Headlines"
        scrollView.addSubview(lable3)
        
    }
    
    func setApperanceFor(label: UILabel) {
        let hue = CGFloat(arc4random() % 256) / CGFloat(256.0)
        let saturation = CGFloat(arc4random() % 128) / CGFloat(256.0) + 0.5
        let brightness = CGFloat(arc4random() % 128) / CGFloat(256.0) + 0.5
        let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
        label.backgroundColor = color
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 21)
        label.textAlignment = .center
    }
    
    @objc func segmentedControlChangedValue(segmentedControl: EasySegmentedControl) {
        print("Selected index \(segmentedControl.selectedSegmentIndex) (via UIControlEventValueChanged)")
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(scrollView.contentOffset.x / pageWidth)
        sc4.setSelectedSegment(index: page, animated: true)
    }


}

