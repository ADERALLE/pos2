import 'package:flutter/widgets.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? defaultSize;
  static Orientation? orientation;

   init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    orientation = _mediaQueryData!.orientation;

    // On iPhone 11 the defaultSize = 10 almost
    // So if the screen size increase or decrease then our defaultSize also vary
    defaultSize = orientation == Orientation.landscape
        ? screenHeight! * 0.024
        : screenWidth! * 0.024;
  }

  double cardPadd(double d) {
    if(SizeConfig.screenWidth!<950)
      return 0;
    return d;
  }

  double detailWidth() {
    // print("siiiiiiiize"+SizeConfig.screenWidth.toString());
    if(SizeConfig.screenWidth!<=1200)
      return SizeConfig.screenWidth! ;
    return SizeConfig.screenWidth! * 0.8;
  }

  double lineUpWidth() {
    // print("siiiiiiiize"+SizeConfig.screenWidth.toString());
    if(SizeConfig.screenWidth!<=1000)
      return SizeConfig.screenWidth! ;
    return 1000;
  }

  double imgHeight() {
     if(SizeConfig.screenWidth!<800)
       return (SizeConfig.screenWidth! *0.8) *0.6;
     if(SizeConfig.screenWidth!<1000)
       return (SizeConfig.screenWidth! *0.8) *0.3;
     return (SizeConfig.screenWidth! *0.8) *0.2;
  }
  double imgWidth() {
    if(SizeConfig.screenWidth!<600)
      return (SizeConfig.screenWidth! *0.8) ;
    if(SizeConfig.screenWidth!<800)
      return (SizeConfig.screenWidth! *0.4);
    return (SizeConfig.screenWidth! *0.4) ;
  }

  double gridRatio(){
    if(SizeConfig.screenWidth!<800)
      return 5 ;
    if(SizeConfig.screenWidth!<1200)
      return 4;
//    if(SizeConfig.screenWidth!<1300)
//      return 3;
    return 3 ;
  }

  int gridCount(){
    if(SizeConfig.screenWidth!<800)
      return 1 ;
    if(SizeConfig.screenWidth!<1200)
      return 2;
//    if(SizeConfig.screenWidth!<1300)
//      return 3;
    return 3 ;
  }

  int gridCount2(){

    if(SizeConfig.screenWidth!<800)
      return 1;
    return 2 ;
  }
  int gridCount3(int l){
    if(l == 1)
      return 1;
    if(SizeConfig.screenWidth!<1450)
      return 1;
    return 2 ;
  }

  double inAppBarPadding(){
    if(SizeConfig.screenWidth! < 800) {
      return 0;
    }
    if(SizeConfig.screenWidth!<1450) {
      return 100;
    }
    return 200 ;
  }

}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  double? screenHeight = SizeConfig.screenHeight;
  double height =SizeConfig.orientation==Orientation.landscape ? 375 : 812;
  // 812 is the layout height that designer use
  double d =(inputHeight / height);
  return  d * (screenHeight ?? 800);
}

// Get the proportionate height as per screen size
double getProportionateScreenWidth(double inputWidth) {
  double? screenWidth = SizeConfig.screenWidth;
  double width = SizeConfig.orientation==Orientation.landscape ? 812 : 375;
  // 375 is the layout width that designer use
  return (inputWidth / width) * (screenWidth??375 );
}
