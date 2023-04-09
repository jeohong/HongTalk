//
//  SettingViewController.swift
//  HongTalk
//
//  Created by 홍정민 on 2023/04/07.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SettingViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfile()
    }
    
    @IBAction func pressedEditButton(_ sender: Any) {
        let editProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        editProfileVC.modalPresentationStyle = .fullScreen
        
        self.present(editProfileVC, animated: true)
    }
    
    @IBAction func pressedNotificationSettingButton(_ sender: Any) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    @IBAction func pressedLogoutButton(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        self.dismiss(animated: false)
    }
    
    func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observe(.value) { snapshot in
            let userModel = UserModel()
            userModel.setValuesForKeys(snapshot.value as! [String: AnyObject])
            
            self.nameLabel.text = userModel.userName
            self.commentLabel.text = userModel.comment
            
            // image
            let url = URL(string: userModel.profileImageUrl)
            print(url)
            URLSession.shared.dataTask(with: url!) { data, response, error in
                DispatchQueue.main.async {
                    self.profileImage.image = UIImage(data: data!)
                    self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
                }
            }.resume()
        }
    }
}
    
