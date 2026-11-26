/*
    SPDX-FileCopyrightText: 2023 eatsu <mkrmdk@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    Kirigami.FormLayout {
        Label {
            text: i18n("About Spaceume")
            font.bold: true
        }

        Label {
            text: i18n('<a href="https://github.com/DoYouKnowMyNamePlz/spaceume">GitHub Repository</a>')
            textFormat: Text.RichText
            linkActivationEnabled: true
            onLinkActivated: Qt.openUrlExternally(link)
        }

        Label {
            text: i18n('<a href="https://github.com/DoYouKnowMyNamePlz/spaceume/issues">Get Help / Report Issues</a>')
            textFormat: Text.RichText
            linkActivationEnabled: true
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}
