//
//  ViewController.m
//  UITableViewCellHeightCache
//
//  Created by 三只鸟 on 2018/3/5.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "UITableView+HeightCache.h"



@interface ViewController ()

@property (nonatomic, strong) NSMutableArray <NSMutableArray *> * data;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UITableView cacheEnabled:YES];
    UIBarButtonItem * insertSection = [[UIBarButtonItem alloc]initWithTitle:@"添加组" style:UIBarButtonItemStyleDone target:self action:@selector(see_insertSection:)];
    UIBarButtonItem * deleteSection = [[UIBarButtonItem alloc]initWithTitle:@"删除组" style:UIBarButtonItemStyleDone target:self action:@selector(see_deleteSection:)];
    UIBarButtonItem * moveSection = [[UIBarButtonItem alloc]initWithTitle:@"移动组" style:UIBarButtonItemStyleDone target:self action:@selector(see_moveSection:)];
    UIBarButtonItem * reloadSection = [[UIBarButtonItem alloc]initWithTitle:@"刷新组" style:UIBarButtonItemStyleDone target:self action:@selector(see_reloadSection:)];
    UIBarButtonItem * editAction = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(see_editAction:)];
    self.navigationItem.rightBarButtonItems = @[insertSection,deleteSection,moveSection,reloadSection,editAction];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TableViewCell class]) bundle:nil] forCellReuseIdentifier:@"cell"];
    
}

- (void)dealloc {
    NSLog(@"dealloc");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    [cell configureWithText:self.data[indexPath.section][indexPath.row]];
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString * data = [self.data[sourceIndexPath.section] objectAtIndex:sourceIndexPath.row];
    [self.data[sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
    [self.data[destinationIndexPath.section] insertObject:data atIndex:destinationIndexPath.row];
    [tableView.heightCache moveRow:sourceIndexPath.row inSection:sourceIndexPath.section toRow:destinationIndexPath.row inSection:destinationIndexPath.section];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction * deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf.tableView beginUpdates];
        [weakSelf.data[indexPath.section] removeObjectAtIndex:indexPath.row];
        [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [weakSelf.tableView endUpdates];
    }];
    UITableViewRowAction * insertAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"插入" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf.tableView beginUpdates];
        [weakSelf.data[indexPath.section] insertObject:[weakSelf see_createData] atIndex:indexPath.row + 1];
        [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        [weakSelf.tableView endUpdates];
    }];
    insertAction.backgroundColor = [UIColor blueColor];
    UITableViewRowAction * reloadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"刷新" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf.tableView beginUpdates];
        [weakSelf.data[indexPath.section] replaceObjectAtIndex:indexPath.row withObject:[weakSelf see_createData]];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        [weakSelf.tableView endUpdates];
    }];
    reloadAction.backgroundColor = [UIColor grayColor];
    return @[deleteAction,insertAction,reloadAction];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView heightForCellWithIdentifier:@"cell" indexPath:indexPath configuration:^(UITableViewCell *cell) {
        [(TableViewCell *)cell configureWithText:self.data[indexPath.section][indexPath.row]];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@",indexPath);
    ViewController * vc = [[ViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)see_insertSection:(UIButton *)sender {
    sender.enabled = NO;
    NSMutableArray * data = [NSMutableArray array];
    NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSet];
    NSInteger sectionCount = arc4random_uniform(3) + 1;
    for (NSInteger j = 0; j < sectionCount; j++) {
        NSMutableArray * arr = [NSMutableArray array];
        NSInteger rowCount = arc4random_uniform(5) + 1;
        for (NSInteger i = 0; i < rowCount; i++) {
            [arr addObject:[self see_createData]];
        }
        [data addObject:arr];
        NSInteger index = arc4random_uniform((uint32_t)(_data.count + sectionCount));
        while ([indexSet containsIndex:index]) {
            index = arc4random_uniform((uint32_t)(_data.count + sectionCount));
        }
        [indexSet addIndex:index];
    }
    [self.tableView beginUpdates];
    [self.data insertObjects:data atIndexes:indexSet];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    sender.enabled = YES;
}

- (void)see_deleteSection:(UIButton *)sender {
    if (self.data.count == 0) return;
    sender.enabled = NO;
    NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSet];
    NSInteger deleteCount = arc4random_uniform((uint32_t)self.data.count) + 1;
    for (NSInteger i = 0; i < deleteCount; i++) {
        NSInteger index = arc4random_uniform((uint32_t)self.data.count);
        while ([indexSet containsIndex:index]) {
            index = arc4random_uniform((uint32_t)self.data.count);
        }
        [indexSet addIndex:index];
    }
    
    [self.tableView beginUpdates];
    [self.data removeObjectsAtIndexes:indexSet];
    [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    sender.enabled = YES;
}

- (NSString *)see_createData {
    NSMutableString * string = [NSMutableString string];
    NSInteger random = arc4random_uniform(30) + 1;
    for (NSInteger j =  0; j < random; j++) {
        [string appendFormat:@"%zd\n",j];
    }
    [string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
    return string.copy;
}

- (void)see_moveSection:(UIButton *)sender {
    if (self.data.count <= 1) return;
    sender.enabled = NO;
    NSInteger from = [self.tableView indexPathsForVisibleRows].firstObject.section;
    NSInteger to;
    do {
        to = arc4random_uniform((uint32_t)self.data.count);
    }while (to == from);
    [self.tableView beginUpdates];
    NSMutableArray * target = [self.data objectAtIndex:from];
    [self.data removeObject:target];
    [self.data insertObject:target atIndex:to];
    [self.tableView moveSection:from toSection:to];
    [self.tableView endUpdates];
    sender.enabled = YES;
}

- (void)see_reloadSection:(UIButton *)sender {
    if (self.data.count == 0) return;
    sender.enabled = NO;
    
    NSMutableArray * data = [NSMutableArray array];
    NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSet];
    NSInteger sectionCount = arc4random_uniform((uint32_t)self.data.count);
    for (NSInteger j = 0; j <= sectionCount; j++) {
        NSMutableArray * arr = [NSMutableArray array];
        NSInteger rowCount = arc4random_uniform(5) + 1;
        for (NSInteger i = 0; i < rowCount; i++) {
            [arr addObject:[self see_createData]];
        }
        [data addObject:arr];
        NSInteger index = arc4random_uniform((uint32_t)(_data.count));
        while ([indexSet containsIndex:index]) {
            index = arc4random_uniform((uint32_t)(_data.count));
        }
        [indexSet addIndex:index];
    }
    
    
    
    [self.tableView beginUpdates];
    [self.data removeObjectsAtIndexes:indexSet];
    [self.data insertObjects:data atIndexes:indexSet];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    sender.enabled = YES;
    
}

- (void)see_editAction:(UIButton *)sender {
    self.tableView.editing = !self.tableView.editing;
}

- (NSMutableArray<NSMutableArray *> *)data {
    if (_data == nil) {
        _data = [NSMutableArray <NSMutableArray *> array];
        NSMutableArray * array = [NSMutableArray array];
        for (NSInteger i = 0; i < 1000; i++) {
            [array addObject:[self see_createData]];
        }
        [_data addObject:array];
    }
    return _data;
}


@end
