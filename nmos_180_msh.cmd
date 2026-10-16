Title "Untitled"

Controls {
}

IOControls {
	EnableSections
}

Definitions {
	Constant "ConstantProfileDefinition_body" {
		Species = "BoronActiveConcentration"
		Value = 3e+17
	}
	AnalyticalProfile "AnalyticalProfileDefinition_sd" {
		Species = "ArsenicActiveConcentration"
		Function = Gauss(PeakPos = 0, PeakVal = 5e+19, ValueAtDepth = 3e+17, Depth = 0.12)
		LateralFunction = Gauss(Factor = 0.8)
	}
	AnalyticalProfile "AnalyticalProfileDefinition_ext" {
		Species = "ArsenicActiveConcentration"
		Function = Gauss(PeakPos = 0, PeakVal = 5e+18, ValueAtDepth = 3e+17, Depth = 0.035)
		LateralFunction = Gauss(Factor = 0.8)
	}
	Refinement "RefinementDefinition_global" {
		MaxElementSize = ( 0.05 0.2 )
		MinElementSize = ( 0.01 0.01 )
		RefineFunction = MaxTransDiff(Variable = "DopingConcentration",Value = 1)
	}
	Refinement "RefinementDefinition_channel" {
		MaxElementSize = ( 0.005 0.005 )
		MinElementSize = ( 0.001 0.0005 )
		RefineFunction = MaxLenInt(Interface("region_body","region_oxide"), Value=0.0005, factor=1.4, DoubleSide, UseRegionNames)
		RefineFunction = MaxLenInt(Interface("region_body","region_source"), Value=0.001, factor=1.4, DoubleSide, UseRegionNames)
		RefineFunction = MaxLenInt(Interface("region_body","region_drain"), Value=0.001, factor=1.4, DoubleSide, UseRegionNames)
	}
}

Placements {
	Constant "ConstantProfilePlacement_body" {
		Reference = "ConstantProfileDefinition_body"
		EvaluateWindow {
			Element = region ["region_body"]
		}
	}
	AnalyticalProfile "AnalyticalProfilePlacement_source" {
		Reference = "AnalyticalProfileDefinition_sd"
		ReferenceElement {
			Element = Line [(0 2) (0.35 2)]
		}
	}
	AnalyticalProfile "AnalyticalProfilePlacement_drain" {
		Reference = "AnalyticalProfileDefinition_sd"
		ReferenceElement {
			Element = Line [(0.73 2) (1.08 2)]
		}
	}
	AnalyticalProfile "AnalyticalProfilePlacement_source_ext" {
		Reference = "AnalyticalProfileDefinition_ext"
		ReferenceElement {
			Element = Line [(0.35 2) (0.45 2)]
		}
	}
	AnalyticalProfile "AnalyticalProfilePlacement_drain_ext" {
		Reference = "AnalyticalProfileDefinition_ext"
		ReferenceElement {
			Element = Line [(0.63 2) (0.73 2)]
		}
	}
	Refinement "RefinementPlacement_global" {
		Reference = "RefinementDefinition_global"
		RefineWindow = Rectangle [(0 0) (1.08 2.01)]
	}
	Refinement "RefinementPlacement_channel" {
		Reference = "RefinementDefinition_channel"
		RefineWindow = Rectangle [(0.3 1.85) (0.78 2)]
	}
}

