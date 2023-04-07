//
//  ChatListViewController.m
//  HongTalk
//
//  Created by 홍정민 on 2023/04/07.
//

#import "ChatListViewController.h"

@interface ChatListViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[ChatListCell alloc] init];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}
@end

// MARK: ChatListCell
@implementation ChatListCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end

