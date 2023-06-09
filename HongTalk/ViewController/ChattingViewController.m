//
//  ChattingViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/05.
//

#import "ChattingViewController.h"
#import "ChatModel.h"
#import "UserModel.h"
#import "NotificationModel.h"
#import "NSNumber+Daytime.h"

@import FirebaseDatabase;

@interface ChattingViewController ()<UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textviewHeight;

@property (nonatomic) NSMutableArray *comments;
@property (nonatomic) UserModel *destinationUserModel;
@property (nonatomic) FIRDatabaseReference *databaseRef;
@property (nonatomic) NSUInteger observe;
@property (nonatomic) NSUInteger peopleCount;
@property (nonatomic) NSString *uid;
@property (nonatomic) NSString *chatRoomUid;

// method
-(void)setupDelegate;
-(void)checkRoom;
-(void)getDestinationInfo;
-(void)getMessageList;
-(void)setReadCountLabel: (UILabel *) label index: (NSInteger) index;
-(void)sendFcm;

@end

@implementation ChattingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _uid = FirebaseManager.sharedInstance.getCurrentUid;
    _comments = [NSMutableArray array];
    [[[self tabBarController] tabBar] setHidden: YES];
    
    [self setupDelegate];
    [[_messageTextView layer] setCornerRadius: 10];
    
    [_sendButton addTarget:self action: @selector(createRoom) forControlEvents:UIControlEventTouchUpInside];
    [self checkRoom];
    
    // 키보드 나타날때 뷰 올려주기
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 키보드 숨기기
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[[self tabBarController] tabBar] setHidden: NO];
    
    [_databaseRef removeObserverWithHandle: _observe];
}

-(void)setupDelegate {
    [_messageTextView setDelegate: self];
    [_chattingTableView setDelegate: self];
    [_chattingTableView setDataSource: self];
}

-(void)checkRoom {
    NSString *usersUid = [NSString stringWithFormat:@"users/%@", _uid];
    [FirebaseManager.sharedInstance chatroomDataObserveSingleWithUid: usersUid isOrder: YES completeBlock:^(FIRDataSnapshot * _Nonnull snapShot) {
        for (FIRDataSnapshot *data in snapShot.children.allObjects) {
            NSDictionary *chatRoomDic = (NSDictionary *)data.value;
            ChatModel *chatModel = [[ChatModel alloc] initWithDictionary:chatRoomDic];
            if ([chatModel.users[self->_destinationUid] isEqual: @YES]) {
                self.chatRoomUid = data.key;
                [self->_sendButton setEnabled: YES];
                [self getDestinationInfo];
            }
        }
    }];
}

-(void)createRoom {
    if ([[_messageTextView text] isEqual: @""]) {
        return;
    }
    NSDictionary *createRoomInfo = @{@"users" : @{_uid: @YES, _destinationUid: @YES}};
    
    if (_chatRoomUid == nil) {
        [_sendButton setEnabled: NO];
        [[[[[FIRDatabase database] reference] child: @"chatrooms"] childByAutoId] setValue: createRoomInfo withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error == nil)
                [self checkRoom];
        }];
    } else {
        NSDictionary *value = @{@"uid": self.uid,
                                @"message": self->_messageTextView.text,
                                @"timestamp": FIRServerValue.timestamp
        };
        
        [[[[[[[FIRDatabase database] reference] child: @"chatrooms"] child: _chatRoomUid]child: @"comments"] childByAutoId] setValue: value withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            [self sendFcm];
            [self->_messageTextView setText: @""];
            [self textViewDidChange: self->_messageTextView];
        }];
    }
}

