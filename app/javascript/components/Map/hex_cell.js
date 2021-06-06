import {Polygon} from 'react-leaflet'
import html from 'utils/html'
import {extendHex} from 'honeycomb-grid'

const HexCell = (props) => {
  const point = props.hex.toPoint();
  const hex = extendHex({
    ...props.options
  })(point.x, point.y);

  const corners = hex.corners().map((pp) => {
    const p = pp.add(point)
    return [p.y, p.x];
  });

  return html.tag(Polygon, 't', {
    pathOptions: {color: 'red'},
    positions: corners
  });
}

export default HexCell;