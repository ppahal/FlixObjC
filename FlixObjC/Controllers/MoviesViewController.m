//
//  MoviesViewController.m
//  FlixObjC
//
//  Created by Priya Pahal on 6/6/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *moviesTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation MoviesViewController

- (void)viewDidLoad {
    //Basic stuff
    [super viewDidLoad];
    self.moviesTableView.dataSource = self;
    self.moviesTableView.delegate = self;
    
    //Set row height
    self.moviesTableView.rowHeight = UITableViewAutomaticDimension;
    
    //Set up searchBar
    self.searchBar.delegate = self;
    
    //Setting up Refresh
    [self fetchMovies];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    //Briefly overlaps first cell in tableview
    //[self.moviesTableView addSubview:self.refreshControl];
    //Puts refresh at specified index
    [self.moviesTableView insertSubview:self.refreshControl atIndex:0];
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

               // Get the array of movies and store the movies in a property to use elsewhere
               self.movies = dataDictionary[@"results"];
               self.filteredMovies = self.movies;
               
               // TODO: Reload your table view data
               [self.moviesTableView reloadData];
               [self.activityIndicator stopAnimating];
           }
        [self.refreshControl endRefreshing];
       }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredMovies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MovieCell *cell = [self.moviesTableView dequeueReusableCellWithIdentifier:(@"MovieCell")];
    //Collection views don't have rows or sections
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.captionLabel.text = movie[@"overview"];
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    return cell;
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
        
    }
    else {
        self.filteredMovies = self.movies;
    }
    [self.moviesTableView reloadData];
 
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.moviesTableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    MovieDetailsViewController *vc = [segue destinationViewController];
    vc.movie = movie;
}

@end
