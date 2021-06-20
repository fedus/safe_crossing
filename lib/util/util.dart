import 'package:flutter/material.dart';

nodeIdToFirestoreId(String nodeId) => nodeId.split('/')[1];

List<Widget> wrapAllWidgetsInPadding({ List<Widget> widgetsToWrap, EdgeInsetsGeometry padding }) {
  return widgetsToWrap
      .map((widgetToWrap) => Padding(padding: padding, child: widgetToWrap))
      .toList();
}
