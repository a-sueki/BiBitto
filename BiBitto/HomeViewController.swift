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
    
    var cardDataArray: [CardData] = []
    var cardData: CardData?
    
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
        
        cardDataArray.removeAll()
        
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child(Paths.CardPath).child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                print("DEBUG_PRINT: HomeViewController .observeSingleEventイベントが発生しました。")
                if let _ = snapshot.value as? NSDictionary {
                    for childSnap in snapshot.children {
                        let cardData = CardData(snapshot: childSnap as! DataSnapshot, id: uid)
                        self.cardDataArray.append(cardData)
                    }
                }
                // tableViewを再表示する
                DispatchQueue.main.async {
                    print("DEBUG_PRINT: ListViewController [DispatchQueue.main.async]")
                    self.cardData = self.cardDataArray.shuffled.first
                    self.showWord()
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
       
        print("DEBUG_PRINT: HomeViewController viewDidLoad end")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: HomeViewController viewWillAppear start")
        
        self.cardData = self.cardDataArray.shuffled.first
        showWord()
        
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
    
    func showWord(){
        print("DEBUG_PRINT: HomeViewController showWord start")

        // ヘッダ
        categoryLabel.text = cardData?.category
        authorNameLabel.text = cardData?.author
        noLabel.text = cardData?.no
        
        // 縦書き対応(本文)
        view.backgroundColor = UIColor.gray
        let titleLabel: TTTAttributedLabel = TTTAttributedLabel(frame: CGRect(
            x: view.frame.width/20 * 8,
            y: view.frame.height/10 * 5,
            width: view.frame.height/2 ,
            height: view.frame.width/10 * 1))
        titleLabel.backgroundColor = UIColor.white
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
            y: view.frame.height/10 * 5,
            width: view.frame.height/2,
            height: view.frame.width/2))
        textLabel.backgroundColor = UIColor.white
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
