pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
	property real memoryTotal: 1
	property real memoryFree: 0
	property real memoryUsed: memoryTotal - memoryFree
    property real memoryUsedPercentage: memoryUsed / memoryTotal
    property real swapTotal: 1
	property real swapFree: 0
	property real swapUsed: swapTotal - swapFree
    property real swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0
    property real cpuUsage: 0
    property var previousCpuStats

    property string gpuDevice: "" // PCI address of the NVIDIA card, empty when there is none
    property bool gpuAsleep: true
    property real gpuUsage: 0
    property real gpuMemoryUsed: 0 // MiB
    property real gpuMemoryTotal: 0 // MiB

    property string maxAvailableMemoryString: kbToGbString(ResourceUsage.memoryTotal)
    property string maxAvailableSwapString: kbToGbString(ResourceUsage.swapTotal)
    property string maxAvailableCpuString: "--"

    readonly property int historyLength: Config?.options.resources.historyLength ?? 60
    property list<real> cpuUsageHistory: []
    property list<real> memoryUsageHistory: []
    property list<real> swapUsageHistory: []

    function kbToGbString(kb) {
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    function updateMemoryUsageHistory() {
        memoryUsageHistory = [...memoryUsageHistory, memoryUsedPercentage]
        if (memoryUsageHistory.length > historyLength) {
            memoryUsageHistory.shift()
        }
    }
    function updateSwapUsageHistory() {
        swapUsageHistory = [...swapUsageHistory, swapUsedPercentage]
        if (swapUsageHistory.length > historyLength) {
            swapUsageHistory.shift()
        }
    }
    function updateCpuUsageHistory() {
        cpuUsageHistory = [...cpuUsageHistory, cpuUsage]
        if (cpuUsageHistory.length > historyLength) {
            cpuUsageHistory.shift()
        }
    }
    function updateHistories() {
        updateMemoryUsageHistory()
        updateSwapUsageHistory()
        updateCpuUsageHistory()
    }

	Timer {
		interval: 1
        running: true 
        repeat: true
		onTriggered: {
            // Reload files
            fileMeminfo.reload()
            fileStat.reload()

            // Parse memory and swap usage
            const textMeminfo = fileMeminfo.text()
            memoryTotal = Number(textMeminfo.match(/MemTotal: *(\d+)/)?.[1] ?? 1)
            memoryFree = Number(textMeminfo.match(/MemAvailable: *(\d+)/)?.[1] ?? 0)
            swapTotal = Number(textMeminfo.match(/SwapTotal: *(\d+)/)?.[1] ?? 1)
            swapFree = Number(textMeminfo.match(/SwapFree: *(\d+)/)?.[1] ?? 0)

            // Parse CPU usage
            const textStat = fileStat.text()
            const cpuLine = textStat.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
            if (cpuLine) {
                const stats = cpuLine.slice(1).map(Number)
                const total = stats.reduce((a, b) => a + b, 0)
                const idle = stats[3]

                if (previousCpuStats) {
                    const totalDiff = total - previousCpuStats.total
                    const idleDiff = idle - previousCpuStats.idle
                    cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0
                }

                previousCpuStats = { total, idle }
            }

            root.updateGpu()
            root.updateHistories()
            interval = Config.options?.resources?.updateInterval ?? 3000
        }
	}

    // nvidia-smi opens the card, and an open card cannot suspend: asked on every
    // tick, it alone would keep the card awake. So it is asked only while some
    // program already has the card open; otherwise the card reads as idle.
    function updateGpu() {
        if (root.gpuDevice === "") return;
        fileGpuPower.reload();
        root.gpuAsleep = fileGpuPower.text().trim() !== "active";
        if (root.gpuAsleep) {
            root.gpuUsage = 0;
            root.gpuMemoryUsed = 0;
        } else if (!gpuQueryProc.running) {
            gpuQueryProc.running = true;
        }
    }

    FileView {
        id: fileGpuPower
        blockLoading: true
        path: root.gpuDevice === "" ? "" : `/sys/bus/pci/devices/${root.gpuDevice}/power/runtime_status`
    }

    Process {
        id: findGpuProc
        running: true
        command: ["bash", "-c", "lspci -Dn -d 10de::0300 | awk 'NR==1{print $1}'"]
        stdout: StdioCollector {
            onStreamFinished: root.gpuDevice = text.trim()
        }
    }

    Process {
        id: gpuQueryProc
        command: ["bash", "-c", "fuser -s /dev/nvidia0 && nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [usage, used, total] = text.trim().split(",").map(Number);
                if (isNaN(total)) {
                    root.gpuUsage = 0;
                    root.gpuMemoryUsed = 0;
                    return;
                }
                root.gpuUsage = usage / 100;
                root.gpuMemoryUsed = used;
                root.gpuMemoryTotal = total;
            }
        }
    }

	FileView { id: fileMeminfo; path: "/proc/meminfo" }
    FileView { id: fileStat; path: "/proc/stat" }

    Process {
        id: findCpuMaxFreqProc
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        command: ["bash", "-c", "lscpu | grep 'CPU max MHz' | awk '{print $4}'"]
        running: true
        stdout: StdioCollector {
            id: outputCollector
            onStreamFinished: {
                root.maxAvailableCpuString = (parseFloat(outputCollector.text) / 1000).toFixed(0) + " GHz"
            }
        }
    }
}
