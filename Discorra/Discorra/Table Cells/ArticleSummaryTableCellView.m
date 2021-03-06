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


#import "ArticleSummaryTableCellView.h"

@implementation ArticleSummaryTableCellView
@synthesize summary;
@synthesize date;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    
    return self;
}

- (void)refreshWithArticle:(Article *)article {
    self.textField.stringValue = article.title;
    self.summary.stringValue = article.summary;
    if(dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    }
    self.date.stringValue = [dateFormatter stringFromDate:article.date];
}

- (void)awakeFromNib {
    summaryColor = self.summary.textColor;
    dateColor = self.date.textColor;
}

- (void)setBackgroundStyle:(NSBackgroundStyle)style
{
    [super setBackgroundStyle:style];
    
    switch (style) {
        case NSBackgroundStyleLight:
            [self.summary setTextColor:summaryColor];
            [self.date setTextColor:dateColor];
            break;
        case NSBackgroundStyleDark:
        default:
            [self.summary setTextColor:[NSColor whiteColor]];
            [self.date setTextColor:[NSColor whiteColor]];
            break;
    }
}

@end
