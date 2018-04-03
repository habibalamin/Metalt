//
//  AltToMetaTransformer.swift
//  Metalt
//
//  Created by Habib Alamin on 27/03/2018.
//  Copyright © 2018 Alaminium. All rights reserved.
//

import Foundation
import AppKit

func appPrefersMeta() -> Bool
{
  return NSWorkspace.shared
    .frontmostApplication?.localizedName == "Terminal"
}

func keyEventLeftAltPressed(_ eventFlags: CGEventFlags) -> Bool
{
  return
    (Int32(eventFlags.rawValue) & NX_DEVICELALTKEYMASK) ==
    NX_DEVICELALTKEYMASK
}

func altToMetaTransformer(proxy: CGEventTapProxy,
                          type: CGEventType,
                          event: CGEvent,
                          refcon: UnsafeMutableRawPointer?)
                          -> Unmanaged<CGEvent>?
{
  if (keyEventLeftAltPressed(event.flags) && appPrefersMeta())
  {
    let eventSource = CGEventSource(event: event)

    let newEventCharDown = event.copy()
    let newEventCharUp = event.copy()
    let notMaskAlternate =
      CGEventFlags(rawValue: ~CGEventFlags.maskAlternate.rawValue)

    newEventCharDown?.type = .keyDown
    newEventCharUp?.type = .keyUp
    newEventCharDown?.flags = event.flags.intersection(notMaskAlternate)
    newEventCharUp?.flags = event.flags.intersection(notMaskAlternate)
    newEventCharDown?.setSource(eventSource)
    newEventCharUp?.setSource(eventSource)

    let newEventEscDown =
      CGEvent(keyboardEventSource: eventSource,
              virtualKey: 53,
              keyDown: true)
    let newEventEscUp =
      CGEvent(keyboardEventSource: eventSource,
              virtualKey: 53,
              keyDown: false)

    newEventEscDown?.tapPostEvent(proxy)
    newEventCharDown?.tapPostEvent(proxy)
    newEventEscUp?.tapPostEvent(proxy)
    newEventCharUp?.tapPostEvent(proxy)

    return nil
  } else
  {
    return Unmanaged.passRetained(event)
  }
}
