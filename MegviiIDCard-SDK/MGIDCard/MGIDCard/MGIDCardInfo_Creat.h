//
//  MGIDCardInfo_Creat.h
//  MGIDCard
//
//  Created by 张英堂 on 16/9/8.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGIDCardInfo.h"

#import "MG_Common.h"
#import "MG_IDCard.h"


@interface MGIDCardInfo ()

- (void)setCardFrame:(MG_IDC_POLYGON )card;
- (void)setShadows:(MG_IDC_POLYGONS )shadows;
- (void)setFaculae:(MG_IDC_POLYGONS )faculae;

@end
