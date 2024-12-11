//
//  CardTVC.swift
//  Card Scanner
//
//  Created by Owais on 05/08/24.
//

import UIKit
import CoreData

class CardTVC: UITableViewCell {
    @IBOutlet weak var lblCardholderName: UILabel!
    @IBOutlet weak var lblJobPosition: UILabel!
    @IBOutlet weak var lblMobileNumber: UILabel!
    @IBOutlet weak var lblEmailAddress: UILabel!
    @IBOutlet weak var lblWebsite: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var lblOthers: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 8
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = #colorLiteral(red: 0.2526076734, green: 0.699511826, blue: 0.8931234479, alpha: 1)
        cardImage.clipsToBounds = true
        cardImage.layer.cornerRadius = 8
        cardImage.layer.borderWidth = 1
        cardImage.layer.borderColor = #colorLiteral(red: 0.2526076734, green: 0.699511826, blue: 0.8931234479, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
