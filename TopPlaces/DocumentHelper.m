//
//  DocumentHelper.m
//  TopPlaces
//
//  Created by kiddjacky on 11/28/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "DocumentHelper.h"

@implementation DocumentHelper

+(void)useDocumentWithOperation:(void (^)(UIManagedDocument *document, BOOL success))operation
{
    DocumentHelper *dh = [DocumentHelper sharedDocumentHelper];
    [dh useDocumentWithOperation:operation];
}

+ (DocumentHelper *)sharedDocumentHelper
{
    static dispatch_once_t pred = 0;
    __strong static DocumentHelper *_sharedDocumentHelper = nil;
    dispatch_once(&pred, ^{
        _sharedDocumentHelper = [[self alloc] init];
    });
    return _sharedDocumentHelper;
}

#define DOCUMENT_NOT_READY_RETRY_TIMEOUT 1.0
-(void)useDocumentWithOperation:(void (^)(UIManagedDocument *document, BOOL success))operation
{
    UIManagedDocument *document = self.document;
    NSLog(@"in document");
    if ([self checkAndSetPreparingDocument]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(useDocumentWithOperation:)
                       withObject:operation
                       afterDelay:DOCUMENT_NOT_READY_RETRY_TIMEOUT];
        });
        NSLog(@"prepare");
    } else {
        NSLog(@"else");
        if(![[NSFileManager defaultManager] fileExistsAtPath:[document.fileURL path]]) {
            NSLog(@"success is unknown");
            [document saveToURL:document.fileURL
               forSaveOperation:UIDocumentSaveForCreating
              completionHandler:^(BOOL success) {
                  NSLog(@"success is %s", success ? "true" : "false");
                  operation(document, success);
                  self.preparingDocument = NO;
              }];
        } else if (document.documentState == UIDocumentStateClosed) {
            [document openWithCompletionHandler:^(BOOL success) {
                operation(document, success);
                self.preparingDocument = NO;
            }];
        } else {
            BOOL success = YES;
            operation(document, success);
            self.preparingDocument = NO;
            NSLog(@"set success to yes");
        }
    }
}


-(BOOL) checkAndSetPreparingDocument
{
    static  dispatch_queue_t queue;
    if (!queue) {
        queue = dispatch_queue_create("Flickr Helper Queue", NULL);
    }
    __block BOOL result = NO;
    dispatch_sync(queue, ^{
        if (!_preparingDocument) {
            _preparingDocument = YES;
        } else {
            result = YES;
        }
    });
    return result;
}

#define DATABASE_DOCUMENT_NAME @"TopRegions"
-(UIManagedDocument *) document {
    if (!_document) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                             inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:DATABASE_DOCUMENT_NAME];
        _document = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    return _document;
}



@end
