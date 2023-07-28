#import "SettingTableViewController.h"

@interface SettingTableViewController ()

@property (nonatomic, retain) NSArray *menuData;

@end

@implementation SettingTableViewController

+ (instancetype)sharedInstance {
    static SettingTableViewController* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self setTitle:@"Setting"];
    
    NSString *rulesFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"rules.plist"];
    NSCharacterSet *CharacterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodedURLString = [rulesFilePath stringByAddingPercentEncodingWithAllowedCharacters:CharacterSet];
    NSURL *filzaURL = [NSURL URLWithString:[@"filza://view" stringByAppendingString:encodedURLString]];
    
    self.menuData = @[
        @{
            @"groupTitle": @"General",
            @"items": @[
                @{
                    @"textLabel": @"Auto blacklist",
                    @"detailTextLabel": @"Auto add the newly installed app to blacklist",
                    @"type": @"switch",
                    @"switchKey": @"auto_blacklist",
                },
            ]
        },
        @{
            @"groupTitle": @"Advanced",
            @"items": @[
                @{
                    @"textLabel": @"View clean rules",
                    @"detailTextLabel": @"Open the rules file through Filza",
                    @"type": @"url",
                    @"url": filzaURL.absoluteString
                },
            ]
        },
    ];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.menuData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *groupData = self.menuData[section];
    NSArray *items = groupData[@"items"];
    return items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *groupData = self.menuData[section];
    return groupData[@"groupTitle"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    NSDictionary *groupData = self.menuData[indexPath.section];
    NSArray *items = groupData[@"items"];
    
    NSDictionary *item = items[indexPath.row];
    cell.textLabel.text = item[@"textLabel"];
    cell.detailTextLabel.text = item[@"detailTextLabel"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([item[@"type"] isEqualToString:@"switch"]) {
        UISwitch *theSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [theSwitch setOn:[defaults boolForKey:item[@"switchKey"]]];
        [theSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = theSwitch;
    }
    
    if([item[@"type"] isEqualToString:@"url"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)switchChanged:(id)sender {
    UISwitch *switchInCell = (UISwitch *)sender;
    CGPoint pos = [switchInCell convertPoint:switchInCell.bounds.origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pos];
    
    NSDictionary *groupData = self.menuData[indexPath.section];
    NSArray *items = groupData[@"items"];
    
    NSDictionary *item = items[indexPath.row];
    
    NSLog(@"%@",item[@"switchKey"]);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:switchInCell.on forKey:item[@"switchKey"]];
    [defaults synchronize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//取消选中效果
    
    NSDictionary *groupData = self.menuData[indexPath.section];
    NSArray *items = groupData[@"items"];
    
    NSDictionary *item = items[indexPath.row];
    
    if([item[@"type"] isEqualToString:@"url"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:item[@"url"]] options:@{} completionHandler:nil];    }
}
@end
