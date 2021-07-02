//
//  TagTableViewCell.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 23.02.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import UIKit


class TagTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    var parent: Portfolio!
    var index: Int!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    @IBAction func editingDidChanged(_ sender: Any) {
        if index < parent.tags.count {
            parent.tags[index!] = textField.text ?? ""
        }
    }
    @IBOutlet weak var addNewItemButton: UIButton!
    @IBAction func addnewItem(_ sender: Any) {
        if index >= 1 {
            if parent.tags[index-1] != "" {
                parent.tags.append("")
                DispatchQueue.main.async {
                    self.parent.tableWithTags.reloadData()
                }
            }
        }
        else if index == 0 {
            parent.tags.insert("", at: 0)
            DispatchQueue.main.async {
                self.parent.tableWithTags.reloadData()
            }
        }

    }
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    @IBAction func deleteAction(_ sender: Any) {
        parent.tags.remove(at: index!)
        DispatchQueue.main.async {
            self.parent.tableWithTags.reloadData()
        }
    }
}
