//
//  ChatListViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/07.
//

#import "ChatListViewController.h"
#import "ChatModel.h"
#import "ChattingViewController.h"
#import "UserModel.h"
#import "NSNumber+Daytime.h"

@import FirebaseAuth;
@import FirebaseDatabase;

@interface ChatListViewController () <UITableViewDelegate, UITableViewDataSource>
// properties
@property (nonatomic) NSMutableArray *chatrooms;
@property (nonatomic) NSMutableArray *destinationUsers;
@property (nonatomic) NSString *uid;

// method
-(void)getChatroomsList;

@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _chatrooms = [NSMutableArray array];
    _destinationUsers = [NSMutableArray array];
    _uid = [[[FIRAuth auth] currentUser] uid];
    [self getChatroomsList];
}

-(void)getChatroomsList {
    NSString *usersUid = [NSString stringWithFormat:@"users/%@", _uid];
    [[[[[[FIRDatabase database] reference] child: @"chatrooms"] queryOrderedByChild: usersUid] queryEqualToValue: @YES] observeEventType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self->_chatrooms removeAllObjects];
        for (FIRDataSnapshot *data in [[snapshot children] allObjects]) {
            NSDictionary *chatRoomDic = (NSDictionary *)data.value;
            ChatModel *chatModel = [[ChatModel alloc] initWithDictionary:chatRoomDic];
            [self->_chatrooms addObject: chatModel];
        }
        
        [self->_chatListTableView reloadData];
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *chatListCellID = @"ChatListCell";
    NSString *destinationUid = [NSString string];
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier: chatListCellID forIndexPath: indexPath];
    
    for (id key in [[_chatrooms objectAtIndex: indexPath.row] valueForKey: @"users"]) {
        if (![key isEqual: _uid]) {
            destinationUid = key;
            [_destinationUsers addObject:destinationUid];
        }
    }

    [[[[[FIRDatabase database] reference] child: @"users"] child: destinationUid] observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        UserModel *userModel = [[UserModel alloc] init];
        [userModel setValuesForKeysWithDictionary: snapshot.value];
        
        [[cell usersNameLabel] setText: userModel.userName];
        
        NSString *lastMessageKey = [[[[[self->_chatrooms objectAtIndex: [indexPath row]] valueForKey: @"comments"] allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj2 compare:obj1];
        }] firstObject];
        
        [[cell lastMessageLabel] setText: [[[[self->_chatrooms objectAtIndex: [indexPath row]] valueForKey: @"comments"] valueForKey: lastMessageKey] valueForKey: @"message"]];
        
        NSNumber *time = [[[[self->_chatrooms objectAtIndex: [indexPath row]] valueForKey: @"comments"] valueForKey: lastMessageKey] valueForKey: @"timestamp"];
        [[cell timestampLabel] setText: [time toDayTime]];
        
        [[[NSURLSession sharedSession] dataTaskWithURL: [NSURL URLWithString: [userModel profileImageUrl]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[cell chatImage] setImage: [UIImage imageWithData: data]];
                [[[cell chatImage] layer] setCornerRadius: cell.chatImage.frame.size.width / 2];
            });
        }] resume];
    }];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _chatrooms.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    NSString *destinationUid = self.destinationUsers[indexPath.row];
    
    UIStoryboard *chatSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChattingViewController *chatVC = (ChattingViewController *)[chatSB instantiateViewControllerWithIdentifier:@"ChattingViewController"];
    chatVC.destinationUid = destinationUid;
    
    [[self navigationController] pushViewController: chatVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  70;
}

@end

// MARK: ChatListCell
@implementation ChatListCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end

