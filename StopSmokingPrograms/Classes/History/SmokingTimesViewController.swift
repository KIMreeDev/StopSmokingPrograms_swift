//
//  SmokingTimesViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/11.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit
import Charts

class SmokingTimesViewController: HistoryBasicViewController , UITableViewDelegate, ChartViewDelegate {
    
    @IBOutlet weak var barChart: HorizontalBarChartView!
    @IBOutlet weak var pageDescriptionLabel: UILabel!
    
    var allRecord = Array<(key: AnyObject, value: AnyObject)>()
    
    private var xAxis: ChartXAxis!
    private var leftAxis: ChartYAxis!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setUpSettingViewController(self)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting"), style: UIBarButtonItemStyle.Done, target: self, action: "showSettingViewController:")
        
        setUpBarChart()
        loadChartsDataWithLimitDays(HistorySettingDays.LastThreeDays)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpBarChart(){
        barChart.delegate = self
        barChart.descriptionText = ""
        barChart.drawBarShadowEnabled = false
        barChart.drawValueAboveBarEnabled = true
        barChart.pinchZoomEnabled = false
        barChart.drawGridBackgroundEnabled = false
        barChart.noDataText = "没有统计数据可以显示"
        
        barChart.viewPortHandler.setMaximumScaleX(2)
        barChart.viewPortHandler.setMaximumScaleY(1)
        
        xAxis = barChart.xAxis
        xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.Bottom
        xAxis.labelFont = UIFont.systemFontOfSize(10)
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.gridLineWidth = 0.3
        
        leftAxis = barChart.leftAxis
        leftAxis.labelFont = UIFont.systemFontOfSize(10)
        leftAxis.drawAxisLineEnabled = true
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridLineWidth = 0.3
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
        leftAxis.valueFormatter = numberFormatter
        
        let rightAxis = barChart.rightAxis
        rightAxis.labelFont = UIFont.systemFontOfSize(10)
        rightAxis.drawAxisLineEnabled = true
        rightAxis.drawGridLinesEnabled = false
        rightAxis.valueFormatter = leftAxis.valueFormatter
        
        barChart.legend.position = ChartLegend.ChartLegendPosition.BelowChartLeft
        barChart.legend.form = ChartLegend.ChartLegendForm.Square
        barChart.legend.formSize = 8
        barChart.legend.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        barChart.legend.xEntrySpace = 4
    }
    
    func loadChartsDataWithLimitDays(historySettingDays: HistorySettingDays){
        
        dispatch_async(dispatch_get_main_queue()) { [weak self]() -> Void in
            if self != nil{
                let tabBarVC = self!.tabBarController as! HistoryTabBarViewController
                self!.allRecord.removeAll()
                
                switch historySettingDays{
                case .LastThreeDays:
                    self!.allRecord.appendContentsOf(tabBarVC.getLastRecordInfoWithLimitDays(3))
                    self!.pageDescriptionLabel.text = "3天内的吸烟时间统计"
                case .LastWeek:
                    self!.allRecord.appendContentsOf(tabBarVC.getLastRecordInfoWithLimitDays(7))
                    self!.pageDescriptionLabel.text = "一周的吸烟时间统计"
                case .LastMonth:
                    self!.allRecord.appendContentsOf(tabBarVC.getLastRecordInfoWithLimitDays(30))
                    self!.pageDescriptionLabel.text = "一个月的吸烟时间统计"
                }
                
                var countDic = [Int: Int]()
                for var i = 0; i < 24; ++i {
                    countDic[i] = 0
                }
                
                for record in self!.allRecord{
                    let dic = record.value as! NSMutableDictionary
                    for _ele in dic{
                        let data = _ele.value as! NSMutableDictionary
                        let hour = (data.objectForKey("hour") ?? "").integerValue
                        countDic[hour] = (countDic[hour] ?? 0) + 1
                    }
                }
                
                var showData = [(Int, Int)]()
                for data in countDic{
                    showData.append(data)
                }
                
                showData = showData.sort({ (data1: (Int, Int), data2: (Int, Int)) -> Bool in
                    return data1.0 > data2.0
                })
                
                
                var xVals = [NSObject]()
                var yVals = [BarChartDataEntry]()
                
                for var i = 0; i < showData.count; ++i {
                    let _data = showData[i]
                    xVals.append(String(stringInterpolationSegment: _data.0))
                    yVals.append(BarChartDataEntry(value: Double(_data.1), xIndex: i))
                }
                
                let set = BarChartDataSet(yVals: yVals, label: "所在时间点的吸烟记录数量")
                set.barSpace = 0.4
                let numberFormatter = NSNumberFormatter()
                numberFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
                set.valueFormatter = numberFormatter
                
                var dataSet = [ChartDataSet]()
                dataSet.append(set)
                
                let data = BarChartData(xVals: xVals, dataSets: dataSet)
                data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10))
                
                self!.barChart.noDataText = ""
                self!.barChart.data = data
                self!.barChart.animate(xAxisDuration: 0, yAxisDuration: 2, easingOption: ChartEasingOption.EaseInOutQuart)
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}
