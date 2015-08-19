//
//  ViewController.swift
//  GaoDeMapTest
//
//  Created by goofygao on 8/19/15.
//  Copyright (c) 2015 goofyy. All rights reserved.
//

import UIKit

let APIKey = "ebcfb60e7224e45b7058a91cfcac023e"

class ViewController: UIViewController ,MAMapViewDelegate, AMapSearchDelegate{
    
    var mapView:MAMapView?
    var search:AMapSearchAPI?
    var currentLocation:CLLocation?
    var buttonLocation:UIButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        MAMapServices.sharedServices().apiKey = APIKey
        
        initMapView()
        
        initSearch()
        
        initButtonLocation()
    }

    func initMapView(){
        
        mapView = MAMapView(frame: self.view.bounds)
        
        mapView!.delegate = self
        
        self.view.addSubview(mapView!)
        
        let compassX = mapView?.compassOrigin.x
        
        let scaleX = mapView?.scaleOrigin.x
        
        //设置指南针和比例尺的位置
        mapView?.compassOrigin = CGPointMake(compassX!, 21)
        
        mapView?.scaleOrigin = CGPointMake(scaleX!, 21)
        
        // 开启定位
        mapView!.showsUserLocation = true
        
        // 设置跟随定位模式，将定位点设置成地图中心点
        mapView!.userTrackingMode = MAUserTrackingMode.Follow
        
    }
    
    // 初始化 AMapSearchAPI
    func initSearch(){
        search = AMapSearchAPI(searchKey: APIKey, delegate: self);
    }
    
    // 逆地理编码   经纬度 = >   地理位置
    func reverseGeocoding(){
        
        let coordinate = currentLocation?.coordinate
        
        // 构造 AMapReGeocodeSearchRequest 对象，配置查询参数（中心点坐标）
        let regeo: AMapReGeocodeSearchRequest = AMapReGeocodeSearchRequest()
        
        regeo.location = AMapGeoPoint.locationWithLatitude(CGFloat(coordinate!.latitude), longitude: CGFloat(coordinate!.longitude))
        
        println("regeo :\(regeo)")
        
        // 进行逆地理编码查询
        self.search!.AMapReGoecodeSearch(regeo)
        
    }
    
    // 定位回调
    func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        if updatingLocation {
            currentLocation = userLocation.location
        }
    }
    
    // 点击Annoation回调
    func mapView(mapView: MAMapView!, didSelectAnnotationView view: MAAnnotationView!) {
        // 若点击的是定位标注，则执行逆地理编码
        if view.annotation.isKindOfClass(MAUserLocation){
            reverseGeocoding()
        }
    }
    
    // 逆地理编码回调
    func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        println("request :\(request)")
        println("response :\(response)")
        
        if (response.regeocode != nil) {
            
            var title:String?
            
            if (count(response.regeocode.addressComponent.city) == 0){
                title = response.regeocode.addressComponent.province
            }
            //给定位标注的title和subtitle赋值，在气泡中显示定位点的地址信息
            mapView?.userLocation.title = title
            mapView?.userLocation.subtitle = response.regeocode.formattedAddress
        }
        
    }
    
    func mapView(mapView: MAMapView!, didChangeUserTrackingMode mode: MAUserTrackingMode, animated: Bool) {
        if mode == .None {
            buttonLocation.backgroundColor = UIColor.redColor()
            
        } else {
            buttonLocation.backgroundColor = UIColor.greenColor()
        }
    }
    
    func initButtonLocation() {
        buttonLocation.frame = CGRectMake(20, 40, 40, 40)
        buttonLocation.addTarget(self, action: "getJiaoDian", forControlEvents: UIControlEvents.TouchDown)
        buttonLocation.backgroundColor = UIColor.redColor()
        
        self.view.addSubview(buttonLocation)
    }
    
    func getJiaoDian() {
        mapView!.userTrackingMode = mapView?.userTrackingMode == .None ? .None : .Follow
    }
    
    
}