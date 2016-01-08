//
//  TodayActionViewController.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/10/28.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

protocol RecordLocationInfoDelegate: NSObjectProtocol{
    func recordLocationInfo(location: CLLocation)
}

class TodayActionViewController: TodayBasicViewController {
    
    @IBOutlet weak var outCircleView: KMTodayCircleView!
    @IBOutlet weak var innerCircleView: KMTodayCircleView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewLeftPadding: NSLayoutConstraint!
    @IBOutlet weak var contentViewRightPadding: NSLayoutConstraint!
    
    
    @IBOutlet weak var smokedLimitLabel: UILabel!
    @IBOutlet weak var saveMoneyLabel: UILabel!
    // 记录当前吸了多少支烟
    @IBOutlet weak var haveSmokedLabel: UILabel!
    
    private var scrollLabel: KMScrollLabel?
    
    private var todayActionRecord = KM_APP_DELEGATE.todayActionRecord
    
    // 记录进入界面时的吸烟数， 方便最后判断吸烟数是否发生变化
    private var copySmokedNum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.setBackgroundImage(imageWithColor(KM_COLOR_BLACK_ALPHA, size: CGSizeMake(KM_FRAME_WIDTH, 64)), forBarMetrics: UIBarMetrics.Default)
        
        buildView()
        rotateAnimation()
        
        smokedNumChangedToValue(todayActionRecord.smokedNum)
        
