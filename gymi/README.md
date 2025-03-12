# eyedid_flutter_example

Demonstrates how to use the Eyedid_Flutter plugin.

## Installation

Run the following commands to get the dependencies:

```bash
flutter pub get
```



## Getting Started

1. You need to input the license key you received from `manage.eyedid.ai`.
 [main.dart](./lib/main.dart)
  ``` dart
  final String _licenseKey = "Input your licenseKey";
  ```

2. The app runs only on actual devices.

3. Camera permission needs to be granted.

## Troubleshooting

- **Initialization Failed**: Ensure your license key is valid and entered correctly.
- **Camera Permissions**: If the camera is not accessible, check that permissions have been granted.

## Eyedid SDK more detail

- go to [docs page](https://docs.eyedid.ai)