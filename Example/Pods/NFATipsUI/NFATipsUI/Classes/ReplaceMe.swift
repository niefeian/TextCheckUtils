import NFAToolkit
public extension NSObject{
    
 func noCount(_ str : String? , tip : String, delayTime : CGFloat = 4) -> Bool{
       if str?.count ?? 0 == 0 {
           if tip == "生日" {
               showTipsWindow("出生日期" + "不能为空", delayTime: delayTime)
           }else{
                showTipsWindow(tip, delayTime: delayTime)
           }
           return true
       }
       return false
   }

   func showTipsWindow(_ tips : String = "系统错误", delayTime : CGFloat = 4){

       let tipsView =  AppWindow().viewWithTag(999) ?? UIView()
       if tipsView.tag == 999 &&  tipsView.alpha != 0 {
           return
       }
       tipsView.backgroundColor = colorConversion(colorValue: "000000", alpha: 0.8)
       tipsView.tag = 999
       AppWindow().addSubview(tipsView)
       tipsView.alpha = 0

       let label = tipsView.viewWithTag(888) as? UILabel ?? UILabel()
       if label.tag != 888 {
           label.textAlignment  = .center
            label.textColor = UIColor.white
          label.font = UIFont.systemFont(ofSize: 14)
          label.numberOfLines = 0
          tipsView.addSubview(label)
       }
      
       label.text = tips
       label.sizeToFit()
       tipsView.frame = CGRect(x: 0, y: 0, width: label.width + 20, height: label.height + 20)
       label.frame = CGRect(x: 10, y: 10, width: label.width, height: label.height)
       tipsView.center = AppWindow().center
      
       Tools.setCornerRadius(tipsView, rate: 5)

       UIView.animate(withDuration: 0.3, animations: {
           tipsView.alpha = 1
       }) { (finished) in
           UIView.animate(withDuration: 0.3, delay: TimeInterval(delayTime), options: UIView.AnimationOptions.curveEaseOut, animations: {
               tipsView.alpha = 0
           }, completion: { (b) in
               tipsView.removeFromSuperview()
           })
       }
   }
}
