/*
 * Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MainWindowController.h"

@implementation MainWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindowController"];
    return self;
}

- (id)initWithBlogPath:(NSString *) path
{
    self = [super initWithWindowNibName:@"MainWindowController"];
    if(self != nil) {
        //tableData = [self getFakeArticles];
        tableData = [NSArray array];
        blogPath = [NSString stringWithString:path];
        engine = [[DiscorraEngine alloc] initWithPath:blogPath];
    }
    return self;
}

- (IBAction)build:(id)sender {
    [self build];
}

- (IBAction)addArticle:(id)sender {
    [self.createArticleWindow clearFields];
    [NSApp beginSheet: self.createArticleWindow
       modalForWindow: self.window
        modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
}

- (IBAction)refresh:(id)sender {
    [self refreshData];
}

- (NSArray*) getFakeArticles {
    Article* a1 = [[Article alloc] init];
    a1.date = [NSDate dateWithString:@"2012-07-24 10:45:32 +0100"];
    a1.summary = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";
    a1.title = @"Cher lorem";
    Article* a2 = [[Article alloc] init];
    a2.date = [NSDate date];
    a2.summary = @"Look, just because I don't be givin' no man a foot massage don't make it right for Marsellus to throw Antwone into a glass motherfuckin' house, fuckin' up the way the nigger talks. Motherfucker do that shit to me, he better paralyze my ass, 'cause I'll kill the motherfucker, know what I'm sayin'?";
    a2.title = @"Samuel L. ipsum";
    return [NSArray arrayWithObjects:a2, a1, nil];
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(editMenuPressed:)];
    [self.inderterminateProgress stopAnimation:self];
    [self.webView setMaintainsBackForwardList:NO];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    //Apply some custom style to the text
    [[self.statusbarText cell] setBackgroundStyle:NSBackgroundStyleRaised];
    [[self.previewText cell] setBackgroundStyle:NSBackgroundStyleRaised];
    if(![engine checkIfPathContainsBlog]) {
        //No animation if we execute this now
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(pathDoesNotContainBlog)
                                       userInfo:nil repeats:NO];
    }
    [self refreshData];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [((AppDelegate*)[NSApp delegate]) removeWindowController:self];
}

- (DiscorraEngine*)engine {
    return engine;
}

#pragma mark Alert callbacks

- (void)alertDidEnd:(NSAlert*)alert returnCode:(int)button contextInfo:(void*)context {
    switch (button) {
        case NSAlertFirstButtonReturn:
            [[self window] close];
            [(AppDelegate*)[NSApp delegate] openDocument:nil];
            break;
        default:
            if(![engine createSkeleton] || ![engine checkIfPathContainsBlog]) {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:NSLocalizedString(@"Select another folder", @"Select another blog folder")];
                [alert addButtonWithTitle:NSLocalizedString(@"Try again", @"Try again")];
                [alert setMessageText:NSLocalizedString(@"Blog creation failed", @"Blog creation failed")];
                [alert setInformativeText:NSLocalizedString(@"The blog skeleton could not be created in the specified folder. Please check that you have write rights and that the disk is not full, then please try again.", @"Description of why blog creation failed")];
                [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
            } else {
                [self refreshData];
            }
            break;
    }
}

- (void)buildSuccessAlertDidEnd:(NSAlert*)alert returnCode:(int)button contextInfo:(void*)context {
    switch (button) {
        case NSAlertFirstButtonReturn:
            [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:[engine buildFolderPath]]];
            break;
        default:
            break;
    }
}

#pragma mark NSTableViewDatasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return tableData.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ArticleSummaryTableCellView *result = [tableView makeViewWithIdentifier:@"Cell" owner:self];
    [result refreshWithArticle:[tableData objectAtIndex:row]];
    return result;
}

#pragma mark IBActions

- (IBAction)refreshButtonPressed:(id)sender {
    [self refreshData];
}

- (IBAction)editMenuPressed:(id)sender {
    if(self.tableView.clickedRow < 0)
        return;
    [self editArticle:[tableData objectAtIndex:self.tableView.clickedRow]];
}

- (IBAction)deleteMenuPressed:(id)sender {
    if(self.tableView.clickedRow < 0)
        return;
    [self deleteArticle:[tableData objectAtIndex:self.tableView.clickedRow]];
}

- (IBAction)globalArticleNew:(id)sender {
    [self addArticle:sender];
}

- (IBAction)globalArticleEdit:(id)sender {
    if(self.tableView.selectedRow < 0)
        return;
    [self editArticle:[tableData objectAtIndex:self.tableView.selectedRow]];
}

- (IBAction)globalArticleDelete:(id)sender {
    if(self.tableView.selectedRow < 0)
        return;
    [self deleteArticle:[tableData objectAtIndex:self.tableView.selectedRow]];
}

- (IBAction)globalBlogBuild:(id)sender {
    [self build];
}

- (IBAction)globalBlogRefresh:(id)sender {
    [self refreshData];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if(self.tableView.selectedRow < 0) {
        [self.webView setHidden:YES];
        [self.webView setMainFrameURL:@"about:blank"];
        self.previewText.stringValue = NSLocalizedString(@"Select an article on the left to preview it", nil);
    } else {
        NSString *articleBuiltPath = [engine builtArticlePath:[tableData objectAtIndex:self.tableView.selectedRow]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = NO;
        if(![fileManager fileExistsAtPath:articleBuiltPath isDirectory:&isDir] || isDir) {
            [self.webView setHidden:YES];
            [self.webView setMainFrameURL:@"about:blank"];
            self.previewText.stringValue = NSLocalizedString(@"The selected article can not be previewed. Did you build the blog ?", nil);
        } else {
            [self.webView setHidden:NO];
            //Append a random number to bypass the stupid WebKit caching
            [self.webView setMainFrameURL:[NSString stringWithFormat:@"file://%@?random=%d", articleBuiltPath, arc4random()]];
        }
    }
}

#pragma mark Helpers

- (void)build {
    [self.inderterminateProgress startAnimation:self];
    [self.buildButton setEnabled:NO];
    [self refreshData];
    NSDate *start = [NSDate date];
    bool buildResult = [engine build];
    NSLog(@"Build time : %f", -[start timeIntervalSinceNow]);
    if(!buildResult) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
        [alert setMessageText:NSLocalizedString(@"Build error", nil)];
        [alert setInformativeText:NSLocalizedString(@"The blog could not be built. Please check that you have write rights and that the disk is not full, then please try again.", @"Description of why blog build failed")];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil  contextInfo:nil];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"Open in Finder", @"Show in Finder")];
        [alert addButtonWithTitle:NSLocalizedString(@"No", @"No")];
        [alert setMessageText:NSLocalizedString(@"Build successful", nil)];
        [alert setInformativeText:NSLocalizedString(@"Do you want to show the output in Finder ?", nil)];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(buildSuccessAlertDidEnd:returnCode:contextInfo:)  contextInfo:nil];
    }
    [self.inderterminateProgress stopAnimation:self];
    [self.buildButton setEnabled:YES];
}

- (void)pathDoesNotContainBlog {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:NSLocalizedString(@"Select another folder", @"Select another blog folder")];
    [alert addButtonWithTitle:NSLocalizedString(@"Create a blog here", @"Create a blog")];
    [alert setMessageText:NSLocalizedString(@"Create a blog in this directory ?", @"Ask for wether or not a blog should be created here")];
    [alert setInformativeText:NSLocalizedString(@"The selected folder is not a blog. Do you want to create a blog here or open another folder ?", @"Description of why a blog might be created (invalid folder)")];
    [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)refreshData {
    [self.webView setHidden:YES];
    [self.webView setMainFrameURL:@"about:blank"];
    self.previewText.stringValue = NSLocalizedString(@"Select an article on the left to preview it", nil);
    tableData = [engine articles];
    [[self tableView] reloadData];
    NSString *countFormat;
    if([tableData count] == 1) {
        countFormat = NSLocalizedString(@"%d article", @"Article count printf format");
    } else {
        countFormat = NSLocalizedString(@"%d articles", @"Articles count printf format (plural)");
    }
    [self statusbarText].stringValue = [NSString stringWithFormat:countFormat, [tableData count]];
}

- (void)editArticle:(Article*)article {
    [[NSWorkspace sharedWorkspace] openFile:article.path];
}

- (void)deleteArticle:(Article*)article {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if(![fileManager trashItemAtURL:[NSURL fileURLWithPath:article.path] resultingItemURL:nil error:&error]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
        [alert setMessageText:NSLocalizedString(@"Error while deleting article", nil)];
        [alert setInformativeText:[error localizedDescription]];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
    [self refreshData];
}

#pragma mark Sheet callbacks

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
    if(returnCode > 0) {
        [self refreshData];
        if([tableData count] != 0 && self.createArticleWindow.openAfterCreation.state == NSOnState)
                [self editArticle:[tableData objectAtIndex:0]];
    }
}

@end

@implementation MainWindowNewArticlePanel

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)clearFields {
    self.articleName.stringValue = @"Article";
    [self setFilenameFromName];
    [self.openAfterCreation setState:NSOnState];
}

- (void)setFilenameFromName {
    if(dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    //We compute the date at each character because the date might change while the user types
    self.articleFilename.stringValue = [NSString stringWithFormat:@"%@_%@.md",
                                        [dateFormatter stringFromDate:[NSDate date]],
                                        [self.articleName.stringValue.lowercaseString  sanitizedFileNameString]];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    if ([notification object] == self.articleName) {
        [self setFilenameFromName];
    }
    [self.createButton setEnabled:(self.articleName.stringValue.length > 0 && self.articleFilename.stringValue.length > 0
                                   && [self.articleFilename.stringValue rangeOfString:@"/"].location == NSNotFound
                                   && [self.articleFilename.stringValue rangeOfString:@":"].location == NSNotFound)];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [NSApp endSheet:self returnCode:0];
}

- (IBAction)createButtonPressed:(id)sender {
    if(self.articleName.stringValue.length == 0 || self.articleFilename.stringValue.length == 0
       || [self.articleFilename.stringValue rangeOfString:@"/"].location != NSNotFound
       || [self.articleFilename.stringValue rangeOfString:@":"].location != NSNotFound) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
        [alert setMessageText:NSLocalizedString(@"Could not create the article", nil)];
        [alert setInformativeText:NSLocalizedString(@"Invalid name or filename (/ and : are forbidden in filenames)", nil)];
        [alert beginSheetModalForWindow:self modalDelegate:self didEndSelector:nil contextInfo:nil];
    } else {
        if(![[self.mainWindowController engine] newArticleWithTitle:self.articleName.stringValue andFilename:self.articleFilename.stringValue]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
            [alert setMessageText:NSLocalizedString(@"Could not create the article", nil)];
            [alert setInformativeText:NSLocalizedString(@"Unknown error while writing the article file. Check that you volume isn't full and that you have write privileges on it.", nil)];
            [alert beginSheetModalForWindow:self modalDelegate:self didEndSelector:nil contextInfo:nil];
        } else {
            [NSApp endSheet:self returnCode:1];
        }
    }
}

@end
