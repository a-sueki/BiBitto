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
        
        SVProgressHUD.show()
        self.cardDataArray = Files.readCardDocument(fileName: Files.card_file)
        if self.cardDataArray.count != 0 {
            self.cardData = self.cardDataArray.shuffled.first
            self.showWord()
        }else{
            SVProgressHUD.showError(withStatus: "カードがありません")
        }
        
        SVProgressHUD.dismiss()
        
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
        categoryLabel.text = cardData?.category
        authorNameLabel.text = cardData?.author
        noLabel.text = String(format: "%03d", (cardData?.no)!)
        // 縦書き対応(本文)
        view.backgroundColor = UIColor.gray
        let titleLabel: TTTAttributedLabel = TTTAttributedLabel(frame: CGRect(
            x: view.frame.width/20 * 8,
            y: view.frame.height/10 * 5,
            width: view.frame.height/2 ,
            height: view.frame.width/10 * 1))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.tag = 1
        view.addSubview(titleLabel)
        
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.verticalAlignment = .top
        
        // ラベルを90°回転させる
        let angle = Double.pi/2
        titleLabel.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        
        if let title = cardData?.title {
            titleLabel.setText(title) { (mutableAttributedString) -> NSMutableAttributedString! in
                mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTVerticalFormsAttributeName as String as String), value: true, range: NSMakeRange(0,(mutableAttributedString?.length)!))
                return mutableAttributedString
            }
        }
        
        // 縦書き対応(本文)
        let textLabel: TTTAttributedLabel = TTTAttributedLabel(frame: CGRect(
            x: view.frame.width/100 * 7,
            y: view.frame.height/12.9 * 5,
            width: view.frame.height/2,
            height: view.frame.width/2))
        textLabel.backgroundColor = UIColor.clear
        textLabel.tag = 2
        view.addSubview(textLabel)
        
        textLabel.textColor = UIColor.black
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.verticalAlignment = .center
        
        // ラベルを90°回転させる
        textLabel.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        
        if let text = cardData?.text {
            textLabel.setText(text) { (mutableAttributedString) -> NSMutableAttributedString! in
                mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTVerticalFormsAttributeName as String as String), value: true, range: NSMakeRange(0,(mutableAttributedString?.length)!))
                return mutableAttributedString
            }
        }

        print("DEBUG_PRINT: HomeViewController showWord end")
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

        self.cardData = self.cardDataArray.shuffled.first
        self.showWord()

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
