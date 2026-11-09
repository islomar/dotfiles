<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents** *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [External SSD (2 TB)](#external-ssd-2-tb)
  - [Laptop ports](#laptop-ports)
  - [Candidates](#candidates)
  - [Decision](#decision)
  - [Test after buying](#test-after-buying)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# External SSD (2 TB)

Research from 2026-11-09 for a 2 TB external SSD bought online in Spain, used with this laptop.
Prices change daily and need a fresh check before buying.

## Laptop ports

Slimbook Executive, Intel Core i7-12700H, read from sysfs on 2026-11-09:

```text
usb2: speed=20000 rx_lanes=2 tx_lanes=2  Thunderbolt 4 controller (00:0d.0)
usb4: speed=10000 rx_lanes=1 tx_lanes=1  chipset controller (00:14.0)
```

| Port | Speed | Effect |
|---|---|---|
| USB-C Thunderbolt 4 | Controller reports 20 Gbps (Gen 2x2) | Only the Samsung T9 could use it. Not confirmed. |
| USB-C 3.2 Gen 2 | 10 Gbps, about 1000 MB/s | Every candidate runs at full speed |
| 2 × USB-A | 5 Gbps per ComputerBase, about 450 MB/s | Do not use for the SSD |

No source shows a Gen 2x2 drive reaching 2000 MB/s on an Alder Lake Thunderbolt 4 port.

## Candidates

| | Kioxia Exceria Plus G2 | SanDisk Extreme V2 | Samsung T9 | Crucial X9 Pro |
|---|---|---|---|---|
| Price seen | 220–260 € | ~235 € | ~372 € | No reliable current price |
| Sustained write | ~12 min above 1000 MB/s (~700 GB), then below 400 MB/s (Tom's Hardware) | Weak data | Weak data | ~900 MB/s across the drive (AnandTech) |
| Warranty | 3 years (Kioxia Europe statement, June 2026) | 5 years | 5 years | 5 years |
| Rating | None | IP65 | Drop-resistant | IP55 |
| Vendor tools on Linux | Not checked | Firmware updater is a Windows `.exe` | Samsung Magician: Windows and macOS | Windows |

Notes:

- SanDisk Extreme V2 had a data-loss firmware bug in 2023.
  Western Digital fixed it, but the updater does not run on Linux.
- Micron closed the Crucial consumer brand in December 2025.
  Shipments ended in February 2026, so the X9 Pro is leftover stock.
- Use LUKS for encryption instead of vendor tools.

Sources: [Tom's Hardware, Kioxia](https://www.tomshardware.com/pc-components/external-ssds/kioxia-exceria-plus-g2-2tb-review),
[Kioxia Europe warranty](https://europe.kioxia.com/content/dam/kioxia/en-europe/personal/support/warranty/asset/KIE_ManufacturersWarrantyStatement_SSD_20260625_EMEA.pdf),
[AnandTech, X9 Pro](https://www.anandtech.com/show/18987),
[Western Digital firmware](https://www.westerndigital.com/support/firmwareupdate),
[StorageReview, Crucial exit](https://www.storagereview.com/news/micron-exits-crucial-consumer-business-to-focus-on-higher-growth-segments),
[ComputerBase, Slimbook ports](https://www.computerbase.de/2022-07/linux-intel-ultrabook-slimbook-executive-14-16/).

## Decision

Recommended: Kioxia Exceria Plus G2, 2 TB.
Same speed as the others on the 10 Gbps USB-C port, the best sustained-write data among drives still sold, and the lowest price.
Trade-off: 3-year warranty and no water resistance.

Pick changes:

- 5-year warranty or outdoor use: SanDisk Extreme V2.
- Video editing from the drive: Samsung T9, only if the port check below shows `20000M`.
- Single copies above ~700 GB: Kioxia drops below 400 MB/s.
  A first full backup can be that large.

Status: not bought yet.

## Test after buying

Buy from a shop with 30-day returns.

1. Connect the drive to a USB-C port, not USB-A.
2. Check the link speed:

   ```bash
   lsusb -t
   ```

   The drive's line must show `10000M`.
   For the T9 on the Thunderbolt 4 port, it must show `20000M`, or return it.
   `5000M` means a wrong cable or port.
3. Confirm the drive uses UAS: the same `lsusb -t` line must show `Driver=uas`, not `usb-storage`.
4. Check sustained write with a file larger than the drive's cache, on the empty drive:

   ```bash
   dd if=/dev/zero of=/media/$USER/<drive>/test.bin bs=1M count=100000 oflag=direct status=progress
   rm /media/$USER/<drive>/test.bin
   ```

5. Format with LUKS if the drive will hold backups.
