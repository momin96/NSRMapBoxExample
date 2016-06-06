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
    self.mapView.rotateEnabled = NO;
    NSMutableArray *annotationList = [NSMutableArray new];
    
    MGLPointAnnotation* point = [[MGLPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(12.937548,77.5790818);
    point.title = @"created";
    point.subtitle = @"My room";
    [self.mapView addAnnotation:point];
    
    
    MGLPointAnnotation* secondPoint = [[MGLPointAnnotation alloc] init];
    secondPoint.coordinate = CLLocationCoordinate2DMake(12.9402157, 77.5757746);
    secondPoint.title = @"started";
    [annotationList addObject:secondPoint];
    
    MGLPointAnnotation* thirdPoint = [[MGLPointAnnotation alloc] init];
    thirdPoint.coordinate = CLLocationCoordinate2DMake(52.257070, 6.160704);
    thirdPoint.title = @"completed";
    [annotationList addObject:thirdPoint];
    
    MGLPointAnnotation* fourthPoint = [[MGLPointAnnotation alloc] init];
    fourthPoint.coordinate = CLLocationCoordinate2DMake(52.255635, 6.160071);
    fourthPoint.title = @"completed";
    [annotationList addObject:fourthPoint];
    [CRLoadingView loadingViewInView:self.mapView Title:@"Loading"];
    //    MGLCoordinateBounds bounds = MGLCoordinateBoundsMake(CLLocationCoordinate2DMake(52.257070, 6.160704),
    //                                                         CLLocationCoordinate2DMake(52.255635,6.160071));
    MGLCoordinateBounds bounds = MGLCoordinateBoundsMake(CLLocationCoordinate2DMake(12.931009593713711, 77.572613561808339),
                                                         CLLocationCoordinate2DMake(12.946548255058971,77.581581762621909));
    [self.mapView setVisibleCoordinateBounds:bounds];
    [self.mapView addAnnotations:annotationList];
    
    UITapGestureRecognizer* tapToCreateNewTicket = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createNewTicket:)];
    [self.mapView addGestureRecognizer:tapToCreateNewTicket];
    
    //    UIBarButtonItem* donwloadOfflinedData = [[UIBarButtonItem alloc] initWithTitle:@"Download Offline Data"
    //                                                                             style:UIBarButtonItemStylePlain
    //                                                                            target:self
    //                                                                            action:@selector(downloadDataForOfflineUsage)];
    
    UIBarButtonItem* donwloadOfflinedData = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                          target:self
                                                                                          action:@selector(downloadDataForOfflineUsage)];
    
    //    UIBarButtonItem* removedOfflinedData = [[UIBarButtonItem alloc] initWithTitle:@"Remove Offline Data"
    //                                                                            style:UIBarButtonItemStylePlain
    //                                                                           target:self
    //                                                                           action:@selector(removeOfflineDate)];
    UIBarButtonItem* removedOfflinedData = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                         target:self
                                                                                         action:@selector(removeOfflineDate)];
    
    UIBarButtonItem* myLocation = [[UIBarButtonItem alloc] initWithTitle:@"My Location"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(findMyLocation)];
    
    self.navigationItem.rightBarButtonItems = @[donwloadOfflinedData, removedOfflinedData, myLocation];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSArray* packs = [[MGLOfflineStorage sharedOfflineStorage] packs];
    if([packs count]){
        MGLOfflinePack* offlinePack = [packs lastObject];
        MGLOfflinePackProgress offlinePackProgress = offlinePack.progress;
        
    }
}

#pragma mark -- Helper Method

-(void)createNewTicket:(UITapGestureRecognizer*)tapGesture{
    
    //    MGLCoordinateBounds visibleCoordinateBounds = self.mapView.visibleCoordinateBounds;
    //    NSLog(@"sw Lati : %f, sw Longi : %f, ne Lati : %f, ne Longi : %f", visibleCoordinateBounds.sw.latitude, visibleCoordinateBounds.sw.longitude, visibleCoordinateBounds.ne.latitude,visibleCoordinateBounds.ne.longitude);
    CLLocationCoordinate2D location = [self.mapView convertPoint:[tapGesture locationInView:self.mapView]
                                            toCoordinateFromView:self.mapView];
    
    NSLog(@"You tapped at: %f, %f", location.latitude, location.longitude);
    NSString* coordinate = [NSString stringWithFormat:@"%.4f, %.4f", location.latitude, location.longitude];
    self.title = coordinate;
    
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
    id <MGLOfflineRegion> offlineRigion = [[MGLTilePyramidOfflineRegion alloc] initWithStyleURL:self.mapView.styleURL bounds:self.mapView.visibleCoordinateBounds fromZoomLevel:self.mapView.zoomLevel toZoomLevel:18];
    
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
    NSArray* packs = [[MGLOfflineStorage sharedOfflineStorage] packs];
    NSLog(@"pack list : %@",packs);
}

