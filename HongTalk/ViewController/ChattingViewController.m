//
//  ChattingViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/05.
//

#import "ChattingViewController.h"
#import "ChatModel.h"
#import "UserModel.h"
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

@end

@implementation ChattingViewController
-(NSMutableArray *)comments {
    return [NSMutableArray array];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _comments = [NSMutableArray array];
    [[[self tabBarController] tabBar] setHidden: YES];
    
    [self setupDelegate];
    [[_messageTextView layer] setCornerRadius: 10];
    
    _uid = [[[FIRAuth auth] currentUser] uid];
    [_sendButton addTarget:self action: @selector(createRoom) forControlEvents:UIControlEventTouchUpInside];
    [self checkRoom];
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
    NSDictionary *createRoomInfo = @{@"users" : @{_uid: @YES, _destinationUid: @YES}};
    
    if (_chatRoomUid == nil) {
        [_sendButton setEnabled: NO];
        [[[[[FIRDatabase database] reference] child: @"chatrooms"] childByAutoId] setValue: createRoomInfo withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error == nil)
                [self checkRoom];
        }];
    } else {
        NSDictionary *value = @{@"uid": self.uid, @"message": self->_messageTextView.text};
        [[[[[[[FIRDatabase database] reference] child: @"chatrooms"] child: _chatRoomUid]child: @"comments"] childByAutoId] setValue: value withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            self->_messageTextView.text =@"";
        }];
    }
}

-(void)getMessageList {
    
    [[[[[[FIRDatabase database] reference] child: @"chatrooms"] child: _chatRoomUid] child: @"comments"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self->_comments removeAllObjects];
        for (FIRDataSnapshot *data in [[snapshot children] allObjects]) {
            Comment *comment = [[Comment alloc] initWithDictionary: data.value];
            [self->_comments addObject:comment];
        }
        
        [self->_chattingTableView reloadData];
        
        if ([self->_comments count] > 0) {
            [self->_chattingTableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: [self->_comments count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}

-(void)getDestinationInfo {
    [[[[[FIRDatabase database] reference] child: @"users"] child: _destinationUid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self->_destinationUserModel = [[UserModel alloc] init];
        [self->_destinationUserModel setValuesForKeysWithDictionary:(NSDictionary *)snapshot.value];
        [self getMessageList];
    }];
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
    if ( [[_comments objectAtIndex: indexPath.row] valueForKey: @"uid"] == _uid ){
        MyMessageCell *cell = [tableView dequeueReusableCellWithIdentifier: myCellId forIndexPath: indexPath];
        [[cell messageLabel] setText: [[_comments objectAtIndex: indexPath.row] valueForKey: @"message"]];
        
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
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
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
