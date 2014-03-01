//
//  NavigationView.h
//  ExpansionTableView
//
//  Created by user on 13-6-19.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    NavigationMode = 0,
    CustomCellMode
}CellModes;

@interface NavigationView : UITableViewCell

@property (nonatomic) NSUInteger cellMode;

@end
