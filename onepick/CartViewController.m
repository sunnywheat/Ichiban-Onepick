//
//  CartViewController.m
//  onepick
//
//  Created by yiqin on 4/28/14.
//  Copyright (c) 2014 purdue. All rights reserved.
//

#import "CartViewController.h"

@interface CartViewController ()

@end

@implementation CartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Core Data
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

// viewWilAppear: load eveytime the page is visited
// viewDidLoad: load only one time, that is the first time
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Welcome to Cart.");
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
    // Since the table view will use array, it is not necessary to use dictionary to handle these data. Reload all the data here.
    // Also Core Data return an array.
    // Note that all data in Cart are mutable.
    if([self.previousCart count] > 0) {
        // Reset the total price
        self.totalDishesFloat = 0;
        self.cartArray = [[NSMutableArray alloc] initWithCapacity:[self.previousCart count]];
        NSMutableArray *keys = [[NSMutableArray alloc] init];
        NSMutableArray *objects = [[NSMutableArray alloc] init];
        NSMutableDictionary *dishDictionary = [[NSMutableDictionary alloc] init];
        for (SelectedDishes *previousDish in self.previousCart) {
            // Why this line never work ?
            // The mutable array doesn't exist at the time this is being called.
            // The mutable array must be initalized first.
            keys = [NSMutableArray arrayWithObjects:@"name", @"price", @"nameChinese", @"parseObjectId",@"count", nil];
            objects = [NSMutableArray arrayWithObjects:previousDish.name, previousDish.price, previousDish.nameChinese, previousDish.parseObjectId,previousDish.count, nil];
            dishDictionary = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
            [self.cartArray addObject:dishDictionary];
            self.totalDishesFloat = self.totalDishesFloat + [previousDish.price floatValue]*[previousDish.count intValue];
        }
    }
    else {
        // [self.cartArray addObject:@"Your cart is empty."];
    }
    
    // Why here I need to add @property (strong, nonatomic) IBOutlet UITableView *cartTableView; to handle reloadData?
    self.totalDishes.text = [NSString stringWithFormat:@"$%.2f",self.totalDishesFloat];
    [self.cartTableView reloadData];
    

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // init a mutable dictionary here, or not?
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.previousCart count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"cartCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    // Similar as DishTableViewController
    NSMutableDictionary *dishInformation = [self.cartArray objectAtIndex:indexPath.row];
    UILabel *nameLabel = (UILabel *) [cell viewWithTag:300];
    nameLabel.text = [dishInformation objectForKey:@"name"];
    UILabel *priceLabel = (UILabel *) [cell viewWithTag:301];
    // NSNumber -> float -> string
    NSNumber *price = [dishInformation objectForKey:@"price"];
    priceLabel.text = [NSString stringWithFormat:@"%.2f",[price floatValue]];
    UILabel *nameChineseLabel = (UILabel *) [cell viewWithTag:302];
    nameChineseLabel.text = [dishInformation objectForKey:@"nameChinese"];
    UILabel *countLabel = (UILabel *) [cell viewWithTag:303];
    countLabel.text = [[dishInformation objectForKey:@"count"] stringValue];
    
    UILabel *listNumLabel = (UILabel *) [cell viewWithTag:304];
    listNumLabel.text = [NSString stringWithFormat:@"%i", indexPath.row+1];
    
    // Dynamically add buttons
    // add button
    UIButton *addDishButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addDishButton.tag = indexPath.row;
    addDishButton.frame = CGRectMake(100.0f, 5.0f, 75.0f, 30.0f);
    [addDishButton setTitle:@"Add" forState:UIControlStateNormal];
    [cell addSubview:addDishButton];
    [addDishButton addTarget:self
                        action:@selector(addDish:)
              forControlEvents:UIControlEventTouchUpInside];

    // minus button
    UIButton *minusDishButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    minusDishButton.tag = indexPath.row;
    minusDishButton.frame = CGRectMake(250.0f, 5.0f, 75.0f, 30.0f);
    [minusDishButton setTitle:@"Delete" forState:UIControlStateNormal];
    [cell addSubview:minusDishButton];
    [minusDishButton addTarget:self
                      action:@selector(minusDish:)
            forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (IBAction)addDish:(id)sender
{
    UIButton *senderButton = (UIButton *)sender;
    NSMutableDictionary *dishInformation = [self.cartArray objectAtIndex:senderButton.tag];
    // NSNumber are not really used to store numbers in actual math.
    int previousCount = [[dishInformation objectForKey:@"count"] integerValue];
    NSNumber *currentCount = [[NSNumber alloc] initWithInt:previousCount+1];
    [dishInformation setValue:currentCount forKey:@"count"];
    self.totalDishesFloat = self.totalDishesFloat + [[dishInformation objectForKey:@"price"] floatValue];
    self.totalDishes.text = [NSString stringWithFormat:@"$%.2f",self.totalDishesFloat];
    [self.cartTableView reloadData];
    [self updateCount:[dishInformation objectForKey:@"name"] withCount:currentCount];
}

- (IBAction)minusDish:(id)sender
{
    UIButton *senderButton = (UIButton *)sender;
    NSMutableDictionary *dishInformation = [self.cartArray objectAtIndex:senderButton.tag];
    // NSNumber are not really used to store numbers in actual math.
    int previousCount = [[dishInformation objectForKey:@"count"] integerValue];
    if (previousCount > 1) {
        NSNumber *currentCount = [[NSNumber alloc] initWithInt:previousCount-1];
        [dishInformation setValue:currentCount forKey:@"count"];
        self.totalDishesFloat = self.totalDishesFloat - [[dishInformation objectForKey:@"price"] floatValue];
        self.totalDishes.text = [NSString stringWithFormat:@"$%.2f",self.totalDishesFloat];
        [self.cartTableView reloadData];
        [self updateCount:[dishInformation objectForKey:@"name"] withCount:currentCount];
    }
    else if (previousCount == 1) {
        NSNumber *currentCount = [[NSNumber alloc] initWithInt:previousCount-1];
        [dishInformation setValue:currentCount forKey:@"count"];
        self.totalDishesFloat = self.totalDishesFloat - [[dishInformation objectForKey:@"price"] floatValue];
        self.totalDishes.text = [NSString stringWithFormat:@"$%.2f",self.totalDishesFloat];
        [self.cartTableView reloadData];
        [self deleteZeroDish:[dishInformation objectForKey:@"name"]];
    }
}

// Save counts in Core Data
- (void) updateCount:(NSString *)dishName withCount:(NSNumber *) count {
    // Grab the context
    NSManagedObjectContext *context = [[self appDelegate] managedObjectContext];
    
    // Fetch all the data we wanna delete
    NSFetchRequest *fetchUpdate = [[NSFetchRequest alloc] init];
    fetchUpdate.entity = [NSEntityDescription entityForName:@"SelectedDishes" inManagedObjectContext:context];
    fetchUpdate.predicate = [NSPredicate predicateWithFormat:@"name == %@", dishName];
    NSArray *arrayUpdate = [context executeFetchRequest:fetchUpdate error:nil];
    
    // maybe some check before, to be sure results is not empty
    if ([arrayUpdate count] > 0) {
        NSManagedObject* updateGrabbed = [arrayUpdate objectAtIndex:0];
        [updateGrabbed setValue:count forKey:@"count"];
    }
    
    // Delete
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"Error deleting movie, %@", [error userInfo]);
    }
}

