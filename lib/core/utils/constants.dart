import 'package:flutter/material.dart';

class APIPath {
  static const getBooks = "https://raw.githubusercontent.com/mamasodikov/books_fake/master/audio_books.json";
}

class DbTexts {
  static const String bookTable = "books";
  static const String audioFilesTable = "audiofiles";

  static const String columnId = "identifier";
  static const String columnTitle = "title";
}


///These are app-specific colors
const cFirstColor = Color(0xFF3A40D3);
const cFirstColorDark = Color(0xFF0E1150);
const cSecondColor = Color(0xFF656DFF);
const cThirdColor = Color(0xFF8E54E9);
const cFourthColor = Color(0xFFF8F9FD);

///Dark
const cFourthColorDark = Color(0xFF101322);
const cPrimaryTextDark = Color(0xFFA3A9C8);
const cCardDarkColor = Color(0xFF313551);

///Library themes
const cVioletishColor = Color(0xffe4e4ff);
const cBluishColor = Color(0xffE2E5EA);
const cPinkishColor = Color(0xffffdedb);

///These are classic colors
const cTextColor = Color(0xFF475E6A);
const cBlackColor = Color(0xFF000000);
const cWhiteColor = Color(0xFFFFFFFF);
const cRedColor = Color(0xFFFF3030);
const cBlueColor = Color(0xFF0088cc);
const cPurpleColor = Color(0xFFB000AB);
const cGrayColor0 = Color(0xFFE1E2E5);
const cGrayColor1 = Color(0xFF949494);
const cGrayColor2 = Color(0xFF4F4F4F);
const cGrayColor3 = Color(0xFF333333);
const cYellowColor = Color(0xFFFFC92F);
const cDarkYellowColor = Color(0xFFFAB93A);
const cOrangeColor = Color(0xFFFF9800);
const cFirstTextColor = Color(0xFF080936);
const cSecondTextColor = Color(0xFF080936);
const cLightBlue = Color(0xFF4C4DDC);
const cPinkLight = Color(0xFFFFEAEA);
const cRedTextColor = Color(0xFFF44747);
const cGreenColor = Color(0xFF13BB42);
const cCarrotColor = Color(0xFFFC6666);
const cIbratColor = Color(0xFFFF8500);
const cMintColor = Color(0xFF019875);

// All gradient
const cFirstGradient = LinearGradient(
  colors: [cSecondColor, cFirstColor],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const cSecondGradient = LinearGradient(
  colors: [cSecondColor, cThirdColor],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

var boxShadow5 = BoxShadow(
  color: cFirstColor.withOpacity(0.09),
  spreadRadius: 1,
  blurRadius: 5,
);

var boxShadow10 = BoxShadow(
  color: cFirstColor.withOpacity(0.09),
  spreadRadius: 1,
  blurRadius: 5,
  offset: Offset(0, 10), // changes position of shadow
);

var boxShadow20 = BoxShadow(
  color: cFirstColor.withOpacity(0.09),
  spreadRadius: 1,
  blurRadius: 20,
  offset: Offset(0, 10), // changes position of shadow
);

var boxShadow60 = BoxShadow(
  color: cFirstColor.withOpacity(0.2),
  spreadRadius: 1,
  blurRadius: 60,
  offset: Offset(0, 10), // changes position of shadow
);

var boxShadowPlay = BoxShadow(
  color: cFirstColor.withOpacity(0.2),
  spreadRadius: 1,
  blurRadius: 20,
  offset: Offset(0, 5), // changes position of shadow
);

var boxShadowStop = BoxShadow(
  color: cRedColor.withOpacity(0.2),
  spreadRadius: 1,
  blurRadius: 20,
  offset: Offset(0, 5), // changes position of shadow
);

const loremIpsumText =
    'Lorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia,'
    'molestiae quas vel sint commodi repudiandae consequuntur voluptatum laborum'
    'numquam blanditiis harum quisquam eius sed odit fugiat iusto fuga praesentium'
    'optio, eaque rerum! Provident similique accusantium nemo autem. Veritatis'
    'obcaecati tenetur iure eius earum ut molestias architecto voluptate aliquam'
    'nihil, eveniet aliquid culpa officia aut! Impedit sit sunt quaerat, odit,'
    'tenetur error, harum nesciunt ipsum debitis quas aliquid. Reprehenderit,'
    'quia. Quo neque error repudiandae fuga? Ipsa laudantium molestias eos'
    'sapiente officiis modi at sunt excepturi expedita sint? Sed quibusdam'
    'recusandae alias error harum maxime adipisci amet laborum. Perspiciatis'
    'minima nesciunt dolorem! Officiis iure rerum voluptates a cumque velit'
    'quibusdam sed amet tempora. Sit laborum ab, eius fugit doloribus tenetur'
    'fugiat, temporibus enim commodi iusto libero magni deleniti quod quam'
    'consequuntur! Commodi minima excepturi repudiandae velit hic maxime'
    'doloremque. Quaerat provident commodi consectetur veniam similique ad'
    'earum omnis ipsum saepe, voluptas, hic voluptates pariatur est explicabo'
    'fugiat, dolorum eligendi quam cupiditate excepturi mollitia maiores labore'
    'suscipit quas? Nulla, placeat. Voluptatem quaerat non architecto ab laudantium'
    'modi minima sunt esse temporibus sint culpa, recusandae aliquam numquam'
    'totam ratione voluptas quod exercitationem fuga. Possimus quis earum veniam'
    'quasi aliquam eligendi, placeat qui corporis!';

