//

import 'package:flutter/material.dart';
import 'package:j_bluetooth/j_bluetooth.dart';

class DeviceTile extends StatelessWidget {
  const DeviceTile({
    super.key,
    required this.result,
  });

  final JafraBluetoothDevice result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: result.majorCategory.color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            result.majorCategory.icon,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.name ?? '',
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
                result.minorCategory?.caption ?? result.majorCategory.caption,
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
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        //   // alignment: Alignment.center,
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: Text(
        //     '${result.rssi} dBm',
        //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
        //           color: result.color,
        //         ),
        //   ),
        // ),
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
    );
  }
}
