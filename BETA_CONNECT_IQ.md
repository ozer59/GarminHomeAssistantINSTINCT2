# HA Instinct - Beta Connect IQ

This branch is prepared as an independent Garmin Connect IQ application for Garmin Instinct 2.

## Identity

- App name: `HA Instinct`
- App ID: `30d7fbea-566f-41c1-9e03-1de02e2d198a`
- Target: `instinct2`
- Type: `watch-app`

Because the App ID is different from the upstream HomeAssistant app, Garmin treats this as a separate application.

## 1. Build a local PRG

Place `developer_key.der` at the project root and run:

```cmd
compile_instinct2.cmd
```

Expected output:

```text
bin\HA-Instinct-instinct2.prg
```

This PRG can be sideloaded for local testing, but sideloaded app settings are not normally managed from the Connect IQ mobile store UI.

## 2. Export the Store/Beta package

Run:

```cmd
export_instinct2_iq.cmd
```

Expected output:

```text
bin\HA-Instinct.iq
```

## 3. Create the Beta app in Garmin Connect IQ Developer Dashboard

1. Sign in to the Garmin Connect IQ Developer Dashboard.
2. Create a new application entry for `HA Instinct`.
3. Upload `bin\HA-Instinct.iq`.
4. Keep the app restricted to Garmin Instinct 2 while testing.
5. Use the dashboard's Beta/Test distribution option rather than publishing publicly.
6. Install the Beta build from the invitation/test link on the Garmin account paired with the Instinct 2.

Once installed through the Beta/Store channel, the app can use the normal Connect IQ app-settings flow separately from the official HomeAssistant application because it has its own App ID.

## Notes

- Do not upload or commit `developer_key.der`.
- The custom Instinct 2 menu icons are embedded in the compiled package.
- Existing HomeAssistant API/menu settings must be entered again for HA Instinct because the new App ID gives it separate application storage/settings.
