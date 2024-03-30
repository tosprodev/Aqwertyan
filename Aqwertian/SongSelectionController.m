//
//  SongSelectionController.m
//  Aqwertian
//
//  Created by Nathan Ziebart on 9/27/12.
//  Copyright (c) 2012 Nathan Ziebart. All rights reserved.
//

#import "SongSelectionController.h"

@interface SongSelectionController ()

@end

@implementation SongSelectionController {
    NSMutableArray *theNames;
    IBOutlet UITableView *theTableView;
    BOOL isSelecting;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
        NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.mus'"];
        NSArray *list = [[dirContents filteredArrayUsingPredicate:fltr] sortedArrayUsingSelector:@selector(compare:)];
        theNames = [NSMutableArray new];
        for (NSString *name in list) {
            [theNames addObject:[name substringToIndex:name.length - 4]];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [theTableView reloadData];
    [self loadSong:@"fur"];
        // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [theTableView scrollToRowAtIndexPath:[theTableView indexPathForSelectedRow] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];

}

- (void)loadSong:(NSString *)name {
    NSInteger theIndex = [theNames indexOfObject:name];
    if (theIndex > -1 && theIndex < theNames.count) {
        isSelecting = YES;
        [theTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:theIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
       // [self.Delegate loadMusFile:name];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return theNames.count;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:@"Standard"];
    if (!theCell) {
        theCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Standard"];
    }
    theCell.textLabel.text = [theNames objectAtIndex:indexPath.row];
    return theCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isSelecting) {
        isSelecting = NO;
        return;
    }
   // [self.Delegate loadMusFile:[theNames objectAtIndex:indexPath.row]];
    [self.Popover dismissPopoverAnimated:YES];
}

@end
