import * as React from "react";
import { Icon, Menu, Dropdown, Popup } from 'semantic-ui-react'
import { MapModeContext, MapSelectionContext, MapToolContext, MapViewContext } from './map_context'
import { useContext } from 'react'
import { SelectParentObjectTypes } from './actions/select_parent'

export const ToolBar = (props) => {
  const mapTool = useContext(MapToolContext);
  const mapMode = useContext(MapModeContext);
  const mapView = useContext(MapViewContext);
  const mapSelection = useContext(MapSelectionContext)
  console.log('ToolBar', props)
  const MapMode = ({name, label}) => {
    return (<Menu.Item
      name={name}
      active={mapMode.mapMode === name}
      content={label}
      onClick={() => {
        localStorage.setItem('mapMode', name)
        mapMode.setMapMode(name)
      }}
    />)
  }

  const MapTool = ({name, label, types}) => {
    if (types && !mapSelection.hasType(types)) {
      return ''
    }

    return (<Menu.Item
      name={name}
      active={mapTool.mapTool === name}
      content={<Popup content={name} trigger={<Icon name={label}/>}/>}
      onClick={() => mapTool.setMapTool(name)}
    />)
  }

  return <div>
    <Menu>
      <MapTool name="select" label="mouse pointer"/>
      <MapTool name="selectPoints" label="expand"/>
      <MapTool name="add" label="plus"/>
      <MapTool name="delete" label="delete"/>
      <MapTool name="editPoints" label="edit"/>
      <MapTool name="claim" label="chain"/>
      <MapTool name="placeMarker" label="marker"/>
      <MapTool name="measure" label="tachometer alternate"/>
      <MapTool name="selectParent" label="sitemap" types={SelectParentObjectTypes}/>
    </Menu>
    <Menu>
      <MapMode name="continents" label="Continents"/>
      <MapMode name="subcontinents" label="Subcontinents"/>
      <MapMode name="regions" label="Regions"/>
      <MapMode name="areas" label="Areas"/>
      <MapMode name="provinces" label="Provinces"/>
      <MapMode name="hexes" label="Hexes"/>
    </Menu>
    <Menu>
      <MapMode name="states" label="States"/>
      <MapMode name="independent_states" label="Independent"/>
      <MapMode name="settlements" label="Settlements"/>
      <MapMode name="cultures" label="Culture"/>
      <MapMode name="biomes" label="Biome"/>
    </Menu>
  </div>
};

