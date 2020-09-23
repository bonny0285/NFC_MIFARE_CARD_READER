//
//  UidCardCell.swift
//  NFC_Card_Reader
//
//  Created by Massimiliano Bonafede on 22/09/2020.
//

import UIKit

class UidCardCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var uidCard: UILabel!
    @IBOutlet weak var cardName: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.bounds = self.contentView.bounds
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupCellWith(_ uid: String) {
        self.cardName.text = uid
    }
    
}
