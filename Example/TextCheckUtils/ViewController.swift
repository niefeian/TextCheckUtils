//
//  ViewController.swift
//  TextCheckUtils
//
//  Created by 335074307@qq.com on 11/06/2019.
//  Copyright (c) 2019 335074307@qq.com. All rights reserved.
//

import UIKit
import TextCheckUtils
class ViewController: UIViewController {

    @IBOutlet weak var textFied: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let vo = ReplaceModel()
        textFied.tag = 109
        vo.textField = textFied
        vo.maxCount = 5
        vo.tipMaxCount = "字数不可以超过5个字"
        vo.replaceType = .中文
        vo.tipReplace = "只允许输入中文"
        ReplaceUtils.addObserverTextField(vo)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

