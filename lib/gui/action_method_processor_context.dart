import 'package:flutter/widgets.dart';

import '../core/action_method_info.dart';

class ActionMethodProcessorContext {
  final BuildContext buildContext;
  final ActionMethodInfo actionMethodInfo;

  ActionMethodProcessorContext(this.buildContext, this.actionMethodInfo);
}
