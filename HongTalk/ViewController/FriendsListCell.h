//
//  FriendsListCell.h
//  HongTalk
//
//  Created by 홍정민 on 2023/04/05.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendsListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userStateLabel;

@end

NS_ASSUME_NONNULL_END
