/* Copyright 2020 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */


// You can run your app in Qt Creator by pressing Alt+Shift+R.
// Alternatively, you can run apps through UI using Tools > External > AppStudio > Run.
// AppStudio users frequently use the Ctrl+A and Ctrl+I commands to
// automatically indent the entirety of the .qml file.


import QtQuick 2.13
import QtQml 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.13 as Controls
import QtQuick.Controls 1.4 as Ctrl
import QtQuick.Controls.Material 2.13
import QtGraphicalEffects 1.0
import QtPositioning 5.3
import QtSensors 5.3
import QtQuick.Extras 1.4
import QtQuick.Dialogs 1.3

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.6
import "bucketCreate.js" as CreateBucket

App{
    id: app
    width: 421
    height: 750

    property bool lightTheme: true
    property int menuCurrentIndex: 0
    property variant bucketData
    property variant serviceFields:[]





    // App color properties
    readonly property color primaryColor:"#3F51B5"
    readonly property color accentColor: Qt.lighter(primaryColor,1.2)
    readonly property color appBackgroundColor: lightTheme? "#FAFAFA":"#303030"
    readonly property color appDialogColor: lightTheme? "#FFFFFF":"424242"
    readonly property color appPrimaryTextColor: lightTheme? "#000000":"#FFFFFF"
    readonly property color appSecondaryTextColor: Qt.darker(appPrimaryTextColor)
    readonly property color headerTextColor:"#FFFFFF"
    readonly property color listViewDividerColor:"#19000000"


    // App size properties

    property real scaleFactor: AppFramework.displayScaleFactor
    readonly property real baseFontSize: app.width<450*app.scaleFactor? 21 * scaleFactor:23 * scaleFactor
    readonly property real titleFontSize: app.baseFontSize
    readonly property real subtitleFontSize: 1.1 * app.baseFontSize
    readonly property real captionFontSize: 0.6 * app.baseFontSize

    // properties used by page 2, the list of bucket lists
    property real bucketNum: 0
    property string newBucketName
    property variant listOfBuckets:[]
    property string activeServiceURL:''

    //properties used by the map view of the bucket lists
    property string currentName: "None"
    property string currentBucket:"States"
    property bool currentVisited: false
    property bool updateVisited: false
    property string currentNameField:"NAME"
    property variant currentDate: [2020,"January",1]
    property string currentPhoto: "None"
    property string currentItem:"0"
    property variant monthsArray: {"January":1,"February":2,"March":3,"April":4,"May":5,"June":6,"July":7,"August":8,"September":9,"October":10,"November":11,"December":12}
    property string fileName: "data.json"
    property FileFolder sourceFolder: app.folder.folder("data")
    property FileFolder destFolder: AppFramework.userHomeFolder.folder("GeoBucketList")
    property string destPath: destFolder.filePath(fileName)
    property url destUrl: destFolder.fileUrl(fileName)
    property variant visitedSymbolList: []
    property var uValuesArray: []
    property bool reloadit:false


// copy the original data file to the local machine
    function copyLocalData() {
        if(destFolder.file("data.json").exists){
            console.log("data already placed")
        }
        else{
            console.log("placing data")
        destFolder.makeFolder();
        sourceFolder.copyFile(fileName, destPath);
        return destUrl;
        }
    }

    //File controls for the data
    File{
        id:bucketFile
        path:destPath
    }
    FileFolder{
        id:fileControl

    }



    // Load Page1 as your default page
    Loader{
        id: loader
        anchors.fill: parent
        sourceComponent: page1ViewPage

        //load the previously saved data
        onLoaded: {
            copyLocalData()

            var fileread
            bucketFile.open(File.OpenModeReadWrite)
            fileread = bucketFile.readAll()
            bucketData = JSON.parse(fileread)

            bucketFile.close()

        }
    }

    Rectangle{
        id: mask
        anchors.fill: parent
        color: "black"
        opacity: drawer.position*0.54
        Material.theme: app.lightTheme ? Material.Light : Material.Dark

    }
    Controls.Drawer {
        id: drawer
        width: Math.min(parent.width, parent.height, 600*app.scaleFactor) * 0.80
        height: parent.height
        Material.elevation: 16
        Material.background: app.appDialogColor

        edge: Qt.LeftEdge
        dragMargin: 0
        contentItem: SideMenuPanel{
            currentIndex: menuCurrentIndex
            menuModel: drawerModel
            onMenuSelected: {
                drawer.close();
                switch(action){
                case "page1":
                    loader.sourceComponent = page1ViewPage;                   
                    break;
                case "page2":
                    loader.sourceComponent = page2ViewPage;
                    break;
                case "about":
                    loader.sourceComponent = aboutViewPage;
                    break;
                default:
                    break;
                }
            }
        }

    }

    ListModel{
        id: drawerModel
        ListElement {action:"page1"; type: "delegate"; name: qsTr("Map"); iconSource: ""}
        ListElement {action:"page2"; type: "delegate"; name: qsTr("Bucket Lists"); iconSource: ""}
        ListElement {action:""; type: "divider"; name: ""; iconSource: ""}
        ListElement {action:"about"; type: "delegate"; name: qsTr("About"); iconSource: ""}

    }
    Component{
        id: page1ViewPage //map page
        TemplatePage{
            titleText: qsTr("GeoBucketList")

            onOpenMenu: {
                drawer.open();
            }
            MapView {
                id: mapView
                anchors.fill:parent

                Map {
                    id:map
                    BasemapImagery {}
                    initialViewpoint: viewpoint
                    ViewpointExtent {
                            id: viewpoint
                            extent: Envelope {
                                xMin: -15000000.778729
                                yMin: 2500000.003309
                                xMax: -6500000.879667
                                yMax: 4600000.535773
                            }
                        }
                    // start the location display
                    onLoadStatusChanged: {
                        if (loadStatus === Enums.LoadStatusLoaded) {
                            mapView.locationDisplay.start();
                        }
                    }
                    FeatureLayer{
                        id:featureLayer
                        UniqueValueRenderer {
                            id:uniqueRenderer
                            property bool uready: false
                            fieldNames: ["OBJECTID"]
                            defaultSymbol: SimpleFillSymbol {
                                style: Enums.SimpleFillSymbolStyleSolid
                                color: "#404040"

                                SimpleLineSymbol {
                                    style: Enums.SimpleLineSymbolStyleSolid
                                    color: "#101010"
                                    width: 2
                                }
                            }
                            onUreadyChanged: {
                                for(var i = 0;i<uValuesArray.length;i++){
                                    uniqueValues.append(uValuesArray[i])
                                    console.log("ln327:another one addded")
                                }
                            }
                        }

                        ServiceFeatureTable{
                            id:activeService
                            url:activeServiceURL
                            onLoadStatusChanged: {
                                if (loadStatus === Enums.LoadStatusLoaded) {
                                    mapView.loadVisited() //This loads the unique value renderer for each item that has been visisted
                                }
                            }
                        }
                    }
                }
                // set the location display's position source
                locationDisplay {
                    positionSource: PositionSource {}
                    compass: Compass {}
                }
                Image {
                    id:gpsIcon
                    source: "assets/Re-Center.png"
                    anchors {
                        left: parent.left
                        top: comboBoxBasemap.bottom
                        margins: 5
                    }
                    width:35
                    height:35
                    MouseArea {
                            anchors.fill: parent
                            onClicked: {
                               mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeRecenter;
                            }
                        }
                }

                //basemap control
                Controls.ComboBox {
                        id: comboBoxBasemap
                        anchors {
                            left: parent.left
                            top: parent.top
                            margins: 5
                        }
                        property int modelWidth: 0
                        width: modelWidth + leftPadding + rightPadding + indicator.width
                        textRole: "text"
                        model: ListModel {
                            ListElement { text: "Imagery (Raster)"; map: "BasemapImagery" }
                            ListElement { text: "Topographic"; map: "BasemapTopographic" }
                            ListElement { text: "Streets"; map: "BasemapStreets" }
                            ListElement { text: "Streets (Vector)"; map: "BasemapStreetsVector" }
                            ListElement { text: "Imagery with Labels (Vector)"; map: "BasemapImageryWithLabelsVector" }
                            ListElement { text: "Light Gray Canvas (Vector)"; map: "BasemapLightGrayCanvasVector" }
                        }

                        Component.onCompleted : {
                            for (var i = 0; i < model.count; ++i) {
                                metrics.text = model.get(i).text;
                                modelWidth = Math.max(modelWidth, metrics.width);
                            }
                        }

                        TextMetrics {
                            id: metrics
                            font: comboBoxBasemap.font
                        }

                        onCurrentIndexChanged: {
                            // Call this JavaScript function when the current selection changes
                            if (map.loadStatus === Enums.LoadStatusLoaded)
                                changeBasemap(model.get(currentIndex).map);
                        }

                        function changeBasemap(type) {
                            map.basemap = ArcGISRuntimeEnvironment.createObject(type);
                        }
                    }

                //Identify feature
                onMouseClicked: {
                    var tolerance = 10;
                    var returnPopupsOnly = false;
                    mapView.identifyLayer(featureLayer, mouse.x, mouse.y, tolerance, returnPopupsOnly)
                }
                onIdentifyLayerStatusChanged: {
                    if (identifyLayerStatus === Enums.TaskStatusCompleted) {
                        // clear any previous selections
                        featureLayer.clearSelection();


                        // create an array to store the features
                        var identifiedObjects = [];
                        for (var i = 0; i < identifyLayerResult.geoElements.length; i++){
                            var elem = identifyLayerResult.geoElements[i];
                            identifiedObjects.push(elem);
                        }
                        // cache the number of identifyLayerResult
                        var count = identifyLayerResult.geoElements.length;

                        // select the features in the feature layer
                        featureLayer.selectFeatures(identifiedObjects);

                        //Get the details from the data and prepare to open the data drawer
                        currentItem = identifiedObjects[0].attributes.attributesJson.OBJECTID
                        var thisItem = bucketData.bucketLists[currentBucket].features[currentItem]
                        currentName = thisItem.name
                        currentDate = thisItem.date
                        currentVisited = thisItem.visited
                        updateVisited = currentVisited
                        currentPhoto = thisItem.photo
                        console.log("%1 %2 selected.".arg(count).arg(count > 1 ? "features" : "feature"))
                        contentDrawer.open()
                    }
                }

                //This function determines which items on the feature layer have been visited and creates the unique value renderer for each one.
                function loadVisited(){
                    visitedSymbolList = []
                    for(let key in bucketData.bucketLists[currentBucket].features){
                        console.log(key,"evaluated")
                        if(bucketData.bucketLists[currentBucket].features[key].visited === true){
                            var newUnique = Qt.createQmlObject('import QtQuick 2.0
                                                import Esri.ArcGISRuntime 100.6
                                                UniqueValue {
                                                    values: ['+key+']
                                                    symbol: SimpleFillSymbol{
                                                        color:"#20404040"
                                                        style:Enums.SimpleFillSymbolStyleSolid
                                                        SimpleLineSymbol{
                                                            style: Enums.SimpleLineSymbolStyleSolid
                                                            color:"#101010"
                                                            width:2
                                                        }
                                                    }
                                                    Component.onCompleted: {
                                                        console.log("UniqueValue:",'+key+'," completed")
                                                    }
                                                }',app)
                            uValuesArray.push(newUnique)
                       }
                    }
                    uniqueRenderer.uready = (uniqueRenderer.uready ? false : true)
                }

                //This is the drawer that opens when a feature is clicked and provides information on if the feature is visited or not, etc.
                Controls.Drawer{
                    id:contentDrawer
                    width:parent.width
                    padding: 10
                    height:parent.height*.3
                    edge:Qt.BottomEdge
                    interactive: true
                    Flickable{
                        width:app.width
                        height:app.height*.3
                        contentHeight: column33.height
                        contentWidth: column33.width
                        Controls.ScrollBar.vertical: Controls.ScrollBar{ }
                        Column{
                            id:column33
                            padding: 15
                            Text{
                                text:"Name: " + currentName
                                font.pointSize: baseFontSize*.66
                            }
                            Text{
                                font.pointSize: baseFontSize*.66
                                text:"Visited: "+currentVisited
                            }
                            Text{
                                font.pointSize: baseFontSize*.66
                                text:"Date visited: "+currentDate[0]+" "+currentDate[1]+" "+currentDate[2]
                            }
                            Image{
                                width:app.width *.8
                                height:100
                                asynchronous: true
                                fillMode: Image.PreserveAspectFit
                                source:{
                                if (currentPhoto == "None"){"assets/no.png"}
                                else {currentPhoto}}
                            }
                            Controls.Button{
                                id:editVisitButton

                                text:"edit"
                                onClicked:{
                                    editVisitWindow.open()
                                }
                            }
                        }
                    }
                }

                //This is the popup for editing what data is already there.
                Controls.Popup{
                    id:editVisitWindow
                    width:parent.width*.85
                    height:parent.height*.85
                    anchors.centerIn: parent
                    Column{
                        padding:15
                        Text{
                            font.pointSize: baseFontSize
                            text:currentName
                        }
                        ToggleButton{
                            id:visitedToggle
                            text:"Visited?"
                            checked:updateVisited
                            onCheckedChanged: {
                                currentVisited = !updateVisited
                            }
                        }
                        Row{
                            Controls.ComboBox{
                                width:editVisitWindow.width*.3
                                id:yearPicker
                                model:[2020,2019,2018,2017,2016,2015,2014,2013,2012,2011,2010,2009,2008,2007,2006,2005,2004,2003,2002,2001,2000,1999,1998,1997,1996,1995,1994,1993,1992,1991,1990,1989,1988,1987,1986,1985,1984,1983,1982,1981,1980,1979,1978,1977,1976,1975,1974,1973,1972,1971,1970,1969,1968,1967,1966,1965,1964,1963,1962,1961,1960,1959,1958,1957,1956,1955,1954,1953,1952,1951,1950,1949,1948,1947,1946,1945,1944,1943,1942,1941,1940,1939,1938,1937,1936,1935,1934,1933,1932,1931,1930,1929,1928,1927,1926,1925,1924,1923,1922,1921,1920]
                            }
                            Controls.ComboBox{
                                id:monthpicker
                                width:editVisitWindow.width*.4
                                model:["January","February","March","April","May","June","July","August","September","October","November","December"]
                            }
                            Controls.ComboBox{
                                id:daypicker
                                width:editVisitWindow.width*.2
                                model:[31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1]
                            }
                        }
                        Controls.Button{
                            id:photoSelect
                            text:"Change photo"
                            onClicked: {
                                fileDialog.open()
                            }
                        }
                        Controls.Button{
                            id:commitChanges
                            text:"Save visit"
                            onClicked: {
                                console.log(yearPicker.currentText, monthpicker.currentText, daypicker.currentText)
                                currentDate = [yearPicker.currentText, monthpicker.currentText, daypicker.currentText]
                                bucketData.bucketLists[currentBucket].features[currentItem].visited = currentVisited
                                bucketData.bucketLists[currentBucket].features[currentItem].date = currentDate
                                bucketData.bucketLists[currentBucket].features[currentItem].photo = currentPhoto
                                fileControl.removeFile("data.json")

                                //save the data
                                bucketFile.open(File.OpenModeWriteOnly)
                                bucketFile.write("")
                                bucketFile.write(JSON.stringify(bucketData))
                                bucketFile.close()
                                console.log("File saved!")
                                editVisitWindow.close()
                                uniqueRenderer.uniqueValues.clear()
                                uValuesArray = []
                                mapView.loadVisited()
                                currentVisited = false
                                updateVisited = false
                            }
                        }
                    }
                }
            }
        }
    }

    //get the filename for the image
    FileDialog {
        id: fileDialog
        title: "Please choose a photo"
        //folder: shortcuts.home
        selectMultiple: false
        selectFolder: false
        onAccepted: {
            console.log("You chose: " + fileDialog.fileUrl)
            currentPhoto = fileDialog.fileUrl
        }
        onRejected: {
            console.log("Canceled")
        }
        visible:false
    }

    //Page 2, which is the list of bucket lists
    Component{
        id: page2ViewPage
        TemplatePage{
            titleText:qsTr("Bucket Lists")
            descText: qsTr("Choose a bucket list and click open")
            onOpenMenu: {
                drawer.open();
            }
            Flickable {
                id:flickland
                anchors.fill:parent
                z:0
                Controls.ScrollBar.vertical: Controls.ScrollBar{ }
                Controls.ButtonGroup {

                    buttons: bucketLists.children
                    onCheckedButtonChanged: {
                        var t = checkedButton.text
                        activeServiceURL = bucketData.bucketLists[t].url
                        currentBucket = t
                    }
                }
                Column {
                    id: bucketLists
                    width: parent.width
                    //anchors.top:parent.top
                    anchors.left:parent.left
                    anchors.right: parent.right
                    Component.onCompleted:  {
                        var string = ''
                        for(let key in bucketData.bucketLists){
                            var bname = bucketData.bucketLists[key].name;
                            CreateBucket.createBucket(bucketLists,"bucketListTemplate.qml",{name:bname},bucketNum)
                        }
                    }
                }
            }
            Row{
                anchors.bottom: flickland.bottom
                Controls.Button {
                    text: "Open"
                    onClicked: {
                        loader.sourceComponent = page1ViewPage
                    }
                }
                Rectangle{
                    width:15
                    color:"transparent"
                }
                Controls.Button {
                    id:addBucketList
                    anchors.margins: 10
                    text:"Add new bucket list"
                    onClicked: addNewBucketList.open()
                }
            }
        }
    }
    Component{
        id: aboutViewPage
        TemplatePage{
            titleText: qsTr("About")
            Text{
                anchors.fill: parent
                wrapMode: Text.WordWrap
                anchors.centerIn: parent
                anchors.margins: 15
                font.pointSize: baseFontSize*.6
                text:qsTr("The GeoBucketList is a mobile application to track your geography 'bucket list' - where you have been and where you want to go. https://devpost.com/software/geobucketlist")
            }

            onOpenMenu: {
                drawer.open();
            }
        }
    }

    // This is the pop up used in page 2 for adding a new bucket list to the app
    Controls.Popup {
        id:addNewBucketList
        width:app.width *.85
        anchors.centerIn: app
        height: app.height*.85
        Column{
            width:parent.width
            Text{
                id:t1
                text:"What is this Bucket List Called?"
                font.pointSize: baseFontSize
                wrapMode: Text.WordWrap
                width:parent.width

            }
            Controls.TextField{
                id:bucketNameField
                width:parent.width*.85
                selectByMouse: true

            }

            Text{
                text:"Enter the Bucket List Service URL"
                font.pointSize: baseFontSize
                wrapMode: Text.WordWrap
                width:parent.width

            }
            Controls.TextField{
                id:serviceURLField
                width:parent.width*.85
                selectByMouse: true

            }
            Controls.Button{
                id:getServiceInfo
                text:"Get Service Info"
                onClicked: {
                    newLayerFeatureTable.url = serviceURLField.text
                }
            }


            Text{
                id:t2
                text:"What field is the feature name field?"
                font.pointSize: baseFontSize
                wrapMode: Text.WordWrap
                width:parent.width

            }
            Controls.ComboBox{
                id:f2
                model:serviceFields
                width:parent.width*.85

            }
            Controls.Button{
                id:b2

                //anchors.bottom:parent.bottom
                text:"Add"
                onClicked: {
                    newBucketName = bucketNameField.text;
                    bucketData.bucketLists[bucketNameField.text].url=serviceURLField.text;
                    bucketData.bucketLists[bucketNameField.text].nameField=f2.currentText;

                    //MORE WORK IS NEEDED HERE to finish importing the OBJECTIDs or FIDs from the feature layer to the data file.
                    //In addition, these fields need to be added to the data: visited, date, photo

                }
            }

        }

    }
// this feature layer is used for adding new bucket lists - it checks the feature layer URL that is provided
    FeatureLayer{
            id:newLayer

                ServiceFeatureTable {
                    id:newLayerFeatureTable
                    onUrlChanged: {
                        newLayerFeatureTable.load()
                    }
                    onLoadStatusChanged:  {
                        var fields = [];
                        if (loadStatus === Enums.LoadStatusLoaded) {
                            var fs = newLayerFeatureTable.fields
                            for(var i=0;i<fs.length;i++){
                                console.log(fs[i].alias)
                                fields.push(fs[i].alias)

                                }
                            serviceFields = fields;

                            }
                        }
                }

    }

}






