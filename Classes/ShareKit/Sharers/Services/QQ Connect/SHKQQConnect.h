//
//  SHKQQConnect.h
//  ShareKitDemo
//
//  Created by Glare on 13-1-9.
//  Copyright (c) 2013年 Glare. All rights reserved.
//

#import "SHKSharer.h"
#import "TencentOAuth.h"
#import "TencentRequest.h"

@interface SHKQQConnect : SHKSharer
<TencentSessionDelegate, TencentRequestDelegate>

@end
