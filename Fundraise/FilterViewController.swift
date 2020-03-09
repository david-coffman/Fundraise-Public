//
//  FilterViewController.swift
//  Fundraise
//
//  Created by David Coffman on 1/10/20.
//  Copyright © 2020 David Coffman. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    
    var preferenceController = UserPreferenceController.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func setContactedOnly(_ sender: UIButton) {
        preferenceController.contactDisplayMode = true
        animateButtonSelectAndSave(button: sender)
    }
    @IBAction func setNCOnly(_ sender: UIButton) {
        preferenceController.contactDisplayMode = false
        animateButtonSelectAndSave(button: sender)
    }
    @IBAction func clearContactFilter(_ sender: UIButton) {
        preferenceController.contactDisplayMode = nil
        animateButtonSelectAndSave(button: sender)
    }
    @IBAction func setDonorOnly(_ sender: UIButton) {
        preferenceController.donorDisplayMode = true
        animateButtonSelectAndSave(button: sender)
    }
    @IBAction func setNDOnly(_ sender: UIButton) {
        preferenceController.donorDisplayMode = false
        animateButtonSelectAndSave(button: sender)
    }
    @IBAction func clearDonorFilter(_ sender: UIButton) {
        preferenceController.donorDisplayMode = nil
        animateButtonSelectAndSave(button: sender)
    }
    
    func animateButtonSelectAndSave(button: UIButton) {
        preferenceController.save()
        UIView.animate(withDuration: 0.5, animations: {
            button.backgroundColor = .systemGreen
        }, completion: { (Bool) -> Void in
            UIView.animate(withDuration: 0.5){
                button.backgroundColor = .systemPink
            }
        })
    }
}
