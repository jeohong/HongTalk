//
//  ChattingViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/05.
//

#import "ChattingViewController.h"
#import "ChatModel.h"
#import "UserModel.h"
#import "NSNumber+Daytime.h"

@import FirebaseDatabase;
@import FirebaseAuth;

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

@end

@implementation ChattingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _uid = [[[FIRAuth auth] currentUser] uid];
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
    [super viewDidDisappear: animated];
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
    
    [[[[[[FIRDatabase database] reference] child: @"chatrooms"] queryOrderedByChild: usersUid] queryEqualToValue: @YES] observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        for (FIRDataSnapshot *data in snapshot.children.allObjects) {
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
            
            // 이곳이 문제 JSON 으로 변환하는 과정에서 오류가 발생하는것으로 보여짐
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


//-(void)getMessageList {
//
//    [[[[[[FIRDatabase database] reference] child: @"chatrooms"] child: _chatRoomUid] child: @"comments"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        [self->_comments removeAllObjects];
//        for (FIRDataSnapshot *data in [[snapshot children] allObjects]) {
//            Comment *comment = [[Comment alloc] initWithDictionary: data.value];
//            [self->_comments addObject:comment];
//        }
//
//        [self->_chattingTableView reloadData];
//
//        if ([self->_comments count] > 0) {
//            [self->_chattingTableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: [self->_comments count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//        }
//    }];
//}

-(void)getDestinationInfo {
    [[[[[FIRDatabase database] reference] child: @"users"] child: _destinationUid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self->_destinationUserModel = [[UserModel alloc] init];
        [self->_destinationUserModel setValuesForKeysWithDictionary:(NSDictionary *)snapshot.value];
        [self getMessageList];
    }];
}

-(void)setReadCountLabel:(UILabel *)label index:(NSInteger)index {
    NSInteger readCount = [[[_comments objectAtIndex: index] readUsers] count];
    if (!_peopleCount) {
        [[[[[[FIRDatabase database] reference] child: @"chatrooms"] child: _chatRoomUid] child: @"users"] observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary *dic = snapshot.value;
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
