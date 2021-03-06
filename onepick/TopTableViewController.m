//
//  TopTableViewController.m
//  onepick
//
//  Created by yiqin on 5/7/14.
//  Copyright (c) 2014 purdue. All rights reserved.
//

#import "TopTableViewController.h"

@interface TopTableViewController ()

@end

@implementation TopTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

// initWithCoder: load only one time, which is the first time
- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        self.objectsPerPage = 5;
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //NSLog(@"Welcome to Top.");
    // Grab the context
    NSManagedObjectContext *context = [[self appDelegate] managedObjectContext];
    // Construct a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SelectedDishes"
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    // Return a fetch array.
    self.previousCart = [context executeFetchRequest:fetchRequest error:&error];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSignedUp"]) {
        SelectRestaurantSignUpViewController *selectRestaurantSignUpViewController = (SelectRestaurantSignUpViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"SelectRestaurantSignUpViewController"];
        [selectRestaurantSignUpViewController.navigationItem setHidesBackButton:YES];
        [selectRestaurantSignUpViewController setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:selectRestaurantSignUpViewController animated:YES];
    }
    else {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstOrderAlert"]) {
            UIAlertView *firstOrderAlert = [[UIAlertView alloc] initWithTitle:@"Instruction" message:@"Please select the dishes in the Top and Menu sections, then change the quantity in the Cart section. You can't change the quantity in the Top and Menu section." delegate:self cancelButtonTitle:@"Start" otherButtonTitles:nil];
            [firstOrderAlert show];
        }
        else {
            
        }
    }
    

    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[LocalyticsSession shared] tagScreen:@"Top Rate"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/

- (PFQuery *)queryForTable
{
    //NSLog(@"test");
    NSString *locationIndicator = [[NSString alloc] init];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"locationIndicator"] != nil) {
        locationIndicator = [[NSUserDefaults standardUserDefaults] objectForKey:@"locationIndicator"];
    }
    else {
        locationIndicator = @"IN";
    }
    
    NSString *parseClassName =  [@"Dishes" stringByAppendingString:locationIndicator];
    PFQuery *query = [PFQuery queryWithClassName:parseClassName];
    [query orderByDescending:@"orderCount"];
    
    // If no objects are loaded in memory, we look to the cache
    // first to fill the table and then subsequently do a query
    // against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    return query;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *) object
{
    static NSString *simpleTableIdentifier = @"topCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    // [object objectForKey:@"dish"] is a JSON string.
    NSDictionary *dishInformation =  [[object objectForKey:@"dish"] JSONStringToDictionay];
    
    NSString *name = [dishInformation objectForKey:@"name"];
    
    UILabel *nameLabel = (UILabel *) [cell viewWithTag:500];
    nameLabel.text = [dishInformation objectForKey:@"name"];
    
    UILabel *nameChineseLabel = (UILabel *) [cell viewWithTag:504];
    nameChineseLabel.text = [dishInformation objectForKey:@"nameChinese"];
    
    UILabel *priceLabel = (UILabel *) [cell viewWithTag:501];
    // NSNumber -> float -> string
    NSNumber *price = [dishInformation objectForKey:@"price"];
    priceLabel.text = [NSString stringWithFormat:@"Price: %.2f",[price floatValue]];
    
    UILabel *listNumLabel = (UILabel *) [cell viewWithTag:502];
    listNumLabel.text = [NSString stringWithFormat:@"NO. %d", (int)indexPath.row+1];
    
    NSNumber *ordered = [object objectForKey:@"orderCount"];
    UILabel *orderedLabel = (UILabel *) [cell viewWithTag:503];
    orderedLabel.text = [NSString stringWithFormat:@"Ordered: %i",[ordered intValue]];
    
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    // Note that in self.previousCart is not NSString objects.
    for(SelectedDishes *previousDish in self.previousCart) {
        if ([previousDish.name isEqualToString:name]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    //NSLog(@"Row: %i", indexPath.row);
    if (indexPath.row < [self.objects count]) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSDictionary *dishInformation =  [[object objectForKey:@"dish"] JSONStringToDictionay];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            // Reflect selection in data model
            [self create:dishInformation withParseObjectId:[object objectId]];
        } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            // Reflect deselection in data model
            [self delete:[dishInformation objectForKey:@"name"]];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

 
// Core Data
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void) create:(NSDictionary *)dishInformation withParseObjectId:(NSString *) parseObjectId{
    // As there is no built in method available, you need to fetch results and check whether result contains object you don't want to be duplicated.
    
    // Grab the context
    NSManagedObjectContext *context = [[self appDelegate] managedObjectContext];
    
    // Grab the Label entity
    SelectedDishes *selectedDishes = [NSEntityDescription insertNewObjectForEntityForName:@"SelectedDishes" inManagedObjectContext:context];
    
    // Set dish name
    NSString *name = [dishInformation objectForKey:@"name"];
    if (name != nil) [selectedDishes setName:name];
    else [selectedDishes setName:@"no good name"];
    
    NSNumber *price = [dishInformation objectForKey:@"price"];
    if (price != nil) [selectedDishes setPrice:price];
    else [selectedDishes setPrice:[[NSNumber alloc] initWithFloat:10]];
    
    NSString *nameChinese = [dishInformation objectForKey:@"nameChinese"];
    if (nameChinese != nil) [selectedDishes setNameChinese:nameChinese];
    else [selectedDishes setNameChinese:@"还没有名字"];
    
    [selectedDishes setParseObjectId:parseObjectId];
    
    NSNumber *count = [[NSNumber alloc] initWithInt:1];
    [selectedDishes setCount:count];
    
    // Save everything
    NSError *error = nil;
    if (![context save:&error])
    {
        //NSLog(@"Error deleting movie, %@", [error userInfo]);
    }
    
}

- (void) delete: (NSString *)dishName {
    // As there is no built in method available, you need to fetch results and check whether result contains object you don't want to be duplicated.
    
    // Grab the context
    NSManagedObjectContext *context = [[self appDelegate] managedObjectContext];
    
    // Fetch all the data we wanna delete
    NSFetchRequest *fetchDelete = [[NSFetchRequest alloc] init];
    fetchDelete.entity = [NSEntityDescription entityForName:@"SelectedDishes" inManagedObjectContext:context];
    fetchDelete.predicate = [NSPredicate predicateWithFormat:@"name == %@", dishName];
    NSArray *arrayDelete = [context executeFetchRequest:fetchDelete error:nil];
    
    for (NSManagedObject *managedObject in arrayDelete) {
        [context deleteObject:managedObject];
    }
    
    // Delete
    NSError *error = nil;
    if (![context save:&error])
    {
        //NSLog(@"Error deleting movie, %@", [error userInfo]);
    }
    
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstOrderAlert"];
            break;
        default:
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
