//
//  MapViewController.swift
//  BiBitto
//
//  Created by admin on 2018/04/22.
//  Copyright © 2018年 aoi.sueki. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MapViewController: UIViewController , UISearchBarDelegate , MKMapViewDelegate{
    
    var locationManager: CLLocationManager!
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var firstFlg = true
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: MapViewController viewDidLoad start")
 
        mapView.delegate = self
        
        // Set up the search results table
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        // Set up the search bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        // Configure the UISearchController appearance
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true

        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self

        
        // 位置情報取得サービスセットアップ
        self.locationManager = CLLocationManager() // インスタンスの生成
        self.locationManager.delegate = self // CLLocationManagerDelegateプロトコルを実装するクラスを指定する
        
        // tracking user location
        self.mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        self.mapView.showsUserLocation = true
        
        // ジェスチャーの生成
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(MapViewController.tapped(_:)))
        self.mapView.addGestureRecognizer(tapGesture)
        
        print("DEBUG_PRINT: MapViewController viewDidLoad end")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: MapViewController viewWillDisappear start")

        // 選択した座標、地名を保存
        for annotation in mapView.annotations {
            if annotation.title != "現在地" {
                if let locationName = annotation.title {
                    UserDefaults.standard.set(locationName, forKey: DefaultString.SelectedLocation)
                }
                let coordinate = annotation.coordinate
                UserDefaults.standard.set(coordinate.latitude.description, forKey: DefaultString.SelectedLatitude)
                UserDefaults.standard.set(coordinate.longitude.description, forKey: DefaultString.SelectedLongitude)
            }
        }
        
        print("DEBUG_PRINT: MapViewController viewWillDisappear end")
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ジェスチャーイベント処理
    @objc func tapped(_ sender: UITapGestureRecognizer){
        print("DEBUG_PRINT: MapViewController tapped start")

        //マップビュー内のタップした位置を取得する。
        let location:CGPoint = sender.location(in: mapView)
        if (sender.state == UIGestureRecognizerState.ended){

            // clear existing pins
            mapView.removeAnnotations(mapView.annotations)
            for overlay in mapView.overlays {
                mapView.remove(overlay)
            }

            //タップした位置を緯度、経度の座標に変換する。
            let mapPoint:CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
            
            //ピンを作成してマップビューに登録する。
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
            annotation.title = ""
            annotation.subtitle = ""
            mapView.addAnnotation(annotation)

            // 円を描く
            let circle = MKCircle(center: mapPoint, radius: 50)
            mapView.add(circle)
            
        }
        print("DEBUG_PRINT: MapViewController tapped end")
    }
    
    // 円の色などを設定
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("DEBUG_PRINT: MapViewController rendererFor")

        let circleRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.fillColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 0.5)
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("DEBUG_PRINT: MapViewController didChangeAuthorization start")
        
        switch status {
        case .notDetermined:
            print("ユーザーはこのアプリケーションに関してまだ選択を行っていません")
            // アプリケーションに関してまだ選択されていない
            //locationManager.requestWhenInUseAuthorization() // 起動中のみの取得許可を求める
            locationManager.requestAlwaysAuthorization() // 常時取得の許可を求める
            
            break
        case .denied:
            print("ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）")
            // 「設定 > プライバシー > 位置情報サービス で、位置情報サービスの利用を許可して下さい」を表示する
            break
        case .restricted:
            print("このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)")
            // 「このアプリは、位置情報を取得できないために、正常に動作できません」を表示する
            break
        case .authorizedAlways:
            print("常時、位置情報の取得が許可されています。")
            // 位置情報取得の設定
            locationManager.allowsBackgroundLocationUpdates = true // バックグランドモードで使用する場合YESにする必要がある
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // 位置情報取得の精度
            locationManager.distanceFilter = 1 // 位置情報取得する間隔、1m単位とする
            // iOSが位置情報を新たに取得する必要がない状況を自動的に判断し、位置情報取得をポーズしてくれる（バックグラウンドでポーズされるとダメなので今回は　false）
            //locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.activityType = .fitness
            // 位置情報取得の開始処理
            locationManager.startUpdatingLocation()
            break
        case .authorizedWhenInUse:
            print("起動時のみ、位置情報の取得が許可されています。")
            // 位置情報取得の設定
            locationManager.allowsBackgroundLocationUpdates = true // バックグランドモードで使用する場合YESにする必要がある
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // 位置情報取得の精度
            locationManager.distanceFilter = 1 // 位置情報取得する間隔、1m単位とする
            // iOSが位置情報を新たに取得する必要がない状況を自動的に判断し、位置情報取得をポーズしてくれる（バックグラウンドでポーズされるとダメなので今回は　false）
            //locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.activityType = .fitness
            // 位置情報取得の開始処理
            locationManager.startUpdatingLocation()
            break
        }
        
        print("DEBUG_PRINT: MapViewController didChangeAuthorization end")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("DEBUG_PRINT: MapViewController didUpdateLocations start")
        
        guard let newLocation = locations.last else {
            return
        }
        guard self.firstFlg == true else {
            return
        }
        
        var location:CLLocationCoordinate2D?
        // 選択済みの場所がある場合はそっちを初期表示にする
        if UserDefaults.standard.string(forKey: DefaultString.SelectedLongitude) != nil &&
            UserDefaults.standard.string(forKey: DefaultString.SelectedLongitude) != "" &&
            UserDefaults.standard.string(forKey: DefaultString.SelectedLatitude) != nil &&
            UserDefaults.standard.string(forKey: DefaultString.SelectedLatitude) != "" {

            print("DEBUG_PRINT: MapViewController didUpdateLocations selected...")

            location = CLLocationCoordinate2DMake(Double(UserDefaults.standard.string(forKey: DefaultString.SelectedLatitude)!)!,Double(UserDefaults.standard.string(forKey: DefaultString.SelectedLongitude)!)!)
            
            // clear existing pins
            mapView.removeAnnotations(mapView.annotations)
            for overlay in mapView.overlays {
                mapView.remove(overlay)
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location!
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true)
            
            // Showing annotation zooms the map automatically.
            mapView.showAnnotations(mapView.annotations, animated: true)
            
            // 円を描く
            let circle = MKCircle(center: annotation.coordinate, radius: 50)
            mapView.add(circle)
            
            // mapにセット
            let span = MKCoordinateSpanMake(0.007, 0.007)
            let region = MKCoordinateRegionMake(location!, span)
            mapView.setRegion(region, animated: true)
            firstFlg = false
            
        }else{
            print("DEBUG_PRINT: MapViewController didUpdateLocations not selected...")

            // 現在地を表示
            location = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
            // update annotation
            mapView.removeAnnotations(mapView.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location!
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true)
            
            // Showing annotation zooms the map automatically.
            mapView.showAnnotations(mapView.annotations, animated: true)
            
            firstFlg = false
        }
        
        print("DEBUG_PRINT: MapViewController didUpdateLocations end")
    }
}

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.007, 0.007)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        // 円を描く
        let circle = MKCircle(center: placemark.coordinate, radius: 50)
        mapView.add(circle)
    }
}
