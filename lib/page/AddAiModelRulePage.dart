import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:form_validator/form_validator.dart';

import '../generated/l10n.dart';
import '../utility/AppPlatformIcons.dart';

class AddAiModelRulePage extends StatefulWidget {
  @override
  _AddAiModelRulePageState createState() => _AddAiModelRulePageState();
}

class _AddAiModelRulePageState extends State<AddAiModelRulePage> {
  final _textEditingController = TextEditingController();
  final _passwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(S.of(context).appleIntelligenceAddRule),
        trailingActions: [
          PlatformIconButton(
            icon: Icon(AppPlatformIcons(context).check),
            onPressed: () {
              Navigator.pop(context, _textEditingController.text);
            },
          )
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Column(
                    children: [
                      PlatformTextFormField(
                          controller: _textEditingController,
                          hintText: S.of(context).appleIntelligencePromptInstruction,
                          maxLines: 5,
                          material: (context, platform) {
                            return MaterialTextFormFieldData(
                              decoration: InputDecoration(
                                labelText: S.of(context).appleIntelligencePromptInstruction,
                                hintText: S.of(context).appleIntelligencePromptInstruction,
                                prefixIcon: Icon(Icons.book),
                              ),
                            );
                          },
                          cupertino: (context, platform) {
                            return CupertinoTextFormFieldData(
                                prefix: Text(S.of(context).appleIntelligencePromptInstruction),
                                decoration: BoxDecoration());
                          },
                          validator: ValidationBuilder().required().build()),
                      if (isCupertino(context)) Divider(),
                      PlatformTextFormField(
                          autofillHints: [AutofillHints.password],
                          controller: _passwdController,
                          hintText: S.of(context).password,
                          material: (context, platform) {
                            return MaterialTextFormFieldData(
                              decoration: InputDecoration(
                                labelText: S.of(context).password,
                                prefixIcon: Icon(Icons.vpn_key),
                              ),
                            );
                          },
                          cupertino: (context, platform) {
                            return CupertinoTextFormFieldData(
                                prefix: Text(S.of(context).password),
                                decoration: BoxDecoration());
                          },
                          obscureText: true,
                          validator: ValidationBuilder().required().build()),
                    ],
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}
