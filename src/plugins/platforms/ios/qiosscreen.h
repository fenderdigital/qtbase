/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the plugins of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or (at your option) the GNU General
** Public license version 3 or any later version approved by the KDE Free
** Qt Foundation. The licenses are as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-2.0.html and
** https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#ifndef QIOSSCREEN_H
#define QIOSSCREEN_H

#include <UIKit/UIKit.h>

#include <qpa/qplatformscreen.h>

@class QIOSOrientationListener;

QT_BEGIN_NAMESPACE

class QIOSScreen : public QObject, public QPlatformScreen
{
    Q_OBJECT

public:
#if !defined(Q_OS_VISIONOS)
    QIOSScreen(UIScreen *screen);
#else
    QIOSScreen();
#endif
    ~QIOSScreen();

    QString name() const override;

    QRect geometry() const override;
    QRect availableGeometry() const override;
    int depth() const override;
    QImage::Format format() const override;
    QSizeF physicalSize() const override;
    QDpi logicalDpi() const override;
    qreal devicePixelRatio() const override;
    qreal refreshRate() const override;

    Qt::ScreenOrientation nativeOrientation() const override;
    Qt::ScreenOrientation orientation() const override;
    void setOrientationUpdateMask(Qt::ScreenOrientations mask) override;

    QPixmap grabWindow(WId window, int x, int y, int width, int height) const override;

#if !defined(Q_OS_VISIONOS)
    UIScreen *uiScreen() const;
#endif
    UIWindow *uiWindow() const;

    void setUpdatesPaused(bool);

    void updateProperties();

private:
    void deliverUpdateRequests() const;

#if !defined(Q_OS_VISIONOS)
    UIScreen *m_uiScreen = nullptr;
#endif
    UIWindow *m_uiWindow = nullptr;
    QRect m_geometry;
    QRect m_availableGeometry;
    int m_depth;
#if !defined(Q_OS_VISIONOS)
    uint m_physicalDpi;
#endif
    QSizeF m_physicalSize;
    QIOSOrientationListener *m_orientationListener = nullptr;
    CADisplayLink *m_displayLink = nullptr;
};

QT_END_NAMESPACE

#endif
