//
//  PSIHKCoordConvertor.m
//  MyLibrarian
//
//  Created by Yu Ho Kwok on 2/2/14.
//  Copyright (c) 2014 invivo interactive limited. All rights reserved.
//

#import "PSIHKCoordConvertor.h"

// Reference ellipsoid of HK80 (based on International 1910 / Transverse Mercator)
#define $A   6378388 //Semi-major axis
#define $F   0.0033670033670034 // Flattening
#define $E2  0.0067226700223333 // First eccentricity (e^2 = 2f - f^2)
#define $M0  1                  // Scale factor along central meridian

// Reference point of HK80 (Patridge Hill Trigonometric Station)
#define $LAT0  0.38942018399288 // deg2rad( 22d 18' 43.68" N)
#define $LNG0  1.99279173737270 // deg2rad(114d 10' 42.80" E)
#define $N0  819069.80
#define $E0  836694.05

#ifndef DEG2RAD
#define DEG2RAD(x) ((x) * 0.01745329251994329575)
#endif

#ifndef RAD2DEG
#define RAD2DEG(x) ((x) * 57.29577951308232087721)
#endif

@implementation PSIHKCoordConvertor

+(double)doBisectIterWithF:(conversionBlock)f X1:(double)x1 X2:(double)x2 withEpsilon:(double)epsilon{
    double y1 = f(x1); // $f($x1);
    double y2 = f(x2); // $f($x2);
    
    //Ensure the signs are opposite
    if(y1 * y2 > 0)
        return NO;
    
    //Ensure the y1 must be the smaller side
    if(y1 > 0)
        return [PSIHKCoordConvertor doBisectIterWithF:f X1:x2 X2:x1 withEpsilon:epsilon];
        //return call_user_func(array('self', __FUNCTION__), $f, $x2, $x1, $epsilon);
    
    double x  = (x1+x2)/2;
    double y = f(x);
    
    //NSLog(@"abs(y): %f", fabs(y));
    if(fabs(y) <= epsilon)
        return x;
    
    return [PSIHKCoordConvertor
            doBisectIterWithF:f
            X1:(y<0)?x:x1
            X2:(y>0)?x:x2
            withEpsilon:epsilon];
    //call_user_func(array('self', __FUNCTION__), $f, ($y<0)?($x):($x1), ($y>0)?($x):($x2), $epsilon);
}

+(double)getMedianDist:(double)lat{
    double a = $A;
    double e2 = $E2;
    
    double a0 = 1 - e2/4 - 3 * e2 * e2 /64;
    double a2 = 3 * (e2 + e2 * e2 / 4) / 8;
    double a4 = 15 * e2 * e2 / 256;
    return a * (a0 * lat - a2 * sin(2*lat) - a4 * sin(4*lat));
}

//input array of NSNumber
+(NSArray*)convertHK80GridToCartesian:(NSArray*)grid{
    double n = [grid[0] doubleValue];
    double e = [grid[1] doubleValue];
    
    //constants
    double a = $A;
    double e2 = $E2;
    double n0 = $N0;
    double e0 = $E0;
    double m0 = $M0;
    double lat0 = $LAT0;
    double lng0 = $LNG0;
    
    // Calculate dN and dE
    double dN = n - n0;
    double dE = e - e0;
    
    // Calculate meridian distance
    double M0 = [self getMedianDist:lat0];
    double m = (dN + M0)/m0;
    
    //NSLog(@"%f", m);
    conversionBlock block =
    ^(double x){
        //
        return (m - [PSIHKCoordConvertor getMedianDist:x]);
    };
//    // Step 1: HK80 Grid => HK80 Geographic Co-ordinates
//    // Newtonian iteration to get the latitude reference evaluated, given meridian distance
    double latP = [PSIHKCoordConvertor doBisectIterWithF:block X1:-10000 X2:10000 withEpsilon:0.00000001];
    //NSLog(@"latP: %f", latP);
//    $latP = self::doBisectIter(
//                               create_function('$x', 'return '.$M.' - Coordinates::getMeridianDist($x);'),
//                               -10000, 10000);
//    
//    // By the latitude reference, the v (radius of curvature in prime vertical),
//    // p (that in meridian) and phi (isometric latitude) at point P are evaluated
//    $vP = $a / pow(1 - $e2 * pow(sin($latP), 2), 0.5);
    double vP = a/pow(1-e2*pow(sin(latP),2), 0.5);
    //NSLog(@"vP: %f", vP);
//    $pP = $a * (1 - $e2) / pow(1 - $e2 * pow(sin($latP), 2), 1.5);
    double pP = a * (1-e2) / pow(1-e2*pow(sin(latP),2), 1.5);
    //NSLog(@"pP: %f", pP);
//    $phiP = $vP / $pP;
    double phiP = vP / pP;
    //NSLog(@"phiP: %f", phiP);
//    
//    // The latitude/longitude (at HK1980) is evaluated by the radius of curvature
//    $lat = $latP - tan($latP) * pow($dE/$m0, 2) / (2*$pP*$vP);
    double lat  = latP - tan(latP) * pow(dE/m0, 2) / (2*pP*vP);
//    $lng = $lng0 + $dE / ($m0*$vP * cos($latP)) - (pow($dE, 3) / (6 * pow($m0*$vP, 3) * cos($latP)))*($phiP + 2 * pow(tan($latP), 2));
    double lng = lng0 + dE / (m0*vP*cos(latP)) - (pow(dE, 3)/(6*pow(m0*vP,3)*cos(latP))) * (phiP + 2 * pow(tan(latP), 2));
//    
//    // Step 2: HK80 Geographic => WGS84 Geographic Co-ordinates
//    // This is the lazy and fast way, suitable for general usage
//    // This uses a rule of thumb to convert coordinate from HK80 to WGS84 directly
//    // TODO: Implement the proper way :P
//    return array(
//                 'lat' => rad2deg($lat) - 5.5/3600,
//                 'lng' => rad2deg($lng) + 8.8/3600
//                 );
    return @[[NSNumber numberWithDouble:(RAD2DEG(lat)-5.5/3600)], [NSNumber numberWithDouble:(RAD2DEG(lng)+8.8/3600)]];
    
    return nil;
}

@end
