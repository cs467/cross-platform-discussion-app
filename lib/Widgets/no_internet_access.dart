import 'package:flutter/material.dart';

class NoInternetAccess extends StatelessWidget {
  const NoInternetAccess({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NoInternetIcon(),
            NoInternetText(
              text: "No Internet", 
              size: 28, 
              weight: FontWeight.bold,
            ),
            Container(
              height: 20,
            ),
            NoInternetText(
              text: "Your device is not connected to the internet.", 
              size: 20, 
              weight: FontWeight.normal,
            ),
            Container(
              height: 10,
            ),
            NoInternetText(
              text: "Check your WiFi or mobile data connection.", 
              size: 20, 
              weight: FontWeight.normal,
            ),
          ],
        ),
      ),
    );
  }
}

class NoInternetText extends StatelessWidget {
  const NoInternetText({Key key, this.text, this.size, this.weight})
   : super(key: key);
  final String text;
  final double size;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: weight,
        ),
      ),
    );
  }
}

class NoInternetIcon extends StatelessWidget {
  const NoInternetIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Icon(
        Icons.cloud_off,
        color: Colors.black,
        size: 108.0,
      ),
    );
  }
}