- (void)getMessageList {
    _databaseRef = [[[[[FIRDatabase database]reference]child: @"chatrooms"] child:_chatRoomUid] child: @"comments"];
    _observe = [_databaseRef observeEventType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self->_comments removeAllObjects];
        NSMutableDictionary *readUserDic = [NSMutableDictionary dictionary];
        
        for (FIRDataSnapshot *data in snapshot.children) {
            NSString *key = data.key;
            Comment *comment = [[Comment alloc] initWithDictionary: data.value];
            Comment *commentMotify = [[Comment alloc] initWithDictionary: data.value];
            commentMotify.readUsers[self->_uid] = @YES;
            readUserDic[key] = [commentMotify dictionaryRepresentation];
            
            [self->_comments addObject: comment];
        }
        
        NSDictionary *nsDic = readUserDic;
        if (![[[[self->_comments lastObject] readUsers] allKeys] containsObject: self->_uid]) {
            [snapshot.ref updateChildValues:(NSDictionary *)nsDic withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                [self->_chattingTableView reloadData];
                
                if (self.comments.count > 0) {
                    [self->_chattingTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.comments.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            }];
        } else {
            [self->_chattingTableView reloadData];
            
            if (self.comments.count > 0) {
                [self->_chattingTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.comments.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    }];
}

-(void)getDestinationInfo {
    [FirebaseManager.sharedInstance userObserveWithUid: self.destinationUid completeBlock:^(FIRDataSnapshot * _Nonnull snapShot) {
        self->_destinationUserModel = [[UserModel alloc] init];
        [self->_destinationUserModel setValuesForKeysWithDictionary:(NSDictionary *)snapShot.value];
        [self getMessageList];
    }];
}

-(void)setReadCountLabel:(UILabel *)label index:(NSInteger)index {
    NSInteger readCount = [[[_comments objectAtIndex: index] readUsers] count];
    if (!_peopleCount) {
        // TODO: 여기부터
        [FirebaseManager.sharedInstance chatroomDataObserveSingleWithUid: self.chatRoomUid isOrder: NO completeBlock:^(FIRDataSnapshot * _Nonnull snapShot) {
            NSDictionary *dic = snapShot.value;
            self->_peopleCount = [dic count];
            NSInteger noReadCount = self->_peopleCount - readCount;
            if (noReadCount > 0) {
                [label setHidden: NO];
                [label setText: [NSString stringWithFormat: @"%ld", noReadCount]];
            } else {
                [label setHidden:YES];
            }
        }];
    } else {
        NSInteger noReadCount = self->_peopleCount - readCount;
        if (noReadCount > 0) {
            [label setHidden: NO];
            [label setText: [NSString stringWithFormat: @"%ld", noReadCount]];
        } else {
            label.hidden = YES;
        }
    }
}

-(void)sendFcm {
    NSString *API = @"AAAAOM_6vIU:APA91bE8YntXx7iCrUeT6b1qdgDiaO412foYJe2uj5tvvO1dgCryMvs_HuJfR2atsVZOFhvB9HCwqHq6kyeoz0V2sGwbqzuY9ceadooczL-qt_0_qg2lDMOankKaOVuvaRj-SOdCDLXp";
    NSString *url = @"https://fcm.googleapis.com/fcm/send";
    NSString *authValue = [NSString stringWithFormat:@"key=%@", API];
    NSString *username = FirebaseManager.sharedInstance.getCurrentDisplayName;
    
    NotificationModel *notificationModel = [[NotificationModel alloc] init];
    notificationModel.to = [_destinationUserModel pushToken];
    notificationModel.notification.title = username;
    notificationModel.notification.body = [_messageTextView text];
    notificationModel.data.title = username;
    notificationModel.data.body = [_messageTextView text];
    
    NSDictionary *params = [notificationModel dictionaryRepresentation];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    // JSON 변경
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Network error: %@", error.localizedDescription);
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = httpResponse.statusCode;
        
        if (statusCode != 200) {
            NSLog(@"HTTP error: %ld", (long)statusCode);
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError) {
            NSLog(@"JSON deserialization error: %@", jsonError.localizedDescription);
            return;
        }
        
        NSLog(@"Response: %@", responseDict);
    }];
    
    [task resume];
    
}

// MARK: TextView Delegate Methods
- (void)textViewDidChange:(UITextView *)textView {
    CGSize size = CGSizeMake(textView.frame.size.width, CGFLOAT_MAX);
    CGSize newSize = [textView sizeThatFits:size];
    CGFloat newHeight = MAX(newSize.height, 30);
    if ( (newSize.height / textView.font.lineHeight) >= 5) {
        self.textviewHeight.constant = 5 * textView.font.lineHeight + textView.textContainerInset.top + textView.textContainerInset.bottom;
    } else {
        self.textviewHeight.constant = newHeight;
    }
    
    [self.view layoutIfNeeded];
}

// MARK: TableView Delegate , DataSource Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *myCellId = @"MyMessageCell";
    NSString *destinationCellId = @"DestinationMessageCell";
    
    if ( [[[_comments objectAtIndex: indexPath.row] valueForKey: @"uid"] isEqual: _uid] ){
        MyMessageCell *cell = [tableView dequeueReusableCellWithIdentifier: myCellId forIndexPath: indexPath];
        [[cell messageLabel] setText: [[_comments objectAtIndex: indexPath.row] valueForKey: @"message"]];
        
        // Time stamp
        NSNumber *time = [[_comments objectAtIndex: indexPath.row] valueForKey: @"timestamp"];
        [[cell timestampLabel] setText: [time toDayTime]];
        [self setReadCountLabel: [cell readCountLabel] index: [indexPath row]];
        
        return cell;
    }else {
        DestinationMessageCell *cell = [tableView dequeueReusableCellWithIdentifier: destinationCellId forIndexPath: indexPath];
        [[cell nameLabel] setText: [_destinationUserModel userName]];
        [[cell messageLabel] setText: [[_comments objectAtIndex: indexPath.row] valueForKey: @"message"]];
        
        // image
        [[[NSURLSession sharedSession] dataTaskWithURL: [NSURL URLWithString: [_destinationUserModel profileImageUrl]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[cell profileImage] setImage: [UIImage imageWithData: data]];
                [[[cell profileImage] layer] setCornerRadius: cell.profileImage.frame.size.width / 2];
            });
        }] resume];
        NSNumber *time = [[_comments objectAtIndex: indexPath.row] valueForKey: @"timestamp"];
        [[cell timestampLabel] setText: [time toDayTime]];
        [self setReadCountLabel: [cell readCountLabel] index: [indexPath row]];
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

// MARK: 키보드에 따른 뷰 올리기
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = CGRectMake(0, -keyboardRect.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 키보드 숨기기
- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

@end

// MARK: MyMessage Cell Class
@implementation MyMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

// MARK: DestinationMessageCell Cell Class
@implementation DestinationMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
