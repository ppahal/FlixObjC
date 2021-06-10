//
//  MovieDetailsViewController.m
//  FlixObjC
//
//  Created by Priya Pahal on 6/9/21.
//

#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TrailerViewController.h"

@interface MovieDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Set title label
    self.titleLabel.text = self.movie[@"title"];
    [self.titleLabel sizeToFit];
    //Set synopsis label
    self.synopsisLabel.text = self.movie[@"overview"];
    [self.synopsisLabel sizeToFit];
    
    //Setup image fading for poster
    NSString *posterURLString = self.movie[@"poster_path"];
    //Small
    NSString *baseURLSmall = @"https://image.tmdb.org/t/p/w200";
    NSString *smallURLString = [baseURLSmall stringByAppendingString:posterURLString];
    NSURL *urlSmall = [NSURL URLWithString:smallURLString];
    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:urlSmall];
    //Large
    NSString *baseURLLarge = @"https://image.tmdb.org/t/p/w500";
    NSString *largeURLString = [baseURLLarge stringByAppendingString:posterURLString];
    NSURL *urlLarge = [NSURL URLWithString:largeURLString];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:urlLarge];

    [self.posterView setImageWithURLRequest:requestSmall
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       
                                       // smallImageResponse will be nil if the smallImage is already available
                                       // in cache (might want to do something smarter in that case).
                                       self.posterView.alpha = 0.0;
                                       self.posterView.image = smallImage;
                                       
                                       [UIView animateWithDuration:0.5
                                                        animations:^{
                                                            
                                                            self.posterView.alpha = 1.0;
                                                            
                                                        } completion:^(BOOL finished) {
                                                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                                                            // per ImageView. This code must be in the completion block.
                                                            [self.posterView setImageWithURLRequest:requestLarge
                                                                                  placeholderImage:smallImage
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                                                                                                self.posterView.image = largeImage;
                                                                                  }
                                                                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               // do something for the failure condition of the large image request
                                                                                               // possibly setting the ImageView's image to a default image
                                                                                           }];
                                                        }];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       // do something for the failure condition
                                       // possibly try to get the large image
                                   }];
    
    //Setup image fading for backdrop
    NSString *backgroundURLString = self.movie[@"backdrop_path"];
    //Small
    smallURLString = [baseURLSmall stringByAppendingString:backgroundURLString];
    urlSmall = [NSURL URLWithString:smallURLString];
    requestSmall = [NSURLRequest requestWithURL:urlSmall];
    //Large
    largeURLString = [baseURLLarge stringByAppendingString:backgroundURLString];
    urlLarge = [NSURL URLWithString:backgroundURLString];
    requestLarge = [NSURLRequest requestWithURL:urlLarge];

    [self.backgroundView setImageWithURLRequest:requestSmall
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       
                                       // smallImageResponse will be nil if the smallImage is already available
                                       // in cache (might want to do something smarter in that case).
                                        self.backgroundView.alpha = 0.0;
                                        self.backgroundView.image = smallImage;
                                       
                                       [UIView animateWithDuration:0.5
                                                        animations:^{
                                                            
                                                        self.backgroundView.alpha = 1.0;
                                                            
                                                        } completion:^(BOOL finished) {
                                                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                                                            // per ImageView. This code must be in the completion block.
                                                            [self.backgroundView setImageWithURLRequest:requestLarge
                                                                                  placeholderImage:smallImage
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                                                                                            self.backgroundView.image = largeImage;
                                                                                  }
                                                                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               // do something for the failure condition of the large image request
                                                                                               // possibly setting the ImageView's image to a default image
                                                                                           }];
                                                        }];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       // do something for the failure condition
                                       // possibly try to get the large image
                                   }];
    // Do any additional setup after loading the view.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if(self.movie[@"video"]){
        TrailerViewController *vc = [segue destinationViewController];
        vc.movie = self.movie;
    }
}


@end
