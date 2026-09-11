import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "triptych"

  property bool popupOpen: false
  property var selectedByWorkspace: ({})
  property string pendingPreset: ""
  property string pendingWorkspaceKey: ""
  property string pendingWorkspaceLabel: ""
  property string statusText: "Choose a layout for this workspace"

  readonly property bool opened: popupOpen
  readonly property string pluginDir: Quickshell.env("HOME") + "/.config/omarchy/plugins/triptych"
  readonly property var focusedWorkspace: Hyprland.focusedWorkspace
  readonly property int activeWorkspaceId: focusedWorkspace ? focusedWorkspace.id : -1
  readonly property string activeWorkspaceKey: String(activeWorkspaceId)
  readonly property string activeWorkspaceLabel: focusedWorkspace
    ? (focusedWorkspace.name ? String(focusedWorkspace.name) : String(focusedWorkspace.id))
    : "unknown"
  readonly property string selectedPreset: selectedByWorkspace[activeWorkspaceKey] || "center-master"
  readonly property var presets: [
    {
      id: "center-master",
      name: "Ultrawide center",
      icon: "▥",
      description: "Full-height center; side columns stack vertically"
    },
    {
      id: "left-master",
      name: "Left master",
      icon: "▧",
      description: "Large left window; remaining windows stack on the right"
    },
    {
      id: "equal-columns",
      name: "Equal columns",
      icon: "▥",
      description: "Three equal scrolling columns across the monitor"
    }
  ]

  function open() { popupOpen = true }
  function close() { popupOpen = false }
  function toggle() { popupOpen = !popupOpen }

  function applyPreset(preset) {
    if (!preset || applyProcess.running) return
    pendingPreset = preset.id
    pendingWorkspaceKey = activeWorkspaceKey
    pendingWorkspaceLabel = activeWorkspaceLabel
    statusText = "Applying " + preset.name + " to workspace " + activeWorkspaceLabel + "…"
    applyProcess.command = [pluginDir + "/triptych-apply", preset.id]
    applyProcess.running = true
  }

  function rememberPreset(workspaceKey, presetId) {
    var next = ({})
    for (var key in selectedByWorkspace) next[key] = selectedByWorkspace[key]
    next[workspaceKey] = presetId
    selectedByWorkspace = next
  }

  component LayoutPreview: Item {
    id: preview
    required property string presetId
    property color foreground: Color.foreground
    property color accent: Color.accent
    property bool selected: false

    readonly property var boxes: presetId === "center-master" ? [
      { x: 0.00, y: 0.00, w: 0.26, h: 0.48 },
      { x: 0.00, y: 0.52, w: 0.26, h: 0.48 },
      { x: 0.30, y: 0.00, w: 0.40, h: 1.00 },
      { x: 0.74, y: 0.00, w: 0.26, h: 0.48 },
      { x: 0.74, y: 0.52, w: 0.26, h: 0.48 }
    ] : presetId === "left-master" ? [
      { x: 0.00, y: 0.00, w: 0.48, h: 1.00 },
      { x: 0.52, y: 0.00, w: 0.48, h: 0.48 },
      { x: 0.52, y: 0.52, w: 0.48, h: 0.48 }
    ] : [
      { x: 0.00, y: 0.00, w: 0.31, h: 1.00 },
      { x: 0.345, y: 0.00, w: 0.31, h: 1.00 },
      { x: 0.69, y: 0.00, w: 0.31, h: 1.00 }
    ]

    Repeater {
      model: preview.boxes

      Rectangle {
        required property var modelData
        x: Math.round(modelData.x * preview.width)
        y: Math.round(modelData.y * preview.height)
        width: Math.max(2, Math.round(modelData.w * preview.width))
        height: Math.max(2, Math.round(modelData.h * preview.height))
        radius: Style.space(2)
        color: preview.selected
          ? Style.selectedFillFor(preview.foreground, preview.accent)
          : Style.normalFillFor(preview.foreground, preview.accent)
        border.width: 1
        border.color: preview.selected ? preview.accent : Qt.darker(preview.foreground, 1.8)
      }
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  IpcHandler {
    target: "triptych"

    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.toggle() }
    function select(preset: string): string {
      for (var i = 0; i < root.presets.length; i++) {
        if (root.presets[i].id === preset) {
          root.applyPreset(root.presets[i])
          return "ok"
        }
      }
      return "unknown"
    }
  }

  Process {
    id: applyProcess

    onExited: function(exitCode) {
      if (exitCode === 0) {
        root.rememberPreset(root.pendingWorkspaceKey, root.pendingPreset)
        root.statusText = "Applied to workspace " + root.pendingWorkspaceLabel
        successReset.restart()
      } else {
        root.statusText = "Could not apply layout (exit " + exitCode + ")"
      }
      root.pendingPreset = ""
      root.pendingWorkspaceKey = ""
      root.pendingWorkspaceLabel = ""
    }
  }

  Timer {
    id: successReset
    interval: 2500
    onTriggered: root.statusText = "Choose a layout for this workspace"
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "▦"
    slotSize: Style.bar.statusSlot
    tooltipText: "Triptych"
    active: root.popupOpen
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) root.toggle()
    }
  }

  PopupCard {
    id: popup
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(540))
    contentHeight: popup.fittedContentHeight(content.implicitHeight)

    Column {
      id: content
      anchors.fill: parent
      spacing: Style.space(10)

      Text {
        text: "Triptych · Workspace " + root.activeWorkspaceLabel
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.subtitle
        font.bold: true
      }

      Text {
        width: parent.width
        text: root.statusText
        color: Qt.darker(root.bar.foreground, 1.35)
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.bodySmall
        wrapMode: Text.Wrap
      }

      PanelSeparator {
        foreground: root.bar.foreground
      }

      Grid {
        id: presetGrid
        width: parent.width
        columns: 3
        spacing: Style.space(8)

        Repeater {
          model: root.presets

          Button {
            id: presetCard
            required property var modelData
            width: (presetGrid.width - presetGrid.spacing * 2) / 3
            height: Style.space(152)
            text: ""
            tooltipText: modelData.description
            foreground: root.bar.foreground
            bordered: true
            selected: root.selectedPreset === modelData.id
            enabled: !applyProcess.running
            opacity: enabled ? 1.0 : 0.55
            onClicked: root.applyPreset(modelData)

            Column {
              anchors.fill: parent
              anchors.margins: Style.space(10)
              spacing: Style.space(7)

              LayoutPreview {
                width: parent.width
                height: Style.space(72)
                presetId: presetCard.modelData.id
                foreground: root.bar.foreground
                accent: Color.accent
                selected: presetCard.selected
              }

              Text {
                width: parent.width
                text: presetCard.modelData.name
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.bodySmall
                font.bold: presetCard.selected
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
              }

              Text {
                width: parent.width
                text: presetCard.modelData.description
                color: Qt.darker(root.bar.foreground, 1.45)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
              }
            }
          }
        }
      }

      Text {
        width: parent.width
        text: "Each workspace can use its own preset during this session · your permanent Hyprland config is unchanged"
        color: Qt.darker(root.bar.foreground, 1.55)
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.caption
        wrapMode: Text.Wrap
      }
    }
  }
}
