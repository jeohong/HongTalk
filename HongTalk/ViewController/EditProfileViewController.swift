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
    @IBOutlet weak var correctNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageEditButton.isHidden = true
        self.correctNameLabel.isHidden = true
        self.nameTextField.delegate = self
        
        loadUserInformation()
    }
    
    @IBAction func pressedSaveButton(_ sender: Any) {
        guard let uid = self.uid else { return }
        // 이미지 수정
        
        // 유저 이름 수정
        if self.nameTextField.text != "" {
            if (correctNameLabel.isHidden) {
                let dic = ["userName":nameTextField.text!]
                Database.database().reference().child("users").child(uid).updateChildValues(dic)
            }
        }
        
        // 상태메세지 수정
        if self.stateMessageTextField.text != "" {
            let dic = ["comment":stateMessageTextField.text!]
            Database.database().reference().child("users").child(uid).updateChildValues(dic)
        }
    }
    
    @IBAction func pressedCancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func pressendImageEditButton(_ sender: Any) {
    }
    
    func loadUserInformation() {
        guard let uid = self.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            let userModel = UserModel()
            userModel.setValuesForKeys(snapshot.value as! [String: AnyObject])
            
            self.nameTextField.placeholder = userModel.userName
            self.stateMessageTextField.text = userModel.comment
            
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

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.correctNameLabel.isHidden = (RegExOfTextfield.sharedInstance().checkName(textField.text!) || (textField.text == ""))
        self.editButton.isEnabled = self.correctNameLabel.isHidden
        
        if !self.editButton.isEnabled {
            self.editButton.backgroundColor = .gray
        } else {
            self.editButton.backgroundColor = .blue
        }
    }
}
