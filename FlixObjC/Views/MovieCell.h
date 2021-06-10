//
//  MovieCell.h
//  FlixObjC
//
//  Created by Priya Pahal on 6/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovieCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@end

NS_ASSUME_NONNULL_END
