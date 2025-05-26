//

enum BluetoothDeviceMinorType {
  // PHONE
  genericPhone, // 'Generic Phone'
  cellularPhone, // 'Cellular Phone'
  cordlessPhone, // 'Cordless Phone'
  smartphone, // 'Smartphone'
  modemOrGateway, // 'Modem or Gateway'
  isdnAccess, // 'ISDN Access'

  // COMPUTER
  genericComputer, // 'Generic Computer'
  desktopComputer, // 'Desktop Computer'
  serverComputer, // 'Server Computer'
  laptopComputer, // 'Laptop Computer'
  handheldPCPDA, // 'Handheld PC/PDA'
  palmSizePCPDA, // 'Palm-size PC/PDA'
  wearableComputer, // 'Wearable Computer'

  // AUDIO_VIDEO
  genericAudioVideo, // 'Generic Audio/Video'
  headset, // 'Headset'
  handsFree, // 'Hands-free'
  microphone, // 'Microphone'
  loudspeaker, // 'Loudspeaker'
  headphones, // 'Headphones'
  portableAudio, // 'Portable Audio'
  carAudio, // 'Car Audio'
  setTopBox, // 'Set-top Box'
  hifiAudioDevice, // 'HiFi Audio Device'
  vcr, // 'VCR'
  videoCamera, // 'Video Camera'
  camcorder, // 'Camcorder'
  videoMonitor, // 'Video Monitor'
  videoDisplaySpeaker, // 'Video Display & Speaker'
  videoConferencing, // 'Video Conferencing'
  gamingToy, // 'Gaming/Toy'

  // NETWORKING
  genericNetwork, // 'Generic Network'
  fullyAvailable, // 'Fully Available'
  utilized1_17, // '1-17% Utilized'
  utilized17_33, // '17-33% Utilized'
  utilized33_50, // '33-50% Utilized'
  utilized50_67, // '50-67% Utilized'
  utilized67_83, // '67-83% Utilized'
  utilized83_99, // '83-99% Utilized'
  noServiceAvailable, // 'No Service Available'

  // PERIPHERAL
  genericPeripheral, // 'Generic Peripheral'
  keyboard, // 'Keyboard'
  pointingDevice, // 'Pointing Device'
  comboKeyboardPointing, // 'Combo Keyboard/Pointing'

  // IMAGING
  genericImagingDevice, // 'Generic Imaging Device'
  display, // 'Display'
  camera, // 'Camera'
  scanner, // 'Scanner'
  printer, // 'Printer'

  // WEARABLE
  genericWearable, // 'Generic Wearable'
  wristWatch, // 'Wrist Watch'
  pager, // 'Pager'
  jacket, // 'Jacket'
  helmet, // 'Helmet'
  glasses, // 'Glasses'

  // TOY
  genericToy, // 'Generic Toy'
  toyRobot, // 'Toy Robot'
  toyVehicle, // 'Toy Vehicle'
  toyActionFigure, // 'Toy Action Figure'
  toyController, // 'Toy Controller'
  toyGame, // 'Toy Game'

  // HEALTH
  genericHealthDevice, // 'Generic Health Device'
  bloodPressureMonitor, // 'Blood Pressure Monitor'
  thermometer, // 'Thermometer'
  weighingScale, // 'Weighing Scale'
  glucoseMeter, // 'Glucose Meter'
  pulseOximeter, // 'Pulse Oximeter'
  heartRateMonitor, // 'Heart Rate Monitor'
  healthDataDisplay, // 'Health Data Display'
  stepCounter, // 'Step Counter'
  bodyCompositionAnalyzer, // 'Body Composition Analyzer'
  peakFlowMonitor, // 'Peak Flow Monitor'
  medicationMonitor, // 'Medication Monitor'
  kneeProsthesis, // 'Knee Prosthesis'
  ankleProsthesis, // 'Ankle Prosthesis'
  genericHealthMonitor, // 'Generic Health Monitor'

  unknownDevice; // 'Unknown Device'

