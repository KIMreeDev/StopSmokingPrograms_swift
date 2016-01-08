//
//  SmokingMapViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/12.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class SmokingMapViewController: HistoryBasicViewController, UITableViewDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var locationDescriptionLabel: UILabel!
    @IBOutlet weak var pageDescriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        setUpSettingViewController(self)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting"), style: UIBarButtonItemStyle.Done, target: self, action: "showSettingViewController:")
        
        mapView.mapType = MKMapType.Standard
        mapView.zoomEnabled = true
        mapView.delegate = self
        
        loadChartsDataWithLimitDays(HistorySettingDays.LastThreeDays)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 获取显示数据
    func loadChartsDataWithLimitDays(historySettingDays: HistorySettingDays){
        dispatch_async(dispatch_get_main_queue()) { [weak self]() -> Void in
            if self != nil{
                
                let tabBarVC = self!.tabBarController as! HistoryTabBarViewController
                self!.locationDescriptionLabel.text = ""
                
                self!.mapView.removeAnnotations(self!.mapView.annotations)
                
                var allRecord = Array<(key: AnyObject, value: AnyObject)>()
                
                switch historySettingDays{
                case .LastThreeDays:
                    allRecord.appendContentsOf(tabBarVC.getLastRecordInfoWithLimitDays(3))
                    self!.pageDescriptionLabel.text = "3天内的吸烟位置记录信息"
                case .LastWeek:
                    allRecord.appendContentsOf(tabBarVC.getLastRecordInfoWithLimitDays(7))
                    self!.pageDescriptionLabel.text = "一周的吸烟位置记录信息"
                case .LastMonth:
                    allRecord.appendContentsOf(tabBarVC.getLastRecordInfoWithLimitDays(30))
                    self!.pageDescriptionLabel.text = "一个月的吸烟位置记录信息"
                }
                
                for record in allRecord{
                    let dateStr = KimreeDateTool.dateStringWithDate(record.key as? NSDate ?? NSDate())
                    let dataDic = record.value as! NSMutableDictionary
                    for info in dataDic{
                        let geocoder = CLGeocoder()
                        let infoDic = info.value as! NSMutableDictionary
                        let hour = (infoDic.objectForKey("hour") ?? "").integerValue
                        let latitude = infoDic.objectForKey("latitude")?.doubleValue
                        let longitude = infoDic.objectForKey("longitude")?.doubleValue
                        
                        if latitude != nil && longitude != nil{
                            geocoder.reverseGeocodeLocation(CLLocation(latitude: latitude!, longitude: longitude!), completionHandler: { (placeMarks: [CLPlacemark]?, error: NSError?) -> Void in
                                if placeMarks != nil{
                                    let mark = placeMarks![0]
                                    self!.mapView.addAnnotation(MyAnnotation(coordinate: mark.location!.coordinate, title: "\(mark.name!)", subtitle: "\(dateStr) \(hour)时"))
                                }
                                
                            })
                        }
                        
                    }
                }
                
                self!.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
            }
        }
        
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let row = indexPath.row
        
        if row == 0{
            loadChartsDataWithLimitDays(HistorySettingDays.LastThreeDays)
        }else if row == 1{
            loadChartsDataWithLimitDays(HistorySettingDays.LastWeek)
        }else if row == 2{
            loadChartsDataWithLimitDays(HistorySettingDays.LastMonth)
        }
        
        self.popoverViewController?.dismissPopoverAnimated(true)
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let title: String! = view.annotation!.title! ?? ""
        let subtitle: String! = view.annotation!.subtitle! ?? ""
        
        let description = (subtitle == "") ? "\(title)" : "\(subtitle) : \(title)"
        locationDescriptionLabel.text = description
        locationDescriptionLabel.sizeToFit()
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
