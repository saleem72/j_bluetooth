//

import 'package:flutter/material.dart';
import 'package:j_bluetooth/j_bluetooth.dart';

class DeviceTile extends StatelessWidget {
  const DeviceTile({
    super.key,
    required this.device,
    this.onTap,
  });

  final JafraBluetoothDevice device;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: device.majorCategory.color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              device.majorCategory.icon,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name ?? '',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // const SizedBox(height: 4),
                // Text(
                //   result.device.address,
                //   style: context.textTheme.bodyMedium?.copyWith(
                //     fontWeight: FontWeight.w500,
                //     fontSize: 14,
                //   ),
                // ),
                const SizedBox(height: 4),
                Text(
                  device.minorCategory?.caption ?? device.majorCategory.caption,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                // const SizedBox(height: 4),
                // Text(
                //   result.deviceCategory ?? 'no minor category',
                //   style: context.textTheme.bodyMedium?.copyWith(
                //     fontWeight: FontWeight.w500,
                //     fontSize: 14,
                //   ),
                // ),
                // const SizedBox(height: 4),
                // Text(
                //   result.toString(),
                //   style: context.textTheme.bodyMedium?.copyWith(
                //     fontWeight: FontWeight.w500,
                //     fontSize: 14,
                //   ),
                // ),
                // const SizedBox(height: 4),
                // Text(
                //   result.device.isConnected ? 'Connected' : 'Disconnected',
                //   // device.status.enumDescription,
                //   style: context.textTheme.bodySmall?.copyWith(
                //     fontWeight: FontWeight.w500,
                //     fontSize: 12,
                //     color: AppColors.greyText,
                //   ),
                // ),
              ],
            ),
          ),
          device.rssi != 0
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  // alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${device.rssi} dBm',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: device.rssiColor,
                        ),
                  ),
                )
              : const SizedBox.shrink(),
          const SizedBox(
            height: 48,
            child: VerticalDivider(color: Colors.black45),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
