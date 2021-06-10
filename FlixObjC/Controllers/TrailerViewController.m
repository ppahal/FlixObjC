//
//  TrailerViewController.m
//  FlixObjC
//
//  Created by Priya Pahal on 6/9/21.
//

#import "TrailerViewController.h"

@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *trailerView;
@property (nonatomic,strong) NSArray *officialTrailer;
@property (nonatomic, strong) NSArray *videos;
@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSInteger id = [self.movie[@"id"] integerValue];
    NSString *idString = [NSString stringWithFormat:@"%ld", (long)id ];
    NSString *baseURLString = [@"https://api.themoviedb.org/3/movie/" stringByAppendingString:idString];
    NSString *urlString = [baseURLString stringByAppendingString:@"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               
               //Setting Up No Wifi Alert
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Trailer"
                                                                              message:@"The internet connection appears to be offline."
                                                                       preferredStyle:(UIAlertControllerStyleAlert)];
               //Create a try again action.
               UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again."
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                   [self fetchTrailer];
                                                                }];
               // add the OK action to the alert controller
               [alert addAction:tryAgainAction];
               //Present error for when you can't fetchMovies
               [self presentViewController:alert animated:YES completion:^{
                   // optional code for what happens after the alert controller has finished presenting
               }];
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               // TODO: Get the array of movies
               self.videos = dataDictionary[@"results"];
               NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(type == %@)",@"Trailer"];
               self.officialTrailer = [self.videos filteredArrayUsingPredicate:predicate];
               NSString *urlString = [@"https://www.youtube.com/watch?v=" stringByAppendingString: self.officialTrailer[0][@"key"]];
               NSURL *url = [NSURL URLWithString:urlString];
               NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                    timeoutInterval:10.0];
               // Load Request into WebView.
               [self.trailerView loadRequest:request];
              // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] Trailer)"];
               //Filter movies with that value
              // NSArray *officialTrailer = [self.trailer filteredArrayUsingPredicate:predicate];
           }
       }];
    [task resume];
    //[self fetchTrailer];
}

- (void) fetchTrailer{
    NSInteger id = [self.movie[@"id"] integerValue];
    NSString *idString = [NSString stringWithFormat:@"%ld", (long)id ];
    NSString *baseURLString = [@"https://api.themoviedb.org/3/movie/" stringByAppendingString:idString];
    NSString *urlString = [baseURLString stringByAppendingString:@"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               
               //Setting Up No Wifi Alert
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Trailer"
                                                                              message:@"The internet connection appears to be offline."
                                                                       preferredStyle:(UIAlertControllerStyleAlert)];
               //Create a try again action.
               UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again."
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                   [self fetchTrailer];
                                                                }];
               // add the OK action to the alert controller
               [alert addAction:tryAgainAction];
               //Present error for when you can't fetchMovies
               [self presentViewController:alert animated:YES completion:^{
                   // optional code for what happens after the alert controller has finished presenting
               }];
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               // TODO: Get the array of movies
               self.videos = dataDictionary[@"results"];
               NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(type == %@)",@"Trailer"];
               self.officialTrailer = [self.videos filteredArrayUsingPredicate:predicate];
               NSString *urlString = [@"https://www.youtube.com/watch?v=\\" stringByAppendingString: self.officialTrailer[0][@"key"]];
               NSURL *url = [NSURL URLWithString:urlString];
               NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                    timeoutInterval:10.0];
               // Load Request into WebView.
               [self.trailerView loadRequest:request];
              // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] Trailer)"];
               //Filter movies with that value
              // NSArray *officialTrailer = [self.trailer filteredArrayUsingPredicate:predicate];
           }
       }];
    [task resume];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
