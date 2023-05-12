/****************************************************************************
** Copyright (C) 2019-2023 Klarälvdalens Datakonsult AB, a KDAB Group company, info@kdab.com.
** All rights reserved.
**
** This file is part of the KD MacTouchBar library.
**
** This file may be distributed and/or modified under the terms of the
** GNU Lesser General Public License version 3 as published by the
** Free Software Foundation and appearing in the file LICENSE.LGPL.txt included.
**
** You may even contact us at info@kdab.com for different licensing options.
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
** Contact info@kdab.com if any conditions of this licensing are not
** clear to you.
**
**********************************************************************/
#include "kdmactouchbarquick.h"

#import <Cocoa/Cocoa.h>

#include <QQuickItemGrabResult>
#include <QQuickWindow>

@interface QuickTouchBarView : NSView
@property(readonly,atomic) NSSize intrinsicContentSize;
@property(atomic) QQuickItem* item;
@property(atomic) QSharedPointer<QQuickItemGrabResult> grabber;
@property(atomic) QImage image;
@end

@implementation QuickTouchBarView

@synthesize item;
@synthesize grabber;
@synthesize image;

- (id)initWithQuickItem:(QQuickItem *)quickitem {
  self = [super init];
  item = quickitem;
  return self;
}

- (void)regrab {
  if (!self.item->window() || self.grabber) {
    return;
  }
  self.grabber = self.item->grabToImage((self.item->size() * 2).toSize());
  QObject::connect(self.grabber.data(), &QQuickItemGrabResult::ready, [self]() {
    self.image = self.grabber->image();
    self.grabber = {};
    [self setNeedsDisplay:YES];
  });
}

- (NSSize)intrinsicContentSize {
  return NSMakeSize(self.item->width(), self.item->height());
}

