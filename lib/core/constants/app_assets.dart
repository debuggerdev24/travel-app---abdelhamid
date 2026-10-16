import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class AppAssets {
  AppAssets._();

  // icons
  static const _iconPath = "assets/icon";
  static const homeIcon = "$_iconPath/icon.svg";
  static const backIcon = "$_iconPath/backbutton.svg";
  static const appIcon = "$_iconPath/homeicon.svg";
  static const homeTab = "$_iconPath/hometab.svg";
  static const tripTab = "$_iconPath/triptab.svg";
  static const chatTab = "$_iconPath/chattab.svg";
  static const schedule = "$_iconPath/schedule.svg";
  static const pin = "$_iconPath/pin.svg";
  static const phone = "$_iconPath/phone.svg";
  static const star = "$_iconPath/star.svg";
  static const starFill = "$_iconPath/starfill.svg";
  static const dropdown = "$_iconPath/dropdown.svg";
  static const checkbox = "$_iconPath/checkbox.svg";
  static const checkFill = "$_iconPath/checkfill.svg";
  static const date = "$_iconPath/date.svg";
  static const check = "$_iconPath/check.svg";
  static const travel = "$_iconPath/travel.svg";
  static const calendar = "$_iconPath/calendar.svg";
  static const profileTab = "$_iconPath/usertab.svg";
  static const notification = "$_iconPath/notification.svg";
  static const google = "$_iconPath/google.svg";
  static const apple = "$_iconPath/apple.svg";
  static const cash = "$_iconPath/cash.svg";
  static const ideal = "$_iconPath/ideal.svg";
  static const creditcard = "$_iconPath/creditcard.svg";
  static const paypal = "$_iconPath/paypal.svg";
  static const essentials = "$_iconPath/essentials.svg";
  static const payment = "$_iconPath/payment.svg";
  static const flight = "$_iconPath/flight.svg";
  static const hotel = "$_iconPath/hotel.svg";
  static const map = "$_iconPath/map.svg";
  static const info = "$_iconPath/info.svg";
  static const itinerary = "$_iconPath/itinerary.svg";
  static const document = "$_iconPath/document.svg";
  static const essential = "$_iconPath/essential.svg";
  static const download = "$_iconPath/downlaod.svg";
  static const plane = "$_iconPath/plane.svg";
  static const truck = "$_iconPath/truck.svg";
  static const arrow = "$_iconPath/arrow.svg";
  static const alarm = "$_iconPath/alarm.svg";
  static const checkmark = "$_iconPath/checkmark.svg";
  static const location = "$_iconPath/location.svg";
  static const share = "$_iconPath/share.svg";
  static const landmark = "$_iconPath/landmark.svg";
  static const save = "$_iconPath/download.svg";
  static const call = "$_iconPath/call.svg";
  static const eye = "$_iconPath/eye.svg";
  static const play = "$_iconPath/play.svg";
  static const imagePicker = "$_iconPath/imagepicker.svg";
  static const addMore = "$_iconPath/addmore.svg";
  static const address = "$_iconPath/address.svg";
  static const wifi = "$_iconPath/wifi.svg";
  static const kitchen = "$_iconPath/kitchen.svg";
  static const breakfast = "$_iconPath/breakfast.svg";
  static const search = "$_iconPath/search.svg";
  static const exit = "$_iconPath/exit.svg";
  static const delete = "$_iconPath/delete.svg";
  static const send = "$_iconPath/send.svg";
  static const photo = "$_iconPath/photo.svg";
  static const camera = "$_iconPath/camera.svg";
  static const faq = "$_iconPath/faq.svg";
  static const facebook = "$_imagePath/facebook.svg";
  static const whatsapp = "$_imagePath/whatsapp.svg";
  static const instagram = "$_imagePath/instagram.svg";
  static const tiktok = "$_imagePath/tiktok.svg";

  // images
  static const _imagePath = "assets/images";
  static const profilePhoto = "$_imagePath/profile.png";
  static const currency = "$_imagePath/currency.png";
  static const paymentFailed = "$_imagePath/paymentfailed.png";
  static const paymentSuccessful = "$_imagePath/paymentsuccessfull.png";
  static const hotel1 = "$_imagePath/hotel1.png";
  static const hotel2 = "$_imagePath/hotel2.png";
  static const hotel3 = "$_imagePath/hotel3.png";
  static const hotel4 = "$_imagePath/hotel4.png";
  static const upload = "$_imagePath/upload.png";
  static const hotelVoucher = "$_imagePath/hotelvoucher.png";
  static const travelInsurance = "$_imagePath/travelinsurance.png";
  static const splashLogo = "$_imagePath/splash_logo.png";
}

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.iconPath, {super.key, double size = 14, this.color})
    : width = size,
      height = size;
  final String iconPath;
  final double width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconPath,
      width: width,
      height: height,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