// Delete zero dish in Core Data
- (void) deleteZeroDish: (NSString *)dishName {
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
        NSLog(@"Error deleting movie, %@", [error userInfo]);
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Do some stuff when the row is selected
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Alert
- (IBAction)deliverToWhere:(id)sender {
    UIActionSheet *deliverToWhereActionSheet = [[UIActionSheet alloc] initWithTitle:@"Update Address"delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"History Address", @"Add New Address", nil];
    [deliverToWhereActionSheet setTag:1];
    [deliverToWhereActionSheet showInView:self.view];
    
}

- (IBAction)confirm:(id)sender {
    UIActionSheet *confirmActionSheet = [[UIActionSheet alloc] initWithTitle:@"Update Address\nUpdate Address" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Confirm", nil];
    [confirmActionSheet setTag:2];
    [confirmActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 0:
                NSLog(@"History Address");
                [self historyButtonPress];
                break;
            case 1:
                NSLog(@"Add New Address");
                [self addNewButtonPress];
                break;
            default:
                break;
        }
    }
    else if (actionSheet.tag == 2) {
        switch (buttonIndex) {
            case 0:
                NSLog(@"Confirm");
                [self confirmButtonPress];
                break;
            default:
                break;
        }
    }
    
}

-(void) addNewButtonPress {
    NewAddressViewController *newAddrewViewController = (NewAddressViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"NewAddrewController"];
    [self.navigationController pushViewController:newAddrewViewController animated:YES];
}

-(void) historyButtonPress {
    HistoryAddressTableViewController *historyAddressTableViewController = (HistoryAddressTableViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryAddressTableViewController"];
    [self.navigationController pushViewController:historyAddressTableViewController animated:YES];
}

- (void) confirmButtonPress {
    NSLog(@"Confirm is pressed.");
    NSLog(@"%@", [[UIDevice currentDevice] name]);
    // Get the currentDevice name for the first, since the name will be changed. Then save it to Core Data
    
    // Move to Order View
    // But I don't why ??
    OrderTableViewController *orderTableViewController = (OrderTableViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"OrderTableViewController"];
    [self.navigationController pushViewController:orderTableViewController animated:YES];
}


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
