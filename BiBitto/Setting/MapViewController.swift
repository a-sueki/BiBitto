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

class MapViewController: UIViewController {
    
    var locationManager: CLLocationManager!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: MapViewController viewDidLoad start")

        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(SettingViewController.cancelTapped(_:))

        // 位置情報取得サービスセットアップ
        locationManager = CLLocationManager() // インスタンスの生成
        locationManager.delegate = self // CLLocationManagerDelegateプロトコルを実装するクラスを指定する
        
        // tracking user location
        mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        mapView.showsUserLocation = true

        print("DEBUG_PRINT: MapViewController viewDidLoad end")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapViewController: CLLocationManagerDelegate {
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("DEBUG_PRINT: SettingViewController didChangeAuthorization start")
        
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
            // 位置情報取得の開始処理
            locationManager.startUpdatingLocation()
            break
        case .authorizedWhenInUse:
            print("起動時のみ、位置情報の取得が許可されています。")
            // 位置情報取得の設定
            locationManager.allowsBackgroundLocationUpdates = true // バックグランドモードで使用する場合YESにする必要がある
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // 位置情報取得の精度
            locationManager.distanceFilter = 1 // 位置情報取得する間隔、1m単位とする
            // 位置情報取得の開始処理
            locationManager.startUpdatingLocation()
            break
        }
        
        print("DEBUG_PRINT: SettingViewController didChangeAuthorization end")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("DEBUG_PRINT: SettingViewController didUpdateLocations start")
        
        guard let newLocation = locations.last else {
            return
        }
        
        let location:CLLocationCoordinate2D
            = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
        let latitude = "".appendingFormat("%.4f", location.latitude)
        let longitude = "".appendingFormat("%.4f", location.longitude)
        
        print("latitude:\(latitude)")
        print("longitude:\(longitude)")
        //        latLabel.text = "latitude: " + latitude
        //        lngLabel.text = "longitude: " + longitude
        
        // update annotation
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = newLocation.coordinate
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        
        // Showing annotation zooms the map automatically.
        mapView.showAnnotations(mapView.annotations, animated: true)
        
        print("DEBUG_PRINT: SettingViewController didUpdateLocations end")
    }
}