  String? get caption {
    switch (this) {
      // PHONE
      case genericPhone:
        return 'Generic Phone';
      case cellularPhone:
        return 'Cellular Phone';
      case cordlessPhone:
        return 'Cordless Phone';
      case smartphone:
        return 'Smartphone';
      case modemOrGateway:
        return 'Modem or Gateway';
      case isdnAccess:
        return 'ISDN Access';

      // COMPUTER
      case genericComputer:
        return 'Generic Computer';
      case desktopComputer:
        return 'Desktop Computer';
      case serverComputer:
        return 'Server Computer';
      case laptopComputer:
        return 'Laptop Computer';
      case handheldPCPDA:
        return 'Handheld PC/PDA';
      case palmSizePCPDA:
        return 'Palm-size PC/PDA';
      case wearableComputer:
        return 'Wearable Computer';

      // AUDIO_VIDEO
      case genericAudioVideo:
        return 'Generic Audio/Video';
      case headset:
        return 'Headset';
      case handsFree:
        return 'Hands-free';
      case microphone:
        return 'Microphone';
      case loudspeaker:
        return 'Loudspeaker';
      case headphones:
        return 'Headphones';
      case portableAudio:
        return 'Portable Audio';
      case carAudio:
        return 'Car Audio';
      case setTopBox:
        return 'Set-top Box';
      case hifiAudioDevice:
        return 'HiFi Audio Device';
      case vcr:
        return 'VCR';
      case videoCamera:
        return 'Video Camera';
      case camcorder:
        return 'Camcorder';
      case videoMonitor:
        return 'Video Monitor';
      case videoDisplaySpeaker:
        return 'Video Display & Speaker';
      case videoConferencing:
        return 'Video Conferencing';
      case gamingToy:
        return 'Gaming/Toy';

      // NETWORKING
      case fullyAvailable:
        return 'Fully Available';
      case genericNetwork:
        return 'Generic Network';
      case utilized1_17:
        return '1-17% Utilized';
      case utilized17_33:
        return '17-33% Utilized';
      case utilized33_50:
        return '33-50% Utilized';
      case utilized50_67:
        return '50-67% Utilized';
      case utilized67_83:
        return '67-83% Utilized';
      case utilized83_99:
        return '83-99% Utilized';
      case noServiceAvailable:
        return 'No Service Available';

      // PERIPHERAL
      case genericPeripheral:
        return 'Generic Peripheral';
      case keyboard:
        return 'Keyboard';
      case pointingDevice:
        return 'Pointing Device';
      case comboKeyboardPointing:
        return 'Combo Keyboard/Pointing';

      // IMAGING
      case genericImagingDevice:
        return 'Generic Imaging Device';
      case display:
        return 'Display';
      case camera:
        return 'Camera';
      case scanner:
        return 'Scanner';
      case printer:
        return 'Printer';

      // WEARABLE
      case genericWearable:
        return 'Generic Wearable';
      case wristWatch:
        return 'Wrist Watch';
      case pager:
        return 'Pager';
      case jacket:
        return 'Jacket';
      case helmet:
        return 'Helmet';
      case glasses:
        return 'Glasses';

      // TOY
      case genericToy:
        return 'Generic Toy';
      case toyRobot:
        return 'Toy Robot';
      case toyVehicle:
        return 'Toy Vehicle';
      case toyActionFigure:
        return 'Toy Action Figure';
      case toyController:
        return 'Toy Controller';
      case toyGame:
        return 'Toy Game';

      // HEALTH
      case genericHealthDevice:
        return 'Generic Health Device';
      case bloodPressureMonitor:
        return 'Blood Pressure Monitor';
      case thermometer:
        return 'Thermometer';
      case weighingScale:
        return 'Weighing Scale';
      case glucoseMeter:
        return 'Glucose Meter';
      case pulseOximeter:
        return 'Pulse Oximeter';
      case heartRateMonitor:
        return 'Heart Rate Monitor';
      case healthDataDisplay:
        return 'Health Data Display';
      case stepCounter:
        return 'Step Counter';
      case bodyCompositionAnalyzer:
        return 'Body Composition Analyzer';
      case peakFlowMonitor:
        return 'Peak Flow Monitor';
      case medicationMonitor:
        return 'Medication Monitor';
      case kneeProsthesis:
        return 'Knee Prosthesis';
      case ankleProsthesis:
        return 'Ankle Prosthesis';
      case genericHealthMonitor:
        return 'Generic Health Monitor';

      case unknownDevice:
        return null;
    }
  }

