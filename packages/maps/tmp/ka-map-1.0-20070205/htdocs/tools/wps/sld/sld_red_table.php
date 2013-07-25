<?php
	header("Content-type: application/xhtml+xml");
?>
<StyledLayerDescriptor version="1.0.0">
	<!-- raster sample -->
	<NamedLayer>
		<Name>visibility2</Name>
		<UserStyle>
			<FeatureTypeStyle>
				<Rule>
					<RasterSymbolizer>
						<ColorMap>
							<ColorMapEntry color="#110000" quantity="1"/>
							<ColorMapEntry color="#220000" quantity="30"/>
							<ColorMapEntry color="#330000" quantity="55"/>
							<ColorMapEntry color="#550000" quantity="75"/>
							<ColorMapEntry color="#770000" quantity="80"/>
							<ColorMapEntry color="#990000" quantity="85"/>
							<ColorMapEntry color="#aa0000" quantity="87"/>
							<ColorMapEntry color="#cc0000" quantity="90"/>
							<ColorMapEntry color="#aa0000" quantity="93"/>
							<ColorMapEntry color="#990000" quantity="95"/>
							<ColorMapEntry color="#770000" quantity="100"/>
							<ColorMapEntry color="#550000" quantity="115"/>
							<ColorMapEntry color="#330000" quantity="125"/>
							<ColorMapEntry color="#220000" quantity="150"/>
							<ColorMapEntry color="#110000" quantity="180"/>
						</ColorMap>
					</RasterSymbolizer>
				</Rule>
			</FeatureTypeStyle>
		</UserStyle>
	</NamedLayer>
	
		<NamedLayer>
		<Name>visibility3</Name>
		<UserStyle>
			<FeatureTypeStyle>
				<Rule>
					<RasterSymbolizer>
						<ColorMap>
							<ColorMapEntry color="#110000" quantity="1"/>
							<ColorMapEntry color="#220000" quantity="30"/>
							<ColorMapEntry color="#330000" quantity="55"/>
							<ColorMapEntry color="#550000" quantity="75"/>
							<ColorMapEntry color="#770000" quantity="80"/>
							<ColorMapEntry color="#990000" quantity="85"/>
							<ColorMapEntry color="#aa0000" quantity="87"/>
							<ColorMapEntry color="#cc0000" quantity="90"/>
							<ColorMapEntry color="#aa0000" quantity="93"/>
							<ColorMapEntry color="#990000" quantity="95"/>
							<ColorMapEntry color="#770000" quantity="100"/>
							<ColorMapEntry color="#550000" quantity="115"/>
							<ColorMapEntry color="#330000" quantity="125"/>
							<ColorMapEntry color="#220000" quantity="150"/>
							<ColorMapEntry color="#110000" quantity="180"/>
						</ColorMap>
					</RasterSymbolizer>
				</Rule>
			</FeatureTypeStyle>
		</UserStyle>
	</NamedLayer>

	<!-- vector: polygon sample -->
	<NamedLayer>
		<Name>buffer</Name>
		<UserStyle>
			<Title>buffer</Title>
			<FeatureTypeStyle>
				<Rule>
					<PolygonSymbolizer>
						<Geometry>
							<PropertyName>the_area</PropertyName>
						</Geometry>
						<Fill>
							<CssParameter name="fill">#ff0000</CssParameter>
						</Fill>
						<Stroke>
							<CssParameter name="stroke">#0000ff</CssParameter>
							<CssParameter name="stroke-width">2.0</CssParameter>
						</Stroke>
					</PolygonSymbolizer>
				</Rule>
			</FeatureTypeStyle>
		</UserStyle>
	</NamedLayer>

	<!-- vector: Point sample -->
	<NamedLayer>
		<Name>WorldPOI</Name>
		<UserStyle>
			<Title>xxx</Title>
			<FeatureTypeStyle>
				<Rule>
					<PointSymbolizer>
						<Geometry>
							<PropertyName>locatedAt</PropertyName>
						</Geometry>
						<Graphic>
							<Mark>
								<WellKnownName>star</WellKnownName>
								<Fill>
									<CssParameter name="fill">#ff0000</CssParameter>
								</Fill>
							</Mark>
							<Size>10.0</Size>
						</Graphic>
					</PointSymbolizer>
				</Rule>
			</FeatureTypeStyle>
		</UserStyle>
	</NamedLayer>

	<!-- vector: Line sample 1 (dashed line) -->
	<NamedLayer>
		<Name>shortestpath</Name>
		<UserStyle>
			<Title>xxx</Title>
			<FeatureTypeStyle>
				<Rule>
					<LineSymbolizer>
						<Geometry>
							<PropertyName>center-line</PropertyName>
						</Geometry>
						<Stroke>
							<CssParameter name="stroke">#0000ff</CssParameter>
							<CssParameter name="stroke-width">3.0</CssParameter>
							<CssParameter name="stroke-dasharray">10.0 5 5 10</CssParameter>
						</Stroke>
					</LineSymbolizer>
				</Rule>
			</FeatureTypeStyle>
		</UserStyle>
	</NamedLayer>

	<!-- vector: Line sample 2 (simple line) -->
	<NamedLayer>
		<Name>minorcostpath</Name>
		<UserStyle>
			<Title>xxx</Title>
			<FeatureTypeStyle>
				<Rule>
					<LineSymbolizer>
						<Geometry>
							<PropertyName>center-line</PropertyName>
						</Geometry>
						<Stroke>
							<CssParameter name="stroke">#0000ff</CssParameter>
						</Stroke>
					</LineSymbolizer>
				</Rule>
			</FeatureTypeStyle>
		</UserStyle>
	</NamedLayer>
</StyledLayerDescriptor> 