//
//  ViewController.m
//  09表视图分组模式
//
//  Created by CORYIL on 16/4/22.
//  Copyright © 2016年 徐锐. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *delete;

@property (weak, nonatomic) IBOutlet UISwitch *mutable;

@property (weak, nonatomic) IBOutlet UISwitch *switchUI;

@property (weak, nonatomic) IBOutlet UITextField *tf;

@property (nonatomic,strong)NSMutableArray *datalist;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取所有字体名称
    _datalist = [NSMutableArray arrayWithArray:[UIFont familyNames]];
    
    _tableView.dataSource = self;
    
    _tableView.delegate = self;
   
    _tf.hidden = YES;
    
    //允许 在编辑模式中多选
//    _tableView.allowsMultipleSelectionDuringEditing = NO;
    
}


//多选删除
- (IBAction)delete:(UIButton *)sender {
    
    //0.获取所选择的所有单元格的索引
    NSArray *selectIPS = [_tableView indexPathsForSelectedRows];
    
    //1.删除数据 -> 倒序删除
    for (NSInteger i = selectIPS.count-1; i>=0; i--) {
        
        NSIndexPath *ip = [selectIPS objectAtIndex:i];
        
        [_datalist removeObjectAtIndex:ip.row];
    }
    
    //2.删除单元格
    [_tableView deleteRowsAtIndexPaths:selectIPS withRowAnimation:UITableViewRowAnimationFade];
    
}


- (IBAction)editAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    //编辑模式中 允许多选
    _tableView.allowsMultipleSelectionDuringEditing = _mutable.on;

    //切换编辑模式
//    _tableView.editing = sender.selected;
    
    //切换编辑模式 附动画
    [_tableView setEditing:sender.selected animated:YES];
    
    
    //编辑模式中 输入框显示 否则隐藏
    _tf.hidden = !_tableView.editing;
    
    //编辑模式中 开关 不可用
    _switchUI.enabled = !_tableView.editing;
    
    _mutable.enabled = !_tableView.editing;
}

#pragma mark --UITableViewDataSource

//是否开启单元格的移动权限

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{

    return YES;

}


//是否开启单元格的编辑权限
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row == 0) {
        return NO;
    }
    
    return YES;

}

//指定行的编辑模式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //如果开关打开 则进入插入模式
    if (_switchUI.on == YES) {
        
        return UITableViewCellEditingStyleInsert;

    }
    
    //UITableViewCellEditingStyleDelete
    return UITableViewCellEditingStyleDelete;
    
}


//编辑模式: 点击的事件 1.删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    /**
     typedef NS_ENUM(NSInteger, UITableViewCellEditingStyle) {
     UITableViewCellEditingStyleNone,
     UITableViewCellEditingStyleDelete,
     UITableViewCellEditingStyleInsert
     };
     */
    
    
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        
        //当输入框内容为空时不添加
        if (_tf.text.length == 0) {
            
            return;
        }
        
        //0.获取row和内容

        NSString *content = _tf.text;
        
        
        //1.插入数据
        //插入的数据在下面
        //NSInteger row = indexPath.row+1;
        [_datalist insertObject:content atIndex:indexPath.row];
        
        //2.插入单元格
        //插入的数据在下面
        //NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row +1 inSection:0];
        
        [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //1.删除数据
        [_datalist removeObjectAtIndex:indexPath.row];
        
        //2.删除单元格
        
        /**
         *  
         typedef NS_ENUM(NSInteger, UITableViewRowAnimation) {
         UITableViewRowAnimationFade,
         UITableViewRowAnimationRight,           // slide in from right (or out to right)
         UITableViewRowAnimationLeft,
         UITableViewRowAnimationTop,
         UITableViewRowAnimationBottom,
         UITableViewRowAnimationNone,            // available in iOS 3.0
         UITableViewRowAnimationMiddle,          // available in iOS 3.2.  attempts to keep cell centered in the space it will/did occupy
         UITableViewRowAnimationAutomatic = 100  // available in iOS 5.0.  chooses an appropriate animation style for you
         };
         */
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
   }
}

//编辑模式: 移动的事件
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    //NSLog(@"起点索引:%@ 终点索引:%@",sourceIndexPath,destinationIndexPath);
     NSLog(@"起点索引:%ld 终点索引:%ld",sourceIndexPath.row,destinationIndexPath.row);
    //1⃣️从上方向下移动
    if (sourceIndexPath.row < destinationIndexPath.row) {
        
        //1.通过SIP获取要移动的元素
        id sid = _datalist[sourceIndexPath.row];
        
        //2.将元素插入到DIP+1的位置
        [_datalist insertObject:sid atIndex:destinationIndexPath.row+1];
        
        //3.删除SIP的元素
        [_datalist removeObjectAtIndex:sourceIndexPath.row];
        
    }
    
    //2⃣️自下方向上移动
    if (sourceIndexPath.row > destinationIndexPath.row) {
        
        //1.通过SIP获取要移动的元素
        id sid = _datalist[sourceIndexPath.row];
        
        //2.将元素插入到DIP的位置
        [_datalist insertObject:sid atIndex:destinationIndexPath.row];
        
        //3.删除SIP+1的元素
        [_datalist removeObjectAtIndex:sourceIndexPath.row];
        
        
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _datalist.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identy = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identy];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
    }
    
    cell.textLabel.text = [_datalist objectAtIndex:indexPath.row];
    
    return cell;
    
}



@end
