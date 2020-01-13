import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.13
import ArcGIS.AppFramework 1.0

Page {
    id:page
    signal openMenu()
    property string titleText:""
    property var descText
    header: ToolBar{
        contentHeight: 56*app.scaleFactor
        Material.primary: app.primaryColor
        RowLayout {
            anchors.fill: parent
            spacing: 0
            Item{
                Layout.preferredWidth: 4*app.scaleFactor
                Layout.fillHeight: true
            }
            ToolButton {
                indicator: Image{
                    width: parent.width*0.5
                    height: parent.height*0.5
                    anchors.centerIn: parent
                    source: "./assets/menu.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }
                onClicked: {
                    openMenu();
                }
            }
            Item{
                Layout.preferredWidth: 20*app.scaleFactor
                Layout.fillHeight: true
            }
            Label {
                Layout.fillWidth: true
                text: titleText
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter               
                font.pixelSize: app.subtitleFontSize
                color: app.headerTextColor
            }

            ToolButton {
                indicator: Image{
                    width: parent.width*0.5
                    height: parent.height*0.5
                    anchors.centerIn: parent
                    horizontalAlignment: Qt.AlignRight
                    verticalAlignment: Qt.AlignVCenter
                    source: "./assets/more.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }
                onClicked: {
                    optionsPanel.toggle()
                }
            }
        }
    }

    Rectangle{
        anchors.fill: parent
        color: app.appBackgroundColor

        Label{
            Material.theme: app.lightTheme? Material.Light : Material.Dark
            anchors.centerIn: parent
            font.pixelSize: app.titleFontSize
            font.bold: true
            wrapMode: Text.Wrap
            padding: 16*app.scaleFactor
            text: descText > ""? descText:""
        }
    }

    OptionsMenuPanel{
        id:optionsPanel
        x: page.width-optionsPanel.width-8*app.scaleFactor
        y: page.y-36*app.scaleFactor
    }
}