- (void)drawRect:(NSRect)frame {
    if (!self.item->isVisible()) {
        return;
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (self.image.isNull()) {
        [self regrab];
    }
    CGImageRef cgImage = self.image.toCGImage();
    NSImage *nsimage = [[NSImage alloc] initWithCGImage:cgImage size:NSZeroSize];
    [nsimage drawInRect:frame];
    [pool release];
}

- (void)touchesBeganWithEvent:(NSEvent *)event {
  NSTouch *touch = [[event touchesMatchingPhase:NSTouchPhaseBegan
                                         inView:self] anyObject];
  const QPointF point = QPointF::fromCGPoint([touch locationInView:self]);
  const QPointF globalPoint = self.item->mapToScene(point);
  QMouseEvent e(QEvent::MouseButtonPress, globalPoint, point,
                Qt::LeftButton, Qt::LeftButton, Qt::NoModifier);
  qApp->sendEvent(self.item->window(), &e);
}
- (void)touchesMovedWithEvent:(NSEvent *)event {
  NSTouch *touch = [[event touchesMatchingPhase:NSTouchPhaseMoved
                                         inView:self] anyObject];
  const QPoint point =
      QPointF::fromCGPoint([touch locationInView:self]).toPoint();
  if (!self.item->contains(point))
    return;
  const QPointF globalPoint = self.item->mapToScene(point);
  QMouseEvent e(QEvent::MouseMove, globalPoint, point, Qt::LeftButton,
                Qt::LeftButton, Qt::NoModifier);
  qApp->sendEvent(self.item->window(), &e);
}
- (void)touchesEndedWithEvent:(NSEvent *)event {
  NSTouch *touch = [[event touchesMatchingPhase:NSTouchPhaseEnded
                                         inView:self] anyObject];
  const QPointF point = QPointF::fromCGPoint([touch locationInView:self]);
  const QPointF globalPoint = self.item->mapToScene(point);
  QMouseEvent e(QEvent::MouseButtonRelease, globalPoint, point,
                Qt::LeftButton, Qt::NoButton, Qt::NoModifier);
  qApp->sendEvent(self.item->window(), &e);
}

@end

@interface TouchBarProvider
    : NSResponder <NSTouchBarDelegate, NSApplicationDelegate, NSWindowDelegate>
@property(strong, atomic) NSCustomTouchBarItem *item;
@property(strong, atomic) NSCustomTouchBarItem *escapeItem;
@property(strong, atomic) NSObject *qtDelegate;
@property(atomic) TouchBar *touchbarQuickItem;
@end

@implementation TouchBarProvider
@synthesize item;
@synthesize escapeItem;
@synthesize qtDelegate;
@synthesize touchbarQuickItem;

- (id)initWithTouchBarItem:(TouchBar *)touchbaritem {
  self = [super init];
  touchbarQuickItem = touchbaritem;
  item = [[[NSCustomTouchBarItem alloc] initWithIdentifier:@"touchbar"]
      autorelease];
  item.view = [[QuickTouchBarView alloc] initWithQuickItem:touchbaritem];
  escapeItem = nil;

  [self installAsDelegateForApplication:[NSApplication sharedApplication]];
  self.touchBar.defaultItemIdentifiers = @[ @"touchbar"];

  return self;
}

- (NSTouchBar *)makeTouchBar {
  self.touchBar = [[NSTouchBar alloc] init];
  self.touchBar.delegate = self;

  return self.touchBar;
}

- (void)setEscapeQuickItem:(QQuickItem *)escapeQuickItem {
  if (self.escapeItem) {
    self.touchBar.escapeKeyReplacementItemIdentifier = nil;
    self.escapeItem = nil;
  }
  if (escapeQuickItem) {
    self.escapeItem = [[[NSCustomTouchBarItem alloc]
        initWithIdentifier:@"escapeitem"] autorelease];
    self.escapeItem.view =
        [[QuickTouchBarView alloc] initWithQuickItem:escapeQuickItem];
    self.touchBar.escapeKeyReplacementItemIdentifier = @"escapeitem";
  }
}

- (NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar
       makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier {
  Q_UNUSED(touchBar)
  if ([self.item.identifier isEqualToString:identifier]) {
    return self.item;
  }
  if ([identifier isEqualToString:@"escapeitem"]) {
    return self.escapeItem;
  }
  return nil;
}

- (void)installAsDelegateForWindow:(NSWindow *)window {
  self.qtDelegate = window.delegate;
  window.delegate = self;
}
- (void)uninstallAsDelegateForWindow {
  /*    if (self.touchbarQuickItem && self.touchbarQuickItem->window()) {
          NSWindow* window =
     [reinterpret_cast<NSView*>(self.touchbarQuickItem->window()->winId())
     window]; if (!qtDelegate || !window) return; window.delegate =
     (NSWindowDelegate*)qtDelegate; qtDelegate = nil;
      }*/
}

- (void)installAsDelegateForApplication:(NSApplication *)application {
  self.qtDelegate = application.delegate;
  application.delegate = self;
}
- (void)uninstallAsDelegateForApplication:(NSApplication *)application {
  if (!self.qtDelegate)
    return;
  application.delegate = static_cast<id>(self.qtDelegate);
  self.qtDelegate = nil;
}

- (BOOL):(SEL)aSelector {
  return [self.qtDelegate respondsToSelector:aSelector] ||
         [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
  [anInvocation invokeWithTarget:self.qtDelegate];
}

@end

QT_BEGIN_NAMESPACE

TouchBar::TouchBar(QQuickItem *parent)
    : QQuickItem(parent)
{
  setX(-685);
  setY(-30);
  setWidth(685);
  setHeight(30);
  m_tbProvider = [[TouchBarProvider alloc] initWithTouchBarItem:this];
}

TouchBar::~TouchBar()
{
  TouchBarProvider *tbp = static_cast<TouchBarProvider *>(m_tbProvider);
  if (m_global) {
    [tbp uninstallAsDelegateForApplication:[NSApplication sharedApplication]];
  } else {
    [tbp uninstallAsDelegateForWindow];
  }
  [tbp retain];
}

bool TouchBar::isGlobal() const
{
    return m_global;
}

void TouchBar::setGlobal(bool global)
{
  if (global == m_global)
    return;

  m_global = global;

  TouchBarProvider *tbp = static_cast<TouchBarProvider *>(m_tbProvider);
  if (global) {
    [tbp uninstallAsDelegateForWindow];
    [tbp installAsDelegateForApplication:[NSApplication sharedApplication]];
  } else {
    [tbp uninstallAsDelegateForApplication:[NSApplication sharedApplication]];
    if (window()) {
      NSWindow *nswindow =
          [reinterpret_cast<NSView *>(window()->winId()) window];
      if (nswindow)
        [tbp installAsDelegateForWindow:nswindow];
    }
  }
  Q_EMIT globalChanged(global);
}

QQuickItem *TouchBar::escapeItem() const
{
    return m_escapeItem;
}

void TouchBar::setEscapeItem(QQuickItem *escapeItem)
{
  m_escapeItem = escapeItem;
  if (m_escapeItem) {
    m_escapeItem->setParentItem(this);
    m_escapeItem->setY(-m_escapeItem->height());
  }
  TouchBarProvider *tbp = static_cast<TouchBarProvider *>(m_tbProvider);
  [tbp setEscapeQuickItem:m_escapeItem];
  setWidth(685 - (m_escapeItem ? m_escapeItem->width() : 64) + 64);
  [tbp.item.view invalidateIntrinsicContentSize];
}

bool TouchBar::eventFilter(QObject *watched, QEvent *event)
{
  if (event->type() == QEvent::UpdateRequest) {
    TouchBarProvider *tbp = static_cast<TouchBarProvider *>(m_tbProvider);
    [tbp.item.view regrab];
    [tbp.escapeItem.view regrab];
  }
  return QQuickItem::eventFilter(watched, event);
}

void TouchBar::itemChange(ItemChange change, const ItemChangeData &value)
{
  if (change == ItemSceneChange && value.window) {
    value.window->installEventFilter(this);
    if (!m_global) {
      TouchBarProvider *tbp = static_cast<TouchBarProvider *>(m_tbProvider);
      [tbp installAsDelegateForWindow:[reinterpret_cast<NSView *>(
                                          value.window->winId()) window]];
    }
  }
  else if (change == ItemVisibleHasChanged) {
      TouchBarProvider *tbp = static_cast<TouchBarProvider *>(m_tbProvider);
      if (!value.boolValue) {
        if (m_global) {
            [tbp uninstallAsDelegateForApplication:[NSApplication sharedApplication]];
          } else {
            [tbp uninstallAsDelegateForWindow];
        }
      }
      else {
          if (m_global) {
              [tbp installAsDelegateForApplication:[NSApplication sharedApplication]];
            } else {
              [tbp installAsDelegateForWindow:[reinterpret_cast<NSView *>(
                                                  value.window->winId()) window]];
          }
      }
      [tbp.item.view regrab];
      [tbp.escapeItem.view regrab];
  }
  QQuickItem::itemChange(change, value);
}

QT_END_NAMESPACE
