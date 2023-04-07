//
//  SettingViewController.swift
//  HongTalk
//
//  Created by 홍정민 on 2023/04/07.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pressedEditButton(_ sender: Any) {
        print("프로필 편집")
    }
    
    @IBAction func pressedNotificationSettingButton(_ sender: Any) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    @IBAction func pressedLogoutButton(_ sender: Any) {
        print("로그아웃")
    }
    
    @IBAction func pressedWithdrawalButton(_ sender: Any) {
        print("회원탈퇴")
    }
    
}
