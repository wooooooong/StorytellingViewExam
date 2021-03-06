//
//  ViewController.swift
//  MyTileImageViewer
//
//  Created by 홍창남 on 2017. 12. 28..
//  Copyright © 2017년 홍창남. All rights reserved.
//

import UIKit
import UIScrollView_minimap

class ViewController: UIViewController {

    @IBOutlet weak var tileImageScrollView: TileImageScrollView!
    @IBOutlet weak var minimap: MinimapView!
    
    var dataSource: TileImageViewDataSource?
    var minimapDataSource: MinimapDataSource?
    
    var audioContentView = AudioContentView()
    var videoContentView = VideoContentView()
    var textContentView = TextContentView()
    var titleLabel = UILabel()
    var num = 0
    var markerDataSource: MarkerViewDataSource!
    var isEditor = false
    var isSelected = false
    var centerPoint = UIView()
    var markerArray = [MarkerView]()
    var imageSize = CGSize()
    var imageName = "shopping"
    var imageExtension = "jpg"
    var thumbnailName = "shoppingSmall"
    var thumbnailExtension = "jpeg"
    
    @objc func addMarker(_ notification: NSNotification){
        let marker = MarkerView()
        let x = notification.userInfo?["x"]
        let y = notification.userInfo?["y"]
        let zoom =  notification.userInfo?["zoomScale"]
        let isAudioContent = notification.userInfo?["isAudioContent"]
        let isVideoContent = notification.userInfo?["isVideoContent"]
        let videoURL = notification.userInfo?["videoURL"]
        let audioURL = notification.userInfo?["audioURL"]
        let markerTitle = notification.userInfo?["title"]
        let link = notification.userInfo?["link"]
        let text = notification.userInfo?["text"]
        let isText = notification.userInfo?["isText"]
        
        marker.set(dataSource: markerDataSource, x: CGFloat(x as! Double), y: CGFloat(y as! Double), zoomScale: CGFloat(zoom as! Double), isTitleContent: true, isAudioContent: isAudioContent as! Bool, isVideoContent: isVideoContent as! Bool, isTextContent: isText as! Bool)
        
        marker.setAudioContent(url: audioURL as! URL)
        marker.setVideoContent(url: videoURL as! URL)
        marker.setTitle(title: markerTitle as! String)
        marker.setText(title: "", link: link as! String, content: text as! String)
        marker.setMarkerImage(markerImage: #imageLiteral(resourceName: "page"))
        
        markerArray.append(marker)
        markerDataSource.framSet(markerView: marker)
        markerDataSource.reset()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(0, forKey: "integerKeyName")
        
        let tiles: [CGSize] = [CGSize(width: 2048, height: 2048), CGSize(width: 1024, height: 1024),
                               CGSize(width: 512, height: 512), CGSize(width: 256, height: 256),
                               CGSize(width: 128, height: 128)]

        UIImage.saveTileOf(size: tiles, name: imageName, withExtension: imageExtension)
        
        let image = UIImage(named: imageName + "." + imageExtension)
        imageSize = CGSize(width: (image?.size.width)!, height: (image?.size.height)!)
        
        let thumbnailImageURL = Bundle.main.url(forResource: thumbnailName , withExtension: thumbnailExtension)!
        
        setupExample(imageSize: imageSize, tileSize: tiles, imageURL: thumbnailImageURL)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addMarker), name: NSNotification.Name(rawValue: "makeMarker"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMarker), name: NSNotification.Name(rawValue: "showMarker"), object: nil)
        
        // title contentView 설정
        titleLabel.center = self.view.center
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.font.withSize(20)
        self.view.addSubview(titleLabel)
        
        // audio contentView 설정
        audioContentView.frame = CGRect(x: 0, y: 200, width: 80, height: 80)
        self.view.addSubview(audioContentView)
        
        // video contentview 설정
        videoContentView.frame = CGRect(x: self.view.center.x - 75, y: self.view.center.y + 80, width: 150, height: 100)
        self.view.addSubview(videoContentView)
        
        // text contentView 설정
        textContentView.frame = CGRect(x: 0, y: self.view.frame.height - 80, width: self.view.frame.width, height: 100)
        self.view.addSubview(textContentView)
        
        var ratio:Double = 200
        if imageSize.height > imageSize.width {
            ratio = Double(imageSize.height) / 40
        } else {
            ratio = Double(imageSize.width) / 40
        }
        
        // markerData Source 설정
        markerDataSource = MarkerViewDataSource(scrollView: tileImageScrollView, imageSize: imageSize, ratioByImage: ratio, titleLabelView: titleLabel, audioContentView: audioContentView, videoContentView: videoContentView, textContentView: textContentView)
        
