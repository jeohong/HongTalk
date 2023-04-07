//
//  ChatListViewController.h
//  HongTalk
//
//  Created by 홍정민 on 2023/04/07.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *chatListTableView;

@end


// MARK: ChatListCell
@interface ChatListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *chatImage;
@property (weak, nonatomic) IBOutlet UILabel *usersNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;

@end

NS_ASSUME_NONNULL_END
