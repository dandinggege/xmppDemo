//
//  MessageTableViewController.m
//  
//
//  Created by 张广洋 on 15/11/15.
//
//

#import "MessageTableViewController.h"

#import "XMPPManager.h"

#import "MessageModel.h"

#import "MessageTableViewCell.h"

#import "MyUIHeader.h"

@interface MessageTableViewController ()
<UITextFieldDelegate>
{
    NSMutableArray * _messageArr;
    UITextField * _msgTF;
    //输入框试图，包括一个文本输入框和一个发送按钮
    UIView * _inputView;
}
@end

@implementation MessageTableViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    _messageArr=[[NSMutableArray alloc]init];
    //
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveMessage:) name:RECEIVE_MESSAGE object:nil];
    //监听键盘即将出现的广播
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    //监听键盘即将出现的广播
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardDidChangeFrameNotification object:nil];
    //即将消失
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardDidHiden:) name:UIKeyboardDidHideNotification object:nil];
    //
    [self createInputView];
}
                                                        

-(void)createInputView{
    //输入视图
    _inputView=[[UIView alloc]initWithFrame:CGRectMake(0, kHeight-45, kWidth, 45)];
    [[UIApplication sharedApplication].keyWindow addSubview:_inputView];
    _inputView.layer.cornerRadius=3;
    _inputView.clipsToBounds=YES;
    _inputView.backgroundColor=[UIColor grayColor];
    //输入文本框
    _msgTF=[[UITextField alloc]initWithFrame:CGRectMake(5, 2, kWidth-62, 40)];
    _msgTF.borderStyle=UITextBorderStyleRoundedRect;
    _msgTF.delegate=self;
    _msgTF.returnKeyType=UIReturnKeySend;
    _msgTF.backgroundColor=[UIColor yellowColor];
    [_inputView addSubview:_msgTF];
    //发送按钮
    UIButton * oneBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    oneBtn.frame=CGRectMake(kWidth-55, 2, 50, 40);
    [oneBtn setTitle:@"发送" forState:0];
    [_inputView addSubview:oneBtn];
    oneBtn.backgroundColor=[UIColor brownColor];
    [oneBtn addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [oneBtn setTitleColor:[UIColor whiteColor] forState:0];
    oneBtn.layer.cornerRadius=5;
    oneBtn.clipsToBounds=YES;
}

-(void)sendBtnClicked{
    [self sendMessage:@""];
    _msgTF.text=@"";
}

-(void)didReceiveMessage:(NSNotification *)ntfs{
    [_messageArr addObject:ntfs.object];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messageArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCellId" forIndexPath:indexPath];
    MessageModel * msgModel=_messageArr[indexPath.row];
    if ([msgModel.fromJid containsString:[XMPPManager manager].userName]) {
        cell.label.textAlignment=NSTextAlignmentLeft;
        cell.label.textColor=[UIColor blueColor];
        cell.label.text=[NSString stringWithFormat:@"%@:%@",[XMPPManager manager].userName,msgModel.message];
    }else{
        NSRange range=[self.title rangeOfString:@"@"];
        cell.label.textAlignment=NSTextAlignmentRight;
        cell.label.textColor=[UIColor greenColor];
        cell.label.text=[NSString stringWithFormat:@"%@:%@",msgModel.message,[self.title substringToIndex:range.location]];
    }
    return cell;
}


-(void)viewWillDisappear:(BOOL)animated{
    [_inputView removeFromSuperview];
    [_msgTF resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendMessage:nil];
    _msgTF.text=@"";
    return YES;
}

#pragma mark - 键盘广播 -

-(void)keyBoardDidShow:(NSNotification *)notf{
    NSDictionary* info = [notf userInfo];
    //kbSize即為鍵盤尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到鍵盤的高度
    NSLog(@"hight_hitht:%f",kbSize.height);
    [self inputViewMoveTo:kHeight-45-kbSize.height];
}

-(void)keyBoardDidHiden:(NSNotification *)notf{
    NSDictionary* info = [notf userInfo];
    //kbSize即為鍵盤尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到鍵盤的高度
    NSLog(@"hight_hitht:%f",kbSize.height);
    [self inputViewMoveTo:kHeight-45];
}

#pragma mark - 其他方法 -

-(void)inputViewMoveTo:(CGFloat)height{
    [UIView animateWithDuration:0.4 animations:^{
        _inputView.frame=CGRectMake(0, height, kWidth, 45);
    }];
}

-(void)sendMessage:(NSString *)msg{
    if (_msgTF.text==nil || [_msgTF.text isEqualToString:@""]) {
        return;
    }
    MessageModel * model=[[MessageModel alloc]init];
    model.message=_msgTF.text;
    model.fromJid=[NSString stringWithFormat:@"%@@%@",[XMPPManager manager].userName,[XMPPManager manager].doMainName];
    model.toJid=self.title  ;
    [[XMPPManager manager]sendMessage:model];
    [_messageArr addObject:model];
    [self.tableView reloadData];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
