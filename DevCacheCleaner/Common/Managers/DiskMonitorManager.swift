//
//  FolderMonitorManager.swift
//  DevCacheCleaner
//
//  Created by Karim Angama on 11/03/2026.
//

import Foundation
import CoreServices

protocol DiskMonitorManager {
    var folderDidChange: ((String) -> Void)? { get set }
    func startMonitoring(url: URL)
    func stopMonitoring()
}

class DiskMonitorManagerImpl: DiskMonitorManager {
    
    private var eventStream: FSEventStreamRef?
    private var monitoredURL: URL?
    private let latency: CFTimeInterval = 0.5
    private let eventQueue = DispatchQueue(label: "com.devcachecleaner.diskmonitor")
    
    var folderDidChange: ((String) -> Void)?
    
    func startMonitoring(url: URL) {
        guard eventStream == nil else {
            return
        }
        
        monitoredURL = url
        
        var context = FSEventStreamContext(version: 0,
                                           info: Unmanaged.passUnretained(self).toOpaque(),
                                           retain: nil,
                                           release: nil,
                                           copyDescription: nil)
        
        let pathArray = [url.path] as CFArray
        
        guard let stream = FSEventStreamCreate(kCFAllocatorDefault,
                                               DiskMonitorManagerImpl.fseventsCallback,
                                               &context,
                                               pathArray,
                                               FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
                                               latency,
                                               UInt32(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagNoDefer))
        else {
            eventStream = nil
            return
        }
        
        FSEventStreamSetDispatchQueue(stream, eventQueue)
        
        if FSEventStreamStart(stream) {
            eventStream = stream
        } else {
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
            eventStream = nil
        }
    }
    
    func stopMonitoring() {
        guard let stream = eventStream else {
            return
        }
        FSEventStreamStop(stream)
        FSEventStreamSetDispatchQueue(stream, nil)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        eventStream = nil
        monitoredURL = nil
    }
    
    private static let fseventsCallback: FSEventStreamCallback = { (streamRef, clientCallBackInfo, numEvents, eventPaths, eventFlags, eventIds) in
        let mySelf = Unmanaged<DiskMonitorManagerImpl>.fromOpaque(clientCallBackInfo!).takeUnretainedValue()
        mySelf.handleEvents(numEvents: numEvents,
                            eventPaths: eventPaths,
                            eventFlags: eventFlags,
                            eventIds: eventIds)
    }
    
    private func handleEvents(numEvents: Int,
                              eventPaths: UnsafeMutableRawPointer?,
                              eventFlags: UnsafePointer<FSEventStreamEventFlags>?,
                              eventIds: UnsafePointer<FSEventStreamEventId>?) {
        
        guard let eventFlags = eventFlags, let eventPaths = eventPaths else { return }

        // Convert eventPaths to a usable Swift array
        let cfArray = Unmanaged<CFArray>.fromOpaque(eventPaths).takeUnretainedValue()
        let paths = cfArray as? [String] ?? []

        for i in 0..<numEvents {
            let flags = eventFlags[i]
            let currentPath = paths[i]

            // Check if the "Removed" flag is present
            let isRemoved = (flags & UInt32(kFSEventStreamEventFlagItemRemoved)) != 0
            
            // Check if the "Renamed" flag is present (often part of a deletion/move)
            let isRenamed = (flags & UInt32(kFSEventStreamEventFlagItemRenamed)) != 0

            // Skip the update if it's a deletion
            if isRemoved {
                continue
            }
            
            // Option: If a file is renamed/moved out, you might want to skip it too
            if isRenamed { continue }

            DispatchQueue.main.async { [weak self] in
                // Send the specific path that changed
                self?.folderDidChange?(currentPath)
            }
        }
    }
    
}
