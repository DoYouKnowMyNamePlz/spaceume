/*
    SPDX-FileCopyrightText: 2023 eatsu <mkrmdk@gmail.com>
    SPDX-FileCopyrightText: 2026 Kilo <kilo@localhost>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.kirigami 2.20 as Kirigami

import org.kde.kcmutils as KCM
import org.kde.config as KConfig

PlasmoidItem {
    id: root

    property bool horizontal: Plasmoid.formFactor !== PlasmaCore.Types.Vertical

    Layout.fillWidth: Plasmoid.configuration.expanding
    Layout.fillHeight: Plasmoid.configuration.expanding

    Layout.minimumWidth: Plasmoid.containment.corona?.editMode ? Kirigami.Units.gridUnit * 2 : 1
    Layout.minimumHeight: Plasmoid.containment.corona?.editMode ? Kirigami.Units.gridUnit * 2 : 1
    Layout.preferredWidth: horizontal
        ? (Plasmoid.configuration.expanding ? optimalSize : Plasmoid.configuration.length)
        : 0
    Layout.preferredHeight: horizontal
        ? 0
        : (Plasmoid.configuration.expanding ? optimalSize : Plasmoid.configuration.length)

    preferredRepresentation: fullRepresentation

    // Search the actual gridLayout of the panel
    property GridLayout panelLayout: {
        let candidate = root.parent;
        while (candidate) {
            if (candidate instanceof GridLayout) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null;
    }

    property real optimalSize: {
        if (!panelLayout || !Plasmoid.configuration.expanding) return Plasmoid.configuration.length;
        let expandingSpacers = 0;
        let thisSpacerIndex = null;
        let sizeHints = [0];
        // Children order is guaranteed to be the same as the visual order of items in the layout
        for (const i in panelLayout.children) {
            const child = panelLayout.children[i];
            if (!child.visible) continue;

            if (child.applet && child.applet.plasmoid.pluginName === Plasmoid.pluginName && child.applet.plasmoid.configuration.expanding) {
                if (child.applet.plasmoid === Plasmoid) {
                    thisSpacerIndex = expandingSpacers
                }
                sizeHints.push(0)
                expandingSpacers += 1
            } else if (root.horizontal) {
                sizeHints[sizeHints.length - 1] += Math.min(child.Layout.maximumWidth, Math.max(child.Layout.minimumWidth, child.Layout.preferredWidth)) + panelLayout.rowSpacing;
            } else {
                sizeHints[sizeHints.length - 1] += Math.min(child.Layout.maximumHeight, Math.max(child.Layout.minimumHeight, child.Layout.preferredHeight)) + panelLayout.columnSpacing;
            }
        }
        sizeHints[0] *= 2; sizeHints[sizeHints.length - 1] *= 2
        let containment = panelLayout
        let opt = Plasmoid.configuration.length
        if (expandingSpacers > 0 && thisSpacerIndex !== null) {
            opt = (root.horizontal ? containment.width : containment.height) / expandingSpacers
                - sizeHints[thisSpacerIndex] / 2 - sizeHints[thisSpacerIndex + 1] / 2
        }
        return Math.max(opt, 0)
    }

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: sourceName => disconnectSource(sourceName)

        function exec(cmd) {
            connectSource(cmd);
        }
    }

    P5Support.DataSource {
        id: volume
        engine: "executable"
        connectedSources: []
        onNewData: sourceName => disconnectSource(sourceName)

        function volumeUp(step) {
            connectSource(`pactl set-sink-volume @DEFAULT_SINK@ +${step}%`);
        }

        function volumeDown(step) {
            connectSource(`pactl set-sink-volume @DEFAULT_SINK@ -${step}%`);
        }

        function muteToggle() {
            connectSource(`pactl set-sink-mute @DEFAULT_SINK@ toggle`);
        }
    }

    function runClickAction(action, command) {
        const shortcuts = [
            "Show Desktop",
            "Overview",
            "Grid View",
            "ExposeAll",
            "Expose",
            "ExposeClass",
        ];
        const shortcut = shortcuts[action - 1];

        if (shortcut) {
            executable.exec(`dbus-send --dest=org.kde.kglobalaccel --type=method_call /component/kwin org.kde.kglobalaccel.Component.invokeShortcut string:"${shortcut}"`);
        } else if (action === 7) {
            executable.exec(command);
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        property bool hovered: containsMouse

        acceptedButtons: {
            if (Plasmoid.configuration.rightClickAction > 0) {
                Qt.LeftButton | Qt.MiddleButton | Qt.RightButton;
            } else {
                // Don't disable the context menu
                Qt.LeftButton | Qt.MiddleButton;
            }
        }

        onEntered: hovered = true
        onExited: hovered = false

        onClicked: mouse => {
            if (Plasmoid.configuration.enableVolumeControl && hovered && mouse.button === Qt.MiddleButton) {
                volume.muteToggle();
                return;
            }
            switch (mouse.button) {
            case Qt.LeftButton:
                runClickAction(
                    Plasmoid.configuration.leftClickAction,
                    Plasmoid.configuration.leftClickCommand
                );
                break;
            case Qt.MiddleButton:
                runClickAction(
                    Plasmoid.configuration.middleClickAction,
                    Plasmoid.configuration.middleClickCommand
                );
                break;
            case Qt.RightButton:
                runClickAction(
                    Plasmoid.configuration.rightClickAction,
                    Plasmoid.configuration.rightClickCommand
                );
                break;
            }
        }

        onWheel: wheel => {
            if (Plasmoid.configuration.enableVolumeControl && hovered) {
                const delta = wheel.angleDelta.y || wheel.angleDelta.x;
                if (delta > 0) {
                    volume.volumeUp(Plasmoid.configuration.volumeStep);
                } else if (delta < 0) {
                    volume.volumeDown(Plasmoid.configuration.volumeStep);
                }
                wheel.accepted = true;
                return;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.highlightColor
        opacity: Plasmoid.containment.corona?.editMode ? 1 : 0
        visible: Plasmoid.containment.corona?.editMode || animator.running

        Behavior on opacity {
            NumberAnimation {
                id: animator
                duration: Kirigami.Units.longDuration
                // easing.type is updated after animation starts
                easing.type: Plasmoid.containment.corona?.editMode ? Easing.InCubic : Easing.OutCubic
            }
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Configure Virtual Desktops…")
            icon.name: "configure"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: KCM.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops")
        }
    ]
}
