enum MapImagery {
  CITY_OF_LUXEMBOURG_ORTHO_2019,
  GEOPORTAIL_ORTHO_2020,
}

extension GetImageryUrlTemplate on MapImagery {
  String get getUrlTemplate {
    switch(this) {
      case MapImagery.CITY_OF_LUXEMBOURG_ORTHO_2019:
        return 'https://maps.vdl.lu/arcgis/rest/services/BASEMAP/ORTHO_2019/MapServer/tile/{z}/{y}/{x}';
      case MapImagery.GEOPORTAIL_ORTHO_2020:
        return 'https://wmts1.geoportail.lu/opendata/wmts/ortho_2020/GLOBAL_WEBMERCATOR_4_V3/{z}/{x}/{y}.jpeg';
      default:
        throw new Exception("Can't determine URL for selected map imagery");
    }
  }
}