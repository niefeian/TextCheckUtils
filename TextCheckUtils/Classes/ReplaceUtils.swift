//
//  ReplaceUtils.swift
//  FBSnapshotTestCase
//
//  Created by 聂飞安 on 2019/11/7.
//

import UIKit
import NFATipsUI
import NFAToolkit
public enum ReplaceType : String{
    case 中文 = "[^\\u4E00-\\u9FA5]",英文 = "[^A-Za-z]",数字 = "[^0-9]",中文或英文="[^A-Za-z\\u4E00-\\u9FA5]",英文或数字="[^A-Za-z0-9]",不校验=""
}

/*
 ReplaceModel 中
 tag 为唯一 不可有重复 若有重复，发出提示
 */


@objc(ReplaceModel)
public class ReplaceModel : NSObject{
    
    public var replaceType : ReplaceType!
    public weak var textField : UITextField!
    @objc public var tag : String = ""
    @objc public var maxCount = 10
    @objc public var minCount = 0
    @objc public  var tipMaxCount = ""
    @objc public  var tipMinCount = ""
    @objc public  var tipReplace = ""
    
    public class func cReplaceModel(_ textField :  UITextField ,replaceType : ReplaceType , tag : String , maxCount : Int = 10 , minCount : Int = 0 , tipReplace : String , tipMaxCount : String = "字数超出限制" , tipMinCount : String = "") -> ReplaceModel{
        let vo = ReplaceModel()
        textField.textFieldTag = tag
        vo.tag = tag
        vo.textField = textField
        vo.replaceType = replaceType
        vo.maxCount = maxCount
        vo.minCount = minCount
        vo.tipReplace = tipReplace
        vo.tipMaxCount = tipMaxCount
        vo.tipMinCount = tipMinCount
        return vo
    }
}

@objc(ReplaceUtils)
open class ReplaceUtils: NSObject {
    private static var instance : ReplaceUtils? = ReplaceUtils()
     
    open class func sharedInstance() -> ReplaceUtils {
           return instance!
    }
    
    private var replaceModels = [String : ReplaceModel]()
    
   
    
    public class func addObserverTextField(_ textVo : ReplaceModel){
        self.sharedInstance().addObserverTextField(textVo)
    }
    
   public  func addObserverTextField(_ textVo : ReplaceModel){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.textFieldChanged),
                                               name:UITextField.textDidChangeNotification,
                                               object: textVo.textField)
    
        #if DEBUG
//        print(textVo.textField.placeholder)
//        print(textVo.tag)
//        print(textVo.textField.textFieldTag)
//        if replaceModels.keys.contains(textVo.tag)
//        {
//            showTipsWindow("当前标记 : \(textVo.tag) 代码不严谨，可通知一下开发查看原因")
//        }
        #endif
        replaceModels[textVo.tag] = textVo
    
    }
    
    
    public class func removeObserverTextField(_ textField : UITextField){
        self.sharedInstance().removeObserverTextField(textField)
    }
    
   public func removeObserverTextField(_ textField : UITextField) {
        removeObserverTextField(textField.textFieldTag ?? "")
    }
    
    public class func removeObserverTextField(_ tag : String){
        self.sharedInstance().removeObserverTextField(tag)
    }
    
    public func removeObserverTextField(_ tag : String) {
        if let vo = replaceModels[tag] {
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: vo.textField)
            replaceModels.removeValue(forKey: tag)
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
        if let textField = obj.object as? UITextField  {
           
        guard let _: UITextRange = textField.markedTextRange else{
                       //当前光标的位置（后面会对其做修改）
                var textFieldVo : ReplaceModel!
                for key in replaceModels.keys{
                    if replaceModels[key]?.textField?.textFieldTag == textField.textFieldTag {
                        textFieldVo = replaceModels[key]
                    }
                }
                if textFieldVo == nil {
                    return
                }
            
               let cursorPostion = textField.offset(from: textField.endOfDocument,
               to: textField.selectedTextRange!.end)
          
                var str =  (textField.text ?? "").pregReplace(pattern: textFieldVo.replaceType!.rawValue, with: "")
                if str.count < textField.text?.count ?? 0 {
                    showTipsWindow(textFieldVo.tipReplace, delayTime: 2)
                }
                if textFieldVo.maxCount > 0 && str.count > textFieldVo.maxCount {
                    str = String(str.prefix(textFieldVo.maxCount))
                     showTipsWindow(textFieldVo.tipMaxCount, delayTime: 2)
                }else if str.count < textFieldVo.minCount {
                     showTipsWindow(textFieldVo.tipMinCount, delayTime: 2)
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
    }
}