- (void)removeOfflineDate{
    NSArray* packs = [[MGLOfflineStorage sharedOfflineStorage] packs];
    if([packs count]){
        [[MGLOfflineStorage sharedOfflineStorage] removePack:[packs lastObject] withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error while removing pack %@ with description : %@",[packs lastObject], error.localizedFailureReason);
            }
            else{
                MGLOfflinePack* offlinePack = [packs lastObject];
                MGLOfflinePackProgress offlinePackProgress = offlinePack.progress;
                uint64_t completedResources = offlinePackProgress.countOfResourcesCompleted;
                //                uint64_t expectedResources = offlinePackProgress.countOfResourcesExpected;
                
                NSString* byteCount = [NSByteCountFormatter stringFromByteCount:offlinePackProgress.countOfBytesCompleted countStyle:NSByteCountFormatterCountStyleMemory];
                
                NSLog(@"Offline Pack %@ : completed %@, %llu resource", offlinePack, byteCount, completedResources);
                
                NSLog(@"Pack %@ removed successfully  and pack list is %@",offlinePack, packs);
                
                NSString* title = [NSString stringWithFormat:@"Offline Pack %@ ",offlinePack];
                NSString* message = [NSString stringWithFormat:@"successfully removed data of size %@, and total %llu resources",byteCount,completedResources];
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* action = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:nil];
                
                [alert addAction:action];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
    else{
        NSLog(@"No packs availabe");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"No packs availabe"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:action];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)findMyLocation{
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MGLUserTrackingModeFollow animated:YES];
    MGLUserLocation* userLocation = self.mapView.userLocation;
    userLocation.isUpdating;
    CLLocationCoordinate2D currentCoordinate =  userLocation.location.coordinate;
    
    NSLog(@"longitude : %f latitude : %f",currentCoordinate.longitude, currentCoordinate.latitude );
    NSString* coordinate = [NSString stringWithFormat:@"%f, %f", currentCoordinate.latitude, currentCoordinate.longitude];
    self.title = coordinate;
    
}

#pragma mark - MGLOfflinePack notification handlers

-(void)offlinePackProgressDidChange:(NSNotification*)notification{
    MGLOfflinePack* offlinePack = notification.object;
    
    NSDictionary* userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:offlinePack.context];
    
    MGLOfflinePackProgress offlinePackProgress = offlinePack.progress;
    
    uint64_t completedResources = offlinePackProgress.countOfResourcesCompleted;
    uint64_t expectedResources = offlinePackProgress.countOfResourcesExpected;
    
    //calculate progess percentage
    float progressPercentage = (float)completedResources/expectedResources;
    
    if (!self.progressView) {
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        CGSize frame = self.view.bounds.size;
        self.progressView.frame = CGRectMake(frame.width / 4, frame.height * 0.75, frame.width / 2, 40);
        [self.view addSubview:self.progressView];
    }
    [self.progressView setProgress:progressPercentage animated:YES];
    
    // If this pack has finished, print its size and resource count.
    if(completedResources == expectedResources){
        //        uint64_t currentTitleCount = [notification.userInfo[MGLOfflinePackProgressUserInfoKey] unsignedLongLongValue];
        
        NSString* byteCount = [NSByteCountFormatter stringFromByteCount:offlinePackProgress.countOfBytesCompleted countStyle:NSByteCountFormatterCountStyleMemory];
        NSLog(@"Offline Pack %@ : completed %@, %llu resource", offlinePack, byteCount, completedResources);
        [self.progressView removeFromSuperview];
        self.progressView  = nil;
        
        NSString* title = [NSString stringWithFormat:@"Offline Pack %@ ",offlinePack];
        NSString* message = [NSString stringWithFormat:@"Completed downloading with size %@, and total %llu resources",byteCount,completedResources];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        NSLog(@"Offline Pack %@ : remains %llu resources out of %llu : Percentage : %.2f%%. ",offlinePack, completedResources, expectedResources, progressPercentage * 100);
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
    NSString* message = [NSString stringWithFormat:@"Error in pack %@ reached limit of %llu tiles.",offlinePack, maximumCount];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
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
    else if ([annotation.title isEqualToString:@"completed"]){
        MGLAnnotationImage* customAnnotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"completed"];
        
        customAnnotationImage = [MGLAnnotationImage annotationImageWithImage:[UIImage imageNamed:@"completed"] reuseIdentifier:@"completed"];
        
        return customAnnotationImage;
    }
    return nil;
}

- (void)mapViewDidFinishRenderingFrame:(MGLMapView *)mapView fullyRendered:(BOOL)fullyRendered{
    
    //    MGLCoordinateBounds visibleCoordinateBounds = mapView.visibleCoordinateBounds;
    //    NSLog(@"sw Lati : %f, sw Longi : %f, ne Lati : %f, ne Longi : %f", visibleCoordinateBounds.sw.latitude, visibleCoordinateBounds.sw.longitude, visibleCoordinateBounds.ne.latitude,visibleCoordinateBounds.ne.longitude);
    
}






@end
