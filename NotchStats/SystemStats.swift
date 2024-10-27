//
//  SystemStats.swift
//  NotchStats
//
//  Created by Abhigyan Mohanta on 27/10/24.
//

import Foundation
import Darwin

class SystemStats: ObservableObject {
    @Published var cpuUsage: Double = 0
    @Published var memoryUsage: Double = 0
    @Published var totalMemory: UInt64 = 0
    @Published var usedMemory: UInt64 = 0
    @Published var freeMemory: UInt64 = 0
    @Published var firstLineFromFile: String = ""
    
    private var timer: Timer?
    private var cpuInfo: processor_info_array_t?
    private var prevCPUInfo: processor_info_array_t?
    private var numCPUInfo: mach_msg_type_number_t = 0
    private var numPrevCPUInfo: mach_msg_type_number_t = 0
    private var numCPUs: uint = 0
    
    init() {
        var numCPUsU: natural_t = 0
        let result = host_processor_info(mach_host_self(),
                                       PROCESSOR_CPU_LOAD_INFO,
                                       &numCPUsU,
                                       &cpuInfo,
                                       &numCPUInfo)
        if result == KERN_SUCCESS {
            numCPUs = uint(numCPUsU)
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStats()
        }
        
        // Initialize the first line from the file
        firstLineFromFile = readFirstLineFromFile()
    }
    
    private func updateStats() {
        cpuUsage = calculateCPUUsage()
        updateMemoryUsage()
    }
    
    private func updateMemoryUsage() {
        var pageSize: vm_size_t = 0
        
        // Get page size
        host_page_size(mach_host_self(), &pageSize)
        
        var hostInfo = host_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
        
        // Get host info
        let kerr = host_info(mach_host_self(),
                            HOST_BASIC_INFO,
                            withUnsafeMutablePointer(to: &hostInfo) {
                                $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                                    UnsafeMutablePointer<integer_t>($0)
                                }
                            },
                            &count)
        
        if kerr == KERN_SUCCESS {
            // Calculate total memory in bytes
            totalMemory = UInt64(hostInfo.max_mem)
            
            var vmStats = vm_statistics64()
            var vmCount = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
            
            let result = withUnsafeMutablePointer(to: &vmStats) { vmStatsPointer in
                vmStatsPointer.withMemoryRebound(to: integer_t.self, capacity: Int(vmCount)) { pointer in
                    host_statistics64(mach_host_self(),
                                    HOST_VM_INFO64,
                                    pointer,
                                    &vmCount)
                }
            }
            
            if result == KERN_SUCCESS {
                // Calculate memory stats
                let active = UInt64(vmStats.active_count) * UInt64(pageSize)
                let inactive = UInt64(vmStats.inactive_count) * UInt64(pageSize)
                let wired = UInt64(vmStats.wire_count) * UInt64(pageSize)
                let compressed = UInt64(vmStats.compressor_page_count) * UInt64(pageSize)
                
                // Calculate used memory
                usedMemory = active + inactive + wired + compressed
                
                // Calculate free memory
                freeMemory = totalMemory - usedMemory
                
                // Calculate memory usage percentage
                memoryUsage = (Double(usedMemory) / Double(totalMemory) * 100.0 * 100).rounded() / 100
            }
        }
    }
    
    private func calculateCPUUsage() -> Double {
        var numCPUsU: natural_t = 0
        var newCPUInfo: processor_info_array_t?
        var newNumCPUInfo: mach_msg_type_number_t = 0
        
        let result = host_processor_info(mach_host_self(),
                                       PROCESSOR_CPU_LOAD_INFO,
                                       &numCPUsU,
                                       &newCPUInfo,
                                       &newNumCPUInfo)
        
        guard result == KERN_SUCCESS else {
            return 0.0
        }
        
        var totalUsage: Double = 0.0
        
        if let newCPUInfo = newCPUInfo {
            if let prevCPUInfo = prevCPUInfo {
                for i in 0..<Int(numCPUs) {
                    let baseIdx = Int(CPU_STATE_MAX) * i
                    
                    let userIdx = baseIdx + Int(CPU_STATE_USER)
                    let user = Int32(newCPUInfo[userIdx])
                    let prevUser = Int32(prevCPUInfo[userIdx])
                    
                    let systemIdx = baseIdx + Int(CPU_STATE_SYSTEM)
                    let system = Int32(newCPUInfo[systemIdx])
                    let prevSystem = Int32(prevCPUInfo[systemIdx])
                    
                    let niceIdx = baseIdx + Int(CPU_STATE_NICE)
                    let nice = Int32(newCPUInfo[niceIdx])
                    let prevNice = Int32(prevCPUInfo[niceIdx])
                    
                    let idleIdx = baseIdx + Int(CPU_STATE_IDLE)
                    let idle = Int32(newCPUInfo[idleIdx])
                    let prevIdle = Int32(prevCPUInfo[idleIdx])
                    
                    let inUse = user + system + nice
                    let prevInUse = prevUser + prevSystem + prevNice
                    
                    let total = inUse + idle
                    let prevTotal = inUse + prevIdle
                    
                    let delta = Double(total - prevTotal)
                    if delta == 0 {
                        totalUsage += 0
                    } else {
                        totalUsage += Double(inUse - prevInUse) / delta
                    }
                }
            }
            
            if let prevCPUInfo = self.prevCPUInfo {
                let prevCPUInfoSize = MemoryLayout<integer_t>.stride * Int(numPrevCPUInfo)
                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prevCPUInfo), vm_size_t(prevCPUInfoSize))
            }
            
            prevCPUInfo = newCPUInfo
            numPrevCPUInfo = newNumCPUInfo
        }
        
        return (totalUsage / Double(numCPUs) * 100.0 * 100).rounded() / 100
    }
    
    private func readFirstLineFromFile() -> String {
        let fileManager = FileManager.default
        
        // Get the path to the Documents directory
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent("NotchStats.txt")
            
            // Check if the file exists
            if !fileManager.fileExists(atPath: fileURL.path) {
                // If the file doesn't exist, create it and write "Shadow Monarch" to it
                do {
                    try "Shadow Monarch".write(to: fileURL, atomically: true, encoding: .utf8)
                } catch {
                    print("Error creating file: \(error)")
                    return "Error creating file"
                }
            }
            
            // Read the first line of the file
            do {
                let fileContent = try String(contentsOfFile: fileURL.path, encoding: .utf8)
                return fileContent.components(separatedBy: .newlines).first ?? ""
            } catch {
                print("Error reading file: \(error)")
                return "Error reading file"
            }
        } else {
            return "Documents path not found"
        }
    }

    deinit {
        timer?.invalidate()
        
        if let prevCPUInfo = prevCPUInfo {
            let prevCPUInfoSize = MemoryLayout<integer_t>.stride * Int(numPrevCPUInfo)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prevCPUInfo), vm_size_t(prevCPUInfoSize))
        }
        
        if let cpuInfo = cpuInfo {
            let cpuInfoSize = MemoryLayout<integer_t>.stride * Int(numCPUInfo)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), vm_size_t(cpuInfoSize))
        }
    }
}
