//
//  MoviesGridViewController.m
//  FlixObjC
//
//  Created by Priya Pahal on 6/9/21.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailsViewController.h"
#import "SearchCollectionReusableView.h"

@interface MoviesGridViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UICollectionView *moviesCollectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.moviesCollectionView.dataSource = self;
    self.moviesCollectionView.delegate = self;
    
    //Fix layout
    //Cast the Collection View Layout as UICollectionViewFlowLayout
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.moviesCollectionView.collectionViewLayout;
    //InterItem Spacing
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    CGFloat postersPerRow = 2;
    CGFloat itemwidth = (self.moviesCollectionView.frame.size.width - layout.minimumInteritemSpacing *(postersPerRow - 1))/postersPerRow;
    CGFloat itemHeight = itemwidth * 1.5;
    layout.itemSize = CGSizeMake(itemwidth, itemHeight);
    
    //Setting up Refresh
    [self fetchMovies];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    
    //Puts refresh at specified index
    [self.moviesCollectionView insertSubview:self.refreshControl atIndex:0];
}

- (void) fetchMovies{
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               //Setting Up No Wifi Alert
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies"
                                                                              message:@"The internet connection appears to be offline."
                                                                       preferredStyle:(UIAlertControllerStyleAlert)];
               //Create a try again action.
               UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again."
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                   [self fetchMovies];
                                                                }];
               // add the OK action to the alert controller
               [alert addAction:tryAgainAction];
               //Present error for when you can't fetchMovies
               [self presentViewController:alert animated:YES completion:^{
                   // optional code for what happens after the alert controller has finished presenting
               }];
           }
           else {
               [self.activityIndicator startAnimating];
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

               // TODO: Get the array of movies
               self.movies = dataDictionary[@"results"];
               self.filteredMovies = self.movies;
               // TODO: Store the movies in a property to use elsewhere
               
               // TODO: Reload your table view data
               [self.moviesCollectionView reloadData];
               [self.activityIndicator stopAnimating];
           }
        [self.refreshControl endRefreshing];
       }];
    [task resume];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionCell *cell = [self.moviesCollectionView dequeueReusableCellWithReuseIdentifier:(@"MovieCollectionCell") forIndexPath:(indexPath)];
    NSDictionary *movie = self.filteredMovies[indexPath.item];
    //Setup image fading for poster
    NSString *posterURLString = movie[@"poster_path"];
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

    [cell.posterView setImageWithURLRequest:requestSmall
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       
                                       // smallImageResponse will be nil if the smallImage is already available
                                       // in cache (might want to do something smarter in that case).
                                       cell.posterView.alpha = 0.0;
                                       cell.posterView.image = smallImage;
                                       
                                       [UIView animateWithDuration:0.5
                                                        animations:^{
                                                            
                                                            cell.posterView.alpha = 1.0;
                                                            
                                                        } completion:^(BOOL finished) {
                                                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                                                            // per ImageView. This code must be in the completion block.
                                                            [cell.posterView setImageWithURLRequest:requestLarge
                                                                                  placeholderImage:smallImage
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                                                                                                cell.posterView.image = largeImage;
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
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.moviesCollectionView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredMovies[indexPath.item];
    MovieDetailsViewController *vc = [segue destinationViewController];
    vc.movie = movie;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SearchCollectionReusableView *searchView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SearchCollectionReusableView" forIndexPath:indexPath];
    return searchView;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //If there's something to search
    if (searchText.length != 0) {
        //Get search value
        /*NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, self.filteredMovies) {
            NSLog(@"%@",_filteredMovies);
            return [evaluatedObject containsString:searchText];
        }];*/
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[cd] %@)", searchText];
        //Filter movies with that value
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
        //NSLog(@"HERE");
    }
    else {
        self.filteredMovies = self.movies;
        //NSLog(@"NOT HERE");
    }
    [self.moviesCollectionView reloadData];
    //PROBLEM: Can't figure out how to keep editing when typing.
    //[self.moviesCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
   /* [self.moviesCollectionView performBatchUpdates:^{bsjdk
                [self.moviesCollectionView reloadData];
            } completion:^(BOOL finished) {
                [searchBar becomeFirstResponder];
            }];*/
}


@end
