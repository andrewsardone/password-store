/*
 * AppController.j
 * PasswordStore
 *
 * Created by You on November 4, 2009.
 * Copyright 2009, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "PSWebLogin.j"


@implementation AppController : CPObject
{
    CPArray     webLogins;
    CPTableView tableView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];

    [self getWebLogins];
    // create a CPScrollView that will contain the CPTableview
    var scrollView = [[CPScrollView alloc] initWithFrame:[contentView bounds]];
    [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    
    // create the CPTableView
    tableView = [[CPTableView alloc] initWithFrame:[scrollView bounds]];
    [tableView setDataSource:self];
    [tableView setUsesAlternatingRowBackgroundColors:YES];
    
    // define the header color
    var headerColor = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"button-bezel-center.png"]]];
    
    [[tableView cornerView] setBackgroundColor:headerColor];
    
    // add the URL column
    
    var column = [[CPTableColumn alloc] initWithIdentifier:@"URL"];
    [[column headerView] setStringValue:"URL"];
    [[column headerView] setBackgroundColor:headerColor];
    [column setWidth:CGRectGetWidth([scrollView bounds])*0.33];
    [tableView addTableColumn:column];
    
    // add the Username column
    var column = [[CPTableColumn alloc] initWithIdentifier:@"Username"];
    [[column headerView] setStringValue:"Username"];
    [[column headerView] setBackgroundColor:headerColor];
    [column setWidth:CGRectGetWidth([scrollView bounds])*0.34];
    [tableView addTableColumn:column];
    
    // add the Password column
    var column = [[CPTableColumn alloc] initWithIdentifier:@"Password"];
    [[column headerView] setStringValue:"Password"];
    [[column headerView] setBackgroundColor:headerColor];
    [column setWidth:CGRectGetWidth([scrollView bounds])*0.34];
    [tableView addTableColumn:column];
    
    // add the 
    
    [scrollView setDocumentView:tableView];

    [contentView addSubview:scrollView];
    [theWindow orderFront:self];

    [CPMenu setMenuBarVisible:YES];
}

// ---
// CPTableView datasource methods
- (int)numberOfRowsInTableView:(CPTableView)tableView
{
   return [webLogins count];
}

- (id)tableView:(CPTableView)tableView objectValueForTableColumn:(CPTableColumn)tableColumn row:(int)row
{
    if ([tableColumn identifier] === @"URL")
        return @"url #" + row;
    else if ([tableColumn identifier] === @"Username")
        return @"username #" + row;
    else
        return @"password #" + row;
}

// ---
// Connection to password-store
- (void)getWebLogins
{
    var request = [CPURLRequest requestWithURL:"http://localhost:9393/weblogins.json?"];
    // twitterConnection = [CPJSONPConnection connectionWithRequest:request callback:"callback" delegate:self];
    var connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(CPJSONPConnection)aConnection didReceiveData:(CPString)data
{
    var result = CPJSObjectCreateWithJSON(data);
    webLogins = [PSWebLogin initWithJSONObjects:result];
    [tableView reloadData];
}

- (void)connection:(CPJSONPConnection)aConnection didFailWithError:(CPString)error
{
    alert(error);
}

@end
