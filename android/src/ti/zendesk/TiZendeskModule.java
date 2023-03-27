/**
 * This file was auto-generated by the Titanium Module SDK helper for Android
 * TiDev Titanium Mobile
 * Copyright TiDev, Inc. 04/07/2022-Present
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
package ti.zendesk;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiApplication;

import zendesk.core.AnonymousIdentity;
import zendesk.core.JwtIdentity;
import zendesk.core.Zendesk;
import zendesk.messaging.MessagingActivity;
import zendesk.support.Support;
import com.zendesk.service.ErrorResponse;
import com.zendesk.service.ZendeskCallback;

@Kroll.module(name = "TiZendesk", id = "ti.zendesk")
public class TiZendeskModule extends KrollModule {

    // Methods
    @Kroll.method
    public void initialize(KrollDict params) {
        String appId = params.getString("appId");
        String clientId = params.getString("clientId");
        String url = params.getString("url");

        Zendesk.INSTANCE.init(TiApplication.getAppCurrentActivity(), url, appId, clientId);
        Support.INSTANCE.init(Zendesk.INSTANCE);
    }

    @Kroll.method
    public void loginUser(KrollDict params) {
        if (params != null) {
            String jwt = params.getString("jwt");
            String name = params.getString("name");
            String email = params.getString("email");

            if (jwt != null) {
                Zendesk.INSTANCE.setIdentity(new JwtIdentity(jwt));
            } else if (name != null && email != null) {
                Zendesk.INSTANCE.setIdentity(new AnonymousIdentity.Builder()
                        .withEmailIdentifier(email)
                        .withNameIdentifier(name)
                        .build());
            }

            return;
        }

        Zendesk.INSTANCE.setIdentity(new AnonymousIdentity());
    }

    @Kroll.method
    public void showMessaging() {
        MessagingActivity.builder().show(TiApplication.getAppCurrentActivity());
    }

    @Kroll.method
    public void registerForPushNotifications(String pushToken) {
        Zendesk.INSTANCE.provider().pushRegistrationProvider().registerWithDeviceIdentifier(pushToken, new ZendeskCallback<String>() {
            @Override
            public void onSuccess(String result) {}

            @Override
            public void onError(ErrorResponse error) {}
        });
    }
}