  factory BluetoothDeviceMinorType.fromFullClass(int deviceClass) {
    switch (deviceClass) {
      // PHONE
      case 0x0200:
        return BluetoothDeviceMinorType.genericPhone;
      case 0x0204:
        return BluetoothDeviceMinorType.cellularPhone;
      case 0x0208:
        return BluetoothDeviceMinorType.cordlessPhone;
      case 0x020C:
        return BluetoothDeviceMinorType.smartphone;
      case 0x0210:
        return BluetoothDeviceMinorType.modemOrGateway;
      case 0x0214:
        return BluetoothDeviceMinorType.isdnAccess;

      // COMPUTER
      case 0x0100:
        return BluetoothDeviceMinorType.genericComputer;
      case 0x0104:
        return BluetoothDeviceMinorType.desktopComputer;
      case 0x0108:
        return BluetoothDeviceMinorType.serverComputer;
      case 0x010C:
        return BluetoothDeviceMinorType.laptopComputer;
      case 0x0110:
        return BluetoothDeviceMinorType.handheldPCPDA;
      case 0x0114:
        return BluetoothDeviceMinorType.palmSizePCPDA;
      case 0x0118:
        return BluetoothDeviceMinorType.wearableComputer;

      // AUDIO_VIDEO
      case 0x0400:
        return BluetoothDeviceMinorType.genericAudioVideo;
      case 0x0404:
        return BluetoothDeviceMinorType.headset;
      case 0x0408:
        return BluetoothDeviceMinorType.handsFree;
      case 0x040C:
        return BluetoothDeviceMinorType.microphone;
      case 0x0410:
        return BluetoothDeviceMinorType.loudspeaker;
      case 0x0414:
        return BluetoothDeviceMinorType.headphones;
      case 0x0418:
        return BluetoothDeviceMinorType.portableAudio;
      case 0x041C:
        return BluetoothDeviceMinorType.carAudio;
      case 0x0420:
        return BluetoothDeviceMinorType.setTopBox;
      case 0x0424:
        return BluetoothDeviceMinorType.hifiAudioDevice;
      case 0x0428:
        return BluetoothDeviceMinorType.vcr;
      case 0x042C:
        return BluetoothDeviceMinorType.videoCamera;
      case 0x0430:
        return BluetoothDeviceMinorType.camcorder;
      case 0x0434:
        return BluetoothDeviceMinorType.videoMonitor;
      case 0x0438:
        return BluetoothDeviceMinorType.videoDisplaySpeaker;
      case 0x043C:
        return BluetoothDeviceMinorType.videoConferencing;
      case 0x0440:
        return BluetoothDeviceMinorType.gamingToy;

      // NETWORKING
      case 0x0300:
        return BluetoothDeviceMinorType.genericNetwork;
      case 0x0304:
        return BluetoothDeviceMinorType.fullyAvailable;
      case 0x0308:
        return BluetoothDeviceMinorType.utilized1_17;
      case 0x030C:
        return BluetoothDeviceMinorType.utilized17_33;
      case 0x0310:
        return BluetoothDeviceMinorType.utilized33_50;
      case 0x0314:
        return BluetoothDeviceMinorType.utilized50_67;
      case 0x0318:
        return BluetoothDeviceMinorType.utilized67_83;
      case 0x031C:
        return BluetoothDeviceMinorType.utilized83_99;
      case 0x0320:
        return BluetoothDeviceMinorType.noServiceAvailable;

      // PERIPHERAL
      case 0x0500:
        return BluetoothDeviceMinorType.genericPeripheral;
      case 0x0540:
        return BluetoothDeviceMinorType.keyboard;
      case 0x0580:
        return BluetoothDeviceMinorType.pointingDevice;
      case 0x05C0:
        return BluetoothDeviceMinorType.comboKeyboardPointing;

      // IMAGING
      case 0x0600:
        return BluetoothDeviceMinorType.genericImagingDevice;
      case 0x0604:
        return BluetoothDeviceMinorType.display;
      case 0x0608:
        return BluetoothDeviceMinorType.camera;
      case 0x060C:
        return BluetoothDeviceMinorType.scanner;
      case 0x0610:
        return BluetoothDeviceMinorType.printer;
      case 0x0680:
        return BluetoothDeviceMinorType.printer;

      // WEARABLE
      case 0x0700:
        return BluetoothDeviceMinorType.genericWearable;
      case 0x0704:
        return BluetoothDeviceMinorType.wristWatch;
      case 0x0708:
        return BluetoothDeviceMinorType.pager;
      case 0x070C:
        return BluetoothDeviceMinorType.jacket;
      case 0x0710:
        return BluetoothDeviceMinorType.helmet;
      case 0x0714:
        return BluetoothDeviceMinorType.glasses;

      // TOY
      case 0x0800:
        return BluetoothDeviceMinorType.genericToy;
      case 0x0804:
        return BluetoothDeviceMinorType.toyRobot;
      case 0x0808:
        return BluetoothDeviceMinorType.toyVehicle;
      case 0x080C:
        return BluetoothDeviceMinorType.toyActionFigure;
      case 0x0810:
        return BluetoothDeviceMinorType.toyController;
      case 0x0814:
        return BluetoothDeviceMinorType.toyGame;

      // HEALTH
      case 0x0900:
        return BluetoothDeviceMinorType.genericHealthDevice;
      case 0x0904:
        return BluetoothDeviceMinorType.bloodPressureMonitor;
      case 0x0908:
        return BluetoothDeviceMinorType.thermometer;
      case 0x090C:
        return BluetoothDeviceMinorType.weighingScale;
      case 0x0910:
        return BluetoothDeviceMinorType.glucoseMeter;
      case 0x0914:
        return BluetoothDeviceMinorType.pulseOximeter;
      case 0x0918:
        return BluetoothDeviceMinorType.heartRateMonitor;
      case 0x091C:
        return BluetoothDeviceMinorType.healthDataDisplay;
      case 0x0920:
        return BluetoothDeviceMinorType.stepCounter;
      case 0x0924:
        return BluetoothDeviceMinorType.bodyCompositionAnalyzer;
      case 0x0928:
        return BluetoothDeviceMinorType.peakFlowMonitor;
      case 0x092C:
        return BluetoothDeviceMinorType.medicationMonitor;
      case 0x0930:
        return BluetoothDeviceMinorType.kneeProsthesis;
      case 0x0934:
        return BluetoothDeviceMinorType.ankleProsthesis;
      case 0x0938:
        return BluetoothDeviceMinorType.genericHealthMonitor;

      default:
        return BluetoothDeviceMinorType.unknownDevice;
    }
  }
}
