import 'package:flutter/widgets.dart';

import '../core/action_method_info.dart';

class ActionMethodPreProcessorContext {
  final BuildContext buildContext;
  final ActionMethodInfo actionMethodInfo;

  ActionMethodPreProcessorContext(this.buildContext, this.actionMethodInfo);
}
