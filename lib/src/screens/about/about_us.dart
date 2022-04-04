import 'package:flutter/material.dart';

class AboutUsElement {
  String title;
  String subtitle;

  AboutUsElement({required this.title, required this.subtitle});
}

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);
  static List<AboutUsElement> elements = [
    AboutUsElement(
        title: "3SPEAK, PROTECT YOUR CONTENT, TOKENISE YOUR COMMUNITY",
        subtitle:
            "3Speak is a place where content creators directly own their onsite assets and their communities. Using blockchain technology, the ownership of these assets and communities are intrinsic to the creator and the user, not 3 Speak. They are therefore transferable to other apps that use blockchain technology. This means that if we do not serve the community and creators in the best possible way, they can take the assets they have generated and move them to another app. The result is that 3Speak is censorship resistant, cannot take your assets away or delete your communities."),
    AboutUsElement(
        title: "REWARDS",
        subtitle:
            "By using the platform, users get rewarded in Hive tokens and can receive donations in our proprietary Speak token. The more of these tokens you hold, the more privileges you have in the eco system. Additionally, the more tokens you hold, the more say you have over the governance of the platform and where it goes in future."),
    AboutUsElement(
        title: "P2P",
        subtitle:
            "The blockchain technology that the site uses ensures that content creators have true P2P connections to their user base, without any middle parties."),
    AboutUsElement(
        title: "TOKENISATION",
        subtitle:
            "Content creators can also easily create their own tokens, market places, stake driven rewards and economies to back their communities"),
    AboutUsElement(
        title: "FREE SPEECH",
        subtitle:
            "Our policy is that the ability to be offensive is the bedrock of Freedom of Speech, and in turn Freedom of Speech protects societies from descending into chaos and civil war. Everyone has the right to their opinions, no matter how offensive some other people may find it (as long as it's not inciting violence or illegal of course). We especially welcome those talking about cryptocurrency and other emerging technologies which are threats to the establishment. Many of these content creators are being silenced because rich and powerful organisations do not want to be challenged. But we believe in Freedom of choice too!"),
    AboutUsElement(
        title: "CITIZEN JOURNALISM",
        subtitle:
            "We also encourage citizen journalists to join us too, and post the kind of content which is often ignored. We believe that citizen journalists are the future, and we invite them to come and join our Citizen Journalist Tag and Community"),
    AboutUsElement(
        title: "George Orwell",
        subtitle:
            "If liberty means anything at all, it means the right to tell people what they do not want to hear."),
    AboutUsElement(
        title: "Voltaire",
        subtitle:
            "I disapprove of what you say, but I will defend to the death your right to say it."),
    AboutUsElement(
        title: "Philip Sharp",
        subtitle:
            "The right to free speech and the unrealistic expectation to never be offended can not coexist."),
    AboutUsElement(
        title: "Marshall Lumsden",
        subtitle:
            "At no time is freedom of speech more precious than when a man hits his thumb with a hammer."),
    AboutUsElement(
        title: "Alan Dershowitz",
        subtitle:
            "Freedom of speech means freedom for those who you despise, and freedom to express the most despicable views. It also means that the government cannot pick and choose which expressions to authorize and which to prevent."),
    AboutUsElement(
        title: "Anna Quindlen",
        subtitle:
            "Ignorant free speech often works against the speaker. That is one of several reasons why it must be given rein instead of suppressed."),
    AboutUsElement(
        title: "Brad Thor",
        subtitle: "Freedom of speech includes the freedom to offend people."),
    AboutUsElement(
        title: "Newton Lee",
        subtitle:
            "There is a fine line between free speech and hate speech. Free speech encourages debate whereas hate speech incites violence."),
    AboutUsElement(
        title: "Hugo L. Black",
        subtitle:
            "Freedom of speech means that you shall not do something to people either for the views they have, or the views they express, or the words they speak or write."),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABOUT 3SPEAK'),
      ),
      body: ListView.separated(
          itemBuilder: (c, i) {
            return ListTile(
              title: Text(elements[i].title),
              subtitle: Text(elements[i].subtitle),
            );
          },
          separatorBuilder: (c, i) => const Divider(),
          itemCount: elements.length),
    );
  }
}
