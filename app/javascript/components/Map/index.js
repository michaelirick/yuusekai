import * as React from 'react'
import * as Leaflet from 'react-leaflet'
import { MapContainer, LayerGroup, LayersControl, useMapEvents, ScaleControl } from 'react-leaflet'
import {
  MapModeContext,
  MapSelectionContext,
  MapToolContext, MapViewContext,
  useMapSelection,
  useMapTool,
  useMapView,
  useMapMode
} from './map_context'
import html from 'utils/html'
import MapLayer from './map_layer'
import GeoLayer from './geo_layer'
import HexGrid from './hex_grid'
import SideBar from './side_bar'
import 'leaflet/dist/leaflet.css'
import './map.css'
import GeoLayerGrid from './geo_layer_grid'
import { zoom } from 'leaflet/src/control/Control.Zoom'
import { ToolBar } from './toolbar'
import L from 'leaflet';
import { World } from 'models/world'

delete L.Icon.Default.prototype._getIconUrl;
// const [container, tileLayer] = html.tagify([MapContainer, TileLayer]);
L.Icon.Default.mergeOptions({
  iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
  iconUrl: require('leaflet/dist/images/marker-icon.png'),
  shadowUrl: require('leaflet/dist/images/marker-shadow.png')
});
const Map = (props) => {
  console.log('Map', props)
  // console.log('mapCenter', localStorage.getItem('mapCenterX'), localStorage.getItem('mapCenterY'))
  // const [selectedObject, setSelectedObject] = React.useState(null);
  const mapSelection = useMapSelection({world: new World(props.world)})
  const mapTool = useMapTool()
  const mapMode = useMapMode()
  const mapView = useMapView()

  const mapLayer = (layer, index) => {
    console.log('layer', layer)
    return <LayersControl.BaseLayer
      key={`layer-${index}`}
      name={layer.title}
      checked={mapMode.mapLayer === layer.title}
    >
      <MapLayer key={`layer-${index}`} {...layer}></MapLayer>
    </LayersControl.BaseLayer>
  }

  const viewOptions = {
    center: [
      localStorage.getItem('mapCenterY') ?? 2800,
      localStorage.getItem('mapCenterX') ?? 3700
    ],
    // center: [4805, 2100],
    zoom: localStorage.getItem('mapZoom') ?? 2
  }

  const geoLayerGrid = () => {
    return html.tag(GeoLayerGrid, 'grid', {
      mapMode: mapMode,
      world: props.world
    });
  }

  const layers = () => {
    return html.tag(LayersControl, 'layers', {},
      props.world.map_layers.sort((a, b) => (a < b)).map((layer, i) => {
        return mapLayer(layer, i)
      }),
      // geoLayers(),
      geoLayerGrid(),
      // hexes(),
      // html.tag(Control, 'control', {position: 'bottomleft'}, 'test')
      // html.tag(ScaleControl, 'scale', {position: 'bottomright'})
    )
  }

  // yo
  const mapContainer = () => {
    console.log('mapContainer', L.CRS.Simple.scale(1))
    return html.tag(MapContainer, 'test', {
      className: 'map-container',
      key: 'test',
      ...viewOptions,
      minZoom: -10,
      // scrollWheelZoom: false,
      style: {
        height: '600px',
        maxHeight: '600px',
        maxWidth: '800px'
        // float: 'left'
      },
      crs: L.CRS.Simple
    }, [
      layers()//,
      // html.tag(Control, 'control', { position: 'bottomleft' }, 'test')
    ])
  }

  const sideBar = () => {
    return <SideBar
      class="map-sidebar"
    ></SideBar>
  }

  return (
    <MapModeContext.Provider value={mapMode}>
      <MapViewContext.Provider value={mapView}>
        <MapSelectionContext.Provider value={mapSelection}>
          <MapToolContext.Provider value={mapTool}>
            <ToolBar />
            <div className="map-component">
              {mapContainer()}
              {sideBar()}
            </div>
          </MapToolContext.Provider>
        </MapSelectionContext.Provider>
      </MapViewContext.Provider>
    </MapModeContext.Provider>
  )
}

export default Map
