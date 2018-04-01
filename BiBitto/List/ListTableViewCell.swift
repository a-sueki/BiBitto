//
//  ListTableViewCell.swift
//  BiBitto
//
//  Created by admin on 2017/10/27.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var baseView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(cardData: CardData) {

        if cardData.category == Category.continents[0] {
            categoryImageView.backgroundColor = UIColor(red: 70/255, green: 72/255, blue: 184/255, alpha: 0.7)
            //baseView.layer.borderColor = UIColor(red: 70/255, green: 72/255, blue: 184/255, alpha: 0.7).cgColor
       }else if cardData.category == Category.continents[1] {
            categoryImageView.backgroundColor = UIColor(red: 229/255, green: 0/255, blue: 30/255, alpha: 0.7)
            //baseView.layer.borderColor = UIColor(red: 229/255, green: 0/255, blue: 30/255, alpha: 0.7).cgColor
        }else if cardData.category == Category.continents[2] {
            categoryImageView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 0.7)
            //baseView.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 0.7).cgColor
        }else if cardData.category == Category.continents[3] {
            categoryImageView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.7)
            //baseView.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.7).cgColor
        }else if cardData.category == Category.continents[4] {
            categoryImageView.backgroundColor = UIColor(red: 255/255, green: 94/255, blue: 25/255, alpha: 0.7)
            //baseView.layer.borderColor = UIColor(red: 255/255, green: 94/255, blue: 25/255, alpha: 0.7).cgColor
        }
        
        //baseView.layer.borderWidth = 1
        noLabel.text =  String(format: "%03d", cardData.no)
        wordLabel.text = cardData.text //cardData.text.replacingOccurrences(of: "\n", with: "")
        
    }
}
