import 'package:lichess_mobile/src/styles/lichess_icons.dart';

enum GameSpeed {
  ultraBullet,
  bullet,
  blitz,
  rapid,
  classical,
  correspondence,
}

final gameSpeedIcons = {
  GameSpeed.ultraBullet: LichessIcons.ultrabullet,
  GameSpeed.bullet: LichessIcons.bullet,
  GameSpeed.blitz: LichessIcons.blitz,
  GameSpeed.rapid: LichessIcons.rapid,
  GameSpeed.classical: LichessIcons.classical,
  GameSpeed.correspondence: LichessIcons.correspondence,
};
