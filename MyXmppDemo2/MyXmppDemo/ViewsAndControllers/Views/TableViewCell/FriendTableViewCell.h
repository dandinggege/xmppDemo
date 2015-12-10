//
//  FriendTableViewCell.h
//  
//
//  Created by 张广洋 on 15/11/15.
//
//

#import <UIKit/UIKit.h>

@interface FriendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageV;

@end
