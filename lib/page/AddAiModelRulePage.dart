import 'package:discuz_flutter/entity/AiRule.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

import '../dao/AiRuleDao.dart';
import '../database/AppDatabase.dart';
import '../generated/l10n.dart';
import '../utility/AppPlatformIcons.dart';

class AddAiModelRulePage extends StatefulWidget {
  AiRule? aiRule;

  AddAiModelRulePage(this.aiRule);

  @override
  _AddAiModelRulePageState createState() => _AddAiModelRulePageState(aiRule);
}

class _AddAiModelRulePageState extends State<AddAiModelRulePage> {
  AiRule? aiRule;

  _AddAiModelRulePageState(this.aiRule);

  final _nameTextEditingController = TextEditingController();
  final _instructionTextEditingController = TextEditingController();
  final _promptTextEditingController = TextEditingController();
  String? nameTextEditingErrorString = null;
  String? instructionTextEditingErrorString = null;
  String title = "";

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(aiRule == null
            ? S.of(context).appleIntelligenceAddRule
            : S
                .of(context)
                .appleIntelligenceModifyRuleTitleTemplate(aiRule!.name)),
        trailingActions: [
          if (!(aiRule?.isExample == true))
            PlatformIconButton(
              liquidGlassSymbol: 'checkmark',
              icon: Icon(
                AppPlatformIcons(context).check,
                semanticLabel: aiRule == null
                    ? S.of(context).appleIntelligenceAddRule
                    : S.of(context).appleIntelligenceModifyRuleTitleTemplate(
                          aiRule!.name,
                        ),
              ),
              onPressed: () {
                saveOrModifyRule();
              },
            )
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (aiRule?.isExample == true)
              PlatformLiquidGlassCard(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                tintColor: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(22),
                child: Text(
                  S.of(context).appleIntelligenceRuleTranslationExampleNotice,
                ),
              ),
            PlatformLiquidGlassCard(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).appleIntelligenceRuleName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  PlatformTextField(
                    enabled: !(aiRule?.isExample == true),
                    controller: _nameTextEditingController,
                  ),
                  if (nameTextEditingErrorString != null)
                    Text(
                      nameTextEditingErrorString!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            PlatformLiquidGlassCard(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).appleIntelligencePromptInstruction,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  PlatformTextField(
                    enabled: !(aiRule?.isExample == true),
                    controller: _instructionTextEditingController,
                    maxLines: null,
                    minLines: 4,
                    hintText: S.of(context).appleIntelligencePromptInstruction,
                  ),
                  if (instructionTextEditingErrorString != null)
                    Text(
                      instructionTextEditingErrorString!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            PlatformLiquidGlassCard(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).appleIntelligencePromptHint,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  PlatformTextField(
                    enabled: !(aiRule?.isExample == true),
                    controller: _promptTextEditingController,
                    maxLines: null,
                    minLines: 3,
                    hintText: S.of(context).appleIntelligencePromptHint,
                  )
                ],
              ),
            ),
            if (aiRule != null && !(aiRule?.isExample == true))
              Padding(
                padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: PlatformElevatedButton(
                    color: Theme.of(context).colorScheme.error,
                    child: Text(
                      S.of(context).deleteAccount,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onError),
                    ),
                    onPressed: () {
                      VibrationUtils.vibrateWithClickIfPossible();
                      deleteRule();
                    },
                  ),
                ),
              ),
          ],
        ),
      )),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAiRuleLayout();
  }

  void initAiRuleLayout() {
    if (aiRule != null) {
      _nameTextEditingController.text = aiRule!.name;
      _promptTextEditingController.text = aiRule!.prompt;
      _instructionTextEditingController.text = aiRule!.instruction;
    } else {}
  }

  Future<void> saveOrModifyRule() async {
    // check the empty first
    String name = _nameTextEditingController.text;
    String instruction = _instructionTextEditingController.text;
    String prompt = _promptTextEditingController.text;

    setState(() {
      if (name.isEmpty) {
        nameTextEditingErrorString = S.of(context).textFieldShouldNotBeEmpty;
      } else {
        nameTextEditingErrorString = null;
      }
      if (instruction.isEmpty) {
        instructionTextEditingErrorString =
            S.of(context).textFieldShouldNotBeEmpty;
      } else {
        instructionTextEditingErrorString = null;
      }
    });

    if (name.isNotEmpty && instruction.isNotEmpty) {
      AiRuleDao aiRuleDao = await AppDatabase.getAiRuleDao();

      AiRule savedAiRule = AiRule(name, instruction, prompt, DateTime.now());

      if (aiRule == null) {
        // it's a new rule
        aiRuleDao.insertAiRule(savedAiRule);
      } else {
        aiRuleDao.putAiRule(aiRule!.key, savedAiRule);
      }
      Navigator.of(context).pop();
    } else {
      // highlight the controller
    }
  }

  Future<void> deleteRule() async {
    if (aiRule != null) {
      showPlatformAlert(
        context: context,
        title: S
            .of(context)
            .appleIntelligenceDeleteRuleTitleTemplate(aiRule!.name),
        message: S
            .of(context)
            .appleIntelligenceDeleteRuleContentemplate(aiRule!.name),
        actions: [
          PlatformAlertAction(
            label: S.of(context).deleteAccount,
            isDestructiveAction: true,
            onPressed: () async {
              VibrationUtils.vibrateWithClickIfPossible();
              AiRuleDao aiRuleDao = await AppDatabase.getAiRuleDao();
              aiRuleDao.deleteAiRule(aiRule!);
              Navigator.pop(context);
            },
          ),
          PlatformAlertAction(
            label: S.of(context).cancel,
            isCancelAction: true,
          ),
        ],
      );
    }
  }
}
