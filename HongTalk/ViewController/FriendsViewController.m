//
//  FriendsViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/05.
//

#import "FriendsViewController.h"
#import "UserModel.h"
@import FirebaseDatabase;
@import FirebaseAuth;

// MARK: FriendsViewController
@interface FriendsViewController() <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *friendsList;
@property NSMutableArray *users;
@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _users = [NSMutableArray array];
    [[[[FIRDatabase database] reference] child: @"users"] observeEventType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self->_users removeAllObjects];
        NSString *uid = [[[FIRAuth auth] currentUser] uid];
        
        for (FIRDataSnapshot *data in [snapshot children]) {
            UserModel *userModel = [[UserModel alloc] init];
            [userModel setValuesForKeysWithDictionary: [data value]];
            
            if ([[userModel uid] isEqual: uid]) {
                continue;
            }
            
            [self.users addObject: userModel];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_friendsList reloadData];
        });
    }];
}

// MARK: Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

// MARK: DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"FriendsListCell";
    FriendsListCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];
    
    [[cell profileImage] setImage: [UIImage imageNamed: @"HongTalk"]];
    [[[cell profileImage] layer] setCornerRadius: cell.profileImage.frame.size.width / 2];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

@end

// MARK: TableView Cell Class
@implementation FriendsListCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
