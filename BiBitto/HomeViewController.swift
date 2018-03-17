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
import SVProgressHUD
import Presentr

class HomeViewController: UIViewController {
    
    var cardDataArray: [CardData] = []
    var cardData: CardData?
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    lazy var signUpViewController: SignUpViewController = {
        let signUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController")
        return signUpViewController as! SignUpViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: HomeViewController viewDidLoad start")
        
        print("DEBUG_PRINT: HomeViewController viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: HomeViewController viewWillAppear start")
        
        self.cardDataArray = Files.readCardDocument(fileName: Files.card_file)
        if self.cardDataArray.count != 0 {
            SVProgressHUD.show()
            self.nextButton.isHidden = false
            self.cardData = self.cardDataArray.shuffled.first
            self.showWord()
            SVProgressHUD.dismiss()
        }else{
            self.nextButton.isHidden = true
            self.noLabel.text = String(format: "%03d",0)
            SVProgressHUD.showInfo(withStatus: "カードがありません")
        }
        
        
        print("DEBUG_PRINT: HomeViewController viewWillAppear end")
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("DEBUG_PRINT: HomeViewController viewDidAppear start")

        // 初回起動時のみ
        if UserDefaults.standard.bool(forKey: "firstLaunch") {
            UserDefaults.standard.set(false, forKey: "firstLaunch")
            signUp()
        }
        // アカウントありで、かつ、ログインしてない場合
        if  UserDefaults.standard.string(forKey: DefaultString.Uid) != nil ,Auth.auth().currentUser == nil{
            self.showAlert(title: "警告", message: "現在、ログインしていません") {
                // OKが選択された場合の処理
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
                self.navigationController?.present(nextViewController, animated: true, completion: nil)
            }
        }
        
        print("DEBUG_PRINT: HomeViewController viewDidAppear end")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: HomeViewController viewWillDisappear start")
        
        for subview in self.view.subviews {
            if subview.tag == 1 || subview.tag == 2 {
                subview.removeFromSuperview()
            }
        }
            
        print("DEBUG_PRINT: HomeViewController viewWillDisappear end")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func removeSubviews(parentView: UIView){
        print("DEBUG_PRINT: HomeViewController removeAllSubviews start")

        let subviews = parentView.subviews
        for subview in subviews {
            print(subview)
            if subview.tag == 1 || subview.tag == 2 {
                subview.removeFromSuperview()
            }
        }
        print("DEBUG_PRINT: HomeViewController removeAllSubviews end")
    }
    
    func showWord(){
        print("DEBUG_PRINT: HomeViewController showWord start")

        // 古いsubviewを削除
        removeSubviews(parentView: self.view)

        // ヘッダ
        categoryLabel.text = self.cardData?.category
        authorNameLabel.text = self.cardData?.author
        noLabel.text = String(format: "%03d", (self.cardData?.no)!)
        view.backgroundColor = UIColor.gray

        // 日本語判定
        var hasJp = false
        if let textString = self.cardData?.text, textString.hasHiragana || textString.hasKatakana || textString.hasKanji  {
            print(textString)
            hasJp = true
        }

        var textLabel :UILabel
        if hasJp {
            // 縦書き対応
            textLabel = TTTAttributedLabel(frame: CGRect(
                x: -10,
                y: view.frame.height/3,
                width: view.frame.height/5 * 3,
                height: view.frame.width/10 * 8))
            print(view.frame.height)    //736.0
            print(view.frame.width)     //414.0
            // ラベルを90°回転させる
            rotateAngle(label: textLabel as! TTTAttributedLabel, data: self.cardData?.text)
            (textLabel as! TTTAttributedLabel).verticalAlignment = .center

            //textLabel.backgroundColor = UIColor.yellow

        }else{
            // 横書き
            textLabel = UILabel(frame: CGRect(
                x: view.frame.width/10,
                y: view.frame.height/4,
                width: view.frame.width/10 * 8 ,
                height: view.frame.height/5  * 3))
            textLabel.text = self.cardData?.text
            textLabel.textAlignment = .center
            //textLabel.backgroundColor = UIColor.red

        }
        
        // デザイン
        textLabel.backgroundColor = UIColor.clear
        textLabel.tag = 2
        view.addSubview(textLabel)
        textLabel.textColor = UIColor.black
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 16)
        
        print("DEBUG_PRINT: HomeViewController showWord end")
    }
    
    func rotateAngle(label: TTTAttributedLabel, data: String?) {
        print("DEBUG_PRINT: HomeViewController rotateAngle start")

        let angle = Double.pi/2
        label.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        
        if let text = data {
            label.setText(text) { (mutableAttributedString) -> NSMutableAttributedString! in
                mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTVerticalFormsAttributeName as String as String), value: true, range: NSMakeRange(0,(mutableAttributedString?.length)!))
                return mutableAttributedString
            }
        }
        print("DEBUG_PRINT: HomeViewController rotateAngle end")
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
    
    @IBAction func handleNextButton(_ sender: Any) {
        print("DEBUG_PRINT: HomeViewController handleNextButton start")

        if self.cardDataArray.count != 0 {
            self.cardData = self.cardDataArray.shuffled.first
            self.showWord()
        }else{
            SVProgressHUD.showError(withStatus: "カードがありません")
        }

        print("DEBUG_PRINT: HomeViewController handleNextButton end")
    }
    
    @IBAction func handleShearButton(_ sender: Any) {
        print("DEBUG_PRINT: HomeViewController handleShearButton start")
        
        // 共有する項目
        let shareText = ShareString.text + (cardData?.text)!
        let shareWebsite = ShareString.website
        let shareItems = [shareText, shareWebsite] as [Any]
        
        // LINEで送るボタンを追加
        let line = UIActivity()
        let avc = UIActivityViewController(activityItems: shareItems, applicationActivities: [line])
        
        present(avc, animated: true, completion: nil)
        
        print("DEBUG_PRINT: HomeViewController handleShearButton end")
    }

    // OK or CancelToast
    func showAlert(title: String, message: String, callback: @escaping () -> Void) {
        print("DEBUG_PRINT: HomeViewController showAlert start")

        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) -> Void in
            callback()
        })
//        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: {
//            (action: UIAlertAction!) -> Void in
//        })
//        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)

        print("DEBUG_PRINT: HomeViewController showAlert end")
    }
    
}
extension Array {
    
    mutating func shuffle() {
        for i in 0..<self.count {
            let j = Int(arc4random_uniform(UInt32(self.indices.last!)))
            if i != j {
                self.swapAt(i, j)
            }
        }
    }
    
    var shuffled: Array {
        var copied = Array<Element>(self)
        copied.shuffle()
        return copied
    }
}
