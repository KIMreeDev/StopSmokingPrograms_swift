//
//  HealthRecoveryViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/13.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

class HealthRecoveryViewController: HealthBasicViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    private var nonSmokedDate: NSDate!
    
    private var currentDate = KimreeDateTool.dateFromString(KimreeDateTool.currentDateString())
    
    // 停止吸烟的天数, 通知吸烟日期小于当前日期时该数据有效
    private lazy var nonSmokedDays: Double = {
        return Double(Int(self.currentDate.timeIntervalSinceDate(self.nonSmokedDate) / 24 / 60 / 60))
    }()
    
    // 身体尼古丁含量减少
    // 目前尚无计算公式
    var nicotineContents: Double{
        get{
            var ratio: Double = 0
            
            if nonSmokedDate.compare(currentDate) == NSComparisonResult.OrderedDescending{
                ratio = 0
            }else{
                let days = self.nonSmokedDays
                if days <= 1{
                    ratio = 0.6
                }else{
                    ratio = 1
                }
            }
            
            if ratio < 0{
                ratio = 0
            }
            
            return ratio
        }
    }
    
    // 血液含氧量提高
    var oxygenContentOfBlood: Double{
        get{
            var ratio: Double = 0
            
            if nonSmokedDate.compare(currentDate) == NSComparisonResult.OrderedDescending{
                ratio = 0
            }else{
                let days = self.nonSmokedDays
                // y=-0.0108147x^2+1.4903x+49.5205
                ratio = (-0.0108147 * pow(days, 2) + 1.4903 * days + 49.5205) / 100
            }
            
            if ratio < 0{
                ratio = 0
            }
            
            return ratio
        }
    }
    
    // 心脏病几率降低
    var heartDisease: Double{
        get{
            var ratio: Double = 0
            
            if nonSmokedDate.compare(currentDate) == NSComparisonResult.OrderedDescending{
                ratio = 0
            }else{
                let days = self.nonSmokedDays
                // y=-3.24249e-05 x^2+0.10762x+9.89241
                ratio = (-3.24249e-5 * pow(days, 2) + 0.10762 * days + 9.89241) / 100
            }
            
            if ratio < 0{
                ratio = 0
            }
            
            return ratio
        }
    }
    
    // 味觉及嗅觉恢复
    var smellAndTaste: Double{
        get{
            var ratio: Double = 0
            
            if nonSmokedDate.compare(currentDate) == NSComparisonResult.OrderedDescending{
                ratio = 0
            }else{
                let days = self.nonSmokedDays
                // y=-0.143514x^2+7.7248x-2.58129
                ratio = (-0.143514 * pow(days, 2) + 7.7248 * days - 2.58129) / 100
            }
            
            if ratio < 0{
                ratio = 0
            }
            
            return ratio
        }
    }
    
    // 肺活量恢复
    var vitalCapacity: Double{
        get{
            var ratio: Double = 0
            
            if nonSmokedDate.compare(currentDate) == NSComparisonResult.OrderedDescending{
                ratio = 0
            }else{
                let days = self.nonSmokedDays
                // y=-0.00198746x^2+0.858218x+9.14377
                ratio = (-0.00198746 * pow(days, 2) + 0.858218 * days + 9.14377) / 100
            }
            
            if ratio < 0{
                ratio = 0
            }
            
            return ratio
        }
    }
    
    // 中风风险降低
    var strokes: Double{
        get{
            var ratio: Double = 0
            
            if nonSmokedDate.compare(currentDate) == NSComparisonResult.OrderedDescending{
                ratio = 0
            }else{
                let nonSmokedDays = Int(self.nonSmokedDays)
                let months = Double(nonSmokedDays % 30 > 0 ? nonSmokedDays / 30 + 1 : nonSmokedDays / 30)
                // y=4.88944e-08x^2+0.0270931x+0.458119
                ratio = (4.88944e-8 * pow(months, 2) + 0.0270931 * months + 0.458119) / 100
            }
            
            if ratio < 0{
                ratio = 0
            }
            
            return ratio
        }
    }
    
    // 肺癌几率降低
    var lungCancer: Double{
        get{
            var ratio: Double = 0
            
            if nonSmokedDate.compare(currentDate) == NSComparisonResult.OrderedDescending{
                ratio = 0
            }else{
                let days = self.nonSmokedDays
                // y=-2.98023e-07x^2+0.0108708x+0.956522
                ratio = (-2.98023e-7 * pow(days, 2) + 0.0108708 * days + 0.956522) / 100
            }
            
            if ratio < 0{
                ratio = 0
            }
            
            return ratio
        }
    }
    
    // 其他癌症几率降低
    var otherCancer: Double{
        get{
            var ratio: Double = 0
            
            if nonSmokedDate.compare(currentDate) == NSComparisonResult.OrderedDescending{
                ratio = 0
            }else{
                let nonSmokedDays = Int(self.nonSmokedDays)
                let months = Double(nonSmokedDays % 30 > 0 ? nonSmokedDays / 30 + 1 : nonSmokedDays / 30)
                // y=4.88944e-08x^2+0.0270931x+0.458119
                ratio = (4.88944e-8 * pow(months, 2) + 0.0270931 * months + 0.458119) / 100
            }
            
            if ratio < 0{
                ratio = 0
            }
            
            return ratio
        }
    }
    
    // 健康恢复总量
    var healthRecovery: Double{
        get{
            var ratio: Double = 0
            
            if nonSmokedDate.compare(currentDate) == NSComparisonResult.OrderedDescending{
                ratio = 0
            }else{
                let days = self.nonSmokedDays
                // y=-5.72205e-06x^2+0.0443926x+10.9556(小于15年时)
                if days < 15 * 365{
                    ratio = (-5.72205e-6 * pow(days, 2) + 0.0443926 * days + 10.9556) / 100
                }else if days < 50 * 365{
                    ratio = 0.99
                }else{
                    ratio = 1
                }
                
            }
            
            if ratio < 0{
                ratio = 0
            }
            
            return ratio
        }
    }
    
    // 寿命增加
    var increasedLongevity: Int{
        get{
            var ratio = 0
            
            if nonSmokedDate.compare(currentDate) == NSComparisonResult.OrderedDescending{
                ratio = 0
            }else{
                let days = self.nonSmokedDays
                // y=-1.5201e-05x^2+0.282878x+0.151503	天
                ratio = Int(-1.5201e-5 * pow(days, 2) + 0.282878 * days + 0.151503)
            }
            
            if ratio < 0{
                ratio = 0
            }
            
            return ratio
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        nonSmokedDate = KMUserActionRecordHelper.getLastSmokedDate(KM_APP_DELEGATE.loginUser!, habits: KM_APP_DELEGATE.userHabits)
        
        setUpTableView()
    }
    
    func setUpTableView(){
        tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 10))
        tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 0, 20))
        
        tableView.registerNib(UINib(nibName: "HealthRecoveryTableViewCell", bundle: nil), forCellReuseIdentifier: "HealthRecovery")
        tableView.registerNib(UINib(nibName: "HealthRecoveryAttributeTableViewCell", bundle: nil), forCellReuseIdentifier: "HealthRecoveryAttribute")
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // must. xib cell的width加载时是固定的320， 不会随屏幕变化而变化
        // 直到他tableView划定隐藏后重新显示时， width才会正常
        tableView.reloadData()
        tableView.hidden = false
    }
    
    // MARK: - goback action
    @IBAction func goback(sender: UIBarButtonItem) {
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        let row = indexPath.row
        if row == 0{
            let rowCell = tableView.dequeueReusableCellWithIdentifier("HealthRecovery") as! HealthRecoveryTableViewCell
            cell = rowCell
            rowCell.ratio = healthRecovery
            rowCell.recoveryDaysLabel.text = "+\(increasedLongevity) 天"
            
            if KM_APP_DELEGATE.userHabits.stillSmoking{
                rowCell.nonSmokingHabitsInfoLabel.text = "您目前没有戒烟计划"
                if nonSmokedDate.compare(currentDate) == NSComparisonResult.OrderedDescending{
                    rowCell.nonSmokingInfoLabel.text = ""
                }else{
                    rowCell.nonSmokingInfoLabel.text = "您从 \(KimreeDateTool.dateStringWithDate(nonSmokedDate)) 起已经没有抽烟记录了"
                }
            }else{
                rowCell.nonSmokingHabitsInfoLabel.text = "计划戒烟开始日期: \(KM_APP_DELEGATE.userHabits.nonSmokeSince!)"
                if nonSmokedDate.compare(currentDate) == NSComparisonResult.OrderedDescending{
                    rowCell.nonSmokingInfoLabel.text = "戒烟计划不起作用, 您仍在吸烟"
                }else{
                    rowCell.nonSmokingInfoLabel.text = "实际戒烟开始日期: \(KimreeDateTool.dateStringWithDate(nonSmokedDate))"
                }
            }
            
            cell.layer.contents = UIImage(named: "cellbackground")?.CGImage
            
        }else{
            var title = ""
            var ratio: Double = 0
            switch row{
            case 1:
                title = "身体内尼古丁含量减少百分比"
                ratio = nicotineContents
            case 2:
                title = "血液含氧量恢复"
                ratio = oxygenContentOfBlood
            case 3:
                title = "心脏活力恢复"
                ratio = heartDisease
            case 4:
                title = "嗅觉和味觉恢复度"
                ratio = smellAndTaste
            case 5:
                title = "肺活量恢复"
                ratio = vitalCapacity
            case 6:
                title = "猝死的几率降低"
                ratio = strokes
            case 7:
                title = "肺癌风险降低"
                ratio = lungCancer
            case 8:
                title = "其它癌症降低"
                ratio = otherCancer
            default:
                title = ""
            }
            
            let rowCell = tableView.dequeueReusableCellWithIdentifier("HealthRecoveryAttribute") as! HealthRecoveryAttributeTableViewCell
            cell = rowCell
            
            rowCell.attributeLabel.text = title
            rowCell.ratio = ratio
        }
        
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 160
        }
        return 60
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
