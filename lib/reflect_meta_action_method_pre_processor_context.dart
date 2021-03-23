import 'package:flutter/widgets.dart';

import 'reflect_meta_action_method.dart';

class ActionMethodPreProcessorContext {
  final BuildContext buildContext;
  final ActionMethodInfo actionMethodInfo;

  ActionMethodPreProcessorContext(this.buildContext, this.actionMethodInfo);
}
