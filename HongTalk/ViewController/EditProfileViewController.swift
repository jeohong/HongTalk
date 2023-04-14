//
//  EditProfileViewController.swift
//  HongTalk
//
//  Created by Hong jeongmin on 2023/04/09.
//

import UIKit
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
    
    let uid = FirebaseManager.sharedInstance().getCurrentUid()
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
        
        setKeyboardObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object:nil)
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 1) {
                self.view.window?.frame.origin.y -= keyboardHeight
            }
        }
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        if self.view.window?.frame.origin.y != 0 {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                UIView.animate(withDuration: 1) {
                    self.view.window?.frame.origin.y += keyboardHeight
                }
            }
        }
    }
    
    @IBAction func pressedSaveButton(_ sender: Any) {
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
                    self.setupDatabase(imageRef, self.uid)
                }
            }
        }
        
        // 유저 이름 수정
        if self.nameTextField.text != "" {
            if (correctNameLabel.isHidden) {
                let dic = ["userName":nameTextField.text!]
                FirebaseManager.sharedInstance().userDataUpdate(uid, childOfData: dic)
                
                let changeRequest = FirebaseManager.sharedInstance().getUserProfile()
                changeRequest.displayName = self.nameTextField.text!
                changeRequest.commitChanges(completion: nil)
            }
        }
        
        // 상태메세지 수정
        if self.stateMessageTextField.text != "" {
            let dic = ["comment":stateMessageTextField.text!]
            FirebaseManager.sharedInstance().userDataUpdate(uid, childOfData: dic)
        }
        
        // 이미지를 변경하지 않은 경우 popupViewController
        if !isImageChange {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setupDatabase(_ imageRef: StorageReference, _ uid: String) {
        imageRef.downloadURL { url, err in
            guard let url = url else { return }
            let dic = ["profileImageUrl":url.absoluteString]
            FirebaseManager.sharedInstance().userDataUpdate(uid, childOfData: dic) { error in
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
        FirebaseManager.sharedInstance().userObserve(withUid: uid) { snapshot in
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
