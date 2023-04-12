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
    @IBOutlet weak var defaultImageButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    let uid = Auth.auth().currentUser?.uid
    var userModel = UserModel()
    var isDefaultImage = false
    var isImageChange = false
    var setupImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageEditButton.isHidden = true
        self.correctNameLabel.isHidden = true
        self.defaultImageButton.isHidden = true
        
        self.nameTextField.delegate = self
        
        loadUserInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func pressedSaveButton(_ sender: Any) {
        guard let uid = self.uid else { return }
        
        self.cancelButton.isHidden = true
        self.editButton.isEnabled = false
        self.editButton.backgroundColor = .gray
        self.editButton.setTitle("변경사항 저장중...", for: .normal)
        
        // 이미지 수정
        var imageRef = Storage.storage().reference().child("userImages")
        // 기본이미지로 설정했을 경우
        if isDefaultImage {
            let deleteRef = Storage.storage().reference().child("userImages").child(uid)
            deleteRef.delete { err in
                if err == nil {
                    print("프로필 이미지 삭제")
                } else {
                    print("삭제 실패")
                }
            }
            imageRef = imageRef.child("basicProfile.png")
            setupDatabase(imageRef, uid)
        } else {
            if isImageChange {
                let image = self.profileImage.image!.jpegData(compressionQuality: 0.1)
                imageRef = imageRef.child(uid)
                
                imageRef.putData(image!) { data, err in
                    self.setupDatabase(imageRef, uid)
                }
            }
        }
        
        // 유저 이름 수정
        if self.nameTextField.text != "" {
            if (correctNameLabel.isHidden) {
                let dic = ["userName":nameTextField.text!]
                Database.database().reference().child("users").child(uid).updateChildValues(dic)
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.nameTextField.text!
                changeRequest?.commitChanges(completion: { err in
                    if err != nil {
                        print(err?.localizedDescription);
                    }
                })
            }
        }
        
        // 상태메세지 수정
        if self.stateMessageTextField.text != "" {
            let dic = ["comment":stateMessageTextField.text!]
            Database.database().reference().child("users").child(uid).updateChildValues(dic)
        }
        
        // 이미지를 변경하지 않은 경우 popupViewController
        if !isImageChange {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setupDatabase(_ imageRef: StorageReference, _ uid: String) {
        imageRef.downloadURL { url, err in
            Database.database().reference().child("users").child(uid).child("profileImageUrl").setValue(url?.absoluteString) { err, ref in
                if (err == nil) {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    // alert 로 경고 띄워주기 ( 업데이트 실패 )
                    print("실패")
                }
            }
        }
    }
    
    @IBAction func pressedCancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pressendImageEditButton(_ sender: Any) {
        isImageChange = true
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func pressedDefaultImage(_ sender: Any) {
        self.profileImage.image = UIImage(named: "basicProfile")
        isDefaultImage = true
        isImageChange = true
    }
    
    func loadUserInformation() {
        guard let uid = self.uid else { return }
        
        Database.database().reference().child("users").child(uid).observe(.value) { snapshot in
            self.userModel.setValuesForKeys(snapshot.value as! [String: AnyObject])
            
            self.nameTextField.placeholder = self.userModel.userName
            self.stateMessageTextField.text = self.userModel.comment
            
            let url = URL(string: self.userModel.profileImageUrl)
            URLSession.shared.dataTask(with: url!) { data, response, error in
                DispatchQueue.main.async {
                    self.profileImage.image = UIImage(data: data!)
                    self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
                    self.imageEditButton.isHidden = false
                    self.defaultImageButton.isHidden = false
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

extension EditProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        profileImage.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        isDefaultImage = false
        setupImage = true
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if !setupImage { isImageChange = false }
        dismiss(animated: true)
    }
}

// Navigation Delegate
extension EditProfileViewController: UINavigationControllerDelegate {
    
}
