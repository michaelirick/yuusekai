// import html from 'utils/html'
// import truth from 'utils/truth'
// import coalesce from 'utils/coalesce'
// import api from 'utils/api'
// eslint-disable-next-line no-use-before-define
import * as React from 'react'

const HexInfo = (props) => {
  console.log('HexInfo', props)
  const hex = props.hex.h ?? {}
  // const header = () => {
  //   return html.h3('header', {}, `${hex.title}`)
  // }

  const coords = () => {
    return <p>{`(${hex.x}, ${hex.y})`}</p>
  }

  // const province = () => {
  //   return html.p('province', {}, `Province: ${hex.province_id}`)
  // }

  // const edit = () => {
  //   return html.a('edit', {
  //     href: `/admin/hexes/${hex.id}/edit?hex[boundaries]=${props.points}`,
  //     target: '_blank',
  //     className: 'button'
  //   }, 'Edit')
  // }

  // const updateBoundariesButton = () => {
  //   return html.a('updateBoundaries', {
  //     onClick: (e) => updateBoundaries(),
  //     className: 'button'
  //   }, 'Update Boundaries')
  // }

  // const updateBoundaries = () => {
  //   api.post(`/admin/hexes/${hex.id}/update_boundaries.json`, { points: props.points.reverse() })
  //     .then((response) => console.log('updateBoundaries', response))
  // }

  // const create = () => {
  //   return html.a('create', {
  //     href: `/admin/hexes/new?hex[world_id]=${hex.world_id}&hex[x]=${hex.x}&hex[y]=${hex.y}&hex[boundaries]=${props.points}`,
  //     target: '_blank'
  //   }, 'New')
  // }

  // const content = () => {
  //   if (!truth.isTruthy(hex.id)) { return create() }

  //   return [
  //     header(),
  //     coords(),
  //     province(),
  //     edit(),
  //     updateBoundariesButton()
  //   ]
  // }

  return <div>{coords()}</div>

  // return html.div('info', {}, content())
}

export default HexInfo
