import {extendHex, defineGrid} from 'honeycomb-grid'
import {useState, useEffect} from 'react'
import {LayerGroup, Polygon, useMapEvents} from 'react-leaflet'
import html from 'utils/html'
import HexCell from './hex_cell'
import api from 'utils/api'

// width of 12 mi gives side 6.9282
// 6.9282 / (25000/8192)
const hexOptions = {
  size: 6.9282 / (25000/8192),
  strokeWidth: 1
}

const gridOptions  ={
  width: 64,
  height: 48
};

const HexFactory = extendHex(hexOptions);
const Grid = defineGrid(HexFactory);

const HexGrid = (props) => {
  const [grid, setGrid] = useState(Grid.rectangle(gridOptions));
  const [center, setCenter] = useState(props.center);
  const [zoom, setZoom] = useState(props.zoom);
  const map = useMapEvents({
    click: (e) => {
      console.log('HexGrid#click', e);
      // map.setCenter([50.5, 30.5])
    },
    zoomend: (e, z) => {
      console.log('zoomend', e, map)
      setZoom(e.target._zoom);
    },
    dragend: (e) => {
      const c = map.getCenter();
      console.log('dragend', e, map.getCenter())
      setCenter([c.lat, c.lng]);
      //setGrid(Grid.rectangle(gridOptions))
    }
  });
  console.log('HexGrid', props, grid)

  const hexes = () => {
    console.log('hexes', zoom, center)
    // hexes ain't useful at larger zooms
    if (zoom < 2)
      return '';

    return grid.map((h, i) => {
      return html.tag(HexCell, i, {
        hex: h,
        options: hexOptions,
        originPoint: center
      });
    });
  }

  return html.tag(LayerGroup, 'hexes', {},
    hexes()
  );
}

export default HexGrid;