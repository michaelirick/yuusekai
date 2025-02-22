import * as React from 'react'
import {useState, createContext} from 'react'

export const useMapSelection = (props) => {
  const [selectedObject, setSelectedObject] = useState(null)
  const [world, setWorld] = useState(props.world)
  return { selectedObject, setSelectedObject, world, setWorld }
}

export const MapSelectionContext = React.createContext({
  selectedObject: null,
  setSelectedObject: (_) => {},
  world: null,
  setWorld: (_) => {}
})

export const useMapTool = () => {
  const [mapTool, setMapTool] = useState(localStorage.getItem('mapTool') || 'select')
  const [mapToolPoints, setMapToolPoints] = useState([])
  const [mapToolPoint, setMapToolPoint] = useState(null)
  return { mapTool, setMapTool, mapToolPoints, setMapToolPoints, mapToolPoint, setMapToolPoint }
}

export const MapToolContext = createContext({
  mapTool: localStorage.getItem('mapTool') || 'select',
  setMapTool: (_) => {},
  mapToolPoint: null,
  setMapToolPoint: (_) => {},
  mapToolPoints: [],
  setMapToolPoints: (_) => {}
})

export const useMapMode = () => {
  const [mapMode, setMapMode] = useState(localStorage.getItem('mapMode') || 'hexes')
  const [mapLayer, setMapLayer] = useState(localStorage.getItem('mapLayer') || 0)
  return { mapMode, setMapMode, mapLayer, setMapLayer }
}

export const MapModeContext = createContext({
  mapMode: localStorage.getItem('mapMode') || 'hexes',
  setMapMode: (_) => {},
  mapLayer: localStorage.getItem('mapLayer') || 0,
  setMapLayer: (_) => {}
})

export const useMapView = () => {
  const [mapZoom, setMapZoom] = useState(localStorage.getItem('mapZoom') || 0)
  const [mapCenterX, setMapCenterX] = useState(localStorage.getItem('mapCenterX') || 2048)
  const [mapCenterY, setMapCenterY] = useState(localStorage.getItem('mapCenterY') || 1024)
  const [map, setMap] = useState(null)
  const updateMapCenter = (map, x, y) => {
    map.setView({lng: x, lat: y}, mapZoom);
    setMapCenterX(x)
    setMapCenterY(y)
  }
  return {
    mapZoom,
    setMapZoom,
    mapCenterX,
    setMapCenterX,
    mapCenterY,
    setMapCenterY,
    updateMapCenter,
    map,
    setMap
  }
}

export const MapViewContext = createContext({
  mapZoom: localStorage.getItem('mapZoom') || 0,
  mapCenterX: localStorage.getItem('mapCenterX') || 2048,
  mapCenterY: localStorage.getItem('mapCenterY') || 1024,
  setMapZoom: (_) => {},
  setMapCenterX: (_) => {},
  setMapCenterY: (_) => {},
  updateMapCenter: (_) => {},
  map: null,
  setMap: (_) => {}
})

