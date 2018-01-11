//
//  ViewController.swift
//  MyTileImageViewer
//
//  Created by 홍창남 on 2017. 12. 28..
//  Copyright © 2017년 홍창남. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tileImageScrollView: TileImageScrollView!
    var dataSource: TileImageViewDataSource?

    @IBOutlet weak var editorBtn: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var audioContentView = AudioContentView()
    var videoContentView = VideoContentView()
    var textContentView = TextContentView()
    var titleLabel = UILabel()
    
    var markerDataSource: MarkerViewDataSource!
    var isEditor = false
    var centerPoint = UIView()
    var markerArray = [MarkerView]()
    var imageSize = CGSize()
    
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

        let tiles: [CGSize] = [CGSize(width: 2048, height: 2048), CGSize(width: 1024, height: 1024),
                               CGSize(width: 512, height: 512), CGSize(width: 256, height: 256),
                               CGSize(width: 128, height: 128)]

        UIImage.saveTileOf(size: tiles, name: "bench", withExtension: "jpg")

        imageSize = CGSize(width: 5214, height: 7300)
        let thumbnailImageURL = Bundle.main.url(forResource: "smallBench", withExtension: "jpg")!

        setupExample(imageSize: imageSize, tileSize: tiles, imageURL: thumbnailImageURL)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addMarker), name: NSNotification.Name(rawValue: "makeMarker"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMarker), name: NSNotification.Name(rawValue: "showMarker"), object: nil)
        //        scrollView.contentInsetAdjustmentBehavior = .never
      
        
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
        
        // markerData Source 설정
        markerDataSource = MarkerViewDataSource(scrollView: tileImageScrollView, imageSize: imageSize, ratioByImage: 180, titleLabelView: titleLabel, audioContentView: audioContentView, videoContentView: videoContentView, textContentView: textContentView)
        
        
//        setZoomParametersForSize(tileImageScrollView.bounds.size)
        recenterImage()
        
        // edit center point 설정
        centerPoint.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2 + tileImageScrollView.frame.origin.y/2, width: CGFloat(10), height: CGFloat(10))
        centerPoint.backgroundColor = UIColor.red
        centerPoint.layer.cornerRadius = 5
        
        self.view.addSubview(centerPoint)
        centerPoint.isHidden = true
    }
    override func viewWillLayoutSubviews() {
//        setZoomParametersForSize(tileImageScrollView.bounds.size)
        recenterImage()
    }
    
    @IBAction func editionButton(_ sender: Any) {
        if isEditor == false {
            editorBtn.titleLabel?.text = "Done"
            tileImageScrollView.layer.borderWidth = 4
            tileImageScrollView.layer.borderColor = UIColor.red.cgColor
            centerPoint.isHidden = isEditor
            isEditor = true
            
        } else {
            editorBtn.titleLabel?.text = "Editor"
            tileImageScrollView.layer.borderWidth = 0
            centerPoint.isHidden = isEditor
            isEditor = false
            
            
            let editorViewController = EditorContentViewController()
            
            editorViewController.zoom = Double(tileImageScrollView.zoomScale)
            editorViewController.x = Double(tileImageScrollView.contentOffset.x/tileImageScrollView.zoomScale + tileImageScrollView.bounds.size.width/tileImageScrollView.zoomScale/2)
            editorViewController.y = Double(tileImageScrollView.contentOffset.y/tileImageScrollView.zoomScale + tileImageScrollView.bounds.size.height/tileImageScrollView.zoomScale/2)
            
            self.show(editorViewController, sender: nil)
        }
    }
    
    @objc func showMarker(){
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.title = ""
        for marker in markerArray {
            marker.isHidden = true
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        isEditor = false
        tileImageScrollView.layer.borderWidth = 0
        centerPoint.isHidden = true
        editorBtn.titleLabel?.text = "Editor"
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationItem.rightBarButtonItem?.title = "Editor"
        markerDataSource?.reset()
        for marker in markerArray {
            marker.isSelected = false
            marker.isHidden = false
        }
        
    }
    
    func recenterImage() {
        let scrollViewSize = tileImageScrollView.bounds.size
        
        let horizontalSpace = imageSize.width < scrollViewSize.width ? (scrollViewSize.width - imageSize.width) / 2 : 0
        let verticalSpace = imageSize.height < scrollViewSize.height ? (scrollViewSize.height - imageSize.height) / 2 : 0
        
        tileImageScrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
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
        dataSource?.thumbnailImageName = "bench"

        // 줌을 가장 많이 확대한 수준
        dataSource?.maxTileLevel = 5

        // 줌이 가장 확대가 안 된 수준
        dataSource?.minTileLevel = 1

        dataSource?.maxZoomLevel = 8

        dataSource?.imageExtension = "jpg"
        tileImageScrollView.set(dataSource: dataSource!)

        dataSource?.requestBackgroundImage { _ in

        }
    }

    func dummy() {
//        UIImage.saveTileOfSize(tiles, name: "windingRoad")
//        let imageSize = CGSize(width: 5120, height: 3200)
//        UIImage.saveTileOfSize(tileSize, name: "windingRoad")
//        let imageSize = CGSize(width: 5120, height: 3200)
//        let imageURL = Bundle.main.url(forResource: "bench", withExtension: "jpg")!
//        let imageURL = Bundle.main.url(forResource: "windingRoad", withExtension: "jpg")!
//        let imageURL = URL(string: "https://dl.dropbox.com/s/t1xwici6yuxplo0/bench.jpg")!
    }
}

extension ViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "scollViewAction"), object: nil, userInfo: nil)
    }
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "scollViewAction"), object: nil, userInfo: nil)
        markerArray.map { marker in
            markerDataSource?.framSet(markerView: marker)
        }
    }
}

