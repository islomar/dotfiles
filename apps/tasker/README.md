<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents** *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Tasker: daily 25,000 steps in Health Connect](#tasker-daily-25000-steps-in-health-connect)
  - [Files](#files)
  - [How it works](#how-it-works)
    - [Limits](#limits)
  - [Set up a new phone](#set-up-a-new-phone)
    - [Connect the phone](#connect-the-phone)
    - [Install and configure](#install-and-configure)
    - [Restore the configuration](#restore-the-configuration)
    - [Verify](#verify)
  - [Update `backup.xml` after a change in Tasker](#update-backupxml-after-a-change-in-tasker)
  - [Troubleshooting](#troubleshooting)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Tasker: daily 25,000 steps in Health Connect

Tasker writes one `StepsRecord` of 25,000 steps per day into Health Connect, from 00:00 to 23:50. Google Fit reads Health Connect.

Tested on a Fairphone 6 with Android 16, Tasker 6.6.20 and Tasker Health Connect 1.0.4.

## Files

| File | Content |
|---|---|
| [`backup.xml`](./backup.xml) | Tasker backup: project `Base`, both profiles, task `Registrar 25000 pasos` and task `Inventario pasos` |
| [`tasker-phone.sh`](./tasker-phone.sh) | ADB helper: `setup`, `doctor`, `runlog`, `inventory` |

## How it works

| Profile | Trigger | Task |
|---|---|---|
| `23:50` | Every day at 23:50 | `Registrar 25000 pasos` |
| `Display Unlocked` | Every unlock | `Registrar 25000 pasos` |

`Registrar 25000 pasos` has 4 actions:

1. JavaScriptlet `Calcular pendientes` lists the days of the last 7 days whose 23:50 has passed, and builds one record per day.
2. `If %haypendientes ~ 1`.
3. Tasker Health Connect, Write Data, `StepsRecord`, input `%pasosjson`.
4. `End If`.

Every record carries `metadata.clientRecordId = "pasos-YYYY-MM-DD"`.
Health Connect treats an insert with an existing `clientRecordId` from the same app as an update.
The task rewrites the whole window on every run.
Repeated runs never duplicate a day, and a day deleted by anything else comes back on the next run.

The task does not read Health Connect.
A read of 7 days returned more than 1000 records from Google Fit, Zepp and Huawei Health.
The plugin's 822 KB reply exceeded Android's limit for one message to Tasker (`TransactionTooLargeException`).
Read Data then timed out after 60 seconds on every run.

`Inventario pasos` is a read-only check. It reads one day per call, and appends each day's total and the Tasker records to `/sdcard/Download/pasos_inventario.txt`.

### Limits

- Recovery covers 7 days. A day older than that stays missing.
- The JavaScriptlet skips days up to `2026-10-25`.
  Those records have no `clientRecordId`, so rewriting them would duplicate them.
  The limit has no effect after 2026-11-01.
- Health Connect sums steps by source priority.
  Where Google Fit has data and ranks above Tasker Health Connect, Fit's count replaces Tasker's.
  Check the order in Health Connect, Data and access, Steps, Data sources and priority.
- Health Connect is on the phone. The task works in airplane mode.

## Set up a new phone

### Connect the phone

1. Install ADB on the computer: `sudo apt install adb android-sdk-platform-tools-common`.
2. On the phone, open Settings, About phone, and tap Build number 7 times.
3. Open Settings, System, Developer options, and turn on USB debugging.
4. Connect the USB cable and choose File transfer.
5. Run `adb devices` and accept the prompt on the phone. The phone must show as `device`.

### Install and configure

1. Install Tasker from the Play Store. Without it, `setup` opens its Play Store page.
2. Run `./tasker-phone.sh setup`. It does the following:
   - Downloads Tasker Health Connect 1.0.4 from GitHub, checks its SHA-256, and installs it.
   - Grants `WRITE_STEPS` and `READ_STEPS` to the plugin.
   - Exempts Tasker from battery optimisation.
   - Pushes `backup.xml` to `/sdcard/Tasker/configs/user/backup.xml`.
3. Open the Tasker Health Connect app once. If `doctor` later shows a permission as `MISSING`, grant it from this app. The `pm grant` path is only tested on a phone that already had the permissions.

### Restore the configuration

Restore replaces Tasker's whole configuration. On a phone that already has Tasker projects, import the tasks and profiles one by one instead.

1. In Tasker, open More options, Data, Restore.
2. Choose the user backup at `Tasker/configs/user/backup.xml`.
3. On the Profiles tab, check that the switches of `23:50` and `Display Unlocked` are on.
4. Turn on the run log: More options, More, Run Log.

### Verify

1. Run `./tasker-phone.sh doctor`. Every line must show `OK`.
2. Lock and unlock the phone. Run `./tasker-phone.sh runlog`. The last lines must show `Display Unlocked` and `Registrar 25000 pasos` with `ExitOK`.
3. After 23:50, or on any later day, run `Inventario pasos` in Tasker. Then run `./tasker-phone.sh inventory`. Each day after `2026-10-25` must show `tasker=1` and a `clientRecordId` of `pasos-YYYY-MM-DD`.

## Update `backup.xml` after a change in Tasker

1. In Tasker, open More options, Data, Backup, and confirm the default path.
2. Run `adb pull /sdcard/Tasker/configs/user/backup.xml apps/tasker/backup.xml` from the repository root.

## Troubleshooting

| Symptom | Check |
|---|---|
| A day is missing | `./tasker-phone.sh runlog`. An `Err` on Write Data shows the failure. The next unlock rewrites the day when it falls within the last 7 days. |
| Nothing runs at 23:50 | Profile switched off, or Tasker battery optimised. Run `doctor`. |
| Write Data is `Err` after 60 seconds | Run `adb logcat -d \| grep -iE 'rafapps\|TransactionTooLarge'`. |
| Google Fit shows fewer steps than expected | Data source priority in Health Connect. See Limits. |

Plugin source: <https://github.com/RafhaanShah/TaskerHealthConnect>.
