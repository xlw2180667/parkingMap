# parkingMap
- Read the Json file to simulating a response received from the backend system. 
- Load the map view (with the viewport based on location_data.bounds)
- Draw the zone polygons (location_data.zones.polygon) on top of the map. Use the payment_is_allowed value for deciding the background color of the polygon. (Use MKPolygonRenderer for drawing the polygon overlays).
- Draw a map pin (MKAnnotation) in the center coordinate of the map. Customise the map pin so that it displays the service price for the selected zone at the center of the pin (selected zone is explained later on)
- Dragging/interacting the map changes the location of the map pin in a way, that once you stop touch gestures (e.g. dragging) on the map, the map pin always appears at the center coordinate of the map. While the map is being dragged, the pin should be hidden.
- Make a creative way of displaying other zone information (location_data.zones) for the currently selected zone. Currently selected zone is the one where the map pin (current location) is located (coordinate is within the zone polygon) and dragging the map pin into another zone should select this zone. Once a zone is selected, the background color of the zone polygon also changes.
- Place a start parking button (UIButton) as a part of your layout. Once tapped, the app will tell which zone is being parked.
