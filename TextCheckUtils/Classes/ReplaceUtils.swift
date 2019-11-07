//
//  ReplaceUtils.swift
//  FBSnapshotTestCase
//
//  Created by 聂飞安 on 2019/11/7.
//

import UIKit
import NFATipsUI
public enum ReplaceType : String{
    case 中文 = "[^\\u4E00-\\u9FA5]",英文 = "[^A-Za-z]",数字 = "[^0-9]",中文或英文="[^A-Za-z\\u4E00-\\u9FA5]",英文或数字="[^A-Za-z0-9]"
}
@objc(ReplaceModel)
public class ReplaceModel : NSObject{
    public var replaceType : ReplaceType!
    public weak var textField : UITextField!
    @objc public var tag = 0
    @objc public var maxCount = 10
    @objc public var minCount = 0
    @objc public  var tipMaxCount = ""
    @objc public  var tipMinCount = ""
    @objc public  var tipReplace = ""
}

@objc(ReplaceUtils)
open class ReplaceUtils: NSObject {
    private static var instance : ReplaceUtils? = ReplaceUtils()
     
    open class func sharedInstance() -> ReplaceUtils {
           return instance!
    }
    
    private var replaceModels = [ReplaceModel]()
    
    public func pregReplace(string : String , pattern: String, with: String,
                     options: NSRegularExpression.Options = [])->String{
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: string, options: [],
                                                    range: NSMakeRange(0, string.count),
                                                    withTemplate: with)
    }
    
    public class func addObserverTextField(_ textVo : ReplaceModel){
        self.sharedInstance().addObserverTextField(textVo)
    }
    
   public  func addObserverTextField(_ textVo : ReplaceModel){
        NotificationCenter.default.addObserver(self,
                                                           selector: #selector(self.textFieldChanged),
                                                           name:UITextField.textDidChangeNotification,
                                                           object: textVo.textField)
        replaceModels.append(textVo)
    }
    public class func removeObserverTextField(_ textField : UITextField){
           self.sharedInstance().removeObserverTextField(textField)
    }
    
   public func removeObserverTextField(_ textField : UITextField) {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: textField)
        for (index,textFieldVO) in replaceModels.enumerated(){
            if textFieldVO.textField?.tag == textField.tag {
                replaceModels.remove(at: index)
                return
            }
        }
    }
    public class func removeObserverTextField(_ tag : Int){
              self.sharedInstance().removeObserverTextField(tag)
       }
    
    public func removeObserverTextField(_ tag : Int) {
        for (index,textFieldVO) in replaceModels.enumerated(){
            if textFieldVO.tag == tag {
                NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: textFieldVO.textField)
                replaceModels.remove(at: index)
                return
            }
        }
    }
    
    public class func removeAll(){
        self.sharedInstance().removeAll()
    }
    
    public func  removeAll(){
        NotificationCenter.default.removeObserver(self)
        replaceModels.removeAll()
    }
    
    @objc func textFieldChanged(_ obj: Notification){
        if let textField = obj.object as? UITextField {
        guard let _: UITextRange = textField.markedTextRange else{
                       //当前光标的位置（后面会对其做修改）
               let cursorPostion = textField.offset(from: textField.endOfDocument,
               to: textField.selectedTextRange!.end)
          
            for (_,textFieldVO) in replaceModels.enumerated(){
                       if textFieldVO.textField.tag == textField.tag {
                       var str = pregReplace(string: textField.text ?? "", pattern: textFieldVO.replaceType!.rawValue, with: "")
                        if str.count < textField.text?.count ?? 0 {
                            showTipsWindow(textFieldVO.tipReplace, delayTime: 2)
                        }
                        if textFieldVO.maxCount > 0 && str.count > textFieldVO.maxCount {
                            str = String(str.prefix(textFieldVO.maxCount))
                             showTipsWindow(textFieldVO.tipMaxCount, delayTime: 2)
                        }else if str.count < textFieldVO.minCount {
                             showTipsWindow(textFieldVO.tipMinCount, delayTime: 2)
                        }
                        textField.text = str
                        //让光标停留在正确位置
                         let targetPostion = textField.position(from: textField.endOfDocument,
                         offset: cursorPostion)!
                         textField.selectedTextRange = textField.textRange(from: targetPostion,
                         to: targetPostion)
                        
                        return
                       }
                }
            return
           }
       }
    }
}
