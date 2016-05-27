//
//  InitialViewController.m
//  NSRMapBoxTest
//
//  Created by Nasirahmed on 27/05/16.
//  Copyright © 2016 Nasir. All rights reserved.
//

#import "InitialViewController.h"
#import "ViewController.h"
@interface InitialViewController ()

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)navigateToMapBoxViewController:(UIButton*)sender{
    ViewController* mapBoxVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    
    [self.navigationController pushViewController:mapBoxVC animated:YES];
}

@end
