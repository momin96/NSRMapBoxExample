//
//  GMapViewController.m
//  NSRMapBoxTest
//
//  Created by Nasirahmed on 06/06/16.
//  Copyright © 2016 Nasir. All rights reserved.
//

#import "GMapViewController.h"
@import GoogleMaps;
@interface GMapViewController ()
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@end

@implementation GMapViewController{
    //    GMSMapView *mapView_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    
    //    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:02.937548
    //                                                            longitude:67.5790818
    //                                                                 zoom:13];
    //    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    //    self.view = mapView_;
    
    // Creates a marker in the center of the map.
    //    GMSMarker *marker = [[GMSMarker alloc] init];
    //    marker.position = CLLocationCoordinate2DMake(12.937548, 77.5790818);
    //    marker.title = @"Sydney";
    //    marker.snippet = @"Australia";
    //    marker.map = self.mapView;
    
    
    UIBarButtonItem* myLocation = [[UIBarButtonItem alloc] initWithTitle:@"My Location"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(findMyLocation)];
    
    self.navigationItem.rightBarButtonItems = @[myLocation];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)findMyLocation{
    
    if (self.mapView.isMyLocationEnabled) {
        NSLog(@"Location is enable");
    }
    CLLocationCoordinate2D coordinate = self.mapView.myLocation.coordinate;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:22];
    self.mapView.camera = camera;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    marker.title = @"Mobinius";
    marker.snippet = @"Bangalore";
    marker.map = self.mapView;
    
    NSLog(@"longitude : %f latitude : %f",coordinate.longitude, coordinate.latitude );
    NSString* deviceCoordinate = [NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude];
    self.title = deviceCoordinate;
    
}
@end