        // minimap 설정
        let thumbnailImage = UIImage(contentsOfFile : thumbnailImageURL.path)!
        minimapDataSource = MyMinimapDataSource(scrollView: tileImageScrollView, thumbnailImage: thumbnailImage, originImageSize: imageSize)
        
        minimapDataSource?.borderColor = UIColor.red
        minimapDataSource?.borderWidth = 2.0
        minimapDataSource?.downSizeRatio = 5 * thumbnailImage.size.width / view.frame.width
        minimap.set(dataSource: minimapDataSource!)
        
        
        setZoomParametersForSize(tileImageScrollView.bounds.size)
        
        // edit center point 설정
        centerPoint.frame = CGRect(x: tileImageScrollView.frame.width/2 - 5 , y: tileImageScrollView.frame.height/2 + (self.navigationController?.navigationBar.frame.height)! - 15, width: CGFloat(10), height: CGFloat(10))
        centerPoint.backgroundColor = UIColor.red
        centerPoint.layer.cornerRadius = 5
        
        self.view.addSubview(centerPoint)
        centerPoint.isHidden = true
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backBtn))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Editor", style: .plain, target: self, action: #selector(editorBtn))
        
        
    }
    override func viewWillLayoutSubviews() {
        setZoomParametersForSize(tileImageScrollView.bounds.size)
//        recenterImage()
    }

    @objc func editorBtn() {
        if isSelected == false {
            if isEditor == false {
                self.navigationItem.rightBarButtonItem?.title = "Done"
                tileImageScrollView.layer.borderWidth = 4
                tileImageScrollView.layer.borderColor = UIColor.red.cgColor
                centerPoint.isHidden = isEditor
                isEditor = true
            } else {
                self.navigationItem.rightBarButtonItem?.title = "Editor"
                tileImageScrollView.layer.borderWidth = 0
                centerPoint.isHidden = isEditor
                isEditor = false
                
                let editorViewController = EditorContentViewController()
                
                editorViewController.zoom = Double(tileImageScrollView.zoomScale)
                editorViewController.x = Double(tileImageScrollView.contentOffset.x/tileImageScrollView.zoomScale + tileImageScrollView.bounds.size.width/tileImageScrollView.zoomScale/2)
                editorViewController.y = Double(tileImageScrollView.contentOffset.y/tileImageScrollView.zoomScale + tileImageScrollView.bounds.size.height/tileImageScrollView.zoomScale/2)
                
                self.show(editorViewController, sender: nil)
            }
        } else {
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
            isSelected = false
            for marker in markerArray {
                if marker.num == num {
                    let index = markerArray.index(of: marker)
                    markerArray.remove(at: index!)
                }
            }
            backBtn()
        }
        
    }
    
    @objc func showMarker(_ notification: NSNotification){
        self.navigationItem.rightBarButtonItem?.title = "Delete Marker"
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        isSelected = true
        num = notification.userInfo?["num"] as! Int
        for marker in markerArray {
            marker.isHidden = true
        }
        
    }
    
    @objc func backBtn() {
        isEditor = false
        isSelected = false
        tileImageScrollView.layer.borderWidth = 0
        centerPoint.isHidden = true
        
        self.navigationItem.rightBarButtonItem?.title = "Editor"
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        
        markerDataSource?.reset()
        
        for marker in markerArray {
            marker.isSelected = false
            marker.isHidden = false
        }
    }
    
    func setZoomParametersForSize(_ scrollViewSize: CGSize) {
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        tileImageScrollView.minimumZoomScale = minScale
        tileImageScrollView.maximumZoomScale = 3.0
        tileImageScrollView.zoomScale = minScale
    }
    
    func setupExample(imageSize: CGSize, tileSize: [CGSize], imageURL: URL) {

        dataSource = MyTileImageViewDataSource(imageSize: imageSize, tileSize: tileSize, imageURL: imageURL)
        
        dataSource?.delegate = self
        dataSource?.thumbnailImageName = imageName

        // 줌을 가장 많이 확대한 수준
        dataSource?.maxTileLevel = 5

        // 줌이 가장 확대가 안 된 수준
        dataSource?.minTileLevel = 1

        dataSource?.maxZoomLevel = 8

        dataSource?.imageExtension = imageExtension
        tileImageScrollView.set(dataSource: dataSource!)

        dataSource?.requestBackgroundImage { _ in

        }
    }

}

extension ViewController: TileImageScrollViewDelegate {

    func didScroll(scrollView: TileImageScrollView) {
        minimapDataSource?.resizeMinimapView(minimapView: minimap)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "scollViewAction"), object: nil, userInfo: nil)
    }
    
    func didZoom(scrollView: TileImageScrollView) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "scollViewAction"), object: nil, userInfo: nil)
        
        markerArray.map { marker in
            markerDataSource?.framSet(markerView: marker)
        }
    }
}