        copySmokedNum = todayActionRecord.smokedNum
    }
    
    func buildView(){
        let distance: CGFloat = 10
        let width: CGFloat = 10
        let maxR: CGFloat = KM_FRAME_WIDTH / 2.0
        let outR: CGFloat = maxR - 30
        let innerR: CGFloat = outR - width - distance
        let padding = (maxR - innerR) + width / 2.0 + distance
        
        // contentView需要根据 circleView 里面的数据进行处理
        contentViewLeftPadding.constant = padding
        contentViewRightPadding.constant = padding
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = KM_FRAME_WIDTH / 2.0 - padding
        
        outCircleView.circleEndAngleRatio = 0
        outCircleView.circleWidth = width
        outCircleView.circleR = outR
        outCircleView.circleBackgroundColor = UIColor.whiteColor()
        outCircleView.circleChnagedColor = UIColor.yellowColor()
        
        innerCircleView.circleEndAngleRatio = 1
        innerCircleView.circleWidth = width
        innerCircleView.circleR = innerR
        innerCircleView.circleBackgroundColor = UIColor.grayColor()
        innerCircleView.circleChnagedColor = UIColor.greenColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - goback action
    @IBAction func goback(sender: UIBarButtonItem) {
        SVProgressHUD.showInfoWithStatus("数据同步中,请稍等!")
        
        let smokedNum = self.todayActionRecord.smokedNum
        if smokedNum > self.copySmokedNum{
            KM_APP_DELEGATE.recordLocation(self.todayActionRecord)
        }
        
        KMUserActionRecordHelper.updateUserActionRecord(self.todayActionRecord)
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: {
            SVProgressHUD.dismiss()
        })
    }
    
    // MARK: - 旋转动画
    func rotateAnimation(){
        
        UIView.animateWithDuration(0.1, animations: { [weak self]() -> Void in
            if self != nil{
                let outRotate = CGAffineTransformRotate(self!.outCircleView.transform, 0.2)
                self!.outCircleView.transform = outRotate
                
                let innerRotate = CGAffineTransformRotate(self!.innerCircleView.transform, -0.15)
                self?.innerCircleView.transform = innerRotate
            }
            
            }) { [weak self](finished: Bool) -> Void in
                self?.rotateAnimation()
        }
    }
    
    // MARK: - 修改已经吸了多少支烟
    @IBAction func minusTapGesture(sender: UITapGestureRecognizer) {
        
        let smokedNum = ((haveSmokedLabel.text ?? "0") as NSString).integerValue
        
        if smokedNum > 0{
            smokedNumChangedToValue(smokedNum - 1)
        }
    }
    
    @IBAction func plusTapGesture(sender: UITapGestureRecognizer) {
        
        let smokedNum = ((haveSmokedLabel.text ?? "0") as NSString).integerValue
        let totalNum = todayActionRecord.habitsNum
        
        if smokedNum == totalNum{
            let alert = UIAlertView(title: "警告", message: "您今天的吸烟数已超过设定的限制数量, 您确定今天还要继续吸烟?", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            alert.showAlertViewWithCompleteBlock({ [weak self](buttonIndex: Int) -> Void in
                if buttonIndex == 1{
                    self?.smokedNumChangedToValue(smokedNum + 1)
                }
            })
        }else{
            smokedNumChangedToValue(smokedNum + 1)
        }
    }
    
    func smokedNumChangedToValue(num: Int){
        todayActionRecord.smokedNum = num
        
        let totalNum = todayActionRecord.habitsNum
        let price = todayActionRecord.priceForOnePackage
        let unitPrice = NSString(format: "%0.2f", price / Float(20)).floatValue
        
        if num > totalNum{
            if scrollLabel == nil{
                scrollLabel = KMScrollLabel(frame: CGRectMake(20, 74, KM_FRAME_WIDTH - 40, 40))
                scrollLabel?.textLabel.textColor = UIColor.redColor()
                self.view.addSubview(scrollLabel!)
            }
            scrollLabel?.textLabel.text = "您今天的吸烟数已超过设定的限制数量!!!"
            scrollLabel?.hidden = false
            scrollLabel?.startScroll()
        }else{
            scrollLabel?.hidden = true
            scrollLabel?.stopScroll()
        }
        
        haveSmokedLabel.text = "\(num)"
        
        let leftNum = totalNum - num
        let smokedLimitText = "还可以吸 \(leftNum) 支"
        let smokedLimitAttr = NSMutableAttributedString(string: smokedLimitText)
        smokedLimitAttr.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: (smokedLimitText as NSString).rangeOfString("\(leftNum)"))
        smokedLimitLabel.attributedText = smokedLimitAttr
        
        let saveMoney = unitPrice * Float(totalNum - num)
        let saveMoneyText = "节省了 \(saveMoney) 元"
        let saveMoneyAttr = NSMutableAttributedString(string: saveMoneyText)
        saveMoneyAttr.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: (saveMoneyText as NSString).rangeOfString("\(saveMoney)"))
        saveMoneyLabel.attributedText = saveMoneyAttr
        
        var smokedRatio: CGFloat = 0
        var saveRatio: CGFloat = 1
        
        if totalNum == 0{
            smokedRatio = 1
            saveRatio = 0
            
            if num > 0{
                outCircleView.circleBackgroundColor = UIColor.yellowColor()
                outCircleView.circleChnagedColor = UIColor.redColor()
                
                innerCircleView.circleBackgroundColor = UIColor.redColor()
                innerCircleView.circleChnagedColor = UIColor.grayColor()
            }else{
                outCircleView.circleBackgroundColor = UIColor.whiteColor()
                outCircleView.circleChnagedColor = UIColor.yellowColor()
                
                innerCircleView.circleBackgroundColor = UIColor.grayColor()
                innerCircleView.circleChnagedColor = UIColor.greenColor()
            }
            
        }else{
            smokedRatio = CGFloat(num) / CGFloat(totalNum)
            saveRatio = CGFloat(totalNum - num) / CGFloat(totalNum)
            
            if smokedRatio > 1{
                if smokedRatio >= 2{
                    smokedRatio = 1
                }else{
                    smokedRatio %= 1
                }
                
                outCircleView.circleBackgroundColor = UIColor.yellowColor()
                outCircleView.circleChnagedColor = UIColor.redColor()
            }else{
                outCircleView.circleBackgroundColor = UIColor.whiteColor()
                outCircleView.circleChnagedColor = UIColor.yellowColor()
            }
            
            if saveRatio < 0{
                if saveRatio < -1{
                    saveRatio = 0
                }else{
                    saveRatio %= 1
                }
                
                innerCircleView.circleBackgroundColor = UIColor.redColor()
                innerCircleView.circleChnagedColor = UIColor.grayColor()
            }else{
                innerCircleView.circleBackgroundColor = UIColor.grayColor()
                innerCircleView.circleChnagedColor = UIColor.greenColor()
            }
        }
        
        
        outCircleView.circleEndAngleRatio = smokedRatio
        innerCircleView.circleEndAngleRatio = saveRatio
        
        outCircleView.setNeedsDisplay()
        innerCircleView.setNeedsDisplay()
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
