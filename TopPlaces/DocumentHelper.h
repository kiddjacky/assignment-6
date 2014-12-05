//
//  DocumentHelper.h
//  TopPlaces
//
//  Created by kiddjacky on 11/28/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentHelper : NSObject
+(void)useDocumentWithOperation:(void (^)(UIManagedDocument *document, BOOL success))operation;
@property (nonatomic, strong) UIManagedDocument *document;
@property (nonatomic) BOOL preparingDocument;

@end
