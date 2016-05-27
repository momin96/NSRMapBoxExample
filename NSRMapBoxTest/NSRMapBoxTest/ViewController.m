//
//  ViewController.m
//  NSRMapBoxTest
//
//  Created by Nasirahmed on 25/05/16.
//  Copyright © 2016 Nasir. All rights reserved.
//

#import "ViewController.h"
#import "CRLoadingView.h"
@import Mapbox;
@interface ViewController ()
@property (weak, nonatomic) IBOutlet MGLMapView *mapView;
@property (nonatomic) UIProgressView *progressView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSMutableArray *annotationList = [NSMutableArray new];
    
    MGLPointAnnotation* point = [[MGLPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(12.937548,77.5790818);
    point.title = @"created";
    [annotationList addObject:point];
    
    
    MGLPointAnnotation* secondPoint = [[MGLPointAnnotation alloc] init];
    secondPoint.coordinate = CLLocationCoordinate2DMake(12.9402157, 77.5757746);
    secondPoint.title = @"started";
    
    [annotationList addObject:secondPoint];
    
    //    [CRLoadingView loadingViewInView:self.mapView Title:@"Loading"];
    
    MGLCoordinateBounds bounds = MGLCoordinateBoundsMake(CLLocationCoordinate2DMake(12.931009593713711, 77.572613561808339),
                                                         CLLocationCoordinate2DMake(12.946548255058971,77.581581762621909));
    [self.mapView setVisibleCoordinateBounds:bounds];
    [self.mapView addAnnotations:annotationList];
    
    UITapGestureRecognizer* tapToCreateNewTicket = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createNewTicket:)];
    [self.mapView addGestureRecognizer:tapToCreateNewTicket];
    
    UIBarButtonItem* offlineButton = [[UIBarButtonItem alloc] initWithTitle:@"Download Offline Data"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(downloadDataForOfflineUsage)];
    
    self.navigationItem.rightBarButtonItem = offlineButton;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

#pragma mark -- Helper Method

-(void)createNewTicket:(UITapGestureRecognizer*)tapGesture{
    
    //    MGLCoordinateBounds visibleCoordinateBounds = self.mapView.visibleCoordinateBounds;
    //    NSLog(@"sw Lati : %f, sw Longi : %f, ne Lati : %f, ne Longi : %f", visibleCoordinateBounds.sw.latitude, visibleCoordinateBounds.sw.longitude, visibleCoordinateBounds.ne.latitude,visibleCoordinateBounds.ne.longitude);
    CLLocationCoordinate2D location = [self.mapView convertPoint:[tapGesture locationInView:self.mapView]
                                            toCoordinateFromView:self.mapView];
    
    NSLog(@"You tapped at: %f, %f", location.latitude, location.longitude);
    
}
-(void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offlinePackProgressDidChange:) name:MGLOfflinePackProgressChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offlinePackDidReceiveError:) name:MGLOfflinePackErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offlinePackDidReceiveMaximumAllowedMapboxTiles:) name:MGLOfflinePackMaximumMapboxTilesReachedNotification object:nil];
}

-(void)downloadDataForOfflineUsage{
    
    [self registerNotification];
    
    // Create a region that includes the current viewport and any tiles needed to view it when zoomed further in.
    // Because tile count grows exponentially with the maximum zoom level, you should be conservative with your `toZoomLevel` setting.
    id <MGLOfflineRegion> offlineRigion = [[MGLTilePyramidOfflineRegion alloc] initWithStyleURL:self.mapView.styleURL bounds:self.mapView.visibleCoordinateBounds fromZoomLevel:self.mapView.zoomLevel toZoomLevel:16];
    
    // Store some data for identification purposes alongside the downloaded resources.
    NSDictionary* userInfo = @{@"activeUser" : @"nasir.ahmed@mobinius.com"};
    NSData* context = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
    
    // Create and register an offline pack with the shared offline storage object.
    [[MGLOfflineStorage sharedOfflineStorage] addPackForRegion:offlineRigion withContext:context completionHandler:^(MGLOfflinePack *  pack, NSError *  error) {
        
        NSLog(@"offline Packs: %@",pack);
        
        if(error){
            // The pack couldn’t be created for some reason.
            NSLog(@"Error: %@", error.localizedFailureReason);
        }
        else{
            [pack resume];
        }
        
    }];
}

#pragma mark - MGLOfflinePack notification handlers

