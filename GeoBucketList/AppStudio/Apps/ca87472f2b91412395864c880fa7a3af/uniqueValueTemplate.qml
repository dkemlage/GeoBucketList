import QtQuick 2.0
import Esri.ArcGISRuntime 100.6

UniqueValue {
    property string valueItem
    values: [valueItem]
    symbol: SimpleFillSymbol{
        color:"#20FF4040"
        style:Enums.SimpleFillSymbolStyleSolid
        SimpleLineSymbol{
            style: Enums.SimpleLineSymbolStyleSolid
            color:"#101010"
            width:2
        }

    }
    Component.onCompleted: {
        console.log("UniqueValue:",valueItem," completed")
    }
}



