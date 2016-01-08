//
//  SmokingNumberViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/11.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit
import Charts

class SmokingNumberViewController: HistoryBasicViewController , UITableViewDelegate, ChartViewDelegate{
    
    @IBOutlet weak var barChart: HorizontalBarChartView!
    @IBOutlet weak var pageDescriptionLabel: UILabel!
    
    var allRecord = Array<(key: AnyObject, value: AnyObject)>()
    private var leftAxis: ChartYAxis!
    private var rightAxis: ChartYAxis!
    private var xAxis: ChartXAxis!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setUpSettingViewController(self)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting"), style: UIBarButtonItemStyle.Done, target: self, action: "showSettingViewController:")
        
        stUpBarChart()
        loadChartsDataWithLimitDays(HistorySettingDays.LastThreeDays)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stUpBarChart(){
        
        let customerFormatter = NSNumberFormatter()
        customerFormatter.negativePrefix = ""
        customerFormatter.positiveSuffix = "支"
        customerFormatter.negativeSuffix = "支"
        customerFormatter.minimumSignificantDigits = 0
        customerFormatter.minimumFractionDigits = 0
        
        barChart.delegate = self
        barChart.descriptionText = ""
        barChart.drawBarShadowEnabled = false
        barChart.drawValueAboveBarEnabled = true
        barChart.pinchZoomEnabled = false
        barChart.noDataText = "没有统计数据可以显示"
        
        barChart.viewPortHandler.setMaximumScaleX(2)
        barChart.viewPortHandler.setMaximumScaleY(2)
        
        leftAxis = barChart.leftAxis
        leftAxis.enabled = false
        
        rightAxis = barChart.rightAxis
        rightAxis.startAtZeroEnabled = false
        rightAxis.valueFormatter = customerFormatter
        rightAxis.labelFont = UIFont.systemFontOfSize(9)
        
        xAxis = barChart.xAxis
        xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.BothSided
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.labelFont = UIFont.systemFontOfSize(9)
        
        
        let legend = barChart.legend
        legend.position = ChartLegend.ChartLegendPosition.BelowChartLeft
        legend.formSize = 8
        legend.formToTextSpace = 4
        legend.xEntrySpace = 6
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
                    self!.pageDescriptionLabel.text = "3天内的吸烟数量统计"
                case .LastWeek:
                    self!.allRecord.appendContentsOf(tabBarVC.getLastRecordWithLimitDays(7))
                    self!.pageDescriptionLabel.text = "一周的吸烟数量统计"
                case .LastMonth:
                    self!.allRecord.appendContentsOf(tabBarVC.getLastRecordWithLimitDays(30))
                    self!.pageDescriptionLabel.text = "一个月的吸烟数量统计"
                }
                
                self!.allRecord = self!.allRecord.reverse()
                
                var xVals = [NSObject]()
                
                // 左边的barLine需要数据小于 0 ， 右边的大于等于 0
                // 实际情况是左边的数据可能等于 0 , 要选个界面显示符合要求， 需进行修改
                // 修改代码查看 HorizontalBarChartRenderer 标签 //TODO: changed by Fran
                var yVals = [BarChartDataEntry]()
                
                var maxNum = 0
                var minNum = 0
                
                for var i = 0; i < self!.allRecord.count; i++ {
                    let entry = self!.allRecord[i]
                    let date = entry.key as? NSDate
                    let dataDic = entry.value as? NSMutableDictionary
                    let dateStr = KimreeDateTool.dateStringWithDate(date ?? NSDate())
                    let smokedNum = dataDic?.objectForKey("smokedNum")?.integerValue ?? 0
                    let limitNum = dataDic?.objectForKey("habitsNum")?.integerValue ?? 0
                    
                    if maxNum < smokedNum{
                        maxNum = smokedNum
                    }
                    if minNum > -limitNum{
                        minNum = -limitNum
                    }
                    
                    xVals.append(dateStr)
                    yVals.append(BarChartDataEntry(values: [Double(-limitNum), Double(smokedNum)], xIndex: i))
                }
                
                maxNum = maxNum + 5
                minNum = minNum - 5
                
                self!.rightAxis.customAxisMax = Double(maxNum)
                self!.rightAxis.customAxisMin = Double(minNum)
                
                let set = BarChartDataSet(yVals: yVals, label: "吸烟数量")
                set.valueFormatter = self!.rightAxis.valueFormatter
                set.valueFont = UIFont.systemFontOfSize(7)
                set.axisDependency = ChartYAxis.AxisDependency.Right
                set.barSpace = 0.4
                set.colors = [UIColor.redColor(), UIColor.greenColor()]
                set.stackLabels = ["限制吸烟数量", "实际吸烟数量"]
                
                let data = BarChartData(xVals: xVals, dataSet: set)
                
                self!.barChart.noDataText = ""
                self!.barChart.data = data
                self!.barChart.animate(xAxisDuration: 2, yAxisDuration: 2, easingOption: ChartEasingOption.EaseInOutQuart)
                
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
