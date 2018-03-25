#import <AppKit/AppKit.h>

bool appPrefersMeta(NSRunningApplication *app)
{
  NSString *appName = [app localizedName];

  return [appName isEqualToString:@"Terminal"];
}

bool keyEventLeftAltPressed(CGEventFlags eventFlags)
{
  return (eventFlags & NX_DEVICELALTKEYMASK) == NX_DEVICELALTKEYMASK;
}

CGEventRef eventCallback (CGEventTapProxy proxy,
                          CGEventType eventType,
                          CGEventRef event,
                          void *context)
{
  CGEventFlags flags = CGEventGetFlags(event);
  NSRunningApplication *focusedApp =
    [[NSWorkspace sharedWorkspace] frontmostApplication];

  if (keyEventLeftAltPressed(flags) && appPrefersMeta(focusedApp))
  {
    CGEventSourceRef eventSource = CGEventCreateSourceFromEvent(event);

    CGEventRef newEventCharDown = CGEventCreateCopy(event);
    CGEventRef newEventCharUp = CGEventCreateCopy(event);

    CGEventSetType(newEventCharDown, kCGEventKeyDown);
    CGEventSetType(newEventCharUp, kCGEventKeyUp);
    CGEventSetFlags(newEventCharDown, flags & ~kCGEventFlagMaskAlternate);
    CGEventSetFlags(newEventCharUp, flags & ~kCGEventFlagMaskAlternate);
    CGEventSetSource(newEventCharDown, eventSource);
    CGEventSetSource(newEventCharUp, eventSource);

    CGEventRef newEventEscDown =
      CGEventCreateKeyboardEvent(eventSource, (CGKeyCode)53, true);
    CGEventRef newEventEscUp =
      CGEventCreateKeyboardEvent(eventSource, (CGKeyCode)53, false);

    CFRelease(eventSource);

    CGEventTapPostEvent(proxy, newEventEscDown);
    CGEventTapPostEvent(proxy, newEventCharDown);
    CGEventTapPostEvent(proxy, newEventEscUp);
    CGEventTapPostEvent(proxy, newEventCharUp);

    CFRelease(newEventEscDown);
    CFRelease(newEventCharDown);
    CFRelease(newEventEscUp);
    CFRelease(newEventCharUp);

    return NULL;
  } else
  {
    return event;
  }
}

int main(int argc, const char * argv[])
{
  @autoreleasepool {
    CFMachPortRef tap =
      CGEventTapCreate(kCGAnnotatedSessionEventTap,
                       kCGTailAppendEventTap,
                       kCGEventTapOptionDefault,
                       CGEventMaskBit(kCGEventKeyDown),
                       eventCallback,
                       NULL);

    if (tap)
    {
      CFRunLoopSourceRef runLoopSource =
        CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);

      CFRunLoopAddSource(CFRunLoopGetCurrent(),
                         runLoopSource,
                         kCFRunLoopCommonModes);

      CFRunLoopRun();

      CFRelease(runLoopSource);
    } else
    {
      printf("Metalt must be run as root to allow it to "
             "read and modify low-level key events.\n");
      exit(1);
    }
  }

  return 0;
}
