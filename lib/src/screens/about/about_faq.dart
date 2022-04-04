import 'package:acela/src/screens/about/about_us.dart';
import 'package:flutter/material.dart';

class AboutFaqScreen extends StatelessWidget {
  const AboutFaqScreen({Key? key}) : super(key: key);
  static List<AboutUsElement> elements = [
    AboutUsElement(
        title: "What is 3Speak?",
        subtitle:
            "3Speak is a place where content creators directly own their onsite assets and their communities. Using blockchain technology, the ownership of these assets and communities are intrinsic to the creator and the user, not 3 Speak. They are therefore transferable to other apps that use blockchain technology. This means that if we do not serve the community and creators in the best possible way, they can take the assets they have generated and move them to another app. The result is that 3Speak is censorship resistant, cannot take your assets away or delete your communities.\n\nOur policy is that the ability to be offensive is the bedrock of Freedom of Speech, and in turn Freedom of Speech protects societies from descending into chaos and civil war. Everyone has the right to their opinions, no matter how offensive some other people may find it (as long as it's not inciting violence or illegal of course). We especially welcome those talking about cryptocurrency and other emerging technologies which are threats to the establishment. Many of these content creators are being silenced because rich and powerful organisations do not want to be challenged. But we believe in Freedom of choice too!"),
    AboutUsElement(
        title: "Why am I not upvoted by 3Speak?",
        subtitle:
            "3Speak will vote at our own discretion and do not follow any specific criteria. The best way to attract our attention is to upload high-quality content and draw audiences and communities to 3speak."),
    AboutUsElement(
        title: "Why are some of my videos missing from the new feed?",
        subtitle:
            "We allow you to upload as many videos as you want! This means that sometimes one user could fill up feeds with just their content, to combat this, we limit the videos by any one creator that can be displayed per load."),
    AboutUsElement(
        title: "What are the guidelines?",
        subtitle:
            "We believe Freedom of Speech is absolute. As outlined above, there are some instances where we would have to restrict content, but for clarity here are 3speak's policies on various subjects:\n\nWe fully support your right to be offensive as long as it does not violate any of our terms (see below).\n\nCRITICISING RELIGION, BELIEFS, GROUPS, PEOPLE:\n\nSWEARING AND PROFANITY:  (slander not allowed)\n\nOFFENSIVE JOKES:  (If you are making a joke which could be construed as something illegal or slanderous, it might be a good idea to make it clear. As long as you aren't calling for people to be killed or harmed in any way.)\n\nALTERNATIVE POLITICS / CONSPIRACIES / CRITICIZING GOVERNMENTS & WORLD LEADERS:\n\nPSEUDONYMS: \n\nCALLING FOR OR INCITEMENT TO VIOLENCE: \n\nSHOWING OF EXCESSIVE GORE OR PORN:"),
    AboutUsElement(
        title: "How do I become a content creator?",
        subtitle:
            "The quickest way to get a hive account is to press the \"Sign up\" button in the navigation panel and follow the instructions. (dont loose your keys!).\nNext you will need to log in with your hive account and click on the \"creator studio\" / upload.\nYou're all set up and ready to go!"),
    AboutUsElement(
        title: "How do I earn rewards for commenting?",
        subtitle:
            "In order to earn rewards, you need a Hive blockchain account. There are a few ways to get a Hive account:\n\n1. Get one for free from Hive (https://signup.hive.io). This can take some time to get approved however.\n2. Purchase a Hive user guide, which comes with a free, instant Hive account here. However, with value adding, useful or articulate commenting you should be able to earn this back in a few days, or after uploading a couple of videos.\n3. Get another Hive user who can claim accounts to give one to you\n\nOnce you have an account, you need to login with Hivesigner. You will need to provide your ACTIVE key ONLY on the first login. Then you can post comments which can earn.\n\nIf you want to comment without earning cryptocurrency rewards, you can simply login with email or via your facebook, google, twitter or instagram accounts."),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FREQUENTLY ASKED QUESTIONS'),
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
