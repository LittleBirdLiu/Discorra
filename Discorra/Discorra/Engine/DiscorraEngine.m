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

#import "DiscorraEngine.h"

@implementation DiscorraEngine

//This is where the articles in .md format will go
static const NSString* articlesFolder = @"articles/";
//The output folder
static const NSString* buildFolder = @"build/";
//The ressources folder (content will be copied as-is to build/res/)
static const NSString* ressourcesFolder = @"res/";
//The template folder
static const NSString* templatesFolder = @"tpl/";
//Article template
static const NSString* templateArticle = @"article.mustache";
//Index (article list) template
static const NSString* templateIndex = @"index.mustache";
//Base template (can be overriden in any sub template by putting a <!-- Discorra:OverrideBaseTemplate -->
static const NSString* templateBase = @"base.mustache";

- (id)initWithPath:(NSString*)path {
    self = [super init];
    if(self != nil) {
        targetPath = [NSString stringWithString:path];
    }
    return self;
}

- (bool)checkIfValidFolder {
    NSArray *folders = [NSArray arrayWithObjects:articlesFolder,
                                                buildFolder,
                                                ressourcesFolder,
                                                templatesFolder,
                        nil];
}

@end
