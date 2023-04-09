//
//  EditProfileViewController.swift
//  HongTalk
//
//  Created by Hong jeongmin on 2023/04/09.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class EditProfileViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var stateMessageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageEditButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageEditButton.isHidden = true
        loadUserInformation()
    }
    
    @IBAction func pressedSaveButton(_ sender: Any) {
    }
    
    @IBAction func pressedCancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func pressendImageEditButton(_ sender: Any) {
    }
    
    func loadUserInformation() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            let userModel = UserModel()
            userModel.setValuesForKeys(snapshot.value as! [String: AnyObject])
            
            self.nameTextField.placeholder = userModel.userName
            self.stateMessageTextField.placeholder = userModel.comment
            
            let url = URL(string: userModel.profileImageUrl)
            URLSession.shared.dataTask(with: url!) { data, response, error in
                DispatchQueue.main.async {
                    self.profileImage.image = UIImage(data: data!)
                    self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
                    self.imageEditButton.isHidden = false
                }
            }.resume()
        }
        
    }
}
