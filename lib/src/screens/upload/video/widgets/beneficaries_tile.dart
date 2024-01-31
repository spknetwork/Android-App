import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/my_account/video_ops.dart';
import 'package:acela/src/screens/my_account/update_video/add_bene_sheet.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';

class BeneficiariesTile extends StatefulWidget {
  const BeneficiariesTile(
      {Key? key,
      required this.userName,
      required this.beneficiaries,
      required this.onChanged})
      : super(key: key);

  final String userName;
  final List<BeneficiariesJson> beneficiaries;
  final Function(List<BeneficiariesJson> beneficaries) onChanged;

  @override
  State<BeneficiariesTile> createState() => _BeneficiariesTileState();
}

class _BeneficiariesTileState extends State<BeneficiariesTile> {
  late List<BeneficiariesJson> beneficiaries;

  @override
  void initState() {
    beneficiaries = widget.beneficiaries;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        beneficiariesBottomSheet(context);
      },
      child: Row(
        children: [
          Text('Video Participants:'),
          Spacer(),
          Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  void beneficiariesBottomSheet(BuildContext context) {
    var filteredBenes = beneficiaries
        .where((element) =>
            element.src != 'ENCODER_PAY' &&
            element.src != 'mobile' &&
            element.src != 'threespeak')
        .toList();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Container(
            height: 400,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Video Participants'),
                actions: [
                  if (beneficiaries.length < 8)
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          showAlertForAddBene(beneficiaries);
                        },
                        icon: Icon(Icons.add))
                ],
              ),
              body: ListView.separated(
                itemBuilder: (c, i) {
                  return ListTile(
                    leading: CustomCircleAvatar(
                      height: 40,
                      width: 40,
                      url: server.userOwnerThumb(filteredBenes[i].account),
                    ),
                    title: Text(filteredBenes[i].account),
                    subtitle: Text(
                        '${filteredBenes[i].src} ( ${filteredBenes[i].weight} % )'),
                    trailing: (filteredBenes[i].src == 'participant')
                        ? IconButton(
                            onPressed: () {
                              var currentBenes = beneficiaries;
                              var author = currentBenes
                                  .where((e) => e.account == widget.userName)
                                  .firstOrNull;
                              if (author == null) return;
                              var otherBenes = currentBenes
                                  .where((e) =>
                                      e.src != 'author' &&
                                      e.account != filteredBenes[i].account)
                                  .toList();
                              author.weight =
                                  author.weight + filteredBenes[i].weight;
                              otherBenes.add(author);
                              setState(() {
                                beneficiaries = otherBenes;
                              });
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          )
                        : null,
                  );
                },
                separatorBuilder: (c, i) => const Divider(),
                itemCount: filteredBenes.length,
              ),
            ),
          ),
        );
      },
    );
  }

  void showAlertForAddBene(List<BeneficiariesJson> benes) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AddBeneSheet(
          benes: benes,
          onSave: (newBenes) {
            setState(() {
              beneficiaries = newBenes;
            });
            widget.onChanged(newBenes);
          },
        );
      },
    );
  }
}
