//
//  SecondViewController.swift
//  BiBitto
//
//  Created by admin on 2017/10/22.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import TTTAttributedLabel
import Presentr

class HomeViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var noLabel: UILabel!
    
    lazy var signUpViewController: SignUpViewController = {
        let signUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController")
        return signUpViewController as! SignUpViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: HomeViewController viewDidLoad start")

        // ヘッダ
        categoryLabel.text = "MIND"
        authorNameLabel.text = "SHOIN YOSHIDA"
        noLabel.text = "034"
        
        // 縦書き対応(本文)
        view.backgroundColor = UIColor.gray
        let titleLabel: TTTAttributedLabel = TTTAttributedLabel(frame: CGRect(
            x: view.frame.width/20 * 8,
            y: view.frame.height/10 * 5,
            width: view.frame.height/2 ,
            height: view.frame.width/10 * 1))
        titleLabel.backgroundColor = UIColor.white
        view.addSubview(titleLabel)
        
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.verticalAlignment = .top
        
        // ラベルを90°回転させる
        let angle = Double.pi/2
        titleLabel.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        
        //let title = "行動力を生む心がけ"
        let title = "迷わない生き方"
        titleLabel.setText(title) { (mutableAttributedString) -> NSMutableAttributedString! in
            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTVerticalFormsAttributeName as String as String), value: true, range: NSMakeRange(0,(mutableAttributedString?.length)!))
            return mutableAttributedString
        }
        
        // 縦書き対応(本文)
        let textLabel: TTTAttributedLabel = TTTAttributedLabel(frame: CGRect(
            x: view.frame.width/100 * 7,
            y: view.frame.height/10 * 5,
            width: view.frame.height/2,
            height: view.frame.width/2))
        textLabel.backgroundColor = UIColor.white
        view.addSubview(textLabel)
        
        textLabel.textColor = UIColor.black
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.verticalAlignment = .center
        
        // ラベルを90°回転させる
        textLabel.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        
        //let text = "日頃から威張っている人ほど、\nいざっていうときになると黙りこんでしまいます。\n\n日頃から「やる」って言いふらしている人ほど、\nいざっていうときになるとなにもやらないものです。\n\n未知なることを知ろうとすること。本質を見抜こうとすること。その意識が一番、行動につながります。"
        //let text = "日頃から威張っている人ほど、\nいざっていうときになると黙りこんでしまいます。"
        let text = "最もつまらないと思うのは\n人との約束を破る人ではなく、\n自分との約束を破る人です。"
        textLabel.setText(text) { (mutableAttributedString) -> NSMutableAttributedString! in
            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTVerticalFormsAttributeName as String as String), value: true, range: NSMakeRange(0,(mutableAttributedString?.length)!))
            return mutableAttributedString
        }
        
        print("DEBUG_PRINT: HomeViewController viewDidLoad end")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("DEBUG_PRINT: HomeViewController viewDidAppear start")

        // 初回起動時のみ
        if UserDefaults.standard.bool(forKey: "firstLaunch") {
            UserDefaults.standard.set(false, forKey: "firstLaunch")
            signUp()
        }

        print("DEBUG_PRINT: HomeViewController viewDidAppear end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func signUp() {
        print("DEBUG_PRINT: HomeViewController signUp start")

        PresentrAlert.presenter.presentationType = .popup
        PresentrAlert.presenter.transitionType = nil
        PresentrAlert.presenter.dismissTransitionType = nil
        PresentrAlert.presenter.keyboardTranslationType = .compress
        PresentrAlert.presenter.dismissOnSwipe = false
        customPresentViewController(PresentrAlert.presenter, viewController: signUpViewController, animated: true, completion: nil)

        print("DEBUG_PRINT: HomeViewController signUp end")
    }
}

