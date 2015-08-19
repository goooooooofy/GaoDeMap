//
//  ViewController.swift
//  GaoDeMapTest
//
//  Created by goofygao on 8/19/15.
//  Copyright (c) 2015 goofyy. All rights reserved.
//

import UIKit

let APIKey = "ebcfb60e7224e45b7058a91cfcac023e"

class ViewController: UIViewController ,MAMapViewDelegate, AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource{
    
    var mapView:MAMapView?
    var search:AMapSearchAPI?
    var currentLocation:CLLocation?
    var buttonLocation = UIButton()
    var buttonSearchNearby = UIButton()
    var tableView:UITableView = UITableView()
    var pois = [AMapPOI]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        search?.delegate = self
        
        MAMapServices.sharedServices().apiKey = APIKey
        
        initMapView()
        
        initSearch()
        
        initButtonLocation()
        
        initTableView()
    }

    func initMapView(){
        
        mapView = MAMapView(frame: CGRectMake(0, 0, DeviceData.screenWidth, DeviceData.screenHeight * 0.5))
        
        
        
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
    /**
    回调方法
    当userTrackingMode状态发生改变的时候进行回调
    */
    func mapView(mapView: MAMapView!, didChangeUserTrackingMode mode: MAUserTrackingMode, animated: Bool) {
        if mode == .None {
            buttonLocation.setImage(UIImage(named: "locationing"), forState: .Normal)
            
        } else {
            buttonLocation.setImage(UIImage(named: "locationed"), forState: .Normal)        }
    }
    
    /**
    回调方法
    
    获取搜索的数据
    */
    
    func onPlaceSearchDone(request: AMapPlaceSearchRequest!, response: AMapPlaceSearchResponse!) {
        println("\(request)")
        println("\(response)")
        if((response) == nil) {return}
        pois = response.pois  as! [(AMapPOI)]
        println("___________\(pois)")
        tableView.reloadData()
    }
    
    func searchRequest(request: AnyObject!, didFailWithError error: NSError!) {
        println("\(error)")
    }
    
    func initButtonLocation() {
        buttonLocation.frame = CGRectMake(20, mapView!.frame.height - 60, 30, 30)
        buttonLocation.addTarget(self, action: "getJiaoDian", forControlEvents: UIControlEvents.TouchDown)
        buttonLocation.setImage(UIImage(named: "locationed"), forState: .Normal)
        
        buttonSearchNearby.frame = CGRectMake(DeviceData.screenWidth - 40, 60, 30, 30)
        buttonSearchNearby.setImage(UIImage(named: "search.png"), forState: .Normal)
        buttonSearchNearby.addTarget(self, action: "searchAction", forControlEvents: .TouchDown)
        
        self.view.addSubview(buttonSearchNearby)
        self.view.addSubview(buttonLocation)
    }
    
    func getJiaoDian() {
        mapView!.userTrackingMode = mapView?.userTrackingMode == .None ? .None : .Follow
    }
    
    func searchAction() {
        
        var request:AMapPlaceSearchRequest = AMapPlaceSearchRequest()
        request.searchType = AMapSearchType.PlaceAround
        request.location = AMapGeoPoint.locationWithLatitude(CGFloat(currentLocation!.coordinate.latitude), longitude: CGFloat(currentLocation!.coordinate.longitude))
        request.keywords = "餐厅"
        println("\(currentLocation!.coordinate.latitude)")
        
        search?.AMapPlaceSearch(request)
    }
    
    
    func initTableView() {
        tableView.frame = CGRectMake(0, DeviceData.screenHeight / 2, DeviceData.screenWidth, DeviceData.screenHeight / 2)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        var poi:AMapPOI = pois[indexPath.row]
        
        cell.textLabel?.text = "\(poi.name)"
        
        cell.detailTextLabel?.text = "\(poi.address)"
        
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pois.count
    }
    
    
    
    
    
}