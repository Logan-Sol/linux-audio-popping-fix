# Linux Audio Popping Fix

A Linux workaround for audio popping/clicking that may be caused by Intel HDA power management.

This repository provides a simple script to disable `snd_hda_intel` power saving, check the current configuration, and revert the changes if necessary.

## Quick Start

    chmod +x disable-hda-powersave.sh
    sudo ./disable-hda-powersave.sh apply

Reboot afterward if necessary.

## Check Status

    ./disable-hda-powersave.sh status

You can also check the settings directly:

    cat /sys/module/snd_hda_intel/parameters/power_save
    cat /sys/module/snd_hda_intel/parameters/power_save_controller

## What It Changes

The workaround disables Intel HDA power saving:

    power_save=0
    power_save_controller=N

The script creates:

    /etc/modprobe.d/hda-no-powersave.conf

containing:

    options snd_hda_intel power_save=0 power_save_controller=N

This makes the settings persistent across reboots.

## Why?

Some Linux systems may produce intermittent audio popping or clicking when Intel HDA audio hardware enters or leaves low-power states.

Disabling HDA power management may prevent these transitions and resolve the issue.

> **Note:** This is a workaround, not a guaranteed fix. Audio popping can also be caused by PipeWire, PulseAudio, kernel/driver issues, audio codecs, or other power-management settings.

## Revert

If the workaround does not help:

    sudo ./disable-hda-powersave.sh revert

Then reboot.

## Manual Testing

To test the workaround without creating the persistent configuration:

    sudo sh -c 'echo 0 > /sys/module/snd_hda_intel/parameters/power_save'
    sudo sh -c 'echo N > /sys/module/snd_hda_intel/parameters/power_save_controller'

Check the results:

    cat /sys/module/snd_hda_intel/parameters/power_save
    cat /sys/module/snd_hda_intel/parameters/power_save_controller

If the audio popping disappears, you can make the change persistent using the script.

## Audio Information

For additional troubleshooting:

    pactl info

## Power Consumption

Disabling audio power saving may slightly increase power consumption, particularly on laptops.

Consider testing the workaround first before making it permanent.

## Requirements

- Linux
- `snd_hda_intel` kernel module
- `sudo` access for applying or reverting the persistent configuration
