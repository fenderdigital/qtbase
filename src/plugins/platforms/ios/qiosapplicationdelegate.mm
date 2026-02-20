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

#include "qiosapplicationdelegate.h"

#include "qiosglobal.h"
#include "qiosintegration.h"
#include "qiosservices.h"
#include "qiosviewcontroller.h"
#include "qioswindow.h"
#include "qiosscreen.h"
#include "quiwindow.h"

#include <qpa/qplatformintegration.h>

#include <QtCore/QtCore>

@interface QIOSWindowSceneDelegate : NSObject<UIWindowSceneDelegate>
@end

@implementation QIOSApplicationDelegate

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *restorableObjects))restorationHandler
{
    Q_UNUSED(application);
    Q_UNUSED(restorationHandler);

    if (!QGuiApplication::instance())
        return NO;

    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        QIOSIntegration *iosIntegration = QIOSIntegration::instance();
        Q_ASSERT(iosIntegration);

        QIOSServices *iosServices = static_cast<QIOSServices *>(iosIntegration->services());

        return iosServices->handleUrl(QUrl::fromNSURL(userActivity.webpageURL));
    }

    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    Q_UNUSED(application);
    Q_UNUSED(options);

    if (!QGuiApplication::instance())
        return NO;

    QIOSIntegration *iosIntegration = QIOSIntegration::instance();
    Q_ASSERT(iosIntegration);

    QIOSServices *iosServices = static_cast<QIOSServices *>(iosIntegration->services());

    return iosServices->handleUrl(QUrl::fromNSURL(url));
}

- (UISceneConfiguration *)application:(UIApplication *)application
                          configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                          options:(UISceneConnectionOptions *)options
{
    qCDebug(lcQpaWindowScene) << "Configuring scene for" << connectingSceneSession
        << "with options" << options;

    auto *sceneConfig = connectingSceneSession.configuration;
    sceneConfig.delegateClass = QIOSWindowSceneDelegate.class;
    return sceneConfig;
}

@end

@implementation QIOSWindowSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions
{
    qCDebug(lcQpaWindowScene) << "Connecting" << scene << "to" << session;

    Q_ASSERT([scene isKindOfClass:UIWindowScene.class]);
    UIWindowScene *windowScene = static_cast<UIWindowScene*>(scene);

    QUIWindow *window = [[QUIWindow alloc] initWithWindowScene:windowScene];

    QIOSScreen *screen = [&]{
        for (auto *screen : qGuiApp->screens()) {
            auto *platformScreen = static_cast<QIOSScreen*>(screen->handle());
#if !defined(Q_OS_VISIONOS)
            if (platformScreen->uiScreen() == windowScene.screen)
#endif
                return platformScreen;
        }
        Q_UNREACHABLE();
    }();

    window.rootViewController = [[[QIOSViewController alloc]
        initWithWindow:window andScreen:screen] autorelease];
}

@end
