//
//  FriendsViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/05.
//

#import "FriendsViewController.h"

@interface FriendsViewController() <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *friendsList;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

// MARK: Delegate

// MARK: DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"FriendsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];
    
    return cell;
}

@end
