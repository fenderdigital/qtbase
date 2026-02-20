// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

#include "quiwindow.h"

#include "qiostheme.h"

#include <QtCore/qscopedvaluerollback.h>

#include <QtGui/private/qguiapplication_p.h>
#include <QtGui/qpa/qplatformtheme.h>

#include <UIKit/UIKit.h>

@implementation QUIWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
        self->_sendingEvent = NO;

    return self;
}

- (void)sendEvent:(UIEvent *)event
{
    QScopedValueRollback<BOOL> sendingEvent(self->_sendingEvent, YES);
    [super sendEvent:event];
}

#if !defined(Q_OS_VISIONOS)
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];

    if (!qGuiApp)
        return;

    if (@available(iOS 12, *)) {
        if (self.screen == UIScreen.mainScreen) {
            if (previousTraitCollection.userInterfaceStyle != self.traitCollection.userInterfaceStyle) {
                QIOSTheme::initializeSystemPalette();
                QWindowSystemInterface::handleThemeChange<QWindowSystemInterface::SynchronousDelivery>(nullptr);
            }
        }
    }
}

#endif

@end
