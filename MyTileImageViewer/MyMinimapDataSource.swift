//
//  MyMinimapDataSource.swift
//  MyTileImageViewer
//
//  Created by mac on 2018. 1. 14..
//  Copyright © 2018년 홍창남. All rights reserved.
//

import UIKit
import UIScrollView_minimap

class MyMinimapDataSource: MinimapDataSource {
    var originImageSize: CGSize?
    let scrollView: UIScrollView
    let thumbnailImage: UIImage
    var borderWidth: CGFloat
    var borderColor: UIColor
    var downSizeRatio: CGFloat
    
    init(scrollView: UIScrollView, thumbnailImage: UIImage, originImageSize: CGSize?) {
        self.scrollView = scrollView
        self.thumbnailImage = thumbnailImage
        self.originImageSize = originImageSize
        self.borderWidth = 0.0
        self.borderColor = UIColor()
        self.downSizeRatio = 0.0
    }
    
    func resizeMinimapView(minimapView: MinimapView) {
        let rect = self.scrollViewVisibleSize.divideCGRectByDouble(ratio: self.downSizeRatio)
        minimapView.focusedBoxView?.frame = currentRect(rect: rect)
    }
}