-(void)offlinePackProgressDidChange:(NSNotification*)notification{
    MGLOfflinePack* offlinePack = notification.object;
    
    NSDictionary* userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:offlinePack.context];
    
    MGLOfflinePackProgress offlinePackProgress = offlinePack.progress;
    
    uint64_t completedResources = offlinePackProgress.countOfResourcesCompleted;
    uint64_t expectedResources = offlinePackProgress.countOfResourcesExpected;
    
    //calculate progess percentage
    float progressPercentage = completedResources / expectedResources;
    
    if (!self.progressView) {
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        CGSize frame = self.view.bounds.size;
        self.progressView.frame = CGRectMake(frame.width / 4, frame.height * 0.75, frame.width / 2, 10);
        [self.view addSubview:self.progressView];
    }
    [self.progressView setProgress:progressPercentage animated:YES];
    
    // If this pack has finished, print its size and resource count.
    if(completedResources == expectedResources){
        NSString* byteCount = [NSByteCountFormatter stringFromByteCount:offlinePackProgress.countOfBytesCompleted countStyle:NSByteCountFormatterCountStyleMemory];
        
        NSLog(@"Offline Pack %@ : completed %@, %llu resource", userInfo[@"activeUser"], byteCount, completedResources);
    }
    else{
        NSLog(@"Offline Pack %@ : remains %llu resources out of %llu : Percentage : %f",userInfo[@"activeUser"], completedResources, expectedResources, progressPercentage * 100);
    }
}

-(void)offlinePackDidReceiveError:(NSNotification*)notification{
    
    MGLOfflinePack* offlinepack = notification.object;
    NSDictionary* userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:offlinepack.context];
    NSError* error = notification.userInfo[MGLOfflinePackErrorUserInfoKey];
    
    NSLog(@"Error in pack %@ with description : %@",userInfo[@"activeUser"], error.localizedFailureReason);
    
}

-(void)offlinePackDidReceiveMaximumAllowedMapboxTiles:(NSNotification*)notification{
    MGLOfflinePack* offlinePack = notification.object;
    NSDictionary* userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:offlinePack.context];
    
    uint64_t maximumCount = [notification.userInfo[MGLOfflinePackMaximumCountUserInfoKey] unsignedLongLongValue];
    
    NSLog(@"Error in pack %@ reached limit of %llu tiles.",userInfo[@"activeUser"], maximumCount);
    
}

#pragma mark -- MGLMapView Delegate Methods
- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation {
    // Always try to show a callout when an annotation is tapped.
    return YES;
}

- (void)mapViewDidFinishLoadingMap:(MGLMapView *)mapView{
    //    [mapView setCenterCoordinate:CLLocationCoordinate2DMake(12.937548,77.5790818) zoomLevel:13 animated:YES];
    [CRLoadingView removeView];
}

- (void)mapViewWillStartRenderingMap:(MGLMapView *)mapView{
    
}

- (void)mapViewDidFinishRenderingMap:(MGLMapView *)mapView fullyRendered:(BOOL)fullyRendered{
    if(fullyRendered){
    }
}

- (MGLAnnotationImage *)mapView:(MGLMapView *)mapView imageForAnnotation:(id <MGLAnnotation>)annotation{
    
    if ([annotation.title isEqualToString:@"created"]) {
        MGLAnnotationImage* customAnnotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"created"];
        
        customAnnotationImage = [MGLAnnotationImage annotationImageWithImage:[UIImage imageNamed:@"created"] reuseIdentifier:@"created"];
        
        return customAnnotationImage;
    }
    else if ([annotation.title isEqualToString:@"started"]) {
        MGLAnnotationImage* customAnnotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"started"];
        
        customAnnotationImage = [MGLAnnotationImage annotationImageWithImage:[UIImage imageNamed:@"started"] reuseIdentifier:@"started"];
        
        return customAnnotationImage;
    }
    return nil;
}

- (void)mapViewDidFinishRenderingFrame:(MGLMapView *)mapView fullyRendered:(BOOL)fullyRendered{
    
    //    MGLCoordinateBounds visibleCoordinateBounds = mapView.visibleCoordinateBounds;
    //    NSLog(@"sw Lati : %f, sw Longi : %f, ne Lati : %f, ne Longi : %f", visibleCoordinateBounds.sw.latitude, visibleCoordinateBounds.sw.longitude, visibleCoordinateBounds.ne.latitude,visibleCoordinateBounds.ne.longitude);
    
}






@end
