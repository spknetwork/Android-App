import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/screens/communities_screen/communities_screen.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';

class CommunityPicker extends StatefulWidget {
  const CommunityPicker(
      {Key? key,
      required this.communityName,
      required this.communityId,
      required this.onChanged})
      : super(key: key);

  final String communityName;
  final String communityId;
  final Function(String, String) onChanged;

  @override
  State<CommunityPicker> createState() => _CommunityPickerState();
}

class _CommunityPickerState extends State<CommunityPicker> {
  late  String selectedCommunityName;
  late  String selectedCommunityId;

  @override
  void initState() {
    selectedCommunityId = widget.communityId;
    selectedCommunityName = widget.communityName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (c) => CommunitiesScreen(
              withoutScaffold: false,
              didSelectCommunity: (name, id) {
                setState(() {
                  selectedCommunityName = name;
                  selectedCommunityId = id;
                });
                widget.onChanged(name, id);
              },
            ),
          ),
        );
      },
      child: Row(
        children: [
          const Text('Select Community:'),
          Spacer(),
          Text(selectedCommunityName),
          SizedBox(width: 10),
          CustomCircleAvatar(
            width: 44,
            height: 44,
            url: server.communityIcon(selectedCommunityId),
          ),
        ],
      ),
    );
  }
}
