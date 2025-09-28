import 'package:flutter/material.dart';

String mainAxisToString(MainAxisAlignment v) {
  switch (v) {
    case MainAxisAlignment.center:
      return 'center';
    case MainAxisAlignment.end:
      return 'end';
    case MainAxisAlignment.spaceBetween:
      return 'spaceBetween';
    case MainAxisAlignment.spaceAround:
      return 'spaceAround';
    case MainAxisAlignment.spaceEvenly:
      return 'spaceEvenly';
    case MainAxisAlignment.start:
      return 'start';
  }
}

String crossAxisToString(CrossAxisAlignment v) {
  switch (v) {
    case CrossAxisAlignment.start:
      return 'start';
    case CrossAxisAlignment.end:
      return 'end';
    case CrossAxisAlignment.stretch:
      return 'stretch';
    case CrossAxisAlignment.baseline:
      return 'baseline';
    case CrossAxisAlignment.center:
      return 'center';
  }
}

MainAxisAlignment? stringToMainAxis(dynamic s) {
  switch (s) {
    case 'center':
      return MainAxisAlignment.center;
    case 'end':
      return MainAxisAlignment.end;
    case 'spaceBetween':
      return MainAxisAlignment.spaceBetween;
    case 'spaceAround':
      return MainAxisAlignment.spaceAround;
    case 'spaceEvenly':
      return MainAxisAlignment.spaceEvenly;
    case 'start':
      return MainAxisAlignment.start;
    default:
      return null;
  }
}

CrossAxisAlignment? stringToCrossAxis(dynamic s) {
  switch (s) {
    case 'start':
      return CrossAxisAlignment.start;
    case 'end':
      return CrossAxisAlignment.end;
    case 'stretch':
      return CrossAxisAlignment.stretch;
    case 'baseline':
      return CrossAxisAlignment.baseline;
    case 'center':
      return CrossAxisAlignment.center;
    default:
      return null;
  }
}

TextAlign? stringToTextAlign(dynamic s) {
  switch (s) {
    case 'center':
      return TextAlign.center;
    case 'right':
      return TextAlign.right;
    case 'left':
      return TextAlign.left;
    default:
      return null;
  }
}

TextOverflow? stringToTextOverflow(json) {
  switch (json) {
    case 'clip':
      return TextOverflow.clip;
    case 'ellipsis':
      return TextOverflow.ellipsis;
    case 'fade':
      return TextOverflow.fade;
    default:
      return null;
  }
}

String textAlignToString(TextAlign v) {
  switch (v) {
    case TextAlign.center:
      return 'center';
    case TextAlign.right:
      return 'right';
    case TextAlign.left:
    default:
      return 'left';
  }
}

BoxFit? stringToBoxFit(dynamic s) {
  switch (s) {
    case 'cover':
      return BoxFit.cover;
    case 'contain':
      return BoxFit.contain;
    case 'fill':
      return BoxFit.fill;
    case 'fitWidth':
      return BoxFit.fitWidth;
    case 'fitHeight':
      return BoxFit.fitHeight;
    case 'none':
      return BoxFit.none;
    case 'scaleDown':
      return BoxFit.scaleDown;
    default:
      return null;
  }
}

String boxFitToString(BoxFit v) {
  switch (v) {
    case BoxFit.cover:
      return 'cover';
    case BoxFit.contain:
      return 'contain';
    case BoxFit.fill:
      return 'fill';
    case BoxFit.fitWidth:
      return 'fitWidth';
    case BoxFit.fitHeight:
      return 'fitHeight';
    case BoxFit.none:
      return 'none';
    case BoxFit.scaleDown:
      return 'scaleDown';
  }
}
