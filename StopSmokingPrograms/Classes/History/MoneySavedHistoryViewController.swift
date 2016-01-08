//
//  MoneySavedHistoryViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/6.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit
import Charts

class MoneySavedHistoryViewController: HistoryBasicViewController, UITableViewDelegate, ChartViewDelegate {
    
    var allRecord = Array<(key: AnyObject, value: AnyObject)>()
    
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var pageDescriptionLabel: UILabel!
    
    private var upperLimitLine: ChartLimitLine!
    private var lowerLimitLine: ChartLimitLine!
    private var leftAxis: ChartYAxis!
    private var rightAxis: ChartYAxis!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setUpSettingViewController(self)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting"), style: UIBarButtonItemStyle.Done, target: self, action: "showSettingViewController:")
        
        setUpLineChart()
        loadChartsDataWithLimitDays(HistorySettingDays.LastThreeDays)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpLineChart(){
        
        lineChart.delegate = self
        lineChart.descriptionText = ""
        lineChart.dragEnabled = true
        lineChart.setScaleEnabled(true)
        lineChart.pinchZoomEnabled = true
        lineChart.drawGridBackgroundEnabled = false
        lineChart.noDataText = "没有统计数据可以显示"
        
        upperLimitLine = ChartLimitLine(limit: 100, label: "资金节省 上限")
        upperLimitLine.lineWidth = 4.0
        upperLimitLine.lineDashLengths = [5, 5]
        upperLimitLine.labelPosition = ChartLimitLine.ChartLimitLabelPosition.RightBottom
        upperLimitLine.valueFont = UIFont.systemFontOfSize(10)
        
        lowerLimitLine = ChartLimitLine(limit: 100, label: "资金节省 下限")
        lowerLimitLine.lineWidth = 4.0
        lowerLimitLine.lineDashLengths = [5, 5]
        lowerLimitLine.labelPosition = ChartLimitLine.ChartLimitLabelPosition.RightBottom
        lowerLimitLine.valueFont = UIFont.systemFontOfSize(10)
        
        leftAxis = lineChart.leftAxis
        leftAxis.removeAllLimitLines()
        leftAxis.addLimitLine(upperLimitLine)
        leftAxis.addLimitLine(lowerLimitLine)
        leftAxis.customAxisMax = 50
        leftAxis.customAxisMin = -50
        leftAxis.startAtZeroEnabled = false
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        //        lineChart.rightAxis.enabled = true
        rightAxis = lineChart.rightAxis
        rightAxis.removeAllLimitLines()
        rightAxis.addLimitLine(upperLimitLine)
        rightAxis.addLimitLine(lowerLimitLine)
        rightAxis.customAxisMax = 50
        rightAxis.customAxisMin = -50
        rightAxis.startAtZeroEnabled = false
        rightAxis.gridLineDashLengths = [5, 5]
        rightAxis.drawLimitLinesBehindDataEnabled = true
        
        
        lineChart.xAxis.axisLabelModulus = 40
        lineChart.xAxis.avoidFirstLastClippingEnabled = true
        
        lineChart.viewPortHandler.setMaximumScaleX(15)
        lineChart.viewPortHandler.setMaximumScaleY(2)
        
        let marker = BalloonMarker(color: KM_COLOR_BLACK_ALPHA, font: UIFont.systemFontOfSize(12), insets: UIEdgeInsetsMake(8, 8, 2, 8))
        marker.minimumSize = CGSizeMake(80, 40)
        lineChart.marker = marker
        
        lineChart.legend.form = ChartLegend.ChartLegendForm.Line
    }
    
    // MARK: - 获取显示数据
    func loadChartsDataWithLimitDays(historySettingDays: HistorySettingDays){
        
        dispatch_async(dispatch_get_main_queue()) { [weak self]() -> Void in
            if self != nil{
                
                let tabBarVC = self!.tabBarController as! HistoryTabBarViewController
                self!.allRecord.removeAll()
                
                switch historySettingDays{
                case .LastThreeDays:
                    self!.allRecord.appendContentsOf(tabBarVC.getLastRecordWithLimitDays(3))
                    self!.pageDescriptionLabel.text = "3天内资金节省状况"
                case .LastWeek:
                    self!.allRecord.appendContentsOf(tabBarVC.getLastRecordWithLimitDays(7))
                    self!.pageDescriptionLabel.text = "一周内资金节省状况"
                case .LastMonth:
                    self!.allRecord.appendContentsOf(tabBarVC.getLastRecordWithLimitDays(30))
                    self!.pageDescriptionLabel.text = "一个月内资金节省状况"
                }
                
                var xVals = [NSObject]()
                var yVals = [ChartDataEntry]()
                
                var maxSaved: Double = 0
                var minSaved: Double = 0
                
                for var i = 0; i < self!.allRecord.count; ++i {
                    let entry = self!.allRecord[i]
                    
                    let date = entry.key as? NSDate ?? NSDate()
                    xVals.append(KimreeDateTool.dateStringWithDate(date))
                    
                    let value = entry.value as? NSDictionary
                    let habitsNum:Int = (value?.objectForKey("habitsNum"))?.integerValue ?? 0
                    let smokedNum:Int = (value?.objectForKey("smokedNum"))?.integerValue ?? 0
                    let priceForOnePackage: Float = (value?.objectForKey("priceForOnePackage"))?.floatValue ?? 0
                    
                    let moneySaved = Double(habitsNum - smokedNum) * Double(priceForOnePackage) / 20
                    yVals.append(ChartDataEntry(value: moneySaved, xIndex: i))
                    
                    if moneySaved > maxSaved{
                        maxSaved = moneySaved
                    }
                    if moneySaved < minSaved{
                        minSaved = moneySaved
                    }
                    
                    // 只有一条数据时 Charts 会报错, 保证起码有2条数据要在界面显示
                    if self!.allRecord.count == 1{
                        xVals.append(KimreeDateTool.dateStringWithDate(date))
                        yVals.append(ChartDataEntry(value: moneySaved, xIndex: i + 1))
                    }
                }
                
                self!.upperLimitLine.limit = maxSaved + 5
                self!.lowerLimitLine.limit = minSaved - 5
                
                self!.leftAxis.customAxisMax = maxSaved + 5 + 5
                self!.leftAxis.customAxisMin = minSaved - 5 - 5
                self!.rightAxis.customAxisMax = maxSaved + 5 + 5
                self!.rightAxis.customAxisMin = minSaved - 5 - 5
                
                let set = LineChartDataSet(yVals: yVals, label: "节省资金(元)")
                set.lineDashLengths = [5, 5]
                set.highlightLineDashLengths = [5, 2.5]
                set.setColor(KM_COLOR_BLACK_ALPHA)
                set.setCircleColor(KM_COLOR_NAVIGATION_BAR_BUTTON_ITEM)
                set.lineWidth = 2
                set.circleRadius = 5
                set.drawCircleHoleEnabled = false
                set.valueFont = UIFont.systemFontOfSize(9)
                set.fillAlpha = 65 / 255.0
                set.fillColor = UIColor.blackColor()
                
                var dataSet = [ChartDataSet]()
                dataSet.append(set)
                
                let lineData = LineChartData(xVals: xVals)
                lineData.dataSets = dataSet
                
                self!.lineChart.noDataText = ""
                self!.lineChart.data = lineData
                self!.lineChart.animate(xAxisDuration: 2, yAxisDuration: 2, easingOption: ChartEasingOption.EaseInOutQuart)
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
    
    // MARK: - ChartViewDelegate
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
