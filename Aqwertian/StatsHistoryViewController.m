//
//  StatsHistoryViewController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 2/10/13.
//  Copyright (c) 2013 Nathan Ziebart. All rights reserved.
//

#import "StatsHistoryViewController.h"
#import "StatsViewController.h"
#import "SongOptions.h"

@interface StatsHistoryViewController ()

@property (weak) IBOutlet UITableView *tableView;

@end

@implementation StatsHistoryViewController {

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Standard"];
    cell.textLabel.text = [[[[SongOptions CurrentItem].Arrangement.statsHistory objectAtIndex:indexPath.row] date] description];
    return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [SongOptions CurrentItem].Arrangement.statsHistory.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[StatsViewController sharedController] displayStats:[SongOptions CurrentItem].Arrangement.statsHistory[indexPath.row]];
}

@end
